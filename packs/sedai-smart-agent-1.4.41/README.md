# Sedai Smart Agent

Sedai Smart Agent is an autonomous Kubernetes optimization platform that continuously monitors, analyzes, and right-sizes your workloads to reduce cloud costs and improve reliability — without requiring manual intervention.

The agent connects your Kubernetes clusters to the Sedai platform, collecting metrics through a built-in or externally managed monitoring stack (Prometheus, Victoria Metrics, Datadog, New Relic, and more), and applies intelligent recommendations automatically.

## Prerequisites

- Kubernetes cluster running version 1.19 or later.
- A [Sedai](https://app.sedai.io) account with a valid API token.
- Outbound internet access from the cluster to the Sedai platform URL (or proxy configured via `proxySettings`).

## Parameters

The following table describes the most commonly configured parameters. For the full list, refer to the `values.yaml` file bundled with this pack.

| **Parameter** | **Description** | **Type** | **Default Value** | **Required** |
|---|---|---|---|---|
| `sedaiIntegrationSettings.sedaiBaseUrl` | Base URL of the Sedai platform | String | `""` | Yes |
| `sedaiIntegrationSettings.sedaiApiToken` | API token for authenticating with Sedai | String | `""` | Yes |
| `sedaiIntegrationSettings.clusterProvider` | Cloud provider for the cluster (`AWS`, `AZURE`, `GCP`, `SELF_MANAGED`) | String | `""` | Yes |
| `sedaiIntegrationSettings.clusterName` | Display name of the cluster in the Sedai UI | String | Palette cluster name | No |
| `sedaiIntegrationSettings.nickName` | Optional nickname for the cluster in the Sedai UI | String | `""` | No |
| `sedaiIntegrationSettings.rbacReadOnly` | Set to `true` to enable read-only (Datapilot) mode | Boolean | `false` | No |
| `sedaiVictoriaMetrics.enabled` | Enable Sedai-managed Victoria Metrics for metric storage | Boolean | `true` | No |
| `sedaiPrometheus.enabled` | Enable Sedai-managed Prometheus for metric collection | Boolean | `false` | No |
| `sedaiKSM.enabled` | Enable Kube State Metrics deployment | Boolean | `true` | No |
| `sedaiNodeExporter.enabled` | Enable Node Exporter for node-level metrics | Boolean | `true` | No |
| `sedaiBeyla.enabled` | Enable Beyla (eBPF-based APM instrumentation) | Boolean | `false` | No |
| `sedaiSync.enabled` | Enable Sedai Sync controller for workload auto-optimization | Boolean | `false` | No |
| `sedaiDcgmExporter.enabled` | Enable DCGM Exporter for GPU metrics (requires NVIDIA GPUs) | Boolean | `false` | No |
| `sedaiGrafanaAlloy.enabled` | Enable Grafana Alloy for metrics collection | Boolean | `false` | No |
| `proxySettings.enabled` | Enable HTTP proxy for outbound internet access | Boolean | `false` | No |
| `proxySettings.proxyHost` | Proxy server hostname | String | `""` | No |
| `proxySettings.proxyPort` | Proxy server port | String | `""` | No |
| `monitoringProvider.datadog.enabled` | Enable Datadog as the monitoring provider | Boolean | `false` | No |
| `monitoringProvider.newrelic.enabled` | Enable New Relic as the monitoring provider | Boolean | `false` | No |
| `monitoringProvider.amp.enabled` | Enable Amazon Managed Prometheus (AMP) as the monitoring provider | Boolean | `false` | No |
| `monitoringProvider.gcpMonitoring.enabled` | Enable Google Cloud Monitoring as the monitoring provider | Boolean | `false` | No |
| `monitoringProvider.dynatrace.enabled` | Enable Dynatrace as the monitoring provider | Boolean | `false` | No |
| `globalRegistry` | Default container image registry prefix for all images | String | `public.ecr.aws` | No |

## Usage

Add the Sedai Smart Agent pack to a cluster profile as an add-on layer. At minimum, provide the following values before deploying:

```yaml
charts:
  sedai-smart-agent:
    sedaiIntegrationSettings:
      sedaiBaseUrl: "https://tenant.sedai.app"
      sedaiApiToken: "<your-sedai-api-token>"
      clusterProvider: "AWS"   # AWS, AZURE, GCP, or SELF_MANAGED
```

The `clusterName` field is automatically populated from the Palette cluster name using `{{ .spectro.system.cluster.name }}`.

**Monitoring provider**

By default, the agent deploys Sedai-managed Victoria Metrics and Kube State Metrics for metric collection. To use an external monitoring provider such as Datadog, New Relic, Amazon Managed Prometheus, Google Cloud Monitoring, or Dynatrace, enable the relevant section under `monitoringProvider` and disable the Sedai-managed components:

```yaml
charts:
  sedai-smart-agent:
    sedaiVictoriaMetrics:
      enabled: false
```

**Auto-optimization (Sedai Sync)**

To enable automatic workload right-sizing, set `sedaiSync.enabled` to `true`:

```yaml
charts:
  sedai-smart-agent:
    sedaiSync:
      enabled: true
```

**GPU monitoring**

For clusters with NVIDIA GPUs, enable the DCGM Exporter to collect GPU metrics:

```yaml
charts:
  sedai-smart-agent:
    sedaiDcgmExporter:
      enabled: true
```

**Proxy configuration**

If your cluster requires an HTTP proxy for outbound internet access:

```yaml
charts:
  sedai-smart-agent:
    proxySettings:
      enabled: true
      proxyHost: "proxy.example.com"
      proxyPort: "3128"
```

**Private registry**

To pull images from a private or proxy registry, update `globalRegistry` and optionally provide an image pull secret:

```yaml
charts:
  sedai-smart-agent:
    globalRegistry: "my-proxy-registry.example.com"
    imagePullSecret:
      enabled: true
      secretName: "my-registry-secret"
```

## References

- [Sedai Documentation](https://docs.sedai.io)

- [Sedai Smart Agent Helm Chart](https://sedaiengineering.github.io/helm-charts/)

- [Contact Sedai](https://www.sedai.io/contact)
