# NVIDIA DRA Driver for GPUs

The [NVIDIA DRA Driver](https://github.com/NVIDIA/k8s-dra-driver-gpu) enables Dynamic Resource Allocation (DRA) for GPUs in Kubernetes 1.32+. This pack works with Palette to provide flexible GPU allocation using DeviceClass and ResourceClaim resources, replacing the traditional device plugin approach with a modern, CEL-based device selection mechanism.


## Prerequisites

- Kubernetes 1.32 or newer (DRA is GA in 1.34+).
- [NVIDIA GPU Operator](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/index.html) 25.3.0+ for driver management and CDI support.
- CDI enabled in the container runtime (containerd/CRI-O).
- [Node Feature Discovery](https://kubernetes-sigs.github.io/node-feature-discovery/) (NFD) for GPU detection.


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

Refer to the [NVIDIA DRA Driver Helm chart](https://github.com/NVIDIA/k8s-dra-driver-gpu) for the complete list of configurable parameters.


## Upgrade

N/A - This is the initial release of the NVIDIA DRA Driver pack.


## Usage

To use the NVIDIA DRA Driver pack, first create a new [add-on cluster profile](https://docs.spectrocloud.com/profiles/cluster-profiles/create-cluster-profiles/create-addon-profile/), search for the **NVIDIA DRA Driver for GPUs** pack, and configure the driver root path based on your environment:

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

- [NVIDIA DRA Driver Documentation](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/dra-intro-install.html)
- [Kubernetes DRA Documentation](https://kubernetes.io/docs/concepts/scheduling-eviction/dynamic-resource-allocation/)
- [NVIDIA DRA Driver on GitHub](https://github.com/NVIDIA/k8s-dra-driver-gpu)
- [NVIDIA GPU Operator Documentation](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/index.html)
