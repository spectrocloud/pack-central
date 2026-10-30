# Jaeger

## Overview

Jaeger is an open source, end-to-end distributed tracing platform used to monitor and troubleshoot distributed applications and microservices. It provides visibility into request flows, helps identify performance bottlenecks, and enables root cause analysis through distributed tracing.

This pack installs the official Jaeger Helm chart using the default All-in-One deployment.

## Prerequisites

Before installing this pack, ensure the following requirements are met:

- Kubernetes 1.29 or later.
- A running Kubernetes cluster.
- Sufficient cluster resources to deploy Jaeger.
- Network connectivity between applications and the Jaeger collector.

## Pack Contents

This pack deploys the following components:

- Jaeger All-in-One
- Jaeger Query UI
- OpenTelemetry Collector
- Kubernetes Services
- Service Account
- RBAC resources
- ConfigMaps

## Configuration

The pack installs Jaeger into the `jaeger` namespace by default.

The following table describes the primary configuration parameters.

| Parameter | Description | Default |
|----------|-------------|---------|
| `pack.namespace` | Namespace where Jaeger is installed. | `jaeger` |

Additional configuration options can be customized through the Helm chart values.

## Installation

Deploy the Jaeger pack from Palette.

Wait until the pack reaches the **Healthy** state before proceeding with validation.

## Validation

Verify that the Jaeger deployment is running successfully.

```bash
kubectl get all -n jaeger
```

Review the logs if necessary.

```bash
kubectl logs deployment/jaeger -n jaeger
```

## Accessing the Jaeger UI

If an Ingress is not configured, forward the Query service locally.

```bash
kubectl port-forward svc/jaeger-query 16686:16686 -n jaeger
```

Open the Jaeger UI using a web browser.

```
http://localhost:16686
```

## Uninstall

Remove the Helm release.

```bash
helm uninstall jaeger -n jaeger
```

Optionally delete the namespace.

```bash
kubectl delete namespace jaeger
```

## References

- https://www.jaegertracing.io/
- https://github.com/jaegertracing/helm-charts