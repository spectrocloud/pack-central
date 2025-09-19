# NVIDIA OVN Kubernetes CNI

Nvidia's fork of the OVN Kubernetes CNI, designed for use with Bluefield-3 DPUs in Host-Trusted mode.

## Prerequisites

This CNI should only be used in conjunction with Bluefield-3 DPUs for north-south traffic. The DPUs need to be in Host-Trusted mode, do not use this CNI for the Zero Trust mode. You also need to deploy the DPF Framework as part of the cluster, which takes care of DPU provisioning.

## Parameters

You can use a table to list parameters with a **Parameter** and a **Description** column. Additionally, include a **Type** column to specify the parameter's type and a **Default Value** column for the parameter's default values. Last, you can include a **Required** column to indicate that the user must provide a value for it.

| **Parameter** | **Description** | **Type** | **Default Value** | **Required** |
|---|---|---|---|---|
| ovn-kubernetes-resource-injector.enabled | Controls if VFs from the DPU should be injected into any new pod created. Should only be enabled after the DPF control plane is fully deployed. | Boolean | false | Yes |
| nodeWithDPUManifests.nodeMgmtPortNetdev | Should be set to the second VF of the first port of the DPU. | String | "ens1f0v1" | Yes |
| k8sAPIServer | Endpoint of Kubernetes API server | String | "https://172.25.0.2:6443" | Yes |
| podNetwork | IP range for Kubernetes pods, /14 is the top level range, under which each /23 range will be assigned to a node | String | "10.244.0.0/16/24" | Yes |
| serviceNetwork | A comma-separated set of CIDR notation IP ranges from which k8s assigns service cluster IPs. This should be the same as the value provided for kube-apiserver "--service-cluster-ip-range" option | String | "10.96.0.0/12" | Yes |
| gatewayOpts | Options related to setting up the gateway. Applies to all relevant manifests. | String | "--gateway-interface=ens1f0np0" | Yes |
| mtu | MTU of network interface in a Kubernetes pod | Integer | 1400 | Yes |


## Upgrade

This is the first version of the Nvidia OVN Kubernetes CNI pack. There are no previous versions to upgrade from.


## Usage

The deploy this CNI, first configure the parameters mentioned above. Then deploy just the Control Plane of your cluster and make sure the `ovn-kubernetes-resource-injector.enabled` setting is set to `false`. Then deploy the DPF Framework to the cluster (Spectro Cloud provides a reference profile for this that aligns to the [HBN-OVN guidance from Nvidia](https://github.com/NVIDIA/doca-platform/blob/v25.4.0/docs/public/user-guides/hbn_ovn/README.md)).

Once the DPF Framework is deployed, change the `ovn-kubernetes-resource-injector.enabled` setting to `true` and add worker nodes containing Bluefield-3 DPUs in Host-Trusted mode. It will take between 20 and 40 minutes for the DPF Framework to flash the DPUs, reboot the nodes and configure them appropriately. After that, the nodes should become Healthy in Spectro Cloud Palette and ready for workloads.


## References

- [Nvidia DOCA Platform Guidance 25.4.0](https://github.com/NVIDIA/doca-platform/blob/v25.4.0/docs/public/user-guides/hbn_ovn/README.md)