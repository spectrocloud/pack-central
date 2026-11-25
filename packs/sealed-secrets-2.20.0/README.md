# Sealed Secrets

## Overview

Sealed Secrets is an open source Kubernetes controller used to manage encrypted Kubernetes Secrets. It allows sensitive configuration data to be stored safely in Git repositories by encrypting Kubernetes Secrets into `SealedSecret` resources.

The Sealed Secrets controller decrypts `SealedSecret` resources inside the Kubernetes cluster and creates the corresponding Kubernetes Secrets.

This pack installs the official Sealed Secrets Helm chart and deploys the Sealed Secrets controller.

## Prerequisites

Before installing this pack, ensure the following requirements are met:

* Kubernetes 1.29 or later.
* A running Kubernetes cluster.
* Sufficient cluster resources to deploy the Sealed Secrets controller.
* Appropriate permissions to create cluster-scoped resources, including CRDs and RBAC resources.

## Pack Contents

This pack deploys the following components:

* Sealed Secrets Controller
* SealedSecret Custom Resource Definition (CRD)
* Kubernetes Service
* Service Account
* ClusterRole and ClusterRoleBinding
* Role and RoleBinding when configured
* ConfigMaps when configured
* ServiceMonitor and PrometheusRule when enabled
* PodDisruptionBudget when enabled

## Configuration

The pack installs Sealed Secrets into the `sealed-secrets` namespace by default.

The following table describes the primary configuration parameters.

| Parameter                        | Description                                     | Default                             |
| -------------------------------- | ----------------------------------------------- | ----------------------------------- |
| `pack.namespace`                 | Namespace where Sealed Secrets is installed.    | `sealed-secrets`                    |
| `image.registry`                 | Container image registry.                       | `docker.io`                         |
| `image.repository`               | Sealed Secrets controller image repository.     | `bitnami/sealed-secrets-controller` |
| `image.tag`                      | Sealed Secrets controller image tag.            | `0.39.1`                            |
| `service.type`                   | Kubernetes Service type used by the controller. | `ClusterIP`                         |
| `service.port`                   | HTTP port exposed by the controller Service.    | `8080`                              |
| `ingress.enabled`                | Enables Ingress for the Sealed Secrets service. | `false`                             |
| `networkPolicy.enabled`          | Enables NetworkPolicy for the controller.       | `false`                             |
| `metrics.serviceMonitor.enabled` | Enables a Prometheus ServiceMonitor.            | `false`                             |

Additional configuration options can be customized through the Helm chart values.

## Installation

Deploy the Sealed Secrets pack from Palette.

Wait until the pack reaches the **Healthy** state before proceeding with validation.

## Validation

Verify that the Sealed Secrets controller is running successfully.

```bash
kubectl get all -n sealed-secrets
```

Verify that the SealedSecret CRD has been installed.

```bash
kubectl get crd sealedsecrets.bitnami.com
```

Verify the Sealed Secrets controller logs if necessary.

```bash
kubectl logs deployment/sealed-secrets -n sealed-secrets
```

Verify that the controller is ready.

```bash
kubectl get pods -n sealed-secrets
```

The controller pod should reach the **Running** state and report ready containers.

## Using Sealed Secrets

The Sealed Secrets controller works together with the `kubeseal` command-line client.

A Kubernetes Secret can be encrypted with `kubeseal` to create a `SealedSecret` resource. The resulting `SealedSecret` can then be stored in a Git repository and deployed through a GitOps workflow.

The Sealed Secrets controller running in the cluster decrypts the `SealedSecret` and creates the corresponding Kubernetes Secret.

## References

* https://github.com/bitnami/sealed-secrets
* https://github.com/bitnami/sealed-secrets/releases
* https://bitnami.github.io/sealed-secrets
