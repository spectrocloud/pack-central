# Veeam Kasten

The [Veeam Kasten](https://docs.kasten.io/) data management platform, purpose-built for Kubernetes, provides
enterprise operations teams an easy-to-use, scalable, and secure system for backup/restore, disaster recovery,
mobility, and ransomware protection of Kubernetes applications.


## Prerequisites

- Kubernetes **1.29** and higher are supported.  
- Supported cloud types: **All clouds**.
- A CSI-based storage provisioner that includes VolumeSnapshot support is highly recommended

### Pre-flight Checks

By installing the `primer` tool, you can perform pre-flight checks
provided that your default `kubectl` context is pointed to the cluster
you intend to install Veeam Kasten on. This tool runs in a cluster pod
and performs the following operations:

- Validates if the Kubernetes settings meet the Veeam Kasten
    requirements.
- Catalogs the available StorageClasses.
- If a CSI provisioner exists, it will also perform basic validation
    of the cluster\'s CSI capabilities and any relevant objects that may
    be required. It is strongly recommended that the same tool be used
    to perform a more comprehensive CSI validation using the
    documentation [here](https://docs.kasten.io/storage.md#csi-preflight).

Note that running the pre-flight checks using the `primer` tool will
create and subsequently clean up a ServiceAccount and ClusterRoleBinding
to perform sanity checks on your Kubernetes cluster.

The `primer` tool assumes that the [Helm 3 package
manager](https://helm.sh/) is installed and access to the Veeam Kasten
Helm Charts repository is configured.

Run the following command to deploy the the pre-check tool:

``` bash
$ curl https://docs.kasten.io/downloads/|version|/tools/k10_primer.sh | bash
```

To run the pre-flight checks in an air-gapped environment, use the
following command:

``` bash
$ curl https://docs.kasten.io/downloads/|version|/tools/k10_primer.sh | bash /dev/stdin -i repo.example.com/k10tools:|version|
```

## Parameters

| **Parameter** | **Description** | **Type** | **Default Value** | **Required** |
|---|---|---|---|---|
| auth.basicAuth.enabled | Enables basic authentication to the K10 dashboard that allows users to login with username and password | bool | false | No |
| auth.basicAuth.htpasswd | A username and password pair separated by a colon character | string | "" | No |
| ingress.class | Cluster ingress controller class (e.g. nginx) | string | "" | No |
| ingress.create | Specifies whether the K10 dashboard should be exposed via ingress | bool | false | No |
| ingress.urlPath | URL path for K10 Dashboard. Defaults to /k10 | string | "/k10" | No |

## Upgrade

- Currently, upgrades are only supported across a maximum of four versions (e.g., 8.0.10 -> 8.0.14). If your Veeam Kasten version is further behind the latest, a step upgrade process is recommended
- Review the latest [Release Notes](https://docs.kasten.io/latest/releasenotes) to ensure no breaking changes


## Usage

Veeam Kasten is installed as a set of **Deployments** in the `kasten-io` namespace. Once deployed, Kasten's dashboard can be access via kubectl port forward, a LoadBalancer, or an Ingress, depending upon the parameters specified at the time of installation.

- For a full list of all install options, review the [Complete List of Veeam Kasten Helm Options](https://docs.kasten.io/latest/install/advanced#helm-options)
- For a complete usage guideline, see [Using Veeam Kasten](https://docs.kasten.io/latest/usage/usage)
- For more detail on Veeam Kasten Dashboard access, see the [Veeam Kasten Dashboard Access Documentation](https://docs.kasten.io/latest/usage/usage)


## References

- [Veeam Kasten Documentation](https://docs.kasten.io)
- [Veeam Kasten Best Practices](https://docs.kasten.io/latest/references/best-practices)