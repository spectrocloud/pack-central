# Title <!-- It must be the pack’s name -->

<!-- A brief overview of the application or service the pack provides. -->
Wordpress-6.4.3
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
### Global parameters

| Name                      | Description                                     | Value |
| ------------------------- | ----------------------------------------------- | ----- |
| `global.imageRegistry`    | Global Docker image registry                    | `""`  |
| `global.imagePullSecrets` | Global Docker registry secret names as an array | `[]`  |
| `global.storageClass`     | Global StorageClass for Persistent Volume(s)    | `""`  |

### Common parameters

| Name                     | Description                                                                                  | Value           |
| ------------------------ | -------------------------------------------------------------------------------------------- | --------------- |
| `kubeVersion`            | Override Kubernetes version                                                                  | `""`            |
| `nameOverride`           | String to partially override common.names.fullname template (will maintain the release name) | `""`            |
| `fullnameOverride`       | String to fully override common.names.fullname template                                      | `""`            |
| `commonLabels`           | Labels to add to all deployed resources                                                      | `{}`            |
| `commonAnnotations`      | Annotations to add to all deployed resources                                                 | `{}`            |
| `clusterDomain`          | Kubernetes Cluster Domain                                                                    | `cluster.local` |
| `extraDeploy`            | Array of extra objects to deploy with the release                                            | `[]`            |
| `diagnosticMode.enabled` | Enable diagnostic mode (all probes will be disabled and the command will be overridden)      | `false`         |
| `diagnosticMode.command` | Command to override all containers in the deployment                                         | `["sleep"]`     |
| `diagnosticMode.args`    | Args to override all containers in the deployment                                            | `["infinity"]`  |

### WordPress Image parameters

| Name                | Description                                                                                               | Value                       |
| ------------------- | --------------------------------------------------------------------------------------------------------- | --------------------------- |
| `image.registry`    | WordPress image registry                                                                                  | `REGISTRY_NAME`             |
| `image.repository`  | WordPress image repository                                                                                | `REPOSITORY_NAME/wordpress` |
| `image.digest`      | WordPress image digest in the way sha256:aa.... Please note this parameter, if set, will override the tag | `""`                        |
| `image.pullPolicy`  | WordPress image pull policy                                                                               | `IfNotPresent`              |
| `image.pullSecrets` | WordPress image pull secrets                                                                              | `[]`                        |
| `image.debug`       | Specify if debug values should be set                                                                     | `false`                     |

### WordPress Configuration parameters

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

### WordPress Multisite Configuration parameters

| Name                            | Description                                                                                                                        | Value       |
| ------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| `multisite.enable`              | Whether to enable WordPress Multisite configuration.                                                                               | `false`     |
| `multisite.host`                | WordPress Multisite hostname/address. This value is mandatory when enabling Multisite mode.                                        | `""`        |
| `multisite.networkType`         | WordPress Multisite network type to enable. Allowed values: `subfolder`, `subdirectory` or `subdomain`.                            | `subdomain` |
| `multisite.enableNipIoRedirect` | Whether to enable IP address redirection to nip.io wildcard DNS. Useful when running on an IP address with subdomain network type. | `false`     |

### WordPress deployment parameters

| Name                                                | Description                                                                                                                                                                                                | Value            |
| --------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------- |
| `replicaCount`                                      | Number of WordPress replicas to deploy                                                                                                                                                                     | `1`              |
| `updateStrategy.type`                               | WordPress deployment strategy type                                                                                                                                                                         | `RollingUpdate`  |
| `schedulerName`                                     | Alternate scheduler                                                                                                                                                                                        | `""`             |
| `terminationGracePeriodSeconds`                     | In seconds, time given to the WordPress pod to terminate gracefully                                                                                                                                        | `""`             |
| `topologySpreadConstraints`                         | Topology Spread Constraints for pod assignment spread across your cluster among failure-domains. Evaluated as a template                                                                                   | `[]`             |
| `priorityClassName`                                 | Name of the existing priority class to be used by WordPress pods, priority class needs to be created beforehand                                                                                            | `""`             |
| `automountServiceAccountToken`                      | Mount Service Account token in pod                                                                                                                                                                         | `false`          |
| `hostAliases`                                       | WordPress pod host aliases                                                                                                                                                                                 | `[]`             |
| `extraVolumes`                                      | Optionally specify extra list of additional volumes for WordPress pods                                                                                                                                     | `[]`             |
| `extraVolumeMounts`                                 | Optionally specify extra list of additional volumeMounts for WordPress container(s)                                                                                                                        | `[]`             |
| `sidecars`                                          | Add additional sidecar containers to the WordPress pod                                                                                                                                                     | `[]`             |
| `initContainers`                                    | Add additional init containers to the WordPress pods                                                                                                                                                       | `[]`             |
| `podLabels`                                         | Extra labels for WordPress pods                                                                                                                                                                            | `{}`             |
| `podAnnotations`                                    | Annotations for WordPress pods                                                                                                                                                                             | `{}`             |
| `podAffinityPreset`                                 | Pod affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                                                                                                        | `""`             |
| `podAntiAffinityPreset`                             | Pod anti-affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                                                                                                   | `soft`           |
| `nodeAffinityPreset.type`                           | Node affinity preset type. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                                                                                                  | `""`             |
| `nodeAffinityPreset.key`                            | Node label key to match. Ignored if `affinity` is set                                                                                                                                                      | `""`             |
| `nodeAffinityPreset.values`                         | Node label values to match. Ignored if `affinity` is set                                                                                                                                                   | `[]`             |
| `affinity`                                          | Affinity for pod assignment                                                                                                                                                                                | `{}`             |
| `nodeSelector`                                      | Node labels for pod assignment                                                                                                                                                                             | `{}`             |
| `tolerations`                                       | Tolerations for pod assignment                                                                                                                                                                             | `[]`             |
| `resourcesPreset`                                   | Set container resources according to one common preset (allowed values: none, nano, small, medium, large, xlarge, 2xlarge). This is ignored if resources is set (resources is recommended for production). | `none`           |
| `resources`                                         | Set container requests and limits for different resources like CPU or memory (essential for production workloads)                                                                                          | `{}`             |
| `containerPorts.http`                               | WordPress HTTP container port                                                                                                                                                                              | `8080`           |
| `containerPorts.https`                              | WordPress HTTPS container port                                                                                                                                                                             | `8443`           |
| `extraContainerPorts`                               | Optionally specify extra list of additional ports for WordPress container(s)                                                                                                                               | `[]`             |
| `podSecurityContext.enabled`                        | Enabled WordPress pods' Security Context                                                                                                                                                                   | `true`           |
| `podSecurityContext.fsGroupChangePolicy`            | Set filesystem group change policy                                                                                                                                                                         | `Always`         |
| `podSecurityContext.sysctls`                        | Set kernel settings using the sysctl interface                                                                                                                                                             | `[]`             |
| `podSecurityContext.supplementalGroups`             | Set filesystem extra groups                                                                                                                                                                                | `[]`             |
| `podSecurityContext.fsGroup`                        | Set WordPress pod's Security Context fsGroup                                                                                                                                                               | `1001`           |
| `containerSecurityContext.enabled`                  | Enabled containers' Security Context                                                                                                                                                                       | `true`           |
| `containerSecurityContext.seLinuxOptions`           | Set SELinux options in container                                                                                                                                                                           | `nil`            |
| `containerSecurityContext.runAsUser`                | Set containers' Security Context runAsUser                                                                                                                                                                 | `1001`           |
| `containerSecurityContext.runAsNonRoot`             | Set container's Security Context runAsNonRoot                                                                                                                                                              | `true`           |
| `containerSecurityContext.privileged`               | Set container's Security Context privileged                                                                                                                                                                | `false`          |
| `containerSecurityContext.readOnlyRootFilesystem`   | Set container's Security Context readOnlyRootFilesystem                                                                                                                                                    | `false`          |
| `containerSecurityContext.allowPrivilegeEscalation` | Set container's Security Context allowPrivilegeEscalation                                                                                                                                                  | `false`          |
| `containerSecurityContext.capabilities.drop`        | List of capabilities to be dropped                                                                                                                                                                         | `["ALL"]`        |
| `containerSecurityContext.seccompProfile.type`      | Set container's Security Context seccomp profile                                                                                                                                                           | `RuntimeDefault` |
| `livenessProbe.enabled`                             | Enable livenessProbe on WordPress containers                                                                                                                                                               | `true`           |
| `livenessProbe.initialDelaySeconds`                 | Initial delay seconds for livenessProbe                                                                                                                                                                    | `120`            |
| `livenessProbe.periodSeconds`                       | Period seconds for livenessProbe                                                                                                                                                                           | `10`             |
| `livenessProbe.timeoutSeconds`                      | Timeout seconds for livenessProbe                                                                                                                                                                          | `5`              |
| `livenessProbe.failureThreshold`                    | Failure threshold for livenessProbe                                                                                                                                                                        | `6`              |
| `livenessProbe.successThreshold`                    | Success threshold for livenessProbe                                                                                                                                                                        | `1`              |
| `readinessProbe.enabled`                            | Enable readinessProbe on WordPress containers                                                                                                                                                              | `true`           |
| `readinessProbe.initialDelaySeconds`                | Initial delay seconds for readinessProbe                                                                                                                                                                   | `30`             |
| `readinessProbe.periodSeconds`                      | Period seconds for readinessProbe                                                                                                                                                                          | `10`             |
| `readinessProbe.timeoutSeconds`                     | Timeout seconds for readinessProbe                                                                                                                                                                         | `5`              |
| `readinessProbe.failureThreshold`                   | Failure threshold for readinessProbe                                                                                                                                                                       | `6`              |
| `readinessProbe.successThreshold`                   | Success threshold for readinessProbe                                                                                                                                                                       | `1`              |
| `startupProbe.enabled`                              | Enable startupProbe on WordPress containers                                                                                                                                                                | `false`          |
| `startupProbe.initialDelaySeconds`                  | Initial delay seconds for startupProbe                                                                                                                                                                     | `30`             |
| `startupProbe.periodSeconds`                        | Period seconds for startupProbe                                                                                                                                                                            | `10`             |
| `startupProbe.timeoutSeconds`                       | Timeout seconds for startupProbe                                                                                                                                                                           | `5`              |
| `startupProbe.failureThreshold`                     | Failure threshold for startupProbe                                                                                                                                                                         | `6`              |
| `startupProbe.successThreshold`                     | Success threshold for startupProbe                                                                                                                                                                         | `1`              |
| `customLivenessProbe`                               | Custom livenessProbe that overrides the default one                                                                                                                                                        | `{}`             |
| `customReadinessProbe`                              | Custom readinessProbe that overrides the default one                                                                                                                                                       | `{}`             |
| `customStartupProbe`                                | Custom startupProbe that overrides the default one                                                                                                                                                         | `{}`             |
| `lifecycleHooks`                                    | for the WordPress container(s) to automate configuration before or after startup                                                                                                                           | `{}`             |

### Traffic Exposure Parameters

| Name                               | Description                                                                                                                                              | Value                    |
| ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------ |
| `service.type`                     | WordPress service type                                                                                                                                   | `LoadBalancer`           |
| `service.ports.http`               | WordPress service HTTP port                                                                                                                              | `80`                     |
| `service.ports.https`              | WordPress service HTTPS port                                                                                                                             | `443`                    |
| `service.httpsTargetPort`          | Target port for HTTPS                                                                                                                                    | `https`                  |
| `service.nodePorts.http`           | Node port for HTTP                                                                                                                                       | `""`                     |
| `service.nodePorts.https`          | Node port for HTTPS                                                                                                                                      | `""`                     |
| `service.sessionAffinity`          | Control where client requests go, to the same pod or round-robin                                                                                         | `None`                   |
| `service.sessionAffinityConfig`    | Additional settings for the sessionAffinity                                                                                                              | `{}`                     |
| `service.clusterIP`                | WordPress service Cluster IP                                                                                                                             | `""`                     |
| `service.loadBalancerIP`           | WordPress service Load Balancer IP                                                                                                                       | `""`                     |
| `service.loadBalancerSourceRanges` | WordPress service Load Balancer sources                                                                                                                  | `[]`                     |
| `service.externalTrafficPolicy`    | WordPress service external traffic policy                                                                                                                | `Cluster`                |
| `service.annotations`              | Additional custom annotations for WordPress service                                                                                                      | `{}`                     |
| `service.extraPorts`               | Extra port to expose on WordPress service                                                                                                                | `[]`                     |
| `ingress.enabled`                  | Enable ingress record generation for WordPress                                                                                                           | `false`                  |
| `ingress.pathType`                 | Ingress path type                                                                                                                                        | `ImplementationSpecific` |
| `ingress.apiVersion`               | Force Ingress API version (automatically detected if not set)                                                                                            | `""`                     |
| `ingress.ingressClassName`         | IngressClass that will be be used to implement the Ingress (Kubernetes 1.18+)                                                                            | `""`                     |
| `ingress.hostname`                 | Default host for the ingress record. The hostname is templated and thus can contain other variable references.                                           | `wordpress.local`        |
| `ingress.path`                     | Default path for the ingress record                                                                                                                      | `/`                      |
| `ingress.annotations`              | Additional annotations for the Ingress resource. To enable certificate autogeneration, place here your cert-manager annotations.                         | `{}`                     |
| `ingress.tls`                      | Enable TLS configuration for the host defined at `ingress.hostname` parameter                                                                            | `false`                  |
| `ingress.tlsWwwPrefix`             | Adds www subdomain to default cert                                                                                                                       | `false`                  |
| `ingress.selfSigned`               | Create a TLS secret for this ingress record using self-signed certificates generated by Helm                                                             | `false`                  |
| `ingress.extraHosts`               | An array with additional hostname(s) to be covered with the ingress record. The host names are templated and thus can contain other variable references. | `[]`                     |
| `ingress.extraPaths`               | An array with additional arbitrary paths that may need to be added to the ingress under the main host                                                    | `[]`                     |
| `ingress.extraTls`                 | TLS configuration for additional hostname(s) to be covered with this ingress record                                                                      | `[]`                     |
| `ingress.secrets`                  | Custom TLS certificates as secrets                                                                                                                       | `[]`                     |
| `ingress.extraRules`               | Additional rules to be covered with this ingress record                                                                                                  | `[]`                     |

### Persistence Parameters

| Name                                                        | Description                                                                                                                                                                                                                                    | Value                      |
| ----------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------- |
| `persistence.enabled`                                       | Enable persistence using Persistent Volume Claims                                                                                                                                                                                              | `true`                     |
| `persistence.storageClass`                                  | Persistent Volume storage class                                                                                                                                                                                                                | `""`                       |
| `persistence.accessModes`                                   | Persistent Volume access modes                                                                                                                                                                                                                 | `[]`                       |
| `persistence.accessMode`                                    | Persistent Volume access mode (DEPRECATED: use `persistence.accessModes` instead)                                                                                                                                                              | `ReadWriteOnce`            |
| `persistence.size`                                          | Persistent Volume size                                                                                                                                                                                                                         | `10Gi`                     |
| `persistence.dataSource`                                    | Custom PVC data source                                                                                                                                                                                                                         | `{}`                       |
| `persistence.existingClaim`                                 | The name of an existing PVC to use for persistence                                                                                                                                                                                             | `""`                       |
| `persistence.selector`                                      | Selector to match an existing Persistent Volume for WordPress data PVC                                                                                                                                                                         | `{}`                       |
| `persistence.annotations`                                   | Persistent Volume Claim annotations                                                                                                                                                                                                            | `{}`                       |
| `volumePermissions.enabled`                                 | Enable init container that changes the owner/group of the PV mount point to `runAsUser:fsGroup`                                                                                                                                                | `false`                    |
| `volumePermissions.image.registry`                          | OS Shell + Utility image registry                                                                                                                                                                                                              | `REGISTRY_NAME`            |
| `volumePermissions.image.repository`                        | OS Shell + Utility image repository                                                                                                                                                                                                            | `REPOSITORY_NAME/os-shell` |
| `volumePermissions.image.digest`                            | OS Shell + Utility image digest in the way sha256:aa.... Please note this parameter, if set, will override the tag                                                                                                                             | `""`                       |
| `volumePermissions.image.pullPolicy`                        | OS Shell + Utility image pull policy                                                                                                                                                                                                           | `IfNotPresent`             |
| `volumePermissions.image.pullSecrets`                       | OS Shell + Utility image pull secrets                                                                                                                                                                                                          | `[]`                       |
| `volumePermissions.resourcesPreset`                         | Set container resources according to one common preset (allowed values: none, nano, small, medium, large, xlarge, 2xlarge). This is ignored if volumePermissions.resources is set (volumePermissions.resources is recommended for production). | `none`                     |
| `volumePermissions.resources`                               | Set container requests and limits for different resources like CPU or memory (essential for production workloads)                                                                                                                              | `{}`                       |
| `volumePermissions.containerSecurityContext.seLinuxOptions` | Set SELinux options in container                                                                                                                                                                                                               | `nil`                      |
| `volumePermissions.containerSecurityContext.runAsUser`      | User ID for the init container                                                                                                                                                                                                                 | `0`                        |

### Other Parameters

| Name                                          | Description                                                            | Value   |
| --------------------------------------------- | ---------------------------------------------------------------------- | ------- |
| `serviceAccount.create`                       | Enable creation of ServiceAccount for WordPress pod                    | `true`  |
| `serviceAccount.name`                         | The name of the ServiceAccount to use.                                 | `""`    |
| `serviceAccount.automountServiceAccountToken` | Allows auto mount of ServiceAccountToken on the serviceAccount created | `false` |
| `serviceAccount.annotations`                  | Additional custom annotations for the ServiceAccount                   | `{}`    |
| `pdb.create`                                  | Enable a Pod Disruption Budget creation                                | `false` |
| `pdb.minAvailable`                            | Minimum number/percentage of pods that should remain scheduled         | `1`     |
| `pdb.maxUnavailable`                          | Maximum number/percentage of pods that may be made unavailable         | `""`    |
| `autoscaling.enabled`                         | Enable Horizontal POD autoscaling for WordPress                        | `false` |
| `autoscaling.minReplicas`                     | Minimum number of WordPress replicas                                   | `1`     |
| `autoscaling.maxReplicas`                     | Maximum number of WordPress replicas                                   | `11`    |
| `autoscaling.targetCPU`                       | Target CPU utilization percentage                                      | `50`    |
| `autoscaling.targetMemory`                    | Target Memory utilization percentage                                   | `50`    |

### Metrics Parameters

| Name                                                        | Description                                                                                                                                                                                                                | Value                             |
| ----------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------- |
| `metrics.enabled`                                           | Start a sidecar prometheus exporter to expose metrics                                                                                                                                                                      | `false`                           |
| `metrics.image.registry`                                    | Apache exporter image registry                                                                                                                                                                                             | `REGISTRY_NAME`                   |
| `metrics.image.repository`                                  | Apache exporter image repository                                                                                                                                                                                           | `REPOSITORY_NAME/apache-exporter` |
| `metrics.image.digest`                                      | Apache exporter image digest in the way sha256:aa.... Please note this parameter, if set, will override the tag                                                                                                            | `""`                              |
| `metrics.image.pullPolicy`                                  | Apache exporter image pull policy                                                                                                                                                                                          | `IfNotPresent`                    |
| `metrics.image.pullSecrets`                                 | Apache exporter image pull secrets                                                                                                                                                                                         | `[]`                              |
| `metrics.containerPorts.metrics`                            | Prometheus exporter container port                                                                                                                                                                                         | `9117`                            |
| `metrics.livenessProbe.enabled`                             | Enable livenessProbe on Prometheus exporter containers                                                                                                                                                                     | `true`                            |
| `metrics.livenessProbe.initialDelaySeconds`                 | Initial delay seconds for livenessProbe                                                                                                                                                                                    | `15`                              |
| `metrics.livenessProbe.periodSeconds`                       | Period seconds for livenessProbe                                                                                                                                                                                           | `10`                              |
| `metrics.livenessProbe.timeoutSeconds`                      | Timeout seconds for livenessProbe                                                                                                                                                                                          | `5`                               |
| `metrics.livenessProbe.failureThreshold`                    | Failure threshold for livenessProbe                                                                                                                                                                                        | `3`                               |
| `metrics.livenessProbe.successThreshold`                    | Success threshold for livenessProbe                                                                                                                                                                                        | `1`                               |
| `metrics.readinessProbe.enabled`                            | Enable readinessProbe on Prometheus exporter containers                                                                                                                                                                    | `true`                            |
| `metrics.readinessProbe.initialDelaySeconds`                | Initial delay seconds for readinessProbe                                                                                                                                                                                   | `5`                               |
| `metrics.readinessProbe.periodSeconds`                      | Period seconds for readinessProbe                                                                                                                                                                                          | `10`                              |
| `metrics.readinessProbe.timeoutSeconds`                     | Timeout seconds for readinessProbe                                                                                                                                                                                         | `3`                               |
| `metrics.readinessProbe.failureThreshold`                   | Failure threshold for readinessProbe                                                                                                                                                                                       | `3`                               |
| `metrics.readinessProbe.successThreshold`                   | Success threshold for readinessProbe                                                                                                                                                                                       | `1`                               |
| `metrics.startupProbe.enabled`                              | Enable startupProbe on Prometheus exporter containers                                                                                                                                                                      | `false`                           |
| `metrics.startupProbe.initialDelaySeconds`                  | Initial delay seconds for startupProbe                                                                                                                                                                                     | `10`                              |
| `metrics.startupProbe.periodSeconds`                        | Period seconds for startupProbe                                                                                                                                                                                            | `10`                              |
| `metrics.startupProbe.timeoutSeconds`                       | Timeout seconds for startupProbe                                                                                                                                                                                           | `1`                               |
| `metrics.startupProbe.failureThreshold`                     | Failure threshold for startupProbe                                                                                                                                                                                         | `15`                              |
| `metrics.startupProbe.successThreshold`                     | Success threshold for startupProbe                                                                                                                                                                                         | `1`                               |
| `metrics.customLivenessProbe`                               | Custom livenessProbe that overrides the default one                                                                                                                                                                        | `{}`                              |
| `metrics.customReadinessProbe`                              | Custom readinessProbe that overrides the default one                                                                                                                                                                       | `{}`                              |
| `metrics.customStartupProbe`                                | Custom startupProbe that overrides the default one                                                                                                                                                                         | `{}`                              |
| `metrics.resourcesPreset`                                   | Set container resources according to one common preset (allowed values: none, nano, small, medium, large, xlarge, 2xlarge). This is ignored if metrics.resources is set (metrics.resources is recommended for production). | `none`                            |
| `metrics.resources`                                         | Set container requests and limits for different resources like CPU or memory (essential for production workloads)                                                                                                          | `{}`                              |
| `metrics.containerSecurityContext.enabled`                  | Enabled containers' Security Context                                                                                                                                                                                       | `true`                            |
| `metrics.containerSecurityContext.seLinuxOptions`           | Set SELinux options in container                                                                                                                                                                                           | `nil`                             |
| `metrics.containerSecurityContext.runAsUser`                | Set containers' Security Context runAsUser                                                                                                                                                                                 | `1001`                            |
| `metrics.containerSecurityContext.runAsNonRoot`             | Set container's Security Context runAsNonRoot                                                                                                                                                                              | `true`                            |
| `metrics.containerSecurityContext.privileged`               | Set container's Security Context privileged                                                                                                                                                                                | `false`                           |
| `metrics.containerSecurityContext.readOnlyRootFilesystem`   | Set container's Security Context readOnlyRootFilesystem                                                                                                                                                                    | `false`                           |
| `metrics.containerSecurityContext.allowPrivilegeEscalation` | Set container's Security Context allowPrivilegeEscalation                                                                                                                                                                  | `false`                           |
| `metrics.containerSecurityContext.capabilities.drop`        | List of capabilities to be dropped                                                                                                                                                                                         | `["ALL"]`                         |
| `metrics.containerSecurityContext.seccompProfile.type`      | Set container's Security Context seccomp profile                                                                                                                                                                           | `RuntimeDefault`                  |
| `metrics.service.ports.metrics`                             | Prometheus metrics service port                                                                                                                                                                                            | `9150`                            |
| `metrics.service.annotations`                               | Additional custom annotations for Metrics service                                                                                                                                                                          | `{}`                              |
| `metrics.serviceMonitor.enabled`                            | Create ServiceMonitor Resource for scraping metrics using Prometheus Operator                                                                                                                                              | `false`                           |
| `metrics.serviceMonitor.namespace`                          | Namespace for the ServiceMonitor Resource (defaults to the Release Namespace)                                                                                                                                              | `""`                              |
| `metrics.serviceMonitor.interval`                           | Interval at which metrics should be scraped.                                                                                                                                                                               | `""`                              |
| `metrics.serviceMonitor.scrapeTimeout`                      | Timeout after which the scrape is ended                                                                                                                                                                                    | `""`                              |
| `metrics.serviceMonitor.labels`                             | Additional labels that can be used so ServiceMonitor will be discovered by Prometheus                                                                                                                                      | `{}`                              |
| `metrics.serviceMonitor.selector`                           | Prometheus instance selector labels                                                                                                                                                                                        | `{}`                              |
| `metrics.serviceMonitor.relabelings`                        | RelabelConfigs to apply to samples before scraping                                                                                                                                                                         | `[]`                              |
| `metrics.serviceMonitor.metricRelabelings`                  | MetricRelabelConfigs to apply to samples before ingestion                                                                                                                                                                  | `[]`                              |
| `metrics.serviceMonitor.honorLabels`                        | Specify honorLabels parameter to add the scrape endpoint                                                                                                                                                                   | `false`                           |
| `metrics.serviceMonitor.jobLabel`                           | The name of the label on the target service to use as the job name in prometheus.                                                                                                                                          | `""`                              |

### NetworkPolicy parameters

| Name                                                          | Description                                                                                                                  | Value   |
| ------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- | ------- |
| `networkPolicy.enabled`                                       | Enable network policies                                                                                                      | `false` |
| `networkPolicy.metrics.enabled`                               | Enable network policy for metrics (prometheus)                                                                               | `false` |
| `networkPolicy.metrics.namespaceSelector`                     | Monitoring namespace selector labels. These labels will be used to identify the prometheus' namespace.                       | `{}`    |
| `networkPolicy.metrics.podSelector`                           | Monitoring pod selector labels. These labels will be used to identify the Prometheus pods.                                   | `{}`    |
| `networkPolicy.ingress.enabled`                               | Enable network policy for Ingress Proxies                                                                                    | `false` |
| `networkPolicy.ingress.namespaceSelector`                     | Ingress Proxy namespace selector labels. These labels will be used to identify the Ingress Proxy's namespace.                | `{}`    |
| `networkPolicy.ingress.podSelector`                           | Ingress Proxy pods selector labels. These labels will be used to identify the Ingress Proxy pods.                            | `{}`    |
| `networkPolicy.ingressRules.backendOnlyAccessibleByFrontend`  | Enable ingress rule that makes the backend (mariadb) only accessible by testlink's pods.                                     | `false` |
| `networkPolicy.ingressRules.customBackendSelector`            | Backend selector labels. These labels will be used to identify the backend pods.                                             | `{}`    |
| `networkPolicy.ingressRules.accessOnlyFrom.enabled`           | Enable ingress rule that makes testlink only accessible from a particular origin                                             | `false` |
| `networkPolicy.ingressRules.accessOnlyFrom.namespaceSelector` | Namespace selector label that is allowed to access testlink. This label will be used to identified the allowed namespace(s). | `{}`    |
| `networkPolicy.ingressRules.accessOnlyFrom.podSelector`       | Pods selector label that is allowed to access testlink. This label will be used to identified the allowed pod(s).            | `{}`    |
| `networkPolicy.ingressRules.customRules`                      | Custom network policy ingress rule                                                                                           | `{}`    |
| `networkPolicy.egressRules.denyConnectionsToExternal`         | Enable egress rule that denies outgoing traffic outside the cluster, except for DNS (port 53).                               | `false` |
| `networkPolicy.egressRules.customRules`                       | Custom network policy rule                                                                                                   | `{}`    |

### Database Parameters

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