# StormForge Agent

## Purpose

The StormForge Agent continuously observes workload behaviour across your Kubernetes
cluster and applies ML-driven resource recommendations (CPU/memory requests and limits)
to reduce waste and improve reliability.  It consists of two components:

| Component | Role |
|-----------|------|
| **workload-agent** | Watches workloads, fetches recommendations from the StormForge API, and applies patches |
| **metrics-forwarder** | Lightweight Prometheus agent that scrapes cAdvisor & kube-state-metrics and remote-writes to StormForge |

---

## Prerequisites

| Requirement | Details |
|-------------|---------|
| Kubernetes | ≥ 1.29 |
| Helm | ≥ 3.8 (OCI support required) |
| Namespace | `stormforge-system` (created automatically by the chart) |
| StormForge account | Sign up at <https://app.stormforge.io> |
| OAuth2 credentials | `CLIENT_ID` and `CLIENT_SECRET` from **StormForge → Settings → API Access** or via `stormforge create auth` |
| Outbound HTTPS | Egress to `*.stormforge.io:443` and `in.stormforge.io:443` |

---

## Key `values.yaml` Parameters

### Required

| Parameter | Description |
|-----------|-------------|
| `clusterName` | Unique name for this cluster in the StormForge platform |
| `authorization.clientID` | OAuth2 client ID |
| `authorization.clientSecret` | OAuth2 client secret — use an ExternalSecret or SealedSecret |

### Workload Controller

| Parameter | Default | Description |
|-----------|---------|-------------|
| `workload.image.repository` | `registry.stormforge.io/optimize/workload-agent` | Image repository |
| `workload.image.tag` | `2.28.2` | Image tag |
| `workload.resources` | 20m CPU / 64Mi RAM | Resource requests |
| `workload.workloadSyncInterval` | `50m` | Heartbeat interval for active workloads |
| `workload.collectLabels` | `true` | Include workload labels in API sync |
| `workload.inactiveWorkloadsGC` | `true` | Garbage-collect stale workloads on the API |

### Metrics Forwarder (Prometheus)

| Parameter | Default | Description |
|-----------|---------|-------------|
| `prom.image.repository` | `quay.io/prometheus/prometheus` | Image repository (swap to `prom/prometheus` for Docker Hub) |
| `prom.image.tag` | `v3.12.0` | Prometheus version |
| `prom.resources` | 20m CPU / 64Mi RAM | Resource requests |
| `prom.scrapeInterval` | `30s` | Scrape cadence |
| `prom.remoteWriteUrl` | `https://in.stormforge.io/prometheus/write` | Remote-write endpoint |
| `storageVolumeSize` | `2G` | WAL volume size |

### Network / Proxy

| Parameter | Default | Description |
|-----------|---------|-------------|
| `proxyUrl` | `""` | HTTPS proxy for egress to StormForge (e.g. `https://proxy.corp.example.com/`) |
| `noProxy` | RFC-1918 ranges | Comma-separated list of addresses to bypass the proxy |

### Platform Flags

| Parameter | Default | Description |
|-----------|---------|-------------|
| `openshift` | `false` | Enable OpenShift compatibility |
| `gkeAutopilot` | `false` | Enable GKE Autopilot compatibility |
| `enableCostMetrics` | `false` | Collect cost-related node metrics |
| `nodeCPUPressureDetection` | `false` | Detect node CPU pressure via PSI (requires Linux ≥ 4.20, cgroup v2) |

### Feature Gates

| Parameter | Default | Description |
|-----------|---------|-------------|
| `featureGates.optimizeCronJobs` | `false` | CronJob optimization support |
| `featureGates.optimizeSparkOperator` | `false` | Spark Operator support |
| `featureGates.optimizeGithubARC` | `false` | GitHub Actions Runner Controller support |

---

## Minimal Configuration Example

```yaml
pack:
  namespace: stormforge-system

charts:
  stormforge-agent:
    clusterName: "my-production-cluster"
    authorization:
      clientID: "{{ .spectrocontext.CLIENT_ID }}"
      clientSecret: "{{ .spectrocontext.CLIENT_SECRET }}"
```

> **Security note:** Never commit `clientSecret` in plain text. 
> secret management or reference a Kubernetes secret via `manageAuthSecret: false`
> and provision the secret externally.

---

## Disable Agent-Managed Auth Secret

If you prefer to manage the auth secret externally (e.g. with Vault or External Secrets Operator):

```yaml
charts:
  stormforge-agent:
    manageAuthSecret: false
    authSecret: "my-external-auth-secret"  # must exist in the target namespace
```

---

## Useful Links

- Documentation: <https://docs.stormforge.io>
- StormForge web app: <https://app.stormforge.io>
- Helm chart source: `oci://registry.stormforge.io/library/stormforge-agent`
- Changelog: <https://docs.stormforge.io/optimize-live/reference/agent-changelog/>
