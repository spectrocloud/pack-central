# vSphere No Provisioner

This is a dummy CSI pack for use in vSphere clusters where you don't want to install any CSI. It only installs the vSphere Cloud Provider, which is required to get the cluster initialized.

## Prerequisites

For VMware vSphere clusters only.


## Parameters

You can only specify values for the vSphere Cloud Provider, which typically do not need any changing.

| **Parameter** | **Description** | **Type** | **Default Value** | **Required** |
|---|---|---|---|---|
| k8sVersion | Kubernetes version for selecting the correct vSphere cloud provider image | String | “{{ .spectro.system.kubernetes.version }}” | Yes |
| image | Optional way to override the vSphere cloud provider image | string | "" | Yes |
| extraArgs | Arguments passed to the vSphere cloud provider | List | [ "--cloud-provider=vsphere", "--v=2", "--cloud-config=/etc/cloud/vsphere.conf" ] | Yes |


## Upgrade

N/A


## Usage

Apply this pack to skip installing any CSI in the vSphere cluster.


## References

- [vSphere Cloud Provider](https://github.com/kubernetes/cloud-provider-vsphere)