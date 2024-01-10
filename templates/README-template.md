# Title <!-- It must be the pack’s name -->

<!-- A brief overview of the application or service the pack provides. -->


## Prerequisites

<!-- List the required software version or hardware the user is required to have installed and available in order to integrate the pack. -->


## Parameters

<!-- If applicable, list and describe only the most commonly used parameters, especially if there are 10 or more that might apply. 

You can use a table to list parameters with a **Parameter** and a **Description** column. Additionally, include a **Type** column to specify the parameter's type and a **Default Value** column for the parameter's default values. Last, you can include a **Required** column to indicate that the user must provide a value for it.

| **Parameter** | **Description** | **Type** | **Default Value** | **Required** |
|---|---|---|---|---|
| Parameter 1   | Description for Parameter 1 | String | “always” | Yes |
| Parameter 2   | Description for Parameter 2 | Int | 10 | No |

-->


## Upgrade

<!-- If applicable, provide instructions on upgrading the pack's version. These instructions should include any prerequisites that are necessary for the upgrade, as well as a step-by-step upgrade guide. Additionally, you can highlight any changes specific to the new version, compatibility issues, and instructions on rolling back an upgrade if needed. The upgrade nuances can be structured in bullets, such as the examples listed below.

- The upgrade to version x.x.x of this pack removes support for installing feature X. We recommend installing feature X separately.
- The `example` key is no longer hard-coded. Therefore, the user does not need to input the key.
Software X API version was updated to v2 and now requires software Y version x.x.x or above.
- The `example` image was migrated to a "non-root" user approach. You can revert this behavior by setting the parameters `x`, `y`, and `z` to `root`.
- Backwards compatibility is no longer supported. Use the workaround below to upgrade from versions previous to x.x.x.
- When upgrading from the major version x.x.x, be aware that there is an incompatible breaking change that requires manual actions. Use the workaround provided below.
- The config `example values` has been refactored. All the values have been moved to the key `exampleKey`, and the limits can now be set separately.

> [!CAUTION]
> Upgrades from a manifest-based pack to a Helm chart-based pack might not be compatible. -->


## Usage

<!-- Provide instructions for the user to add the pack and configure essential settings. If there are any specific configurations users should be aware of, explain them in detail and use examples if possible. In summary, the usage section should provide a practical demonstration of how to use the pack. This could involve specifying parameters, creating extra layers, or interacting with other components or services, such as the use cases described below.

- How to handle dependencies.
    Example - when using the [Prometheus](https://docs.spectrocloud.com/integrations/prometheus-operator/) pack, Grafana can be utilized to visualize the metrics scrapped by Prometheus.
- How to acquire credentials.
    Example - when deploying the [Vault](https://docs.spectrocloud.com/integrations/vault/) pack, you need to get the root token.
- How to connect to an exposed UI or dashboard.
    Example - when using the [Kubernetes Dashboard](https://docs.spectrocloud.com/integrations/kubernetes-dashboard/) pack, use the port-forward command to expose and access the dashboard at a specific port from your localhost.
- How to add and integrate an extra layer.
    Example - when using the [ngrok](https://docs.spectrocloud.com/integrations/ngrok) pack, you need to create an ingress service definition for your application, which requires a new manifest layer.

> [!CAUTION]
> Call-out notes must follow the GitHub Flavored Markdown syntax. -->


## References

<!-- List one or more sources users can reference to learn more about the pack. References can comprise the official application or service documentation, a dedicated tutorial, the Helm Chart documentation, and more. 
References must be in a bullet list that adheres to the standard MarkDown link format.
- [link_label](https://link) -->