# WEKA Operator

Kubernetes operator for managing WEKA clusters on Kubernetes.

## Overview

The weka-operator automates the deployment and management of WEKA distributed storage clusters on Kubernetes. It provides:

- Automated WEKA cluster provisioning and lifecycle management
- Node discovery and container orchestration
- Drive management and cluster scaling
- CSI driver integration for persistent volumes

## Prerequisites

- Kubernetes cluster (v1.26+)
- Helm 3.x
- Container registry access (Quay.io or your own registry)
- WEKA license and credentials

## Installation
Set image pull secret name if needed
```shell
export QUAY_USERNAME=<quay username>
export QUAY_PASSWORD=<quay password>

kubectl create namespace weka-operator-system
kubectl create secret docker-registry quay-io-robot-secret \
  --docker-server=quay.io \
  --docker-username=$QUAY_USERNAME \
  --docker-password=$QUAY_PASSWORD \
  --docker-email=$QUAY_USERNAME \
  --namespace=weka-operator-system # operator will be scheduling some containers in own namespace

kubectl create secret docker-registry quay-io-robot-secret \
  --docker-server=quay.io \
  --docker-username=$QUAY_USERNAME \
  --docker-password=$QUAY_PASSWORD \
  --docker-email=$QUAY_USERNAME \
  --namespace=default # wekacluster/wekaclient namespaces, that can be different from operator itself, each namespace needs a copy of secret
```
```shell
# Install CRDs using server-side apply
helm show crds oci://quay.io/weka.io/helm/weka-operator --version v1.9.1 | \
  kubectl apply --server-side -f -

# Install operator
helm upgrade --install weka-operator oci://quay.io/weka.io/helm/weka-operator \
  --namespace weka-operator-system \
  --create-namespace --version v1.9.1
```

## Configuration

### Helm Values

Key configuration options in `https://github.com/weka/weka-operator/charts/weka-operator/values.yaml`:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `imagePullSecret` | Image pull secret name | `quay-io-robot-secret` |
| `csi.installationEnabled` | Enable CSI driver | `false` |

See [values](https://github.com/weka/weka-operator/charts/weka-operator/values.yaml) for all configuration options.


# References
- https://github.com/weka/weka-operator