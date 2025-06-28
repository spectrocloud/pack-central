# Medik8s - Kubernetes Node Remediation

Medik8s is a project consists of several kubernetes operators that provide automatic node remediation and high availability for singleton workloads.

Hardware is imperfect, and software contains bugs. When node level failures such as kernel hangs or dead NICs occur, the work required from the cluster does not decrease - workloads from affected nodes need to be restarted somewhere.

However some workloads, such as RWO volumes and StatefulSets, may require at-most-one semantics. Failures affecting these kind of workloads risk data loss and/or corruption if nodes (and the workloads running on them) are assumed to be dead whenever we stop hearing from them. For this reason it is important to know that the node has reached a safe state before initiating recovery of the workload.

Unfortunately it is not always practical to require admin intervention in order to confirm the node’s true status. In order to automate the recovery of exclusive workloads, Medik8s presents a collection of projects that can be installed on any kubernetes-based cluster to automate:
* The detection of failures,
* Putting nodes into a safe state,
* Allowing the scheduler to recover affected workloads
* Attempting to restore cluster capacity


## Prerequisites

- A Kubernetes cluster.


## Parameters

To deploy the Medik8s pack, you need to review the following parameters in the pack's YAML and adjust if necessary

| Name | Description | Type | Default Value | Required |
| --- | --- | --- | --- | --- |
| `medik8s.olm.install` | Whether to install the Operator Lifecycle Manager (OLM). If OLM is already installed in your cluster by other means, set this to `false` | Boolean | `true` | Yes |
| `medik8s.olm.catalog.image` | Where to get the OperatorHub Catalog from. Adjust this if you use a private registry | String | quay.io/operatorhubio/catalog:latest | Yes |
| `medik8s.nodeHealthChecks[*].spec.minHealthy` | The minimum percentage of nodes that must be healthy for the operator to act. | String | 51% | Yes |
| `medik8s.nodeHealthChecks[*].spec.unhealthyConditions[*].duration` | Time that nodes can be unhealthy before the operator acts. | String | 300s | Yes |
| `medik8s.oselfNodeRemediationConfigs[*].spec.apiCheckInterval` | Frequency to check connectivity with each API server | String | 15s | Yes |
| `medik8s.oselfNodeRemediationConfigs[*].spec.apiServerTimeout` | Timeout to check connectivity with each API server. When this timeout elapses, the Operator starts remediation | String | 5s | Yes |
| `medik8s.oselfNodeRemediationConfigs[*].spec.hostPort` | HostPort is used for internal communication between SNR agents, do not change. | Integer | 30001 | Yes |
| `medik8s.oselfNodeRemediationConfigs[*].spec.isSoftwareRebootEnabled` | Specify if you want to enable software reboot of the unhealthy nodes | Boolean | true | Yes |
| `medik8s.oselfNodeRemediationConfigs[*].spec.maxApiErrorThreshold` | When reaching this threshold, the node starts contacting its peers | Integer | 3 | Yes |
| `medik8s.oselfNodeRemediationConfigs[*].spec.peerApiServerTimeout` | Timeout for the peer to connect the API server | String | 5s | Yes |
| `medik8s.oselfNodeRemediationConfigs[*].spec.peerDialTimeout` | Timeout for establishing connection with the peer | String | 5s | Yes |
| `medik8s.oselfNodeRemediationConfigs[*].spec.peerRequestTimeout` | Timeout to get a response from the peer | String | 5s | Yes |
| `medik8s.oselfNodeRemediationConfigs[*].spec.peerUpdateInterval` | Frequency to update peer information, such as IP address | String | 15m | Yes |
| `medik8s.oselfNodeRemediationConfigs[*].spec.watchdogFilePath` | File path of the watchdog device in the nodes. If a watchdog device is unavailable, the SelfNodeRemediationConfig CR uses a software reboot | String | /dev/watchdog | Yes |


Review the node failure detection information at the [Medik8s website](https://www.medik8s.io/failure_detection/) for more details on healthcheck behavior. 

## Upgrade

This pack deploys an operator, which takes care of phased upgrades


## Usage

To use the Medik8s pack, first create a new [add-on cluster profile](https://docs.spectrocloud.com/profiles/cluster-profiles/create-cluster-profiles/create-addon-profile/), add a pack and search for the **Medik8s** pack in the Palete Community Registry. Then either accept the defaults or modify them as needed.

In its default configuration, the Node Healthcheck Controller will detect node failures based on Kubernetes `unhealthyConditions` (if they endure for longer than the maximum `duration`) and timeouts set in the `selfNodeRemediationConfig`.

Once a failure has been detected, remediation will start. You can fine tune the validation and remediation behavior by adjusting the `selfNodeRemediationConfig` section in the pack. Review the information about the [Self Node Remediation Configuration options](https://www.medik8s.io/remediation/self-node-remediation/configuration/) on the Medik8s website.

Once you have configured the pack, you can deploy it to cluster.


## References

- [Medik8s website](https://www.medik8s.io/failure_detection/)
- [Self Node Remediation Configuration options](https://www.medik8s.io/remediation/self-node-remediation/configuration/)