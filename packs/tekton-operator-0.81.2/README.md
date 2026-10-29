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

To upgrade the Tektoncd Operator to the latest LTS version, re-apply the official release manifest. The operator will automatically handle the lifecycle and rolling updates of the underlying Tekton components based on your active profile.

### 1. Backup Existing Configuration

```bash
kubectl get tektonconfigs.operator.tekton.dev -o yaml > tektonconfig-backup.yaml
```

### 2. Apply the Updated Manifest

```bash
kubectl apply -f https://infra.tekton.dev/tekton-releases/operator/latest/release.yaml
```

---

## Usage

### 1. Install the Operator

Deploy the operator using the official release manifest.

```bash
kubectl apply -f https://infra.tekton.dev/tekton-releases/operator/latest/release.yaml
```

### 2. Configure Installation Profiles (Optional)

If you prefer a different subset of components instead of the default stack, apply a specific configuration profile:

```bash
kubectl apply -f https://raw.githubusercontent.com/tektoncd/operator/main/config/crs/kubernetes/config/all/operator_v1alpha1_config_cr.yaml
```

### 3. Verify the Installation

Ensure the operator and its custom resources are successfully deployed:

```bash
kubectl get deployments -n tekton-operator
kubectl get tektonconfig
```

### 4. Uninstall the Operator

The Tekton Operator acts as an orchestrator for other Tekton components. For safety reasons, uninstalling the operator does not automatically remove all resources created and managed by those components.

This behavior helps:

- Protect user data.
- Separate infrastructure lifecycle from workload lifecycle.
- Prevent accidental cascading deletions.
- Maintain cluster stability.

Remove the operator with:

```bash
kubectl delete -f https://infra.tekton.dev/tekton-releases/operator/latest/release.yaml
```

Additional Tekton resources may need to be removed manually if no longer required.

---

## References

- https://tekton.dev/docs/operator/install/
- https://github.com/tektoncd/operator
- https://tekton.dev/docs/operator/air-gap/
