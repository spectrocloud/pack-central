# Tekton Pipelines

Tekton Pipelines is a Kubernetes-native extension that installs and runs on your cluster, providing a set of Kubernetes Custom Resources (Tasks, Pipelines, PipelineRuns, and TaskRuns). These act as building blocks to assemble robust, cloud-native continuous integration and continuous delivery (CI/CD) workflows. 

## Prerequisites

- **Kubernetes:** Version 1.29+ (e.g., AWS EKS, OpenShift, or generic clusters).
- **Helm:** Version 3.0.0+ installed and configured.
- **Storage:** A default `StorageClass` configured in your cluster (such as the EBS CSI driver) if utilizing Tekton Workspaces for pipeline artifacts.

## Parameters

The following tables lists the configurable parameters of the Tekton Pipelines chart and their default values.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `replicaCount` | int | `1` | Number of replicas for the Tekton controller |
| `image.repository` | string | `"gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/controller"` | Image repository for the controller |
| `image.tag` | string | `"v1.12.0"` | Image tag (defaults to chart appVersion) |
| `webhook.enabled` | bool | `true` | Enable the mutating/validating webhook |
| `featureFlags.enable-api-fields` | string | `"stable"` | Setting to `alpha` enables experimental features |
| `resources.requests.cpu` | string | `"100m"` | CPU requests for the controller pods |
| `resources.requests.memory` | string | `"100Mi"` | Memory requests for the controller pods |
| `serviceMonitor.enabled` | bool | `true` | Enable Prometheus ServiceMonitor for cloud-native observability |

## Upgrade

**Note:** Before upgrading, particularly across major versions, it is recommended to ensure no critical `PipelineRuns` or `TaskRuns` are actively executing.  

## Usage

To install  `tekton-pipelines`, deploy a tekton-pipelines addon profile on cluster.
 
You are now ready to deploy Tekton resources. For instance, to test your setup with a simple Task:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: hello-world
spec:
  steps:
    - name: echo
      image: busybox
      command:
        - echo
      args:
        - "Hello from Tekton!"
EOF
```

## References

- [Tekton Pipelines Official Documentation](https://tekton.dev/docs/pipelines/)
- [Tekton GitHub Repository](https://github.com/tektoncd/pipeline)
- [Tekton Tasks Hub](https://hub.tekton.dev/)
