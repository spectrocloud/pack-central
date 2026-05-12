# Sedai

Sedai is the world's first self-driving cloud platform that autonomously optimizes Kubernetes workloads to reduce costs, boost performance, and improve availability — all without breaking production.

Unlike tools that only recommend changes, Sedai makes safe, continuous optimizations based on real workload behavior. Its patented ML engine learns how each service responds to traffic, validates every action against live signals, and rolls back automatically if performance drifts. Customers using Sedai typically achieve 30–50% cloud cost savings alongside measurable improvements in performance and reliability.

Sedai integrates seamlessly with your existing Kubernetes environment through standard APIs, requiring no deployment changes. The Spectro Cloud integration makes it easy to bring autonomous Kubernetes optimization into your cluster profiles with minimal setup.

## Key Features

- **Autonomous Workload Rightsizing:** Continuously tunes pod CPU and memory based on real workload behavior. No static requests, limits, or thresholds.

- **AI-Tuned Autoscalers:** Tunes HPA, VPA, KEDA, and Cluster Autoscaler policies from real behavior and SLOs — not static thresholds or manual guesswork.

- **Cluster-Level Optimization:** Evaluates your cluster beyond the pod or node level to deliver actual node reductions and real infrastructure savings.

- **Waste Detection at Every Layer:** Identifies idle and over-provisioned capacity across pods, nodes, and clusters, and removes it autonomously.

## Key Benefits

- **Safe Optimization in Production:** Every change is applied incrementally and protected by continuous validation and guardrails. Sedai rolls back automatically on any performance drift, so production stays stable.

- **Cost & Capacity Intelligence:** See exactly where Kubernetes spend lives and how optimizations reduce cost over time. Base capacity and purchasing decisions on real workload behavior, not fixed estimates.

- **Flexible Autonomy Modes:** Choose how much Sedai does for you — Datapilot (recommendations only), Copilot (review and approve), or Autopilot (fully autonomous, validated optimizations).

- **No Monitoring Changes Required:** Sedai works with the metrics and signals already exposed by your Kubernetes cluster and services, and requires no changes to your existing monitoring setup.

# Prerequisites

- A running Kubernetes cluster (EKS, AKS, GKE, OpenShift, Rancher, VMware Tanzu, IBM Cloud Kubernetes Service, Oracle OKE, Platform9, DigitalOcean, Alibaba CS, or similar).
- Kubernetes version 1.19 or later.
- A Sedai account with a valid API token. You can [book a demo](https://sedai.io) to get started.
- Outbound internet access from the cluster to the Sedai platform URL (or a proxy configured via `proxySettings`).

# Parameters

The Sedai pack supports all parameters exposed by the Sedai Helm Chart. Refer to the [Sedai documentation](https://docs.sedai.io) for the full list of configuration options.

| **Parameter** | **Description** | **Type** | **Default** | **Required** |
|---|---|---|---|---|
| `sedaiIntegrationSettings.sedaiBaseUrl` | Base URL of the Sedai platform | String | `""` | Yes |
| `sedaiIntegrationSettings.sedaiApiToken` | API token for authenticating with Sedai | String | `""` | Yes |
| `sedaiIntegrationSettings.clusterProvider` | Cloud provider (`AWS`, `AZURE`, `GCP`, `SELF_MANAGED`) | String | `""` | Yes |
| `sedaiIntegrationSettings.clusterName` | Display name of the cluster in the Sedai UI | String | Palette cluster name | No |
| `sedaiIntegrationSettings.rbacReadOnly` | Enable read-only (Datapilot) mode | Boolean | `false` | No |
| `sedaiVictoriaMetrics.enabled` | Enable Sedai-managed Victoria Metrics (enabled by default) | Boolean | `true` | No |
| `sedaiKSM.enabled` | Enable Kube State Metrics (enabled by default) | Boolean | `true` | No |
| `sedaiNodeExporter.enabled` | Enable Node Exporter (enabled by default) | Boolean | `true` | No |
| `sedaiSync.enabled` | Enable auto-optimization (Sedai Sync) | Boolean | `false` | No |
| `sedaiBeyla.enabled` | Enable Beyla (eBPF-based APM) | Boolean | `false` | No |
| `sedaiDcgmExporter.enabled` | Enable DCGM Exporter for GPU metrics | Boolean | `false` | No |
| `sedaiGrafanaAlloy.enabled` | Enable Grafana Alloy for metrics collection | Boolean | `false` | No |
| `monitoringProvider.datadog.enabled` | Enable Datadog as the monitoring provider | Boolean | `false` | No |
| `monitoringProvider.newrelic.enabled` | Enable New Relic as the monitoring provider | Boolean | `false` | No |
| `monitoringProvider.amp.enabled` | Enable Amazon Managed Prometheus (AMP) | Boolean | `false` | No |
| `monitoringProvider.gcpMonitoring.enabled` | Enable Google Cloud Monitoring | Boolean | `false` | No |
| `monitoringProvider.dynatrace.enabled` | Enable Dynatrace as the monitoring provider | Boolean | `false` | No |
| `proxySettings.enabled` | Enable HTTP proxy for outbound access | Boolean | `false` | No |
| `globalRegistry` | Default container image registry prefix | String | `public.ecr.aws` | No |

# Usage

## Step 1 — Add the pack to a cluster profile

Add the Sedai Smart Agent pack to a cluster profile as an add-on layer. You can create a new cluster profile or update an existing one.

## Step 2 — Configure required values

At minimum, set the following in the pack's `values.yaml` before deploying:

```yaml
charts:
  sedai-smart-agent:
    sedaiIntegrationSettings:
      sedaiBaseUrl: "https://<your-tenant>.sedai.app"
      sedaiApiToken: "<your-sedai-api-token>"
      clusterProvider: "AWS"   # AWS, AZURE, GCP, or SELF_MANAGED
```

The `clusterName` is automatically populated from the Palette cluster name.

By default, the pack deploys Victoria Metrics, Kube State Metrics, and Node Exporter for metric collection. No additional monitoring configuration is required for a standard deployment.

## Step 3 — Deploy the cluster

Deploy or update your cluster. The Sedai Smart Agent enrollment job runs automatically on first install and registers your cluster with the Sedai platform.

## Step 4 — Verify in the Sedai dashboard

Log in to your Sedai tenant and confirm the cluster appears as connected. Sedai typically needs 2–4 weeks to learn your workload patterns before autonomous optimizations reach full effectiveness.

## Optional — Use an external monitoring provider

To use Datadog, New Relic, AMP, Google Cloud Monitoring, or Dynatrace instead of the default Sedai-managed Victoria Metrics, enable the relevant provider under `monitoringProvider` and disable the Sedai-managed stack:

```yaml
charts:
  sedai-smart-agent:
    sedaiVictoriaMetrics:
      enabled: false
    monitoringProvider:
      datadog:
        enabled: true
        datadogEndpoint: "https://api.datadoghq.com"
        datadogApiKey: "<your-api-key>"
        datadogApplicationKey: "<your-app-key>"
```

## Optional — Configure a proxy

If your cluster requires an HTTP proxy for outbound internet access:

```yaml
charts:
  sedai-smart-agent:
    proxySettings:
      enabled: true
      proxyHost: "proxy.example.com"
      proxyPort: "3128"
```

# References

- [Sedai Platform Overview](https://sedai.io/platform/kubernetes)

- [Sedai Documentation](https://docs.sedai.io)

- [Contact Sedai](https://sedai.io/company/contact)