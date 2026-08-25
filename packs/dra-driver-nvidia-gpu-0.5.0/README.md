# NVIDIA DRA Driver for GPUs

The [DRA Driver for NVIDIA GPUs](https://github.com/kubernetes-sigs/dra-driver-nvidia-gpu) enables Dynamic Resource Allocation (DRA) for GPUs in Kubernetes. This pack works with Palette to provide flexible GPU allocation using DeviceClass and ResourceClaim resources, replacing the traditional device plugin approach with a modern, CEL-based device selection mechanism.


## Prerequisites

- Kubernetes 1.34.2 or newer
- [NVIDIA GPU Operator](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/index.html) 26.3.3 or newer for driver management and CDI support.
- CDI enabled in the container runtime (containerd/CRI-O) (GPU Operator v26.3.3 does this by default)
- [Node Feature Discovery](https://kubernetes-sigs.github.io/node-feature-discovery) (NFD) for GPU detection. Comes with the GPU Operator.
- [GPU Feature Discovery](https://github.com/NVIDIA/gpu-feature-discovery) (NFD) for GPU detection. Comes with the GPU Operator.


## Parameters

To deploy the NVIDIA DRA Driver, you can configure the following parameters in the pack's YAML.

| **Name** | **Description** | **Type** | **Default Value** | **Required** |
|---|---|---|---|---|
| `nvidiaDriverRoot` | Path to NVIDIA driver installation. Use `/run/nvidia/driver` with GPU Operator, `/` for host-installed drivers. | String | `/run/nvidia/driver` | No |
| `resources.gpus.enabled` | Enable GPU allocation via DRA. | Boolean | `true` | No |
| `resources.computeDomains.enabled` | Enable ComputeDomains for Multi-Node NVLink (MNNVL) on GB200 systems. | Boolean | `false` | No |
| `image.tag` | DRA driver image tag. | String | `v25.8.1` | No |
| `logVerbosity` | Log verbosity level (0-7, higher = more verbose). | String | `4` | No |
| `webhook.enabled` | Enable admission webhook for advanced validation. | Boolean | `false` | No |

Refer to the [DRA Driver for NVIDIA GPUs Documentation](https://dra-driver-nvidia-gpu.sigs.k8s.io/docs/) for the complete list of configurable parameters.


## Upgrade

The previous pack was the NVIDIA DRA Driver v25.8.1, which was before NVIDIA donated the chart to the CNCF. This pack replaces the original one with a new CNCF-owned chart. This chart has a new name, so a direct upgrade is not possible. Uninstall the old pack from the cluster first and then install this pack.


## Usage

To use the NVIDIA DRA Driver pack, first create a new [add-on cluster profile](https://docs.spectrocloud.com/profiles/cluster-profiles/create-cluster-profiles/create-addon-profile/), search for the **DRA Driver for NVIDIA GPUs** pack, and verify the driver root path based on your environment:

```yaml
charts:
  nvidia-dra-driver-gpu:
    nvidiaDriverRoot: /run/nvidia/driver  # Use "/" if drivers installed on host
```

After installation, the DRA driver creates:
- A default `DeviceClass` named `gpu.nvidia.com`
- `ResourceSlice` objects representing available GPUs on each node

To request a GPU for your workload, create a ResourceClaimTemplate and reference it in your Pod. Click on the **Add Manifest** button to create a new manifest layer with the following content:

```yaml
apiVersion: resource.k8s.io/v1
kind: ResourceClaimTemplate
metadata:
  name: gpu-claim
spec:
  spec:
    devices:
      requests:
        - name: gpu
          deviceClassName: gpu.nvidia.com
---
apiVersion: v1
kind: Pod
metadata:
  name: gpu-pod
spec:
  containers:
    - name: cuda
      image: nvidia/cuda:12.0-base
      resources:
        claims:
          - name: gpu
  resourceClaims:
    - name: gpu
      resourceClaimTemplateName: gpu-claim
```

Once you have configured the NVIDIA DRA Driver pack, you can add it to an existing cluster profile, as an add-on profile, or as a new add-on layer to a deployed cluster.


## References

- [DRA Driver for NVIDIA GPUs Documentation](https://dra-driver-nvidia-gpu.sigs.k8s.io/docs/)
- [Kubernetes DRA Documentation](https://kubernetes.io/docs/concepts/scheduling-eviction/dynamic-resource-allocation/)
- [DRA Driver for NVIDIA GPUs o Github](https://github.com/kubernetes-sigs/dra-driver-nvidia-gpu)
- [NVIDIA GPU Operator Documentation](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/index.html)
