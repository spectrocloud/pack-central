# Hello Universe

[Hello Universe](https://github.com/spectrocloud/hello-universe) is a demo web application utilized to help users learn more about [Palette](https://docs.spectrocloud.com/introduction) and its features. It functions as a standalone front-end application and provides users with a local click counter and funny Spectro Cloud-themed images.

## Prerequisites

- A Palette account.

- A cluster profile where the Hello Universe pack can be integrated.

- A Palette cluster with port `:8080` available. If port 8080 is not available, you can set a different port in the **values.yaml** file.

- Ensure sufficient CPU resources within the cluster to allocate a minimum of 100 milliCPU and a maximum of 200 milliCPU per replica.

## Parameters

The following parameters are applied to the **hello-universe.yaml** manifest through the **values.yaml** file. Users do not need to take any additional actions regarding these parameters.

| **Parameter**                     | **Description**                                                                | **Default Value**                           | **Required** |
| --------------------------------- | ------------------------------------------------------------------------------ | ------------------------------------------- | ------------ |
| `manifests.namespace`             | The namespace in which the application will be deployed.                       | `hello-universe`                            | No           |
| `manifests.images.hello-universe` | The application image that will be utilized to create the containers.          | `ghcr.io/spectrocloud/hello-universe:1.1.1` | No           |
| `manifests.port`                  | The cluster port number on which the service will listen for incoming traffic. | `8080`                                      | No           |
| `manifests.replicas`              | The number of Pods to be created.                                              | `1`                                         | No           |

## Usage

To utilize the Hello Universe pack, create either a [full Palette cluster profile](https://docs.spectrocloud.com/profiles/cluster-profiles/create-cluster-profiles/create-full-profile) or an [add-on Palette cluster profile](https://docs.spectrocloud.com/profiles/cluster-profiles/create-cluster-profiles/create-addon-profile/) and add the pack to your profile.

If your infrastructure provider does not offer a native load balancer solution, such as VMware and MAAS, the [MetalLB](https://docs.spectrocloud.com/integrations/metallb) pack must be included to the cluster profile to help the LoadBalancer service specified in the manifest obtain an IP address.

After defining the cluster profile, use it to deploy a new cluster or attach it as an add-on profile to an existing cluster.

Once the cluster status displays **Running** and **Healthy**, access the Hello Universe application through the exposed service URL along with the displayed port number.

## References

- [Hello Universe GitHub Repository](https://github.com/spectrocloud/hello-universe)

- [Deploy a Custom Pack Tutorial](https://docs.spectrocloud.com/registries-and-packs/deploy-pack/)

- [Registries and Packs](https://docs.spectrocloud.com/registries-and-packs/)
