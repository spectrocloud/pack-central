## Loki

Grafana Loki is a horizontally scalable log aggregation system designed for efficient storage and querying of logs. This package deploys Loki using the Grafana Community Helm Chart and supports Monolithic, Simple Scalable, and Microservices deployment modes.

### Package Information

| Property | Value |
|-----------|---------|
| Application | Grafana Loki |
| Chart | loki |
| Chart Version | 18.5.2 |
| Application Version | 3.7.4 |
| Namespace | loki |

---

## Prerequisites

Before deploying this package, ensure the following requirements are met:

### Kubernetes Requirements

- Kubernetes 1.25 or later
- Helm 3.x

### Dependencies

The following components are included as subcharts:

| Repository | Dependency | Version |
|------------|------------|---------|
| https://charts.min.io | MinIO | 5.4.0 |
| https://grafana.github.io/helm-charts | Rollout Operator | 0.50.1 |

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
    tag: 3.7.4
```

### Package Images

```yaml
pack:
  content:
    images:
      - image: docker.io/grafana/loki:3.7.4
      - image: docker.io/grafana/loki-canary:3.7.4
      - image: docker.io/grafana/loki-helm-test:3.7.4
      - image: docker.io/nginxinc/nginx-unprivileged:1.31-alpine
      - image: ghcr.io/jkroepke/access-log-exporter:0.4.6
      - image: docker.io/memcached:1.6.45-alpine
      - image: quay.io/prometheus/memcached-exporter:v0.16.0
      - image: docker.io/kiwigrid/k8s-sidecar:2.8.1
      - image: registry.k8s.io/kubectl:v1.36.0
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

```bash
helm upgrade loki grafana-community/loki \
  --namespace loki \
  -f values.yaml
```

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

### Install from OCI Registry

```bash
helm install loki \
  oci://ghcr.io/grafana-community/helm-charts/loki \
  --namespace loki \
  --create-namespace
```

### Install from Helm Repository

```bash
helm repo add grafana-community https://grafana-community.github.io/helm-charts

helm repo update

helm install loki \
  grafana-community/loki \
  --namespace loki \
  --create-namespace
```

### Verify Installation

```bash
kubectl get pods -n loki
```

```bash
kubectl get svc -n loki
```

### Uninstall

```bash
helm uninstall loki -n loki
```

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
