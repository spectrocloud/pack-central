# Akuity Agent

The Akuity Agent connects a Kubernetes cluster to an [Argo CD](https://argo-cd.readthedocs.io/) instance managed by the [Akuity Platform](https://akuity.io). Once registered, the cluster appears in your Akuity organization and Argo CD can deploy applications to it.

The agent is designed to be installed as part of cluster bootstrapping. Adding this pack to a cluster profile ensures every new cluster is automatically registered with Akuity Platform without manual intervention.


## Prerequisites

- An active [Akuity Platform](https://akuity.io) account with an organization and at least one Argo CD instance.
- An Akuity API key. Generate one from the **API Keys** tab on the organization profile page in the [Akuity Portal](https://app.akuity.io).


## Parameters

| **Parameter** | **Description** | **Type** | **Default Value** | **Required** |
|---|---|---|---|---|
| `clusterName` | Name of the cluster as it will appear in the Akuity Platform | String | `""` | Yes |
| `instanceName` | Name of the Argo CD instance to register the cluster with | String | `""` | Yes |
| `organizationName` | Name of your Akuity organization | String | `""` | Yes |
| `akuityApiKeyId` | Akuity API key ID | String | `""` | Yes |
| `akuityApiKeySecret` | Akuity API key secret | String | `""` | Yes |
| `akuityServerUrl` | Akuity Platform API URL | String | `"https://akuity.cloud"` | No |
| `version` | Pin a specific agent version | String | `""` | No |
| `agentSize` | Agent resource size | String | `""` | No |
| `project` | Project to associate the cluster with | String | `""` | No |
| `labels` | Labels to apply to the cluster, e.g. `["env=prod", "team=platform"]` | List | `[]` | No |
| `namespaceScoped` | Install the agent in namespace-scoped mode | Boolean | `false` | No |
| `disableAutoUpdate` | Disable automatic agent updates | Boolean | `false` | No |
| `stateReplication` | Enable state replication | Boolean | `false` | No |
| `redisTunneling` | Enable Redis tunneling | Boolean | `false` | No |


## Usage

To use the Akuity Agent pack, create a new [add-on cluster profile](https://docs.spectrocloud.com/profiles/cluster-profiles/create-cluster-profiles/create-addon-profile/), search for the **Akuity Agent** pack, and set the required parameters in the pack's YAML:

```yaml
clusterName: "my-cluster"
instanceName: "my-argocd-instance"
organizationName: "my-org"
akuityApiKeyId: "YOUR_API_KEY_ID"
akuityApiKeySecret: "YOUR_API_KEY_SECRET"
```

> [!CAUTION]
> Avoid hardcoding `akuityApiKeyId` and `akuityApiKeySecret` directly in the cluster profile. Use your organization's secrets management solution to inject these values at deploy time.

Once deployed, the cluster will appear in your Akuity organization under the specified Argo CD instance, and Argo CD can begin deploying applications to it.


## References

- [Akuity Platform documentation](https://docs.akuity.io)
- [Akuity Agent Helm chart](https://quay.io/akuity/akuity-platform-charts/akuity-agent)
- [Argo CD documentation](https://argo-cd.readthedocs.io/)
