# Wordpress

WordPress is the world's most popular blogging and content management platform. Powerful yet simple, everyone from students to global corporations use it to build beautiful, functional websites.

## Prerequisites

- Kubernetes 1.25+

## Parameters

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

User can set `wordpress-chart.charts.wordpress.wordpressPassword` and `wordpress-chart.charts.wordpress.wordpressUsername` as per the need before deploying the addon pack. Similarly make the changes in the Mariadb parameters.

After the pack comes up running. you can access the wordpress app using the External Ip assigned to the service.
To login to the wordpress admin console, use the URL `http/https"://{ExternalIP}/admin`.

You can create more users from the admin console settings.

## References

[Overview of WordPress](http://www.wordpress.org)
