# Archivista

![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

Helm chart for Archivista - a graph and storage service for in-toto attestations.

## Prerequisites

A MySQL database and S3 compatible store are needed to successfully install this Helm chart.
Refer to the [Archivista configuration](https://github.com/in-toto/archivista#configuration) configuration guide for environment variables needed
to establish connections to each datastore. These environment variables can be added to this Helm chart using the value `deployment.env[]`.

Non-sensitive connection settings (backend type, endpoint, bucket name, TLS flag) are already set via
`deployment.env[]` in this pack's `values.yaml`. Sensitive credentials are not stored in `values.yaml` and must
be supplied through a Kubernetes Secret named **`archivista-credentials`**, created in the target namespace
before installing this chart, referenced via `deployment.envFrom[]`. It must contain the following keys:

- `ARCHIVISTA_SQL_STORE_CONNECTION_STRING` — MySQL connection string (e.g. `user:pass@tcp(host:3306)/dbname`)
- `ARCHIVISTA_BLOB_STORE_ACCESS_KEY_ID` — S3/MinIO access key
- `ARCHIVISTA_BLOB_STORE_SECRET_ACCESS_KEY_ID` — S3/MinIO secret key

Also confirm that `deployment.env[].ARCHIVISTA_BLOB_STORE_ENDPOINT` (default `archivista-minio:9000`) points to
a reachable S3-compatible service in your target environment before deploying.

### MySQL connection string caveat (Archivista v0.11.1)

Archivista's own entrypoint (`entrypoint.sh`) applies database migrations via Atlas before starting the
server, and the two steps parse `ARCHIVISTA_SQL_STORE_CONNECTION_STRING` differently:

- **Migrations (Atlas)** require a plain `user:pass@host:port/dbname` value — an explicit `tcp(host:port)`
  wrapper causes Atlas to fail with `invalid port ":<port>)" after host`.
- **Runtime** (the `archivista` binary itself, via `go-sql-driver/mysql`) requires the `tcp(host:port)`
  wrapper explicitly — without it, it fails with `default addr for network '<host:port>' unknown`.

No single connection string satisfies both. The workaround used in this pack's `values.yaml`
(`deployment.command: ["/bin/archivista"]`) skips `entrypoint.sh` (and therefore its migration step)
and launches the server directly, using the `tcp(host:port)` format the runtime requires. This means
schema migrations must be applied out-of-band once, before relying on this override:

1. Temporarily remove/empty `deployment.command`, and set `ARCHIVISTA_SQL_STORE_CONNECTION_STRING` in the
   `archivista-credentials` Secret to the plain form (no `tcp(...)`), e.g.
   `user:pass@archivista-mysql:3306/archivista`. Deploy/restart — `entrypoint.sh` will run migrations
   (look for `No migration files to execute` or successful `atlas migrate apply` output in the pod logs).
2. Switch `ARCHIVISTA_SQL_STORE_CONNECTION_STRING` to the `tcp(...)`-wrapped form, e.g.
   `user:pass@tcp(archivista-mysql:3306)/archivista`, restore `deployment.command: ["/bin/archivista"]`,
   and restart. The pod should reach `1/1 Running` with a `startup complete` log line.

Repeat step 1 (temporarily) whenever a future Archivista upgrade ships new migrations.

### Fresh cluster deployment runbook

This walks through everything needed to go from "cluster profile stuck in `AddOnDeploying`" to a
healthy pod, for a cluster that has never run this pack before (e.g. rebuilding the test cluster,
or standing up a new one). It combines the two prerequisites above (external MySQL/S3, and the
migration caveat) into one ordered checklist.

**0. Confirm this is actually the blocker.** If the addon is stuck deploying, check the pod first:

```
kubectl get pods -n archivista
kubectl get events -n archivista --sort-by=.lastTimestamp
```

- `CreateContainerConfigError` + `secret "archivista-credentials" not found` → go to step 2 (no Secret yet).
- `CrashLoopBackOff` with nothing else in the namespace besides `archivista-archivista` → go to step 1
  (no MySQL/MinIO in this cluster yet).
- `CrashLoopBackOff` with MySQL/MinIO already `Running` → go straight to step 3 (migration caveat).

**1. Stand up MySQL + MinIO, if this cluster doesn't already have them.** This chart does not deploy
its own database or object store (by design — production users typically point it at RDS/S3 or
similarly managed services instead). For a throwaway dev/test dependency stack, save the manifest
below (e.g. as `dev-dependencies.yaml`, anywhere outside this pack's own directory) and apply it:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: archivista-mysql
  namespace: archivista
  labels:
    app: archivista-mysql
spec:
  replicas: 1
  selector:
    matchLabels:
      app: archivista-mysql
  template:
    metadata:
      labels:
        app: archivista-mysql
    spec:
      containers:
        - name: mysql
          image: mysql:8.0
          env:
            - name: MYSQL_ROOT_PASSWORD
              value: "rootpass"
            - name: MYSQL_DATABASE
              value: "archivista"
            - name: MYSQL_USER
              value: "archivista"
            - name: MYSQL_PASSWORD
              value: "archivistapass"
          ports:
            - containerPort: 3306
          readinessProbe:
            exec:
              command: ["mysqladmin", "ping", "-h", "127.0.0.1", "-u", "root", "-prootpass"]
            initialDelaySeconds: 10
            periodSeconds: 5
          # runAsNonRoot/capabilities.drop are deliberately NOT set here: the official mysql:8.0
          # image needs to start as root WITH CAP_SETUID/CAP_SETGID/CAP_CHOWN to init its data
          # directory and then de-escalate internally via gosu (no persistent volume here, so
          # this runs on every restart). Tested: dropping ALL capabilities breaks it with
          # "setgid: Operation not permitted" even though the process is still root.
          securityContext:
            allowPrivilegeEscalation: false
            seccompProfile:
              type: RuntimeDefault
          resources:
            requests:
              cpu: 100m
              memory: 256Mi
            limits:
              cpu: 500m
              memory: 512Mi
---
apiVersion: v1
kind: Service
metadata:
  name: archivista-mysql
  namespace: archivista
spec:
  selector:
    app: archivista-mysql
  ports:
    - port: 3306
      targetPort: 3306
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: archivista-minio
  namespace: archivista
  labels:
    app: archivista-minio
spec:
  replicas: 1
  selector:
    matchLabels:
      app: archivista-minio
  template:
    metadata:
      labels:
        app: archivista-minio
    spec:
      containers:
        - name: minio
          image: minio/minio:latest
          args: ["server", "/data", "--console-address", ":9001"]
          env:
            - name: MINIO_ROOT_USER
              value: "testifytestifytestify"
            - name: MINIO_ROOT_PASSWORD
              value: "exampleexampleexample"
          ports:
            - containerPort: 9000
            - containerPort: 9001
          readinessProbe:
            tcpSocket:
              port: 9000
            initialDelaySeconds: 5
            periodSeconds: 5
          # runAsNonRoot/runAsUser are deliberately NOT set here: this image's /data (no
          # persistent volume, so it's the container's own filesystem layer) is not owned by
          # an arbitrary non-root UID. Tested: forcing runAsUser:1000 breaks it with
          # "unable to create /data/.minio.sys/tmp: file access denied".
          securityContext:
            allowPrivilegeEscalation: false
            capabilities:
              drop:
                - ALL
            seccompProfile:
              type: RuntimeDefault
          resources:
            requests:
              cpu: 100m
              memory: 128Mi
            limits:
              cpu: 500m
              memory: 256Mi
---
apiVersion: v1
kind: Service
metadata:
  name: archivista-minio
  namespace: archivista
spec:
  selector:
    app: archivista-minio
  ports:
    - name: api
      port: 9000
      targetPort: 9000
    - name: console
      port: 9001
      targetPort: 9001
---
apiVersion: batch/v1
kind: Job
metadata:
  name: archivista-minio-create-bucket
  namespace: archivista
spec:
  template:
    spec:
      restartPolicy: OnFailure
      containers:
        - name: mc
          image: minio/mc:latest
          command:
            - /bin/sh
            - -c
            - |
              until mc alias set archivista http://archivista-minio:9000 testifytestifytestify exampleexampleexample; do sleep 3; done
              mc mb --ignore-existing archivista/attestations
          # runAsNonRoot/runAsUser/capabilities.drop NOT set here: mc writes its config to
          # $HOME/.mc (defaults to /root/.mc) and needs CAP_DAC_OVERRIDE (part of "full root")
          # to do so in this image. Tested: dropping ALL capabilities breaks it with
          # "mkdir /root/.mc: permission denied" even while still running as root.
          securityContext:
            allowPrivilegeEscalation: false
            seccompProfile:
              type: RuntimeDefault
          resources:
            requests:
              cpu: 50m
              memory: 64Mi
            limits:
              cpu: 200m
              memory: 128Mi
---
# Deploy this Secret with the PLAIN (no tcp()) connection string FIRST, for the initial
# migration pass. Switch it to the tcp(...)-wrapped form afterwards (step 3 below), once
# migrations have been confirmed applied.
apiVersion: v1
kind: Secret
metadata:
  name: archivista-credentials
  namespace: archivista
type: Opaque
stringData:
  ARCHIVISTA_SQL_STORE_CONNECTION_STRING: "archivista:archivistapass@archivista-mysql:3306/archivista"
  ARCHIVISTA_BLOB_STORE_ACCESS_KEY_ID: "testifytestifytestify"
  ARCHIVISTA_BLOB_STORE_SECRET_ACCESS_KEY_ID: "exampleexampleexample"
```

```
kubectl apply -f dev-dependencies.yaml
```

This creates `archivista-mysql` (Service on port 3306), `archivista-minio` (Service on ports
9000/9001), a Job that creates the `attestations` bucket, and the `archivista-credentials` Secret
(pre-populated with the *plain*, no-`tcp()` connection string needed for step 3's first pass).
Wait for `archivista-mysql` and `archivista-minio` pods to reach `1/1 Running` and the bucket Job to
reach `Completed` before continuing.

If instead you're pointing at real infrastructure (RDS, managed S3, etc.), skip this manifest and
create the `archivista-credentials` Secret yourself per the **Prerequisites** section above.

**2. Create/confirm `archivista-credentials`.** If step 1's manifest wasn't used (real infra
instead), create it manually:

```
kubectl create secret generic archivista-credentials -n archivista \
  --from-literal=ARCHIVISTA_SQL_STORE_CONNECTION_STRING="user:pass@host:port/dbname" \
  --from-literal=ARCHIVISTA_BLOB_STORE_ACCESS_KEY_ID="..." \
  --from-literal=ARCHIVISTA_BLOB_STORE_SECRET_ACCESS_KEY_ID="..."
```

Note the connection string is deliberately in the **plain** form here (no `tcp(...)`) — that's what
step 3's first pass needs.

**3. Run the two-step migration dance** (see "MySQL connection string caveat" above for *why* this
is necessary):

```
# 3a. Let entrypoint.sh's Atlas migration run (remove the command override that skips it):
kubectl patch deployment archivista-archivista -n archivista --type json \
  -p '[{"op":"remove","path":"/spec/template/spec/containers/0/command"}]'

# Watch until the pod's logs show "No migration files to execute" (or a successful
# "atlas migrate apply") followed by the runtime FATAL about the connection string missing
# tcp(...) — that FATAL is expected and confirms migrations already succeeded.
kubectl logs -n archivista deployment/archivista-archivista

# 3b. Switch the connection string to the tcp(...)-wrapped form:
kubectl patch secret archivista-credentials -n archivista --type merge \
  -p '{"stringData":{"ARCHIVISTA_SQL_STORE_CONNECTION_STRING":"user:pass@tcp(host:port)/dbname"}}'

# If you used the dev-dependencies manifest from step 1 as-is (fixed dev credentials), this
# exact command is copy-paste ready — no need to recompute anything:
#   kubectl patch secret archivista-credentials -n archivista --type merge \
#     -p '{"stringData":{"ARCHIVISTA_SQL_STORE_CONNECTION_STRING":"archivista:archivistapass@tcp(archivista-mysql:3306)/archivista"}}'

# 3c. Restore the command override so future restarts skip entrypoint.sh's (broken) migration step:
kubectl patch deployment archivista-archivista -n archivista \
  -p '{"spec":{"template":{"spec":{"containers":[{"name":"archivista","command":["/bin/archivista"]}]}}}}'

kubectl get pods -n archivista -w
```

Success looks like `1/1 Running` with a `startup complete` line in the logs (no restarts). In
Palette, the addon profile should move from `AddOnDeploying` to healthy.

**On future Archivista upgrades:** if the new version ships schema changes, repeat step 3 (3a first,
to let the new migrations apply against the plain connection string, then 3b/3c to switch back).
If it doesn't ship schema changes, the existing `command: ["/bin/archivista"]` override can stay in
place across the upgrade.

## Parameters

| Key                                        | Type   | Default       |
|---                                         |---     |---            |
| affinity                                   | object | `{}`          |
| autoscaling.enabled                        | bool   | `false`       |
| autoscaling.maxReplicas                    | int    | `10`          |
| autoscaling.minReplicas                    | int    | `1`           |
| autoscaling.targetCPUUtilizationPercentage | int    | `80`          |
| deployment.command                         | list   | `[]`          |
| deployment.env                             | list   | `[]`          |
| deployment.envFrom                         | list   | `[]`          |
| fullnameOverride                           | string | `""`          |
| image.pullPolicy                           | string | `"IfNotPresent"` |
| image.repository                           | string | `"ghcr.io/in-toto/archivista"` |
| image.tag                                  | string | `"0.11.1"` (falls back to `.Chart.AppVersion` if empty) |
| ingress.annotations                        | object | `{}`          |
| ingress.className                          | string | `""`          |
| ingress.enabled                            | bool   | `true`        |
| ingress.hosts[0].host                      | string | `"archivista.localhost"` |
| ingress.hosts[0].path                      | string | `"/"`         |
| ingress.tls                                | list   | `[]`          |
| nameOverride                               | string | `""`          |
| nodeSelector                               | object | `{}`          |
| podAnnotations                             | object | `{}`          |
| podSecurityContext                         | object | `{}`          |
| replicaCount                               | int    | `1`           |
| resources                                  | object | `{}`          |
| securityContext                            | object | `{}`          |
| serviceAccount.annotations                 | object | `{}`          |
| serviceAccount.create                      | bool   | `false`       |
| serviceAccount.name                        | string | `""`          |
| service.port                               | int    | `8082`        |
| service.type                               | string | `"ClusterIP"` |
| tolerations                                | list   | `[]`          |

## Usage
You can find additional guidance in the [Archivista Github](https://github.com/in-toto/archivista/blob/main/README.md) README.

## References

- [Archivista Helm Chart](https://github.com/in-toto/archivista/chart)
- [Archivista](https://github.com/in-toto/archivista)
- [in-toto](https://in-toto.io/)