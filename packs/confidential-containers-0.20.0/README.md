# Confidential Containers

[Confidential Containers](https://confidentialcontainers.org/) (CoCo) is a CNCF Sandbox project that runs Kubernetes pods inside hardware-backed Trusted Execution Environments (TEEs). It builds on [Kata Containers](https://katacontainers.io/) to give each pod a memory-encrypted, attestable virtual machine, so workload code and data stay protected from the host, the cluster operator, and the cloud provider.

This pack deploys the upstream `confidential-containers` umbrella Helm chart (v0.20.0, which bundles Kata Containers **3.29.0**) with default values. The chart is the officially recommended way to install CoCo and replaces the deprecated Confidential Containers operator.

## What this deploys

This is an umbrella chart. With default values it installs:

- **`kata-deploy` DaemonSet** (vendored as the `kata-as-coco-runtime` subchart) — lays down the Kata/CoCo runtime binaries and configures containerd on each node.
- **TEE RuntimeClasses** — `kata-qemu-snp` (AMD SEV-SNP), `kata-qemu-tdx` (Intel TDX), `kata-qemu-coco-dev` (non-TEE dev/test), and the NVIDIA GPU SNP/TDX variants. The default shim is `qemu-snp`.
- Guest-pull image handling via the `nydus` snapshotter, so encrypted images are pulled inside the guest and never exposed to the host.

Peer-pods (cloud-api-adaptor) are included in the chart but **disabled by default** in this pack.

## Prerequisites

- A Kubernetes cluster running version 1.29 or higher with a containerd-based runtime.
- **TEE-capable worker nodes** for the default shims:
  - `kata-qemu-snp` requires AMD EPYC CPUs with SEV-SNP enabled.
  - `kata-qemu-tdx` requires Intel CPUs with TDX enabled.
  - For evaluation on non-TEE hardware, use the `kata-qemu-coco-dev` RuntimeClass, which runs the CoCo software stack without hardware encryption.
- Privileged access on nodes — the DaemonSet mounts host paths and restarts the node's container runtime.

> [!CAUTION]
> Do not run this pack and the standalone `kata-deploy` pack on the same nodes. Both manage the node's containerd configuration and Kata RuntimeClasses and will conflict. Use one or the other per node pool.

## Parameters

Runtime options live under the `kata-as-coco-runtime` key (the bundled kata-deploy subchart). The most commonly adjusted values:

| **Parameter** | **Description** | **Type** | **Default Value** | **Required** |
|---|---|---|---|---|
| `kata-as-coco-runtime.k8sDistribution` | Target distribution: `k8s`, `k3s`, `rke2`, `k0s`, `microk8s`. | String | `k8s` | No |
| `kata-as-coco-runtime.defaultShim.amd64` | Shim used when a pod requests the generic `kata` RuntimeClass. | String | `qemu-snp` | No |
| `kata-as-coco-runtime.shims.<name>.enabled` | Enable/disable individual TEE shims. | Bool | TEE shims on, rest off | No |
| `kata-as-coco-runtime.runtimeClasses.createDefault` | Also create a default `kata` RuntimeClass. | Bool | `false` | No |
| `customContainerd.enabled` | Install a custom containerd binary before runtime deploy (k8s distro only). | Bool | `false` | No |
| `peerpods.enabled` | Enable peer-pods (confidential VMs on clouds without bare-metal TEE). | Bool | `false` | No |

## Upgrade

- Upgrades are applied by re-running the chart; the kata-deploy DaemonSet rolls out the new runtime artifacts node by node.
- This chart version pins Kata Containers 3.29.0. Review the [CoCo release notes](https://github.com/confidential-containers/charts/releases/tag/0.20.0) before upgrading across minor versions, as enabled shims and runtime class names can change.

## Usage

- After deployment, list the TEE RuntimeClasses the pack created:

  ```shell
  kubectl get runtimeclass
  ```

- Schedule a confidential workload by setting `runtimeClassName` on the pod. For AMD SEV-SNP:

  ```yaml
  apiVersion: v1
  kind: Pod
  metadata:
    name: coco-example
  spec:
    runtimeClassName: kata-qemu-snp
    containers:
      - name: app
        image: nginx:stable
  ```

- For end-to-end attestation you also need a Key Broker Service / Trustee (KBS). The KBS is **not** part of this chart — deploy it separately and point the guest's attestation agent at it.

## References

- [Confidential Containers documentation](https://confidentialcontainers.org/docs/)
- [confidential-containers/charts (v0.20.0)](https://github.com/confidential-containers/charts)
- [Trustee / Key Broker Service](https://github.com/confidential-containers/trustee)
- [Kata Containers documentation](https://katacontainers.io/docs/)
