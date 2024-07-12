# Hello Universe

[Hello Universe](https://github.com/spectrocloud/hello-universe) is a demo web application utilized to help users learn more about [Palette](https://docs.spectrocloud.com/introduction) and its features.

You can deploy it using two preset configurations: 
- A standalone front-end application. It provides a click counter that is saved locally and displays Spectro Cloud themed images.
- A three-tier application with a front-end application, API server and PostgreSQL database into a Kubernetes cluster. It provides a click counter that is saved in the deployed database and displays Spectro Cloud themed images. You can read more about this configuration on the Hello Universe [README](https://github.com/spectrocloud/hello-universe?tab=readme-ov-file#reverse-proxy-with-kubernetes).

## Prerequisites

- A Palette account.

- A cluster profile where the Hello Universe pack can be integrated.

- A Palette cluster with port `:8080` available. If port 8080 is not available, you can set a different port in the **values.yaml** file.

- If you are using the **Enable Hello Universe API** preset, you will need the `:3000` port available on your cluster too. Check out the [Usage](#usage) section for further details.

- Ensure sufficient CPU resources within the cluster to allocate a minimum of 500 milliCPU and a maximum of 500 milliCPU per replica.

## Parameters

The following parameters are applied to the **hello-universe.yaml** manifest through the **values.yaml** file. Users do not need to take any additional actions regarding these parameters.

| **Parameter**                     | **Description**                                                                | **Default Value**                           | **Required** |
| --------------------------------- | ------------------------------------------------------------------------------ | ------------------------------------------- | ------------ |
| `manifests.namespace`             | The namespace in which the application will be deployed.                       | `hello-universe`                            | Yes           |
| `manifests.images.hellouniverse` | The [`hello-universe`](https://github.com/spectrocloud/hello-universe) application image that will be utilized to create the containers.          | `ghcr.io/spectrocloud/hello-universe:1.1.3`/ `ghcr.io/spectrocloud/hello-universe:1.1.3-proxy` | Yes           |
| `manifests.images.hellouniverseapi` | The [`hello-universe-api`](https://github.com/spectrocloud/hello-universe-api) application image that will be utilized to create the containers.          | `ghcr.io/spectrocloud/hello-universe-api:1.0.12` | No           |
| `manifests.images.hellouniversedb` | The [`hello-universe-db`](https://github.com/spectrocloud/hello-universe-db) application image that will be utilized to create the containers.          | `ghcr.io/spectrocloud/hello-universe-db:1.0.2` | No           |
| `manifests.apiEnabled`                  | The flag that indicates whether to deploy the UI application as standalone or together with the API server. | `false`                                      | Yes           |
| `manifests.port`                  | The cluster port number on which the service will listen for incoming traffic. | `8080`                                      | Yes           |
| `manifests.replicas`              | The number of Pods to be created.                                              | `1`                                         | Yes           |
| `manifests.dbPassword`           | The base64 encoded database password to connect to the API database.           |            `REPLACE_ME`                                 | No          |
| `manifests.authToken`            | The base64 encoded auth token for the API connection.                          |      `REPLACE_ME`                                       | No          |
| `manifests.hello-universe.ui.useTolerations`            | Flag to indicate whether to use tolerations for the UI pods.                          |      `false`                                       | No          |
| `manifests.hello-universe.api.useTolerations`            | Flag to indicate whether to use tolerations for the API pods.                          |      `false`                                       | No          |
| `manifests.hello-universe.postgres.useTolerations`            | Flag to indicate whether to use tolerations for the Postgres pods.                          |      `false`                                   | No          |
| `manifests.hello-universe.ui.tolerations.effect`            | The toleration effect to use for the Hello Universe UI pods. The allowed values are `PreferNoSchedule`, `NoSchedule` and `NoExecute`.                          |      `PreferNoSchedule`                                 | No          |
| `manifests.hello-universe.api.tolerations.effect`            | The toleration effect to use for the Hello Universe API pods. The allowed values are `PreferNoSchedule`, `NoSchedule` and `NoExecute`.                          |      `PreferNoSchedule`                                   | No          |
| `manifests.hello-universe.postgres.tolerations.effect`            | The toleration effect to use for the Hello Universe Postgres pods. The allowed values are `PreferNoSchedule`, `NoSchedule` and `NoExecute`.                          |      `PreferNoSchedule`                                   | No          |
| `manifests.hello-universe.ui.tolerations.key`            | The tolerations key to use for the Hello Universe UI pods.                         |      `app`                                   | No          |
| `manifests.hello-universe.api.tolerations.key`            | The tolerations key to use for the Hello Universe API pods.                         |      `app`                                   | No          |
| `manifests.hello-universe.postgres.tolerations.key`            | The tolerations key to use for the Hello Universe Postgres pods.                         |      `app`                                   | No          |
| `manifests.hello-universe.ui.tolerations.value`            | The tolerations value to use for the Hello Universe UI pods.                         |      `ui`                                   | No          |
| `manifests.hello-universe.api.tolerations.value`            | The tolerations value to use for the Hello Universe API pods.                         |      `api`                                   | No          |
| `manifests.hello-universe.postgres.tolerations.value`            | The tolerations value to use for the Hello Universe Postgres pods.                         |      `postgres`                                | No          |

## Usage

The Hello Universe pack has two presets that you can select:
- **Disable Hello Universe API** configures Hello Universe as a standalone frontend application. This is the default configuration of the pack. 
- **Enable Hello Universe API** configures Hello Universe as a three-tier application with a frontend, API server, and Postgres database.

To utilize the Hello Universe pack, create either a [full Palette cluster profile](https://docs.spectrocloud.com/profiles/cluster-profiles/create-cluster-profiles/create-full-profile) or an [add-on Palette cluster profile](https://docs.spectrocloud.com/profiles/cluster-profiles/create-cluster-profiles/create-addon-profile/) and add the pack to your profile. You can select the preset you wish to deploy on the cluster profile creation page.

If your infrastructure provider does not offer a native load balancer solution, such as VMware and MAAS, the [MetalLB](https://docs.spectrocloud.com/integrations/metallb) pack must be included to the cluster profile to help the LoadBalancer service specified in the manifest obtain an IP address.

After defining the cluster profile, use it to deploy a new cluster or attach it as an add-on profile to an existing cluster.

Once the cluster status displays **Running** and **Healthy**, access the Hello Universe application through the exposed service URL along with the displayed port number.

The Hello Universe pack provides parameters for providing pod tolerations. These make it possible to provide [Kubernetes Taints](https://docs.spectrocloud.com/clusters/cluster-management/taints/#taints). You can only apply toleration for the UI, API, and Postgres pods.

The parameters are applied using the `Equal` operator as demonstrated below:

```yaml
    tolerations:
    - effect: {{ .Values.ui.tolerations.effect }}
    key: {{ .Values.ui.tolerations.key }}
    operator: Equal
    value: {{ .Values.ui.tolerations.value }}
```

## References

- [Hello Universe GitHub Repository](https://github.com/spectrocloud/hello-universe)

- [Hello Universe API GitHub Repository](https://github.com/spectrocloud/hello-universe-api)

- [Deploy a Custom Pack Tutorial](https://docs.spectrocloud.com/registries-and-packs/deploy-pack/)

- [Registries and Packs](https://docs.spectrocloud.com/registries-and-packs/)

- [Node Labels and Taints](https://docs.spectrocloud.com/clusters/cluster-management/taints/)
