# Fluent Bit

Fluent Bit is a lightweight and high-performance log processor and forwarder. It allows you to collect data or logs from different sources, unify them, and send them to multiple destinations including Elasticsearch, OpenSearch, Kafka, Datadog, and more.

### How it works

Fluent Bit runs as a DaemonSet in the Kubernetes cluster and collects logs from each node. The logs are parsed, filtered, and enriched with Kubernetes metadata before being shipped to the specified backend. This configuration is fully customizable via Fluent Bit configuration blocks defined in the Helm `values.yaml`.

The default configuration in this package collects logs from containers in `/var/log/containers/*.log` and system logs via `systemd`, filters them using Kubernetes metadata, and forwards them to an Elasticsearch endpoint.

## Prerequisites

Kubernetes 1.27 and higher are supported.

The following cloud types are supported:
* all clouds



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

## References

- [Fluent Bit Official Docs](https://docs.fluentbit.io/manual)
- [Fluent Bit Helm Chart](https://github.com/fluent/helm-charts/tree/main/charts/fluent-bit)
- [Spectro Cloud Docs - Fluent Bit](https://docs.spectrocloud.com/integrations/fluentbit)

---

This package is maintained by **Spectro Cloud** and is provided as a community-supported integration.

**Version:** 4.1.0

**Source:** community

**Contributor:** Spectro Cloud

