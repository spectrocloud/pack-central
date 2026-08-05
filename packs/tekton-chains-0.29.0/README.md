# Tekton Chains Helm Chart

Tekton Chains is a Kubernetes controller designed for supply chain security and management in Tekton. This project observes the execution of `TaskRuns` and `PipelineRuns`, extracts their provenance, signs it, and stores it securely (e.g., as in-toto attestations or OCI signatures).

This file describes the usage of the Helm chart to deploy Tekton Chains.

## Prerequisites

Before installing this chart, ensure your cluster meets the following requirements:

*   **Kubernetes:** Version 1.29 or higher.
*   **Helm:** Version 3.0+.
*   **Tekton Pipelines:** Tekton Pipelines must be previously installed on the cluster.
*   **Signing Tool:** Optionally, have `cosign` installed on your local machine to generate the cryptographic key pair.

## Parameters

The following table lists the most common configuration parameters that you can adjust in the `values.yaml` file or via `--set` during installation:

| Parameter | Description | Default Value |
| :--- | :--- | :--- |
| `replicaCount` | Number of replicas for the Chains controller. | `1` |
| `image.repository` | Repository for the Chains controller image. | `gcr.io/tekton-releases/github.com/tektoncd/chains/cmd/controller` |
| `image.tag` | Image tag (version) to use. | `latest` |
| `serviceAccount.create` | Whether to create the ServiceAccount for the controller. | `true` |
| `config.artifacts.taskrun.format`| Generated attestation format (e.g., `in-toto`, `slsa/v1`). | `in-toto` |
| `config.artifacts.taskrun.storage`| Storage backend (e.g., `tekton`, `oci`, `gcs`). | `tekton` |
| `config.transparency.enabled` | Enables signature registration in a transparency log (e.g., Rekor).| `false` |

## Upgrade

To upgrade an existing Tekton Chains installation to a new version, run the following command with Helm, ensuring you use your custom values:

```bash
helm upgrade tekton-chains ./tekton-chains \
  --namespace tekton-chains \
  --values your-values.yaml
```

*Note:* Always check the release notes in the official repository to identify if there are any incompatible changes in the configuration `ConfigMaps` before applying the upgrade.

## Usage

**1. Install the Chart:**

To deploy Tekton Chains in your cluster within the `tekton-chains` namespace, run:

```bash
helm install tekton-chains ./tekton-chains \
  --namespace tekton-chains \
  --create-namespace
```

**2. Configure signing keys:**

Once the controller is running, you need to provide it with a cryptographic key pair so it can sign the artifacts. Using `cosign`:

```bash
# Generate the keys and store them directly as a secret in Kubernetes
cosign generate-key-pair k8s://tekton-chains/signing-secrets
```

**3. Verify the status:**

Ensure the pods have initialized correctly:

```bash
kubectl get pods -n tekton-chains --watch
```

From this point forward, Tekton Chains will automatically intercept successful `TaskRuns` and `PipelineRuns` to generate the attestation and sign them according to the configuration defined in your cluster.

## References

*   [Tekton Chains GitHub Repository](https://github.com/tektoncd/chains)
*   [Tekton Pipelines Documentation](https://tekton.dev/docs/pipelines/)
*   [Cosign and Sigstore Guide](https://docs.sigstore.dev/cosign/overview/)
*   [SLSA Specification (Supply-chain Levels for Software Artifacts)](https://slsa.dev/)
