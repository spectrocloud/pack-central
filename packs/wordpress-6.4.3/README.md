# Title <!-- It must be the pack’s name -->

<!-- A brief overview of the application or service the pack provides. -->

WordPress is the world's most popular blogging and content management platform. Powerful yet simple, everyone from students to global corporations use it to build beautiful, functional websites.

## Prerequisites

<!-- List the required software version or hardware the user is required to have installed and available in order to integrate the pack. -->
- Kubernetes 1.23+

## Parameters

<!-- If applicable, list and describe only the most commonly used parameters, especially if there are 10 or more that might apply. 

You can use a table to list parameters with a **Parameter** and a **Description** column. Additionally, include a **Type** column to specify the parameter's type and a **Default Value** column for the parameter's default values. Last, you can include a **Required** column to indicate that the user must provide a value for it.

| **Parameter** | **Description** | **Type** | **Default Value** | **Required** |
|---|---|---|---|---|
| Parameter 1   | Description for Parameter 1 | String | “always” | Yes |
| Parameter 2   | Description for Parameter 2 | Int | 10 | No |

-->


| Name                                   | Description                                                                           | Value              |
| -------------------------------------- | ------------------------------------------------------------------------------------- | ------------------ |
| `wordpressUsername`                    | WordPress username                                                                    | `user`             |
| `wordpressPassword`                    | WordPress user password                                                               | `""`               |
| `existingSecret`                       | Name of existing secret containing WordPress credentials                              | `""`               |
| `wordpressEmail`                       | WordPress user email                                                                  | `user@example.com` |
| `wordpressFirstName`                   | WordPress user first name                                                             | `FirstName`        |
| `wordpressLastName`                    | WordPress user last name                                                              | `LastName`         |
| `wordpressBlogName`                    | Blog name                                                                             | `User's Blog!`     |
| `wordpressTablePrefix`                 | Prefix to use for WordPress database tables                                           | `wp_`              |
| `wordpressScheme`                      | Scheme to use to generate WordPress URLs                                              | `http`             |
| `wordpressSkipInstall`                 | Skip wizard installation                                                              | `false`            |
| `wordpressExtraConfigContent`          | Add extra content to the default wp-config.php file                                   | `""`               |
| `wordpressConfiguration`               | The content for your custom wp-config.php file (advanced feature)                     | `""`               |
| `existingWordPressConfigurationSecret` | The name of an existing secret with your custom wp-config.php file (advanced feature) | `""`               |
| `wordpressConfigureCache`              | Enable W3 Total Cache plugin and configure cache settings                             | `false`            |
| `wordpressPlugins`                     | Array of plugins to install and activate. Can be specified as `all` or `none`.        | `none`             |
| `apacheConfiguration`                  | The content for your custom httpd.conf file (advanced feature)                        | `""`               |
| `existingApacheConfigurationConfigMap` | The name of an existing secret with your custom httpd.conf file (advanced feature)    | `""`               |
| `customPostInitScripts`                | Custom post-init.d user scripts                                                       | `{}`               |
| `smtpHost`                             | SMTP server host                                                                      | `""`               |
| `smtpPort`                             | SMTP server port                                                                      | `""`               |
| `smtpUser`                             | SMTP username                                                                         | `""`               |
| `smtpPassword`                         | SMTP user password                                                                    | `""`               |
| `smtpProtocol`                         | SMTP protocol                                                                         | `""`               |
| `smtpExistingSecret`                   | The name of an existing secret with SMTP credentials                                  | `""`               |
| `allowEmptyPassword`                   | Allow the container to be started with blank passwords                                | `true`             |
| `allowOverrideNone`                    | Configure Apache to prohibit overriding directives with htaccess files                | `false`            |
| `overrideDatabaseSettings`             | Allow overriding the database settings persisted in wp-config.php                     | `false`            |
| `htaccessPersistenceEnabled`           | Persist custom changes on htaccess files                                              | `false`            |
| `customHTAccessCM`                     | The name of an existing ConfigMap with custom htaccess rules                          | `""`               |
| `command`                              | Override default container command (useful when using custom images)                  | `[]`               |
| `args`                                 | Override default container args (useful when using custom images)                     | `[]`               |
| `extraEnvVars`                         | Array with extra environment variables to add to the WordPress container              | `[]`               |
| `extraEnvVarsCM`                       | Name of existing ConfigMap containing extra env vars                                  | `""`               |
| `extraEnvVarsSecret`                   | Name of existing Secret containing extra env vars                                     | `""`               |


| Name                                       | Description                                                                                    | Value               |
| ------------------------------------------ | ---------------------------------------------------------------------------------------------- | ------------------- |
| `mariadb.enabled`                          | Deploy a MariaDB server to satisfy the applications database requirements                      | `true`              |
| `mariadb.architecture`                     | MariaDB architecture. Allowed values: `standalone` or `replication`                            | `standalone`        |
| `mariadb.auth.rootPassword`                | MariaDB root password                                                                          | `""`                |
| `mariadb.auth.database`                    | MariaDB custom database                                                                        | `bitnami_wordpress` |
| `mariadb.auth.username`                    | MariaDB custom user name                                                                       | `bn_wordpress`      |
| `mariadb.auth.password`                    | MariaDB custom user password                                                                   | `""`                |
| `mariadb.primary.persistence.enabled`      | Enable persistence on MariaDB using PVC(s)                                                     | `true`              |
| `mariadb.primary.persistence.storageClass` | Persistent Volume storage class                                                                | `""`                |
| `mariadb.primary.persistence.accessModes`  | Persistent Volume access modes                                                                 | `[]`                |
| `mariadb.primary.persistence.size`         | Persistent Volume size                                                                         | `8Gi`               |
| `externalDatabase.host`                    | External Database server host                                                                  | `localhost`         |
| `externalDatabase.port`                    | External Database server port                                                                  | `3306`              |
| `externalDatabase.user`                    | External Database username                                                                     | `bn_wordpress`      |
| `externalDatabase.password`                | External Database user password                                                                | `""`                |
| `externalDatabase.database`                | External Database database name                                                                | `bitnami_wordpress` |
| `externalDatabase.existingSecret`          | The name of an existing secret with database credentials. Evaluated as a template              | `""`                |
| `memcached.enabled`                        | Deploy a Memcached server for caching database queries                                         | `false`             |
| `memcached.auth.enabled`                   | Enable Memcached authentication                                                                | `false`             |
| `memcached.auth.username`                  | Memcached admin user                                                                           | `""`                |
| `memcached.auth.password`                  | Memcached admin password                                                                       | `""`                |
| `memcached.auth.existingPasswordSecret`    | Existing secret with Memcached credentials (must contain a value for `memcached-password` key) | `""`                |
| `memcached.service.port`                   | Memcached service port                                                                         | `11211`             |
| `externalCache.host`                       | External cache server host                                                                     | `localhost`         |
| `externalCache.port`                       | External cache server port                                                                     | `11211`             |



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

[Overview of WordPress](http://www.wordpress.org)