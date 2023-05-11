# AVI Operator
The Avi Kubernetes Operator (AKO) is used to provide L4-L7 load balancing for applications deployed in a kubernetes cluster for north-south traffic.

## Pre-requisites:
To run AKO you need the following pre-requisites:

* <i>**Step 1:**</i> Configure an Avi Controller with a [vCenter cloud](https://avinetworks.com/docs/latest/installing-avi-vantage-for-vmware-vcenter/). The Avi Controller should be versioned 18.2.10 / 20.1.2 or later.
    * <i>**Step 1a:**</i> [Deploy Avi Controller OVA in Write Access](https://avinetworks.com/docs/latest/installing-avi-vantage-for-vmware-vcenter/#deploying-avi-vantage-in-write-access-mode) 
    * <i>**Step 1b:**</i> [Performing the Avi Controller Initial setup](https://avinetworks.com/docs/latest/installing-avi-vantage-for-vmware-vcenter/#performing-the-avi-controller-initial-setup)
    * <i>**Step 1c:**</i> (For static IP assignment) [Configuring IP address pools](https://avinetworks.com/docs/latest/installing-avi-vantage-for-vmware-vcenter/#configuring-ip-address-pools)
    * <i>**Step 1d:**</i> [Verifying the Configuration](https://avinetworks.com/docs/latest/installing-avi-vantage-for-vmware-vcenter/#verifying-the-configuration)
* <i>**Step 2:**</i> Create Service Engine groups per AKO cluster

## Kubernetes compatibility
Kubernetes version 1.16 and above

## CloudTypes supported:
Supported for all cloudTypes

## Parameters

The table lists commonly used parameters you can configure when adding this pack.

| Parameter  | Description | Default  | Required | 
| --- | --- | --- | --- |
| AKOSettings.clusterName | A unique identifier for the kubernetes cluster, that helps distinguish the objects for this cluster in the avi controller. | my-cluster | Yes |
| AKOSettings.cniPlugin | Set the string if your CNI is calico or openshift. enum: calico|canal|flannel|openshift|antrea|ncp | Empty  | Yes, for calico or openshift  |
| NetworkSettings.nodeNetworkList  | This list of network and cidrs are used in pool placement network for vcenter cloud. Node Network details are not needed when in nodeport mode / static routes are disabled/non-vcenter clouds | Empty  | Yes  |
| NetworkSettings.vipNetworkList | Network information of the VIP network. Multiple networks allowed only for AWS Cloud. | Empty  | Yes  |  
| ControllerSettings.serviceEngineGroupName  | Name of the ServiceEngine Group.  | Empty  | Yes  |
| ControllerSettings.controllerVersion | The controller API version  | 22.1.2 | Yes  |  | ControllerSettings.cloudName | The configured cloud name on the Avi controller.  | Default-Cloud  | Yes  |
| ControllerSettings.controllerHost  | IP address or Hostname of Avi Controller  | Empty  | Yes  |  
| avicredentials.username  | Controller username | Empty  | Yes  |
| avicredentials.password  | Controller password | Empty  | Yes  |

## References:
* [AKO installation](https://avinetworks.com/docs/ako/1.5/ako-installation/)
* [Github](https://github.com/vmware/load-balancer-and-ingress-services-for-kubernetes/tree/release-1.5.2)
* [AKO](https://avinetworks.com/docs/ako/1.5/avi-kubernetes-operator/)
