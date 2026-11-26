# OpenObserve
OpenObserve is a cloud-native observability platform built for logs, metrics, traces, and real user monitoring (RUM). It provides a unified solution for collecting, storing, and analyzing telemetry data with high performance and cost efficiency.

## Prerequisites
- An active account in any of the below mentioned environments with privileges to launch Kubernetes cluster with OpenObserve as an addon.
- Supported cloud types -  vsphere, maas, edge-native
- Postgresql pack installed
- Network connectivity between metrics collector/scraper and this service.

## Parameters

| Name | Description | Type | Default Value | Required |
| --- | --- | --- | --- | --- |
| service.type | Type of Kubernetes service to expose OpenObserve. | String | `LoadBalancer` | Yes |
| service.http_port | HTTP port for the OpenObserve service. | Integer | `5080` | No |
| service.grpc_port | gRPC port for the OpenObserve service. | Integer | `5081` | No |
| auth.ZO_ROOT_USER_EMAIL | Root user email for authentication. | String | `admin@openobserve.dev` | Yes |
| auth.ZO_ROOT_USER_PASSWORD | Root user password for authentication. | String | `<password>` | Yes |
| auth.ZO_S3_ACCESS_KEY | AWS access key to access s3 bucket. | String | `<enter-access-key>` | Yes |
| auth.ZO_S3_SECRET_KEY | AWS secret key to access s3 bucket. | String | `<enter-secret-key>` | Yes |
| config.ZO_LOCAL_MODE | Set this to true to use local storage mode. | String | `false` | Yes |
| replicaCount.ingester | Number of ingester replicas. | Integer | `1` | No |
| replicaCount.querier | Number of querier replicas. | Integer | `1` | No |
| replicaCount.router | Number of router replicas. | Integer | `1` | No |
| replicaCount.compactor | Number of compactor replicas. | Integer | `1` | No |
| replicaCount.alertmanager | Number of alertmanager replicas. | Integer | `1` | No |
| config.ZO_META_STORE | Metadata store type (postgres, etcd). | String | `postgres` | No |
| config.ZO_CLUSTER_COORDINATOR | Cluster coordination mechanism (nats, etcd). | String | `nats` | No |
| config.ZO_QUEUE_STORE | Queue store type (nats, etcd). | String | `nats` | No |
| config.ZO_S3_REGION_NAME | Name of the region where s3 bucket is located | String | "us-east-2" | yes |
| config.ZO_S3_BUCKET_NAME | Name of the s3 bucket | String | "<enter-bucket-name>" | yes |

## Upgrade
Upgrade from older version to this version is supported, but make sure to upgrade the dependency pack postgresql from 1.22.1 to 1.29.0 too.

## Usage
Add the OpenObserve addon pack in your cluster profile. Configure credentials and other parameters as described above. Launch the cluster in desired infrastructure. Once the cluster is up, access the OpenObserve UI through the LoadBalancer service endpoint. Configure data sources and start observing/monitoring telemetry data from your applications and infrastructure.

## Airgap Support
While using this pack in airgap mode, make sure to set charts.openobserve.config.ZO_LOCAL_MODE to "true"

## References:
* [OpenObserve Documentation](https://openobserve.ai/docs/)
* [OpenObserve GitHub](https://github.com/openobserve/openobserve)
* [OpenObserve Helm Chart](https://github.com/openobserve/openobserve-helm-charts) %
