# CloudCasa Kubernetes Agent

[CloudCasa](https://cloudcasa.io) - Leader in Kubernetes Data Protection and Application Mobility

CloudCasa is a SaaS data protection, disaster recovery, migration, and replication solution for Kubernetes and cloud-native applications.
Configuration is quick and easy, and basic service is free.

This pack installs and configures the CloudCasa agent on a Kubernetes cluster.

## Prerequisites

- Kubernetes 1.20 or above
- A CloudCasa account. You can [sign up](https://signup.cloudcasa.io/) for free.
- A CloudCasa **Cluster ID** (see below)

## Parameters

To deploy the CloudCasa agent, you **must** set the `clusterID` parameter to the Cluster ID provided by CloudCasa.
All other parmeters are optional or can be left at their default values.

| Key                              | Type   | Default                                     | Required |
|---                               |---     |---                                          |---       |
| clusterID                        | string | `""`                                        | Yes      |
| image.repository                 | string | `"docker.io/catalogicsoftware/amds-kagent"` | Yes      |
| image.tag                        | string | `"3.1.0-prod"`                              | Yes      |
| imagePullSecret                  | string | `null`                                      | No       |

## Usage

1. Log in to https://home.cloudcasa.io and add your Kubernetes cluster under Clusters/Overview. Note the returned cluster ID.
2. Install the pack, setting the `clusterID` parameter to the returned ID.

This will install the CloudCasa agent and complete registration of the cluster with the CloudCasa service.

###Using an alternate image repository

The agent manager container can be installed from an alternate repository by setting values for image.repository and image.tag.
Note that the alternate repository will also need to be set for the cluster in CloudCasa so that all agent containers will be loaded from it.
See the [CloudCasa User Guide](https://docs.cloudcasa.io/help/cluster-add.html) for more information.

If the registry you are using requires authentication, you can define a Kubernetes secret with the authentication information
and reference it by setting a value for imagePullSecret.
See the [Kubernetes Docs](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/) for more information.
Note that the secret name will also need to be set for the cluster in CloudCasa so that it will be used for all agent containers.
See the [CloudCasa User Guide](https://docs.cloudcasa.io/help/cluster-add.html) for more information.

## References

- The CloudCasa Website: [https://cloudcasa.io](https://cloudcasa.io/)
- The CloudCasa [User Guide](https://docs.cloudcasa.io/help/)
- The CloudCasa [Getting Started Guide](https://cloudcasa.io/get-started)

*CloudCasa is a trademark of Catalogic Software, Inc.*
