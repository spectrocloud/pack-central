## Loki

Grafana Loki is a horizontally scalable log aggregation system designed for efficient storage and querying of logs. This package deploys Loki using the Grafana Community Helm Chart and supports Monolithic, Simple Scalable, and Microservices deployment modes.

### Package Information

| Property | Value |
|-----------|---------|
| Application | Grafana Loki |
| Chart | loki |
| Chart Version | 18.11.7 |
| Application Version | 3.7.7 |
| Namespace | loki |

---

## Prerequisites

Before deploying this package, ensure the following requirements are met:

### Kubernetes Requirements

- Kubernetes 1.29 or later
- Helm 3.x

### Dependencies

The following components are included as subcharts:

| Repository | Dependency | Version |
|------------|------------|---------|
| https://charts.min.io | MinIO | 5.4.4 |
| https://grafana.github.io/helm-charts | Rollout Operator | 0.51.1 |

> Note: The embedded MinIO deployment is deprecated for production environments. Use external object storage whenever possible.

### Storage Requirements

For production deployments, configure one of the following object storage backends:

- Amazon S3
- Azure Blob Storage
- Google Cloud Storage
- S3-compatible storage

---

## Parameters

### Common Configuration

```yaml
deploymentMode: Monolithic

gateway:
  enabled: true

lokiCanary:
  enabled: true
```

### Loki Image Configuration

```yaml
loki:
  image:
    repository: grafana/loki
    tag: 3.7.7
```

### Package Images

```yaml
pack:
  content:
    images:
      - image: docker.io/grafana/loki:3.7.7
      - image: docker.io/grafana/loki-canary:3.7.7
      - image: docker.io/grafana/loki-helm-test:3.7.7
      - image: docker.io/nginxinc/nginx-unprivileged:1.31-alpine
      - image: ghcr.io/jkroepke/access-log-exporter:0.4.12
      - image: docker.io/memcached:1.6.45-alpine
      - image: quay.io/prometheus/memcached-exporter:v0.17.0
      - image: docker.io/kiwigrid/k8s-sidecar:2.10.3
      - image: registry.k8s.io/kubectl:v1.37.0
```

### Storage Example

```yaml
loki:
  storage:
    bucketNames:
      chunks: loki-chunks
      ruler: loki-ruler
```

---

## Upgrade

### Upgrade Package

Replace the Loki addon profile with a new version.

### Important Upgrade Considerations

#### From 17.x to 18.x

- Monitoring settings moved under `.Values.monitoring`
- Dashboard generation now uses upstream `loki-mixin`
- `cluster` label replaced by `app_instance`
- Alert configuration moved to `monitoring.alerts`

#### From 16.x to 17.x

- Embedded MinIO deployment is deprecated
- External object storage is recommended

#### From 11.x to 12.x

- Default deployment mode changed to `Monolithic`
- `SingleBinary` renamed to `Monolithic`

#### Kubernetes Compatibility

- Kubernetes 1.25+ required
- Deprecated API versions removed

---

## Usage

### Install 

Add a Loki addon profile to the cluster

### Uninstall

Remove the Loki addon profile from the cluster

---

## References

### Documentation

- https://grafana.com/docs/loki/latest/
- https://grafana.com/docs/loki/latest/setup/install/helm/
- https://grafana.com/oss/loki/

### Source Code

- https://github.com/grafana/loki

### Helm Repository

- https://grafana-community.github.io/helm-charts

### Storage Documentation

- https://grafana.com/docs/loki/latest/configure/storage/
- https://grafana.com/docs/loki/latest/operations/storage/schema/

### Changelog

- https://grafana-community.github.io/helm-charts/changelog/?chart=loki
