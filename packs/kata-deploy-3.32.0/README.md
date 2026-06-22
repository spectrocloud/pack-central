# Kata Containers

[Kata Containers](https://katacontainers.io/) is an open-source project that delivers a secure container runtime with lightweight virtual machines. Each container (or pod) runs inside its own hardware-virtualized guest, providing the workload isolation and security advantages of VMs with the speed and integration of containers.

This pack deploys Kata Containers onto your cluster nodes using the upstream `kata-deploy` Helm chart. By default it runs the `kata-deploy` DaemonSet, which installs the Kata runtime binaries and configures the container runtime (containerd) on every worker node, and creates the `RuntimeClass` resources used to schedule sandboxed pods.

## Prerequisites

- A Kubernetes cluster running version 1.29 or higher.
- Worker nodes running a containerd-based runtime (`k8sDistribution` defaults to `k8s`; set it to `k3s`, `rke2`, `k0s`, or `microk8s` to match your distribution).
- Nodes with hardware virtualization support (Intel VT-x / AMD-V) for the default QEMU-based shims. Bare-metal nodes or VMs with nested virtualization enabled are required.
- Privileged access on nodes — the `kata-deploy` DaemonSet mounts host paths and restarts the node's container runtime to register the Kata runtimes.

## Parameters

The pack ships the upstream chart's default values. The most commonly adjusted parameters are listed below.

| **Parameter** | **Description** | **Type** | **Default Value** | **Required** |
|---|---|---|---|---|
| `deploymentMode` | Install model: long-running `daemonset` or one-shot `job` dispatcher. | String | `daemonset` | No |
| `k8sDistribution` | Target distribution, controls containerd config paths (`k8s`, `k3s`, `rke2`, `k0s`, `microk8s`). | String | `k8s` | No |
| `nodeSelector` | Restrict which nodes Kata is installed on (e.g. `kata-containers: "enabled"`). | Map | `{}` | No |
| `shims.disableAll` | Disable all shims, then enable specific ones individually. | Bool | `false` | No |
| `defaultShim` | Default shim per architecture. | Map | `qemu` for all arches | No |
| `runtimeClasses.createDefault` | Create a default `kata` RuntimeClass in addition to the per-shim ones. | Bool | `false` | No |
| `monitor.enabled` | Deploy the `kata-monitor` DaemonSet for metrics. | Bool | `false` | No |
| `node-feature-discovery.enabled` | Manage NFD as a subchart and enforce virtualization checks. | Bool | `false` | No |

## Upgrade

- Upgrades are applied by re-running the chart. In `daemonset` mode the DaemonSet rolls out the new runtime artifacts node by node (default strategy `RollingUpdate`, `maxUnavailable: 1`).
- When using `deploymentMode: job` and adding new nodes later, re-run the upgrade so the dispatcher enumerates and installs Kata on the new nodes — the staged install actions are idempotent.

> [!CAUTION]
> Changing the runtime configuration restarts the node's container runtime (containerd), which briefly disrupts pods on that node. Roll out during a maintenance window on production clusters.

## Usage

- After the pack is deployed, confirm the runtime is registered by listing the RuntimeClasses created by the pack:

  ```shell
  kubectl get runtimeclass
  ```

- Schedule a workload onto the Kata runtime by setting `runtimeClassName` on the pod spec. For the default QEMU shim:

  ```yaml
  apiVersion: v1
  kind: Pod
  metadata:
    name: kata-example
  spec:
    runtimeClassName: kata-qemu
    containers:
      - name: nginx
        image: nginx:stable
  ```

- To install Kata on a subset of nodes only, label the target nodes and set `nodeSelector` (for example `nodeSelector: { kata-containers: "enabled" }`).

## References

- [Kata Containers documentation](https://katacontainers.io/docs/)
- [kata-deploy chart and source (v3.32.0)](https://github.com/kata-containers/kata-containers/tree/3.32.0/tools/packaging/kata-deploy)
- [Kata Containers RuntimeClass usage](https://github.com/kata-containers/kata-containers/blob/main/docs/install/README.md)
