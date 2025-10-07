# NVIDIA DPF Prereqs for DPF Operator

This pack installs the prerequirements for the Nvidia DPF Operator v25.7.0. In this version of the DPF Operator, the prerequired software components are no longer included, hence a separate pack is needed.

## Prerequisites

This pack should be used in conjunction with the Nvidia DPF Operator v25.7.0 pack (or Helm chart). If you're deploying DPF clusters in Host-Trusted mode, you also need to combine this with the Nvidia OVN Kubernetes v25.7.0 CNI.

## Parameters

| **Parameter** | **Description** | **Type** | **Default Value** | **Required** |
|---|---|---|---|---|
| node-feature-discovery.worker.extraEnvs.value for "KUBERNETES_SERVICE_HOST" | IP address or FQDN of Kubernetes API server | String | "1.2.3.4" | Yes |
| node-feature-discovery.worker.extraEnvs.value for "KUBERNETES_SERVICE_PORT" | IP address or FQDN of Kubernetes API server | String | "6443" | Yes |


## Upgrade

This is the first version of the Nvidia DPF Prereqs pack. There are no previous versions to upgrade from.


## Usage

The deploy this pack for Host-Trusted mode clusters, first configure the parameters mentioned above. Then deploy just the Control Plane of your cluster and make sure the `ovn-kubernetes-resource-injector.enabled` setting in the Nvidia OVN Kubernetes CNI pack is set to `false`. Then deploy the DPF Framework to the cluster (Spectro Cloud provides a reference profile for this that aligns to the [HBN-OVN guidance from Nvidia](https://github.com/NVIDIA/doca-platform/blob/v25.7.0/docs/public/user-guides/host-trusted/use-cases/hbn-ovnk/README.md)).

Once the DPF Framework is deployed, change the `ovn-kubernetes-resource-injector.enabled` setting to `true` and add worker nodes containing Bluefield-3 DPUs in Host-Trusted mode. It will take between 20 and 40 minutes for the DPF Framework to flash the DPUs, reboot the nodes and configure them appropriately. After that, the nodes should become Healthy in Spectro Cloud Palette and ready for workloads.


## References

- [Nvidia DOCA Platform Guidance 25.7.0](https://github.com/NVIDIA/doca-platform/blob/v25.7.0/docs/public/user-guides/host-trusted/use-cases/hbn-ovnk/README.md)