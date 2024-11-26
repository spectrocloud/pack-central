# Netapp-Trident
Trident is a fully supported open source project maintained by NetApp. It has been designed from the ground up to help you meet your containerized applications' persistence demands using industry-standard interfaces, such as the Container Storage Interface.

Trident deploys in Kubernetes clusters as pods and provides dynamic storage orchestration services for your Kubernetes workloads. It enables your containerized applications to quickly consume persistent storage from NetApp's broad portfolio that
includes ONTAP, Element, HCI/SolidFire, as well as the Azure NetApp Files service, Cloud Volumes Service on Google Cloud, and Amazon FSx for ONTAP.

Trident features also address data protection, disaster recovery, portability, and migration use cases for Kubernetes workloads leveraging NetApp's industry-leading data management technology for snapshots, backups,
replication, and cloning.

## Prerequisites
For a full list of Trident requirements, check out the [Getting Started](https://docs.netapp.com/us-en/trident/trident-get-started/requirements.html) guide. 

Critical information about Trident:
* Kubernetes 1.31 is now supported in Trident. Upgrade Trident prior to upgrading Kubernetes.
* Trident strictly enforces the use of multipathing configuration in SAN environments, with a recommended value of find_multipaths: no: in multipath.conf file.

Supported frontends (orchestrators)
Trident supports multiple container engines and orchestrators, including the following:
* Anthos On-Prem (VMware) and Anthos on bare metal 1.16
* Kubernetes 1.25 - 1.31
* OpenShift 4.10 - 4.17
* Rancher Kubernetes Engine 2 (RKE2) v1.28.5+rke2r1

The Trident operator is supported with these releases:
* Anthos On-Prem (VMware) and Anthos on bare metal 1.16
* Kubernetes 1.25 - 1.31
* OpenShift 4.10 - 4.17
* Rancher Kubernetes Engine 2 (RKE2) v1.28.5+rke2r1

Trident also works with a host of other fully-managed and self-managed Kubernetes offerings, including Google Kubernetes Engine (GKE), Amazon Elastic Kubernetes Services (EKS), Azure Kubernetes Service (AKS), Mirantis Kubernetes Engine (MKE), and VMWare Tanzu Portfolio.

Supported backends (storage)
To use Trident, you need one or more of the following supported backends:
* Amazon FSx for NetApp ONTAP
* Azure NetApp Files
* Cloud Volumes ONTAP
* Google Cloud NetApp Volumes
* FAS/AFF/Select 9.5 or later
* NetApp All SAN Array (ASA)
* NetApp HCI/Element software 11 or above

## Parameters
This table and the values.yaml file, which is part of the Helm chart, provide the list of keys and their default valueshis table and the values.yaml file, which is part of the Helm chart, provide the list of keys and their default values.
| Parameter  | Description | Default  | Required | 
| --- | --- | --- | --- | 
| nodeSelector | Node labels for pod assignment | Empty | No |
| podAnnotations| Pod annotations| Empty | No |
| deploymentAnnotations | Deployment annotations | Empty  | No |
| tolerations | Tolerations for pod assignment | Empty  | No |  
| affinity | Affinity for pod assignment | All Nodes  | Yes |
| tridentControllerPluginNodeSelector | Additional node selectors for pods. Refer to Understanding controller pods and node pods for details. | Empty | No  | 
| tridentControllerPluginTolerations | Overrides Kubernetes tolerations for pods. Refer to Understanding controller pods and node pods for details. | Empty | No |
| tridentNodePluginNodeSelector | Additional node selectors for pods. Refer to Understanding controller pods and node pods for details. | Empty | No |
| tridentNodePluginTolerations | Overrides Kubernetes tolerations for pods. Refer to Understanding controller pods and node pods for details. | Empty | No |
| imageRegistry | Identifies the registry for the trident-operator, trident, and other images. Leave empty to accept the default. | Empty | No |
| imagePullPolicy | Sets the image pull policy for the trident-operator. | IfNotPresent | Yes |
| imagePullSecrets | Sets the image pull secrets for the trident-operator, trident, and other images. | Empty | No |
| kubeletDir | Allows overriding the host location of kubelet's internal state. | "/var/lib/kubelet" | Yes |
| operatorLogLevel | Allows the log level of the Trident operator to be set to: trace, debug, info, warn, error, or fatal. | "info" | Yes |
| operatorDebug | Allows the log level of the Trident operator to be set to debug. | true | Yes |
| operatorImage | Allows the complete override of the image for trident-operator. | Empty | No |
| operatorImageTag | Allows overriding the tag of the trident-operator image. | Empty | No |
| tridentIPv6 | Allows enabling Trident to work in IPv6 clusters. | false | No |
| tridentK8sTimeout | Overrides the default 30-second timeout for most Kubernetes API operations (if non-zero, in seconds). | 0 | No |
| tridentHttpRequestTimeout | Overrides the default 90-second timeout for the HTTP requests, with 0s being an infinite duration for the timeout. Negative values are not allowed. | "90s" | Yes |
| tridentSilenceAutosupport | Allows disabling Trident periodic AutoSupport reporting. | false | No |
| tridentAutosupportImageTag | Allows overriding the tag of the image for Trident AutoSupport container. | <version> | Yes |
| tridentAutosupportProxy | Enables Trident AutoSupport container to phone home via an HTTP proxy. | Empty | No |
| tridentLogFormat | Sets the Trident logging format (text or json). | "text" | No |
| tridentDisableAuditLog | Disables Trident audit logger. | true | No |
| tridentLogLevel | Allows the log level of Trident to be set to: trace, debug, info, warn, error, or fatal. | "info" | No |
| tridentDebug | Allows the log level of Trident to be set to debug. | false | No |
| tridentLogWorkflows | Allows specific Trident workflows to be enabled for trace logging or log suppression. | Empty | No |
| tridentLogLayers | Allows specific Trident layers to be enabled for trace logging or log suppression. | Empty | No |
| tridentImage | Allows the complete override of the image for Trident. | Empty | No |
| tridentImageTag | Allows overriding the tag of the image for Trident. | Empty | No |
| tridentProbePort | Allows overriding the default port used for Kubernetes liveness/readiness probes. | Empty | No |
| windows | Enables Trident to be installed on Windows worker node. | false | No |
| enableForceDetach | Allows enabling the force detach feature. | false | No |
| excludePodSecurityPolicy | Excludes the operator pod security policy from creation. | false | No |
| cloudProvider | Set to "Azure" when using managed identities or a cloud identity on an AKS cluster. Set to "AWS" when using a cloud identity on an EKS cluster. | Empty | No |
| cloudIdentity | Set to workload identity ("azure.workload.identity/client-id: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx") when using cloud identity on an AKS cluster. Set to AWS IAM role ("'eks.amazonaws.com/role-arn: arn:aws:iam::123456:role/trident-role'") when using cloud identity on an EKS cluster. | Empty | No |
| iscsiSelfHealingInterval | The interval at which the iSCSI self-healing is invoked. | 5m0s | No |
| iscsiSelfHealingWaitTime | The duration after which iSCSI self-healing initiates an attempt to resolve a stale session by performing a logout and subsequent login. | 7m0s | No |
| nodePrep | Enables Trident to prepare the nodes of the Kubernetes cluster to manage volumes using the specified data storage protocol. | Currently, iscsi is the only value supported. | No |

## Usage
Please refer to the Trident Documentation for usage related to Trident Backend Setup, Storage Class parameters, and other features - [Trident Docs](https://docs.netapp.com/us-en/trident/index.html)

## Upgrade
This pack is maintained by NetApp and new version of this pack will be updated along with new versions of Trident according to the regular [release cycle](https://mysupport.netapp.com/site/info/trident-support)  	

## References:
* [Trident Docs](https://docs.netapp.com/us-en/trident/index.html)
* [NetApp's Support site](https://mysupport.netapp.com/site/info/version-support)
* [Trident's Release and Support Lifecycle](https://mysupport.netapp.com/site/info/trident-support)
* [Chat](http://netapp.io/slack/)
* [GitHub last commit](https://github.com/NetApp/trident/commits)
* [Go Report Card](https://goreportcard.com/report/github.com/netapp/trident)
