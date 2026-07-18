# Cert Manager

## Description

cert-manager automates the management and issuance of TLS certificates for workloads running on Kubernetes and OpenShift clusters. It obtains certificates from multiple certificate authorities such as Let's Encrypt, HashiCorp Vault, CyberArk, and private PKI providers, while automatically renewing certificates before expiration.

---

## Prerequisites

Before installing this pack, ensure the following requirements are met:

- A supported Kubernetes cluster.
- Helm 3.x installed.
- Cluster administrator privileges.
- Custom Resource Definitions (CRDs) enabled during installation.

For supported Kubernetes versions, refer to the official cert-manager documentation.

---

## Parameters

The following are the most commonly configured parameters.

| Parameter | Description | Default |
|----------|-------------|---------|
| `crds.enabled` | Installs the cert-manager Custom Resource Definitions. | `false` |
| `crds.keep` | Prevents CRDs from being removed during uninstall. | `true` |
| `replicaCount` | Number of controller replicas. | `1` |
| `global.logLevel` | Logging verbosity (0-6). | `2` |
| `global.rbac.create` | Creates required RBAC resources. | `true` |
| `prometheus.enabled` | Enables Prometheus metrics. | `true` |
| `webhook.replicaCount` | Number of webhook replicas. | `1` |
| `cainjector.enabled` | Deploys the CA Injector component. | `true` |
| `startupapicheck.enabled` | Runs startup API validation after installation. | `true` |

For the complete list of configurable parameters, refer to the Helm chart values documentation.

---

## Usage

Install the chart using Helm:

```bash
helm install cert-manager oci://quay.io/jetstack/charts/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.21.0 \
  --set crds.enabled=true
```

After installation, create an `Issuer` or `ClusterIssuer` resource to begin issuing certificates.

Example:

```bash
kubectl apply -f clusterissuer.yaml
```

Once an issuer is configured, certificates can be requested through Certificate resources or automatically via supported Ingress resources.

---

## Upgrade

Before upgrading cert-manager, review the official upgrade documentation to identify any version-specific considerations.

Upgrade using Helm:

```bash
helm upgrade cert-manager oci://quay.io/jetstack/charts/cert-manager \
  --namespace cert-manager \
  --version <new-version>
```

It is recommended to review release notes before upgrading between major or minor versions.

---

## References

- Official Documentation: https://cert-manager.io/docs/
- Installation Guide: https://cert-manager.io/docs/installation/helm/
- Upgrade Guide: https://cert-manager.io/docs/installation/upgrading/
- Supported Kubernetes Releases: https://cert-manager.io/docs/releases/
- Issuer Configuration: https://cert-manager.io/docs/configuration/
- Ingress Integration: https://cert-manager.io/docs/usage/ingress/