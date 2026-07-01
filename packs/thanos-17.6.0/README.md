<!--- app-name: Thanos -->

## Pack Description
Thanos is a highly available metrics system designed to be added on top of existing Prometheus deployments, providing a global, unified query view across all Prometheus installations.

This Helm chart simplifies the deployment of Thanos on a Kubernetes cluster using Bitnami Secure Images (based on Photon Linux). These images are hardened, minimized for CVEs, and tailored to meet enterprise security compliance.

---

## Prerequisites
* **Kubernetes:** Version 1.29 or higher.
* **Helm:** Version 3.8.0 or higher.
* **Storage:** Support for a Persistent Volume provisioner (PV provisioner) in the underlying infrastructure.

---

## Usage
To perform a quick installation of this chart under the release name "my-release", execute the following command:

    helm install my-release oci://registry-1.docker.io/bitnamicharts/thanos

---

## Parameters
The chart configuration options are detailed within the documentation, divided into these primary blocks:

* **Global Parameters (global.*):** General settings such as the global Docker registry (global.imageRegistry), image pull secrets (global.imagePullSecrets), and the default storage class (global.defaultStorageClass).
* **Thanos Common Parameters (image.*, objstoreConfig):** Options shared across all components, including the base image configuration (image.registry, image.repository), object store settings (objstoreConfig, existingObjstoreSecret), and TLS/HTTPS setups.
* **Component-Specific Parameters:** Fine-grained configuration sections to enable, scale (replicas and CPU/Memory resource allocations), configure ports, and manage health probes (Liveness/Readiness) for each specific sub-component:
  * query (Querier module)
  * queryFrontend
  * bucketweb
  * compactor
  * ruler
  * receive

---

## Upgrade

### Upgrading to 1.0.0 or Higher
If you are upgrading from a version lower than <1.0.0, you are required to migrate the Querier Ingress settings to the new structured values layout due to breaking configuration changes in the chart schema:

    ingress.enabled                  -> querier.ingress.enabled
    ingress.certManager              -> querier.ingress.certManager
    ingress.hostname                 -> querier.ingress.hostname
    ingress.annotations              -> querier.ingress.annotations
    ingress.extraHosts[0].name       -> querier.ingress.extraHosts[0].name
    ingress.extraHosts[0].path       -> querier.ingress.extraHosts[0].path
    ingress.extraHosts[0].hosts[0]   -> querier.ingress.extraHosts[0].hosts[0]
    ingress.extraHosts[0].secretName -> querier.ingress.extraHosts[0].secretName
    ingress.secrets[0].name          -> querier.ingress.secrets[0].name
    ingress.secrets[0].certificate   -> querier.ingress.secrets[0].certificate
    ingress.secrets[0].key           -> querier.ingress.secrets[0].key

*Note:* It is strongly recommended to use immutable image tags (fixed tags instead of "latest") in production environments to maintain deployment stability during automated chart upgrades.

---

## References
* **Thanos Official Website:** https://thanos.io/
* **Thanos Bitnami Containers Repository:** https://github.com/bitnami/containers/tree/main/bitnami/thanos
* **Bitnami Public Applications Catalog:** https://app-catalog.vmware.com/bitnami/apps
* **Backup and Restore Guide with Velero:** https://techdocs.broadcom.com/us/en/vmware-tanzu/application-catalog/tanzu-application-catalog/services/tac-doc/apps-tutorials-backup-restore-deployments-velero-index.html
