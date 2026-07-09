
```markdown
# Tektoncd Operator

The Tektoncd Operator provides a declarative way to install, upgrade, and manage the lifecycle of Tekton components (Pipelines, Triggers, Dashboard, etc.) on Kubernetes and OpenShift clusters.

---

## Prerequisites

Before deploying the operator, ensure your environment meets the following requirements:

* **Kubernetes:** v1.29+ (or a compatible OpenShift environment).
* **Tools:** `kubectl` CLI installed and configured.
* **Cluster Permissions:** Cluster-admin privileges are required to deploy the cluster-wide Custom Resource Definitions (CRDs), Roles, and Operator deployments.

---

## Parameters

When configuring the operator via its main Custom Resource (`TektonConfig`), you can manage components through **Installation Profiles**. The available profiles and the components they install are:

| Platform | Profile | Installed Components |
| :--- | :--- | :--- |
| Kubernetes, OpenShift | `lite` | Pipeline |
| Kubernetes, OpenShift | `basic` | Pipeline, Trigger, Chains |
| Kubernetes | `all` | Pipeline, Trigger, Chains, Dashboard |
| OpenShift | `all` | Pipeline, Trigger, Chains, Pipelines as Code, Addons |

---

## Upgrade

To upgrade the Tektoncd Operator to the latest LTS version, re-apply the official release manifest. The operator will automatically handle the lifecycle and rolling updates of the underlying Tekton components based on your active profile.

1. **Backup existing configurations:**
   ```bash
   kubectl get tektonconfigs.operator.tekton.dev -o yaml > tektonconfig-backup.yaml

```

2. **Apply the updated manifest:**
```bash
kubectl apply -f [https://infra.tekton.dev/tekton-releases/operator/latest/release.yaml](https://infra.tekton.dev/tekton-releases/operator/latest/release.yaml)

```



---

## Usage

### 1. Install the Operator

Deploy the operator using the official release manifest. This single command sets up the operator alongside the default components (Pipelines, Triggers, Chains, and Dashboard):

```bash
kubectl apply -f [https://infra.tekton.dev/tekton-releases/operator/latest/release.yaml](https://infra.tekton.dev/tekton-releases/operator/latest/release.yaml)

```

### 2. Configure Installation Profiles (Optional)

If you prefer a different subset of components instead of the default stack, you can apply a specific configuration profile (e.g., the `all` profile for Kubernetes):

```bash
kubectl apply -f [https://raw.githubusercontent.com/tektoncd/operator/main/config/crs/kubernetes/config/all/operator_v1alpha1_config_cr.yaml](https://raw.githubusercontent.com/tektoncd/operator/main/config/crs/kubernetes/config/all/operator_v1alpha1_config_cr.yaml)

```

### 3. Verify the Installation

Ensure the operator and its custom resources are successfully deployed in the cluster:

```bash
kubectl get deployments -n tekton-operator
kubectl get tektonconfig

```

### 4. Uninstalling

The tekton-operator pack acts as an orchestrator for other components; therefore, it creates resources that cannot be removed when the operator is uninstalled. In this case, the user must manually remove all remaining resources. The tekton pack is designed this way to protect user data, separate the infrastructure from workloads, prevent dangerous cascading removals, and for other reasons.

To remove the operator from your cluster:

```bash
kubectl delete -f [https://infra.tekton.dev/tekton-releases/operator/latest/release.yaml](https://infra.tekton.dev/tekton-releases/operator/latest/release.yaml)

```

---

## References

* [Official Tekton Operator Installation Guide](https://tekton.dev/docs/operator/install/)
* [Tektoncd Operator GitHub Repository](https://github.com/tektoncd/operator)
* [Air Gap Image Configuration Guide](https://www.google.com/search?q=https://tekton.dev/docs/operator/air-gap/)

```

```