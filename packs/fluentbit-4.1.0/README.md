# Fluent Bit

Fluent Bit is a lightweight and high-performance log processor and forwarder. It allows you to collect data or logs from different sources, unify them, and send them to multiple destinations including Elasticsearch, OpenSearch, Kafka, Datadog, and more.

## Prerequisites

- Kubernetes **1.27** and higher are supported.  
- Supported cloud types: **All clouds**.

## Parameters

| **Parameter** | **Description** | **Type** | **Default Value** | **Required** |
|---|---|---|---|---|
| charts.fluent-bit.kind | Kubernetes controller to use (DaemonSet or Deployment) | string | DaemonSet | Yes |
| charts.fluent-bit.image.repository | Image repository for Fluent Bit | string | cr.fluentbit.io/fluent/fluent-bit | Yes |
| charts.fluent-bit.image.pullPolicy | Image pull policy | string | IfNotPresent | No |
| charts.fluent-bit.flush | Interval (in seconds) to flush the logs | integer | 1 | No |
| charts.fluent-bit.logLevel | Logging level for Fluent Bit | string | info | No |
| charts.fluent-bit.metricsPort | Port for exposing metrics | integer | 2020 | No |
| charts.fluent-bit.config.service | Main Fluent Bit service configuration | string | See values.yaml | Yes |
| charts.fluent-bit.config.inputs | Log input configuration | string | See values.yaml | Yes |
| charts.fluent-bit.config.filters | Filters applied to logs (e.g. Kubernetes metadata) | string | See values.yaml | Yes |
| charts.fluent-bit.config.outputs | Log output configuration | string | See values.yaml | Yes |
| charts.fluent-bit.config.customParsers | Custom parsers for log messages | string | See values.yaml | No |
| charts.fluent-bit.daemonSetVolumes | Volumes to mount for log access | list | /var/log, /var/lib/docker/containers, /etc/machine-id | Yes |
| charts.fluent-bit.daemonSetVolumeMounts | Mount points in Fluent Bit containers | list | See values.yaml | Yes |
| charts.fluent-bit.service.port | Port exposed by the Fluent Bit service | integer | 2020 | No |
| charts.fluent-bit.rbac.create | Whether to create RBAC resources | bool | true | No |
| charts.fluent-bit.podSecurityPolicy.create | Whether to create PodSecurityPolicy | bool | false | No |
| charts.fluent-bit.hotReload.enabled | Enable configmap hot reload with sidecar | bool | false | No |
| charts.fluent-bit.autoscaling.enabled | Enable horizontal pod autoscaler (only for Deployment) | bool | false | No |

## Upgrade

- Ensure compatibility with the Kubernetes version (1.27 or higher) before upgrading.  
- Review any changes in the Fluent Bit Helm chart configuration that could impact existing parameters.  
- If upgrading from a previous major version, verify that configuration blocks (inputs, filters, outputs) maintain their structure and names.

> [!CAUTION]
> Upgrades from a manifest-based pack to a Helm chart-based pack might not be compatible.

## Usage

Fluent Bit runs as a **DaemonSet** in a Kubernetes cluster and collects logs from each node.  
The logs are parsed, filtered, and enriched with Kubernetes metadata before being shipped to the specified backend.

- The default configuration collects:
  - Container logs from `/var/log/containers/*.log`
  - System logs via `systemd`
- Logs are filtered using Kubernetes metadata.
- Output is sent to the defined destination, such as **Elasticsearch**.

You can customize this configuration through `values.yaml`, adjusting sections such as `inputs`, `filters`, and `outputs`.

> [!NOTE]
> Fluent Bit’s configuration allows flexible integrations with other monitoring tools like **Datadog**, **OpenSearch**, or **Kafka**.

## References

- [Fluent Bit Official Docs](https://docs.fluentbit.io/manual)
- [Fluent Bit Helm Chart](https://github.com/fluent/helm-charts/tree/main/charts/fluent-bit)
- [Spectro Cloud Docs - Fluent Bit](https://docs.spectrocloud.com/integrations/fluentbit)

---

**Maintainer:** Spectro Cloud  
**Version:** 4.0.3  
**Source:** Community  
**Contributor:** Spectro Cloud  

