# Tektoncd Operator

The Tektoncd Operator provides a declarative way to install, upgrade, and manage the lifecycle of Tekton components (Pipelines, Triggers, Dashboard, etc.) on Kubernetes and OpenShift clusters.

---

## Prerequisites

Before deploying the operator, ensure your environment meets the following requirements:

- **Kubernetes:** v1.29+ (or a compatible OpenShift environment).
- **Tools:** `kubectl` CLI installed and configured.
- **Cluster Permissions:** Cluster-admin privileges are required to deploy the cluster-wide Custom Resource Definitions (CRDs), Roles, and Operator deployments.

---

## Parameters

When configuring the operator via its main Custom Resource (`TektonConfig`), you can manage components through **Installation Profiles**.

| Platform | Profile | Installed Components |
|-----------|----------|----------------------|
| Kubernetes, OpenShift | `lite` | Pipeline |
| Kubernetes, OpenShift | `basic` | Pipeline, Trigger, Chains |
| Kubernetes | `all` | Pipeline, Trigger, Chains, Dashboard |
| OpenShift | `all` | Pipeline, Trigger, Chains, Pipelines as Code, Addons |

---

## Upgrade

To upgrade the Tektoncd Operator to the latest LTS version, replace the addon profile on cluster. The operator will automatically handle the lifecycle and rolling updates of the underlying Tekton components based on your active profile.
 
---

## Usage

Deploy the addon tekton operator profile on cluster

### Uninstall the Operator

The Tekton Operator acts as an orchestrator for other Tekton components. For safety reasons, uninstalling the operator does not automatically remove all resources created and managed by those components.

This behavior helps:

- Protect user data.
- Separate infrastructure lifecycle from workload lifecycle.
- Prevent accidental cascading deletions.
- Maintain cluster stability.

Additional Tekton resources may need to be removed manually if no longer required.

---

## References

- https://tekton.dev/docs/operator/install/
- https://github.com/tektoncd/operator
- https://tekton.dev/docs/operator/air-gap/
