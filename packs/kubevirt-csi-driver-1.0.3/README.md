# Kubevirt CSI driver

The Kubevirt CSI driver is made for a guest cluster deployed on top of Spectro Cloud Palette VMO, and enables it to provision Persistent Volumes from the host VMO cluster. This CSI driver is deployed on the guest cluster. It will contact the host VMO cluster to orchestrate the hot-plugging of disks to VMs running the guest cluster, which will appear as PVCs inside Kubernetes.

![image](https://github.com/kubevirt/csi-driver/raw/main/docs/high-level-diagram.svg)


## Prerequisites

- A host Palette VMO cluster.
- A guest Kubernetes cluster deployed with VMO VMs, using Palette Agent Mode.
- Palette Agent mode must be configured to set the hostname of the OS to match the name of the VM (using the `NAME` tag, see Usage section).


## Parameters

To deploy the Kubevirt CSI Driver pack, you need to set at least the following parameters in the pack's YAML.

| Name | Description | Type | Default Value | Required |
| --- | --- | --- | --- | --- |
| `deployment.driver.infraClusterNamespace` | The namespace in the host VMO cluster in which the VMs for this guest cluster run | String | virtual-machines | Yes |
| `deployment.infraClusterKubeconfig.k8sAPIendpoint` | The Kubernetes API endpoint of the host VMO cluster | String | `https://vmo-cluster.company.local:6443` | Yes |
| `deployment.infraClusterKubeconfig.token` | Base64-encoded token from the kubevirt-csi-secret secret in the namespace where the VMs are running in the host VMO cluster | String | - | Yes |
| `storageClasses[*].infraStorageClassName` | Name of the storageclass in the host VMO cluster that this storageclass should link to | String | spectro-storage-class | Yes |


Review the [README](https://github.com/kubevirt/csi-driver/blob/main/README.md) for more details. 

## Upgrade

To update the Kubevirt CSI Driver, deploy a newer version of the pack.


## Usage

To use the Kubevirt CSI Driver pack, first create a new [add-on cluster profile](https://docs.spectrocloud.com/profiles/cluster-profiles/create-cluster-profiles/create-addon-profile/), Click "Add New Pack" and search for the **Kubevirt CSI Driver** pack in the Palete Community Registry.

Then we need to configure the sections in the pack YAML:
* The `deployment.driver.infraClusterNamespace` parameter needs to match the namespace in the host VMO cluster that the VMs of the guest cluster will be running in.
* The `deployment.infraClusterKubeconfig` section requires preparation on the host VMO cluster. The administrator of the host VMO cluster needs to first deploy the "Kubevirt CSI Driver Infra add-on" pack to the host VMO cluster. In that pack, the namespace you want to use in this pack needs to be included.
* The `deployment.infraClusterKubeconfig.k8sAPIendpoint` parameter can be retrieved from the "Overview" tab of the host VMO cluster in Palette. Use the value of the "Kubernetes API" field on that tab.
* The `deployment.infraClusterKubeconfig.token` parameter can be retrieved by the administrator of the host VMO cluster after applying the "Kubevirt CSI Driver Infra add-on" pack to the host VMO cluster. The administrator can run the following command to retrieve the token:
```bash
kubectl get secret kubevirt-csi-secret -n <namespace> -o json | jq .data.token
```
* The output of the command will be a base64-encoded string. Put that string as-is into the `deployment.infraClusterKubeconfig.token` parameter.
* Finally, review the `deployment.storageClasses` section. Typically, the host VMO cluster will have 1 storageclass for virtual machines and the name of that storageclass depends on the type of storage used in the VMO cluster. The administrator of the host VMO cluster can provide the correct name for this storageclass. Enter that name in the `parameters.infraStorageClassName` section of the example "kubevirt" storageclass.

### VM deployment
Once you have configured the pack, you can deploy it to a cluster. Note that you must use Palette Agent-mode clusters for this, and use specific preparation to set up the Agent-mode VMs. The hostname in the OS of each VM must match the name of the VM inside VMO. In order to automate this, we can set the `name` tag during registration of the VM. The following userdata for the VM can be used to automatically configure and register the VM with Palette as an agent-mode edge host, including the correct `name` tag:
```
#cloud-config
ssh_pwauth: True
chpasswd: { expire: False }
password: spectro
disable_root: false
packages:
  - jq
  - conntrack
write_files:
  - path: /tmp/user-data
    owner: 'root:root'
    permissions: '0755'
    content: |
      #cloud-config
      install:
        reboot: true
        poweroff: false
      stylus:
        site:
          edgeHostToken: [registration token here]
          paletteEndpoint: api.console.spectrocloud.com
          tags:
            name: %NAME%
runcmd:
  - |
    mkdir -p /system/oem; mkdir -p /oem; mkdir -p /usr/local/cloud-config; mkdir -p /opt/spectrocloud/state
    curl --location --output /tmp/palette-agent-install.sh https://github.com/spectrocloud/agent-mode/releases/latest/download/palette-agent-install.sh
    chmod +x /tmp/palette-agent-install.sh
    export USERDATA=/tmp/user-data
    sed -i "s/%NAME%/$(hostname)/" /tmp/user-data
    sudo --preserve-env /tmp/palette-agent-install.sh
```

### Snapshot support
In order to use this CSI for snapshots, the following `VolumeSnapshotClass` can be created (manually, not part of this pack), through deploying the Volume Snapshot Controller pack:
```
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshotClass
metadata:
  name: kubevirt-csi-snapclass
driver: csi.kubevirt.io
deletionPolicy: Delete
```

In the default pack configuration, the VolumeSnapshotClass in the guest cluster will be mapped to the default VolumeSnapshotClass in the host VMO cluster (assuming that VolumeSnapshotClass in the host VMO cluster contains the `snapshot.storage.kubernetes.io/is-default-class: "true"` annotation). If there is no default VolumeSnapshotClass in the host VMO cluster, or if multiple exist, a mapping can be configured in the `deployment.driver.infraStorageClassEnforcement` section of the pack. Review the information [here](https://github.com/kubevirt/csi-driver/blob/main/docs/snapshot-driver-config.md) on how to map VolumeSnapshotClasses to those in the host VMO cluster.

## References

- [Kubevirt CSI driver Github](https://github.com/kubevirt/csi-driver)
- [Storage classes and Snapshot classes mapping](https://github.com/kubevirt/csi-driver/blob/main/docs/snapshot-driver-config.md)