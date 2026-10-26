# OpenObserve 1.0.2 — Changes Over Upstream Helm Chart

This document lists all modifications made on top of the upstream OpenObserve Helm chart
([openobserve/openobserve-helm-charts](https://github.com/openobserve/openobserve-helm-charts))
for the Spectro Cloud pack release.

---

## 1. Helm Chart Template Patches (`charts/openobserve-1.0.2.tgz`)

The upstream chart tarball was modified in-place. The `.tgz.orig` file preserves the original
unmodified chart for reference.

### 1.1 PVC Retention Policy — 4 StatefulSets

**Files changed:**
- `templates/alertquerier-statefulset.yaml`
- `templates/querier-statefulset.yaml`
- `templates/ingester-statefulset.yaml`
- `templates/scheduler-statefulset.yaml`

**Change:** Added `persistentVolumeClaimRetentionPolicy` to each StatefulSet spec, guarded by
the component's `persistence.enabled` value:

```yaml
{{- if .Values.<component>.persistence.enabled }}
persistentVolumeClaimRetentionPolicy:
  whenDeleted: Retain
  whenScaled: Retain
{{- end }}
```

**Purpose:** Prevents PVCs from being automatically deleted when the StatefulSet is deleted or
scaled down. Without this, a `helm uninstall` or a scale-in operation would permanently destroy
persisted data. Setting both policies to `Retain` ensures data survives accidental removals and
can be reattached on reinstall.

---

### 1.2 Autoscaling Guard for Local Mode — Ingester Only

**File changed:** `templates/ingester-statefulset.yaml`

**Change:**

```diff
- {{- if .Values.autoscaling.ingester.enabled }}
+ {{- if and .Values.autoscaling.ingester.enabled (ne .Values.config.ZO_LOCAL_MODE "true") }}
```

**Purpose:** Suppresses HPA creation for the ingester when OpenObserve runs in single-node local
mode (`ZO_LOCAL_MODE=true`). In local mode all components run as a single combined process, so
scaling the ingester independently via HPA is meaningless and could cause reconciliation
conflicts with the StatefulSet controller.

---

## 2. Pack-Level `values.yaml`

**File:** `values.yaml`

**Change:** All container image references replaced with mirrors hosted in Spectro Cloud's private
registry (`us-docker.pkg.dev/palette-images/packs/openobserve/1.0.2/`).

| Component | Upstream Image | Spectro Mirror |
|---|---|---|
| OpenObserve | openobserve/openobserve:v1.0.1 | .../openobserve:v1.0.1 |
| OpenObserve Enterprise | openobserve/openobserve-enterprise:v1.0.1 | .../openobserve-enterprise:v1.0.1 |
| Report Server | openobserve/report-server:v0.11.4 | .../report-server:v0.11.4 |
| NATS | nats:2.14.2-alpine | .../nats:2.14.2-alpine |
| MinIO | minio/minio:RELEASE.2023-02-10T18-48-39Z | .../minio:RELEASE.2023-02-10T18-48-39Z |
| PostgreSQL | bitnami/postgresql:18.3 | .../postgresql:18.3 |
| Dex | dexidp/dex:v2.37.0 | .../dex:v2.37.0 |
| OpenFGA | openfga/openfga:v1.14.2 | .../openfga:v1.14.2 |
| O2 AI | openobserve/o2-ai:v1.0.1 | .../o2-ai:v1.0.1 |

**Purpose:** Enables airgap / disconnected cluster deployments where nodes cannot reach public
container registries. All images are pulled from Spectro's controlled registry which is
accessible in air-gapped environments.

---

## 3. Pre-built Monitoring Dashboards (`manifests/`)

Six Kubernetes ConfigMap manifests are shipped alongside the Helm chart. Each ConfigMap contains
a pre-configured OpenObserve dashboard JSON payload.

| File | Dashboard Name | Metrics Covered |
|---|---|---|
| `cluster-level.yaml` | Cluster Level | Node CPU and memory utilization |
| `namespace-level.yaml` | Namespace Level | CPU, memory, and PVC usage per namespace |
| `pod-level.yaml` | Pod Level | Per-pod CPU and memory with `$k8s_namespace_name` / `$k8s_pod_name` variables |
| `objects.yaml` | Kubernetes Objects | Deployment, StatefulSet, DaemonSet, CronJob, and Event counts |
| `pods.yaml` | Pods | Network I/O, CPU, and memory per pod |
| `spectro-clusters.yaml` | Spectro Clusters | Cluster health status, pod counts, and `cluster_name` metrics specific to Spectro-managed clusters |

**Purpose:** Delivers a ready-to-use observability baseline for Kubernetes workloads without any
manual dashboard configuration. The dashboards target common Day-2 operational views for cluster
operators and are pre-wired to the metric streams that OpenObserve collects from the cluster.

---

## 4. Automatic Dashboard Import Job (`manifests/dashboard-import-job.yaml`)

**Change:** A Kubernetes `Job` manifest added as a Helm post-install and post-upgrade hook.

**What it does:**
- Runs a `curl`-based container after chart installation or upgrade
- Calls the OpenObserve REST API to upsert all 6 dashboards from the ConfigMaps above
- Handles deduplication — existing dashboards with the same name are updated, not duplicated
- Reads OpenObserve credentials from environment variables (sourced from the chart's Secret)

**Purpose:** Fully automates dashboard provisioning. Without this job, an operator would need to
manually import each dashboard JSON through the OpenObserve UI after every install or upgrade.

---

## 5. Pack Descriptor (`pack.json`)

**Change:** Spectro Cloud pack metadata added to integrate OpenObserve into the Palette content
lifecycle.

| Field | Value |
|---|---|
| Pack name | openobserve |
| Version | 1.0.2 |
| Layer | addon |
| Addon type | monitoring |
| Cloud types | vsphere, maas, edge-native |
| Architecture | amd64, arm64 |
| Airgap | enabled |
| Required dependency | PostgreSQL >= 1.29.0 |
| Optional dependency | Kubernetes >= 1.29 |

**Purpose:** Registers the pack in Palette's content catalog, declares its dependency on the
PostgreSQL pack for metadata storage, marks it as airgap-capable, and restricts it to validated
cloud types.

---

## 6. Documentation (`README.md`)

**Change:** Spectro-specific README added covering:
- Prerequisites (Palette account, supported cloud types, PostgreSQL pack, network requirements)
- Configuration parameter reference table with defaults
- Cluster launch and UI access instructions
- Upgrade path including PostgreSQL version upgrade steps
- Airgap mode setup instructions

**Purpose:** Provides operators with Spectro-specific deployment guidance that is not present in
the upstream chart documentation.
