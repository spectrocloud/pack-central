# Kubevirt CSI driver Infra add-on

The Kubevirt CSI driver is made for a guest cluster deployed on top of Spectro Cloud Palette VMO, and enables it to provision Persistent Volumes from the host VMO cluster. This CSI driver is deployed on the guest cluster. It will contact the host VMO cluster to orchestrate the hot-plugging of disks to VMs running the guest cluster, which will appear as PVCs inside Kubernetes.

![image](https://github.com/kubevirt/csi-driver/raw/main/docs/high-level-diagram.svg)

This pack deploys the components in the host VMO cluster.

## Prerequisites

- A host Palette VMO cluster.
- A guest Kubernetes cluster deployed with VMO VMs, using Palette Agent Mode.
- Palette Agent mode must be configured to set the hostname of the OS to match the name of the VM.


## Parameters

To deploy the Kubevirt CSI Driver Infra add-on pack, you need to set, at minimum, the following parameters in the pack's YAML.

| Name | Description | Type | Default Value | Required |
| --- | --- | --- | --- | --- |
| `deployment.namespaces` | Namespaces in which to deploy the Kubevirt CSI service account on the host VMO cluster. Kubernetes clusters on VMs in these namespaces will be able to use the Kubevirt CSI Driver | Array of strings | `[default, virtual-machines]` | Yes

A service account, secret, role and rolebinding will be deployed to each namespace listed. The token of each service account will be needed by the Kubevirt CSI Driver pack for each respective namespace.

## Upgrade

To update the Kubevirt CSI Driver Infra add-on, deploy a newer version of the pack.


## Usage

To use the Kubevirt CSI Driver Infra add-on pack, we recommend adding it to the VMO Core cluster profile. Open this cluster profile, click "Add new pack" and search for the **Kubevirt CSI Driver Infra add-on** pack in the Palete Community Registry. Then configure the namespaces to be enabled for the Kubevirt CSI Driver in the pack YAML:

```yaml
charts:
  kubevirt-csi-driver-infra:
    deployment:
      model: tenant
      namespaces:
        - default
        - virtual-machines
```

Once you have configured the pack, you can deploy the changes to your VMO cluster.

## References

- [Kubevirt CSI driver Github](https://github.com/kubevirt/csi-driver)