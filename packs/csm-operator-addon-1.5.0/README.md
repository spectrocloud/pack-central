# Description
Dell Technologies Container Storage Modules (CSM) Operator is an open-source Kubernetes operator which can be used to install and manage various CSI Drivers and CSM Modules.

CSI capabilities per driver can be found [here](https://dell.github.io/csm-docs/docs/csidriver/)
Supported components can be found [here](https://dell.github.io/csm-docs/docs/deployment/csmoperator/#supported-csm-components)


# Kubernetes versions supported:
Above 1.26

# Constraints:
Support for PowerFlex, PowerMax and PowerStore is available.
Support for PowerScale and UnityXT is not available at this time.

Please see [here](https://dell.github.io/csm-docs/docs/deployment/csmoperator/drivers/) for installation prereqs. For PowerFlex, PowerMax and PowerStore you typically need to install either the ScaleIO driver (PowerFlex) and/or Multipath, as well as iSCSI packages if iSCSI is used. The Dell page linked above contains information on these prereqs, which will need to be added to the OS layer in the cluster profile.

# Cloud types supported:
This pack was designed to be used with clusters on Canonical MAAS

### Usage

Dell Container Storage Modules Operator is a Kubernetes native application which helps in installing and managing CSI Drivers and CSM Modules provided by Dell Technologies for its various storage platforms. Dell Container Storage Modules Operator uses Kubernetes CRDs (Custom Resource Definitions) to define a manifest that describes the deployment specifications for each driver to be deployed.

To create a `StorageClasses` by default storageclass is `true` and it creates the storageclass `vxflexos` for `powerflex-v2100`, `powermax` for `powermax-v2100` & `powerstore` for `powerstore-v2100`.


:::tip

Check out the [Palette Backup and Restore Documentation](https://docs.spectrocloud.com/clusters/cluster-management/backup-restore/) to learn how to backup and restore your cluster.

::::

### CSM Snapshot Controller Creation

The Dell Container Storage Modules Operator pack supports snapshot controller creation. In the **presets.yaml**, modify the parameter`charts.csm-operator.snapshot-controller.enabled` to enable the controller snapshotter for `powerflex-v2100`, `powermax-v2100` &  `powerstore-v2100`. By default it is `true`.

### CSM Volume Snapshot Creation

The Dell Container Storage Modules Operator pack supports snapshot volume creation. In the **presets.yaml**, modify the parameter`charts.csm-operator.snapshot-controller.volumeSnapshotClass.create` to enable the volume snapshotter for `powerflex-v2100`, `powermax-v2100` &  `powerstore-v2100`. By default it is `true` for `powerflex-v2100` &  `powerstore-v2100`. By default it is `false` for `powermax-v2100`

### CSM Webhook Snapshot Creation

The Dell Container Storage Modules Operator pack supports snapshot volume creation. In the **presets.yaml**, modify the parameter`charts.csm-operator.snapshot-controller.webhook.enable` to enable the volume snapshotter for `powerflex-v2100`, `powermax-v2100` &  `powerstore-v2100`. By default it is `true` for `powerflex-v2100`, `powermax-v2100` &  `powerstore-v2100`. 


# References:

- [GITHUB](https://github.com/dell/csm-operator)

- [Palette Backup and Restore Documentation](https://docs.spectrocloud.com/clusters/cluster-management/backup-restore/)
