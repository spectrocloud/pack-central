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
*  Enterprise Search: 7.7+, 8+, 9+
*  Beats: 7.0+, 8+, 9+
*  Elastic Agent: 7.10+ (standalone), 7.14+, 8+ (Fleet), 9+
*  Elastic Maps Server: 7.11+, 8+, 9+
*  Logstash 8.7+

Check the [Quickstart](https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-quickstart.html) to deploy your first cluster with ECK.

For general questions, please see the Elastic [forums](https://discuss.elastic.co/c/eck).

# ECK Operator Helm Chart

A Helm chart to install the ECK Operator: the official Kubernetes operator from Elastic to orchestrate Elasticsearch, Kibana, APM Server, Enterprise Search, and Beats on Kubernetes.

## Requirements

- Supported Kubernetes versions are listed in the documentation: https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s_supported_versions.html

## Usage

Refer to the documentation at https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-install-helm.html

## References

For more information about the ECK Operator, see:
- [Documentation](https://www.elastic.co/guide/en/cloud-on-k8s/current/index.html)
- [GitHub repo](https://github.com/elastic/cloud-on-k8s)