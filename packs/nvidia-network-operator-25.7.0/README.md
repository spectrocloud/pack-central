# NVIDIA Network Operator

The Nvidia Network Operator pack installs and manages the lifecycle of Nvidia Network Operator. It's a versatile operator that can facilitate many different networking scenarios. Nvidia Network Operator
leverages [Kubernetes CRDs](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/)
and [Operator SDK](https://github.com/operator-framework/operator-sdk) to manage Networking related Components in order
to enable Fast networking, RDMA and GPUDirect for workloads in a Kubernetes cluster. Network Operator works in
conjunction with [GPU-Operator](https://github.com/NVIDIA/gpu-operator) to enable GPU-Direct RDMA on compatible systems.

The Goal of Network Operator is to manage _all_ networking related components to enable execution of RDMA and GPUDirect
RDMA workloads in a kubernetes cluster including:

* Mellanox Networking drivers to enable advanced features
* Kubernetes device plugins to provide hardware resources for fast network
* Kubernetes secondary network for Network intensive workloads


## Prerequisites

* RDMA capable hardware: Mellanox ConnectX-5 NIC or newer.
* NVIDIA GPU and driver supporting GPUDirect e.g Quadro RTX 6000/8000 or newer.
  (GPU-Direct only)
* Operating Systems: Ubuntu 20.04 LTS or newer.

> __NOTE__: ConnectX-6 Lx is not supported.


## Parameters

### dpf-operator-config
| **Parameter** | **Type** | **Default Value** | **Description** |
|---|---|---|---|
| nfd.enabled | bool | `true` | Deploy Node Feature Discovery operator |
| nfd.deployNodeFeatureRules | bool | `true` | | Deploy Node Feature Rules to label the nodes with the discovered features |
| upgradeCRDs | bool | `true` | Enable CRDs upgrade with helm pre-install and pre-upgrade hooks |
| sriovNetworkOperator.enabled | bool | `false` | Deploy SR-IOV Network Operator |
| nicConfigurationOperator.enabled | bool | `false` | Deploy NIC Configuration Operator (deprecated) |
| maintenanceOperator.enabled | bool | `false` | Deploy Maintenance Operator |
| node-feature-discovery.enableNodeFeatureApi | bool | `true` | The Node Feature API enable communication between nfd master and worker through NodeFeature CRs. Otherwise communication is through gRPC |
| node-feature-discovery.featureGates.NodeFeatureAPI | bool | `true` |  |
| node-feature-discovery.image.repository | bool | `"nvcr.io/nvidia/mellanox/node-feature-discovery"` |  |
| node-feature-discovery.image.tag | bool | `"network-operator-v25.7.0"` |  |
| node-feature-discovery.image.pullPolicy | bool | `"IfNotPresent"` |  |
| node-feature-discovery.imagePullSecrets | list | `[]` | imagePullSecrets for node-feature-discovery Network Operator related images |
| node-feature-discovery.master.serviceAccount.name | string | `"node-feature-discovery"` |  |
| node-feature-discovery.master.serviceAccount.create | bool | `true` |  |
| node-feature-discovery.master.config.extraLabelNs | list | `["nvidia.com"]` |  |
| node-feature-discovery.gc.enable | bool | `true` | Specifies whether the NFD Garbage Collector should be created |
| node-feature-discovery.gc.replicaCount | int | `1` | Specifies the number of replicas for the NFD Garbage Collector |
| node-feature-discovery.gc.serviceAccount.name | string | `"node-feature-discovery"` | The name of the service account for garbage collector to use. If not set and create is true, a name is generated using the fullname template and -gc suffix |
| node-feature-discovery.gc.serviceAccount.create | bool | `false` |  |
| node-feature-discovery.worker.serviceAccount.name | string | `"node-feature-discovery"` |  |
| node-feature-discovery.worker.serviceAccount.create | bool | `false` | Disable creation to avoid duplicate serviceaccount creation by master spec above |
| node-feature-discovery.worker.serviceAccount.tolerations | list | Tolerations for control plane taints and `nvidia.com/gpu:NoSchedule` |  |
| node-feature-discovery.worker.serviceAccount.config.sources.pci.deviceClassWhitelist | list | `["0300","0302"]` |  |
| node-feature-discovery.worker.serviceAccount.config.sources.pci.deviceLabelFields | list | `["vendor"]` |  |
| sriov-network-operator.cniBinPath | string | `"/opt/cni/bin"` | Directory where SRIOV CNI binaries will be deployed on the node |
| sriov-network-operator.operator.resourcePrefix | string | `"nvidia.com"` | Prefix to be used for resources names |
| sriov-network-operator.operator.admissionControllers.enabled | bool | `false` | Enables admission controller |
| sriov-network-operator.operator.admissionControllers.certificates.secretNames.operator | string | `"operator-webhook-cert"` |  |
| sriov-network-operator.operator.admissionControllers.certificates.secretNames.injector | string | `"network-resources-injector-cert"` |  |
| sriov-network-operator.operator.admissionControllers.certificates.certManager.enabled | bool | `true` | When enabled, makes use of certificates managed by cert-manager |
| sriov-network-operator.operator.admissionControllers.certificates.certManager.generateSelfSigned | bool | `true` | When enabled, certificates are generated via cert-manager and then name will match the name of the secrets defined above |
| sriov-network-operator.operator.admissionControllers.certificates.custom.enabled | bool | `false` | If not specified, no secret is created and secrets with the names defined above are expected to exist in the cluster. In that case, the ca.crt must be base64 encoded twice since it ends up being an env variable |
| sriov-network-operator.operator.admissionControllers.certificates.custom.operator.caCrt | string | `""` | |
| sriov-network-operator.operator.admissionControllers.certificates.custom.operator.tlsCrt | string | `""` | |
| sriov-network-operator.operator.admissionControllers.certificates.custom.operator.tlsKey | string | `""` | |
| sriov-network-operator.operator.admissionControllers.certificates.custom.injector.caCrt | string | `""` | |
| sriov-network-operator.operator.admissionControllers.certificates.custom.injector.tlsCrt | string | `""` | |
| sriov-network-operator.operator.admissionControllers.certificates.custom.injector.tlsKey | string | `""` | |
| sriov-network-operator.images.operator | string | `"nvcr.io/nvidia/mellanox/sriov-network-operator:network-operator-v25.7.0"` |  |
| sriov-network-operator.images.sriovConfigDaemon | string | `"nvcr.io/nvidia/mellanox/sriov-network-operator-config-daemon:network-operator-v25.7.0"` |  |
| sriov-network-operator.images.sriovCni | string | `"nvcr.io/nvidia/mellanox/sriov-cni:network-operator-v25.7.0"` |  |
| sriov-network-operator.images.ibSriovCni | string | `"nvcr.io/nvidia/mellanox/ib-sriov-cni:network-operator-v25.7.0"` |  |
| sriov-network-operator.images.ovsCni | string | `"nvcr.io/nvidia/mellanox/ovs-cni-plugin:network-operator-v25.7.0` |  |
| sriov-network-operator.images.rdmaCni | string | `"nvcr.io/nvidia/mellanox/rdma-cni:network-operator-v25.7.0"` |  |
| sriov-network-operator.images.sriovDevicePlugin | string | `"nvcr.io/nvidia/mellanox/sriov-network-device-plugin:network-operator-v25.7.0"` |  |
| sriov-network-operator.images.resourcesInjector | string | `"ghcr.io/k8snetworkplumbingwg/network-resources-injector:v1.7.0"` |  |
| sriov-network-operator.images.webhook | string | `"nvcr.io/nvidia/mellanox/sriov-network-operator-webhook:network-operator-v25.7.0"` |  |
| sriov-network-operator.imagePullSecrets | list | `[]` | imagePullSecrets for sriov-network-operator related images |
| sriov-network-operator.sriovOperatorConfig.deploy | bool | `true` | Deploy ``SriovOperatorConfig`` custom resource |
| sriov-network-operator.sriovOperatorConfig.configDaemonNodeSelector | map | `beta.kubernetes.io/os: "linux"` and `network.nvidia.com/operator.mofed.wait: "false"` | Selects the nodes to be configured |
| nic-configuration-operator-chart.operator.image.repository | string | `"nvcr.io/nvidia/mellanox"` | |
| nic-configuration-operator-chart.operator.image.name | string | `"nic-configuration-operator"` | |
| nic-configuration-operator-chart.operator.image.tag | string | `"network-operator-v25.7.0"` | |
| nic-configuration-operator-chart.configDaemon.image.repository | string | `"nvcr.io/nvidia/mellanox"` | |
| nic-configuration-operator-chart.configDaemon.image.name | string | `"nic-configuration-operator-daemon"` | |
| nic-configuration-operator-chart.configDaemon.image.tag | string | `"network-operator-v25.7.0"` | |
| maintenance-operator-chart.operatorConfig.deploy | bool | `false` | Deploy MaintenanceOperatorConfig. Maintenance Operator might be already deployed on the cluster, in that case no need to deploy MaintenanceOperatorConfig |
| maintenance-operator.imagePullSecrets | list | `[]` | imagePullSecrets for maintenance-operator related images |
| maintenance-operator-chart.operator.image.repository | string | `"nvcr.io/nvidia/mellanox"` | |
| maintenance-operator-chart.operator.image.name | string | `"maintenance-operator"` | |
| maintenance-operator-chart.operator.image.tag | string | `"network-operator-v25.7.0"` | |
| maintenance-operator-chart.operator.admissionController.enable | bool | `false` | Enable admission controller of the operator |
| maintenance-operator-chart.operator.admissionController.certificates.secretNames.operator | string | `"maintenance-webhook-cert"` | Secret name containing certificates for the operator admission controller |
| maintenance-operator-chart.operator.admissionController.certificates.certManager.enable | bool | `false` | Use cert-manager for certificates |
| maintenance-operator-chart.operator.admissionController.certificates.certManager.generateSelfSigned | bool | `false` | Generate self-signed certificates with cert-manager |
| maintenance-operator-chart.operator.admissionController.certificates.custom.enable | bool | `false` | Enable custom certificates using secrets |
| operator.resources.limits.cpu | string | `"500m" | |
| operator.resources.limits.memory | string | `"128Mi" | |
| operator.resources.requests.cpu | string | `"5m" | |
| operator.resources.requests.memory | string | `"64Mi" | |
| operator.tolerations | list | Tolerations for control plane taints | |
| operator.nodeSelector | map | `{}` | Configure node selector settings for the operator |
| operator.affinity | map | Affinity for control plane nodes | Configure node affinity settings for the operator |
| operator.repository | string | `"nvcr.io/nvidia/cloud-native"` | Network Operator image repository |
| operator.image | string | `"network-operator"` | Network Operator image name |
| operator.imagePullSecrets | list | `[]` | imagePullSecrets for Network Operator related images |
| operator.nameOverride | string | `""` | Name to be used as part of objects name generation |
| operator.fullnameOverride | string | `""` | Name to be used to replace generated names |
| operator.tag | string | `""` | If defined will use the given image tag, else chart AppVersion will be used |
| operator.cniBinDirectory | string | `"/opt/cni/bin"` | Directory where CNI binaries will be deployed on the node |
| operator.cniNetworkDirectory | string | `"/etc/cni/net.d"` | Directory where CNI network configuration will be deployed on the nodes |
| operator.maintenanceOperator.useRequestor | bool | `false` | Enable the use of maintenance operator upgrade logic |
| operator.maintenanceOperator.requestorID | string | `"nvidia.network.operator"` | |
| operator.maintenanceOperator.nodeMaintenanceNamePrefix | string | `"nvidia.network.operator"` | |
| operator.maintenanceOperator.nodeMaintenanceNamespace | string | `"default"` | |
| operator.useDTK | bool | `true` | Enable the use of Driver ToolKit to compile DOCA-OFED Drivers (OpenShift only) |
| operator.admissionController.enable | bool | `false` | Deploy with admission controller |
| operator.admissionController.useCertManager | bool | `false` | Use cert-manager for generating self-signed certificate |
| operator.admissionController.certificate.caCrt | string | `""` | Custom certificate instead of using cert-manager|
| operator.admissionController.certificate.tlsCrt | string | `""` | Custom certificate instead of using cert-manager|
| operator.admissionController.certificate.tlsKey | string | `""` | Custom certificate instead of using cert-manager|
| operator.ofedDriver.initContainer.enable | bool | `true` | Deploy OFED init container |
| operator.ofedDriver.initContainer.repository | string | `"nvcr.io/nvidia/mellanox"` | OFED init container image repository |
| operator.ofedDriver.initContainer.image | string | `"network-operator-init-container"` | OFED init container image name |
| operator.ofedDriver.initContainer.version | string | `"network-operator-v25.7.0"` | OFED init container image version |
| imagePullSecrets | list | `[]` | An optional list of references to secrets to use for pulling any of the Network Operator images |


## Upgrade

### Upgrade CRDs to compatible version

The network-operator helm chart contains a hook(pre-install, pre-upgrade) that will automatically upgrade required CRDs in the cluster.
The hook is enabled by default. If you don't want to upgrade CRDs with helm automatically, 
you can disable auto upgrade by setting `upgradeCRDs: false` in the helm chart values.
Then you can follow the guide below to download and apply CRDs for the concrete version of the network-operator.


## Usage

#### Deploy Network Operator without Node Feature Discovery

By default the network operator
deploys [Node Feature Discovery (NFD)](https://github.com/kubernetes-sigs/node-feature-discovery)
in order to perform node labeling in the cluster to allow proper scheduling of Network Operator resources. If the nodes
where already labeled by other means (either deployed from upstream or deployed within another deployment), it is possible to disable the deployment of NFD by setting
`nfd.enabled=false` chart parameter and make sure that the installed version is `v0.13.2` or newer and has NodeFeatureApi enabled.

##### Deploy NFD from upstream with NodeFeatureApi enabled
```
$ export NFD_NS=node-feature-discovery
$ helm repo add nfd https://kubernetes-sigs.github.io/node-feature-discovery/charts
$ helm repo update
$ helm install nfd/node-feature-discovery --namespace $NFD_NS --create-namespace --generate-name --set enableNodeFeatureApi='true'
```
For additional information , refer to the official [NVD deployment with Helm](https://kubernetes-sigs.github.io/node-feature-discovery/v0.13/deployment/helm.html)

##### Deploy Network Operator without Node Feature Discovery
```
$ helm install --set nfd.enabled=false -n network-operator --create-namespace --wait network-operator nvidia/network-operator
```

##### Currently the following NFD labels are used:

| Label                                         | Where                                             |
|-----------------------------------------------|---------------------------------------------------|
| `feature.node.kubernetes.io/pci-15b3.present` | Nodes bearing Nvidia Mellanox Networking hardware |
| `nvidia.com/gpu.present`                      | Nodes bearing Nvidia GPU hardware                 |

> __Note:__ The labels which Network Operator depends on may change between releases.

> __Note:__ By default the operator is deployed without an instance of `NicClusterPolicy` and `MacvlanNetwork`
> custom resources. The user is required to create it later with configuration matching the cluster or use chart parameters to deploy it together with the operator.

#### Deploy Network Operator with Admission Controller

The Admission Controller can be optionally included as part of the Network Operator installation process.  
It has the capability to validate supported Custom Resource Definitions (CRDs), which currently include NicClusterPolicy and HostDeviceNetwork.  
By default, the deployment of the admission controller is disabled. To enable it, you must set `operator.admissionController.enabled` to `true`.
  
Enabling the admission controller provides you with two options for managing certificates.  
You can either utilize [cert-manager](https://cert-manager.io/docs/installation/) for generating a self-signed certificate automatically, or you can provide your own self-signed certificate.  
  
To use `cert-manager`, ensure that `operator.admissionController.useCertManager` is set to `true`. Additionally, make sure that you deploy cert-manager before initiating the Network Operator deployment.
  
If you prefer not to use `cert-manager`, set `operator.admissionController.useCertManager` to `false`, and then provide your custom certificate and key using `operator.admissionController.certificate.tlsCrt` and `operator.admissionController.certificate.tlsKey`.

> __NOTE__: When using your own certificate, the certificate must be valid for <Release_Name>-webhook-service.<
> Release_Namespace>.svc, e.g. network-operator-webhook-service.network-operator.svc  

> __NOTE__: When deploying network operator with admission controller using helm, you need to append `--wait` to helm install and helm upgrade commands
>

##### Generating self-signed certificate using OpenSSL

To generate a self-signed SSL certificate valid for a specific hostname, you can use the `openssl` command-line tool.
First, navigate to the directory where you want to store your certificate and key files. Then, run the following
command:

```bash
SVCNAME="network-operator-webhook-service.network-operator.svc"
openssl req -x509 -nodes -batch -newkey rsa:2048 -keyout server.key -out server.crt -days 365 -addext "subjectAltName=DNS:$SVCNAME"
```

Replace `SVCNAME` with the SVC name follows this convention <Release_Name>-webhook-service.<Release_Namespace>.svc.
This command will generate a new RSA key pair with 2048 bits and create a self-signed certificate (`server.crt`) and
private key (`server.key`) that are valid for 365 days.


## Additional components

### Node Feature Discovery

Nvidia Network Operator relies on the existance of specific node labels to operate properly. e.g label a node as having
Nvidia networking hardware available. This can be achieved by either manually labeling Kubernetes nodes or using
[Node Feature Discovery](https://github.com/kubernetes-sigs/node-feature-discovery) to perform the labeling.

To allow zero touch deployment of the Operator we provide a helm chart to be used to optionally deploy Node Feature
Discovery in the cluster. This is enabled via `nfd.enabled` chart parameter.

### SR-IOV Network Operator

Nvidia Network Operator can operate in unison with SR-IOV Network Operator to enable SR-IOV workloads in a Kubernetes
cluster. We provide a helm chart to be used to optionally
deploy [SR-IOV Network Operator](https://github.com/k8snetworkplumbingwg/sriov-network-operator) in the cluster. This is
enabled via `sriovNetworkOperator.enabled` chart parameter.

SR-IOV Network Operator can work in conjuction with [IB Kubernetes](#ib-kubernetes) to use InfiniBand PKEY Membership
Types

For more information on how to configure SR-IOV in your Kubernetes cluster using SR-IOV Network Operator refer to the
project's github.


## References

- [Official Documentation](https://docs.nvidia.com/networking/software/cloud-orchestration/index.html)
- [Operator SDK](https://github.com/operator-framework/operator-sdk)
- [GPU-Operator](https://github.com/NVIDIA/gpu-operator)