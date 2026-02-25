# Elastic Cloud on Kubernetes (ECK)

Elastic Cloud on Kubernetes automates the deployment, provisioning, management, and orchestration of Elasticsearch, Kibana, APM Server, Enterprise Search, Beats, Elastic Agent, Elastic Maps Server, and Logstash on Kubernetes based on the operator pattern.

Current features:

*  Elasticsearch, Kibana, APM Server, Enterprise Search, and Beats deployments
*  TLS Certificates management
*  Safe Elasticsearch cluster configuration & topology changes
*  Persistent volumes usage
*  Custom node configuration and attributes
*  Secure settings keystore updates

Supported versions:

*  Kubernetes 1.25-1.29
*  Elasticsearch, Kibana, APM Server: 6.8+, 7.1+, 8+, 9+
*  Enterprise Search: 7.7+, 8+
*  Beats: 7.0+, 8+, 9+
*  Elastic Agent: 7.10+ (standalone), 7.14+, 8+ (Fleet), 9+
*  Elastic Maps Server: 7.11+, 8+
*  Logstash 8.7+, 9+

Check the [Quickstart](https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-quickstart.html) to deploy your first cluster with ECK.

For general questions, please see the Elastic [forums](https://discuss.elastic.co/c/eck).

# ECK-Stack

ECK Stack is a Helm chart to assist in the deployment of Elastic Stack components, which are
managed by the [ECK Operator](https://www.elastic.co/guide/en/cloud-on-k8s/current/index.html)

## Supported Elastic Stack Resources

The following Elastic Stack resources are currently supported. 

- Elasticsearch
- Kibana
- Elastic Agent
- Fleet Server
- Beats
- Logstash
- APM Server

Additional resources will be supported in future releases of this Helm Chart.

## Upgrade

To upgrade the stack to a newer version, follow these general steps:

1. Check Compatibility: Ensure your Kubernetes cluster remains within the supported version range (1.25-1.29 for general ECK features).
2. Review CRDs: Verify if the new version of the ECK Operator requires updated Custom Resource Definitions.
3. Helm Upgrade: Run the standard upgrade command: helm upgrade <release-name> elastic/eck-stack

## Usage

The chart currently supports the deployment of the following resources:

- Elasticsearch & Kibana: Enabled by default for immediate cluster setup.
- Agents & Servers: Optional deployment of Elastic Agent, Fleet Server, Beats, Logstash, and APM Server.
- Security: Features include automated TLS Certificates management and secure settings via keystore updates.
- Persistence: Utilizes Persistent Volumes for data storage across cluster changes.

## Prerequisites

- Kubernetes 1.27+
- Elastic ECK Operator

## Parameters

The following table lists the configurable parameters of the eck-stack chart and their default values.

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `eck-elasticsearch.enabled` | If `true`, create an Elasticsearch resource (using the eck-elasticsearch Chart) | `true` |
| `eck-kibana.enabled` | If `true`, create a Kibana resource (using the eck-kibana Chart) | `true` |
| `eck-agent.enabled` | If `true`, create an Elastic Agent resource (using the eck-agent Chart) | `false` |
| `eck-fleet-server.enabled` | If `true`, create a Fleet Server resource (using the eck-fleet-server Chart) | `false` |
| `eck-logstash.enabled` | If `true`, create a Logstash resource (using the eck-logstash Chart) | `false` |
| `eck-apm-server.enabled` | If `true`, create a standalone Elastic APM Server resource (using the eck-apm-server Chart) | `false` |

## References

Quickstart Guide: https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-quickstart.html
Official Documentation: https://www.elastic.co/guide/en/cloud-on-k8s/current/index.html
Community Support: https://discuss.elastic.co/c/eck

