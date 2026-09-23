# Tekton Pipelines

Tekton Pipelines is a Kubernetes-native extension that installs and runs on your cluster, providing a set of Kubernetes Custom Resources such as Tasks, Pipelines, PipelineRuns, and TaskRuns. These resources act as building blocks for cloud-native continuous integration and continuous delivery (CI/CD) workflows.

## Version

This package is based on **Tekton Pipelines v1.16.0**.

## Prerequisites

- **Kubernetes:** Version 1.29+ (for the supported package baseline; verify cluster compatibility before installation).
- **Helm:** Version 3.0.0+ installed and configured.
- **Storage:** A default `StorageClass` configured in the cluster if Tekton Workspaces are used for pipeline artifacts.

## Parameters

The following table lists the main configurable parameters of the Tekton Pipelines chart and their default values.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `replicaCount` | int | `1` | Number of replicas for the Tekton controller. |
| `image.repository` | string | `gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/controller` | Image repository for the controller. Verify the repository against the v1.16.0 release manifest. |
| `image.tag` | string | `v1.16.0` | Image tag corresponding to Tekton Pipelines v1.16.0. |
| `webhook.enabled` | bool | `true` | Enables the mutating/validating webhook. |
| `featureFlags.enable-api-fields` | string | `stable` | Controls the API feature level. Setting it to `alpha` enables experimental features. |
| `resources.requests.cpu` | string | `100m` | CPU request for the controller pod. |
| `resources.requests.memory` | string | `100Mi` | Memory request for the controller pod. |
| `serviceMonitor.enabled` | bool | `true` | Enables the Prometheus ServiceMonitor for observability. |

> **Note:** For package image mirroring or digest validation, use the images and digests from the official Tekton Pipelines **v1.16.0** release manifest rather than assuming that the controller image is the only image required.

## Upgrade

To upgrade an existing installation of the Tekton Pipelines chart:

```bash
helm repo update

helm upgrade tekton-pipelines <your-repo>/tekton-pipelines \
  --namespace tekton-pipelines \
  --values overrides.yaml
```

Before upgrading, particularly across major or significant version changes, ensure that no critical `PipelineRuns` or `TaskRuns` are actively executing.

It is also recommended to review custom configuration overrides against the newly released `values.yaml` using tools such as `yq` or `jq`.

## Usage

To install the chart with the release name `tekton-pipelines`:

```bash
# Add the Helm repository
helm repo add tekton-charts <repository-url>
helm repo update

# Install the chart
helm install tekton-pipelines tekton-charts/tekton-pipelines \
  --namespace tekton-pipelines \
  --create-namespace
```

Once deployed, verify that the Tekton controllers are running:

```bash
kubectl get pods -n tekton-pipelines
```

You can also verify the installed Tekton resources:

```bash
kubectl get crd | Select-String tekton
```

### Example Task

The following example uses the stable Tekton API:

```yaml
apiVersion: tekton.dev/v1
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
```

Apply it with:

```bash
kubectl apply -f hello-world.yaml
```

You can then verify the Task:

```bash
kubectl get task hello-world
```

## Version-specific Release Manifest

For reproducible package construction, use the release manifest corresponding specifically to v1.16.0:

```text
https://infra.tekton.dev/tekton-releases/pipeline/previous/v1.16.0/release.yaml
```

For example, on Windows PowerShell:

```powershell
curl.exe -L https://infra.tekton.dev/tekton-releases/pipeline/previous/v1.16.0/release.yaml -o release.yaml
```

Avoid using `pipeline/latest/release.yaml` when building the `tekton-pipelines-1.16.0` package, because `latest` can point to a different release over time.

## References

- [Tekton Pipelines Documentation](https://tekton.dev/docs/pipelines/)
- [Tekton Pipelines GitHub Repository](https://github.com/tektoncd/pipeline)
- [Tekton Tasks Hub](https://hub.tekton.dev/)
