# NVIDIA DPF Deployment

This pack installs the Nvidia DPF custom resources for DPF in Host-Trusted mode.

## Prerequisites

This pack should be used in conjunction with the Nvidia DPF Operator v25.7.0 pack. If you're deploying DPF clusters in Host-Trusted mode, you also need to combine this with the Nvidia OVN Kubernetes v25.7.0 CNI.

## Parameters

### dpf-operator-config
| **Parameter** | **Type** | **Default Value** | **Description** |
|---|---|---|---|
| bfb.url | string | `"https://content.mellanox.com/BlueField/BFBs/Ubuntu22.04/bf-bundle-3.1.0-76_25.07_ubuntu-22.04_prod.bfb"` |  |
| dpuServiceConfigurations | list | Configs for `blueman`, `dts`, `ovn` and `hbn` | Service configurations for DPU apps |
| dpuDeployments | list | Config for `ovn-hbn` | Deployment configurations of DPU apps |
| dpuServiceTemplates | list | Helm templates for `blueman`, `dts`, `ovn` and `hbn` | Service templates for DPU apps |
| dpuServiceInterfaces | list | Configs for ports `p0`, `p1` and `ovn` | Service interfaces for DPU apps |
| dpuServiceCredentialRequests | list | Config `ovn-hbn` | Service credential requests for DPU apps |
| dpuServiceIPAMs | list | IPAM configs for `asn`, `loopback` and `pool1` | Service IPAMs for DPU apps |


## Upgrade

This is the first version of the Nvidia DPF Deployment pack. There are no previous versions to upgrade from.


## Usage

The deploy this pack for Host-Trusted mode clusters, first configure the parameters mentioned above. Then deploy just the Control Plane of your cluster and make sure the `ovn-kubernetes-resource-injector.enabled` setting in the Nvidia OVN Kubernetes CNI pack is set to `false`. Then deploy the DPF Framework to the cluster (Spectro Cloud provides a reference profile for this that aligns to the [HBN-OVN guidance from Nvidia](https://github.com/NVIDIA/doca-platform/blob/v25.7.0/docs/public/user-guides/host-trusted/use-cases/hbn-ovnk/README.md)).

Once the DPF Framework is deployed, change the `ovn-kubernetes-resource-injector.enabled` setting to `true` and add worker nodes containing Bluefield-3 DPUs in Host-Trusted mode. It will take between 20 and 40 minutes for the DPF Framework to flash the DPUs, reboot the nodes and configure them appropriately. After that, the nodes should become Healthy in Spectro Cloud Palette and ready for workloads.


## References

- [Nvidia DOCA Platform Guidance 25.7.0](https://github.com/NVIDIA/doca-platform/blob/v25.7.0/docs/public/user-guides/host-trusted/use-cases/hbn-ovnk/README.md)