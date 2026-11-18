# Kubevious

Kubevious is an open-source Kubernetes dashboard and configuration validator. It provides a visual representation of cluster resources, detects misconfigurations, and surfaces policy violations in real time. The pack deploys the full Kubevious stack — backend, collector, guard, parser, UI, MySQL, and Redis — into a dedicated `kubevious` namespace.


## Prerequisites

- A Kubernetes cluster with a working **dynamic storage provisioner** (required for the MySQL PersistentVolumeClaim; default size: 10Gi).
- Minimum cluster capacity available on worker nodes: **512m CPU** and **1636Mi memory**.


## Parameters

| **Parameter** | **Description** | **Type** | **Default Value** | **Required** |
|---|---|---|---|---|
| `charts.kubevious.ingress.enabled` | Enables or disables the Ingress resource for the Kubevious UI. | Boolean | `false` | No |
| `charts.kubevious.ingress.className` | IngressClass name to use. | String | `""` | No |
| `charts.kubevious.ingress.hosts[0].host` | Hostname for the Ingress rule. | String | `""` | Yes, if ingress is enabled |
| `charts.kubevious.mysql.external.enabled` | Use an external MySQL instance instead of the bundled one. | Boolean | `false` | No |
| `charts.kubevious.mysql.external.host` | Hostname of the external MySQL server. | String | `""` | Yes, if external MySQL is enabled |
| `charts.kubevious.mysql.external.port` | Port of the external MySQL server. | String | `""` | Yes, if external MySQL is enabled |
| `charts.kubevious.mysql.external.database` | Database name on the external MySQL server. | String | `""` | Yes, if external MySQL is enabled |
| `charts.kubevious.mysql.external.user` | Username for the external MySQL server. | String | `""` | Yes, if external MySQL is enabled |
| `charts.kubevious.mysql.external.password` | Password for the external MySQL server. | String | `""` | Yes, if external MySQL is enabled |
| `charts.kubevious.mysql.generate_passwords` | Auto-generate MySQL passwords. When `false`, `db_password` and `root_password` must be set manually. | Boolean | `false` | No |
| `charts.kubevious.mysql.db_password` | Password for the Kubevious MySQL user. | String | `""` | Yes, if `generate_passwords` is `false` |
| `charts.kubevious.mysql.root_password` | MySQL root password. | String | `""` | Yes, if `generate_passwords` is `false` |
| `charts.kubevious.mysql.persistence.size` | PersistentVolumeClaim size for MySQL data. | String | `"10Gi"` | No |
| `charts.kubevious.mysql.persistence.storageClass` | StorageClass for the MySQL PVC. Leave empty to use the cluster default. | String | `""` | No |
| `charts.kubevious.worldvious.opt_out_all` | Opt out of all anonymous telemetry reporting (version checks, error reports, counter and metric reports). | Boolean | `false` | No |


## Upgrade

- When upgrading from a version that used `kubevious/mysql` to a version using an external MySQL instance, migrate the database manually before enabling `mysql.external`.
- MySQL passwords are not rotated automatically on upgrade. If `generate_passwords` was `false` and passwords were left empty on the initial install, set them explicitly before upgrading to avoid authentication failures.


## Usage

### Accessing the Kubevious UI

By default, the UI service is of type `ClusterIP` on port 80. To access it locally, use port-forward:

```sh
kubectl port-forward svc/kubevious-ui 8080:80 -n kubevious
```

Then open `http://localhost:8080` in your browser.

### Enabling Ingress

Select the **Enable** preset under the **Ingress** group in the Spectro Cloud UI, or set the following parameters:

```yaml
charts:
  kubevious:
    ingress:
      enabled: true
      hosts:
        - host: kubevious.example.com
          paths:
            - path: /
              pathType: ImplementationSpecific
```

### Using an External MySQL Instance

To connect Kubevious to an existing MySQL database instead of deploying the bundled one:

```yaml
charts:
  kubevious:
    mysql:
      external:
        enabled: true
        host: "mysql.example.com"
        port: "3306"
        database: "kubevious"
        user: "kubevious"
        password: "your-password"
```

### Disabling Telemetry

To opt out of all anonymous reporting to [worldvious.io](https://worldvious.io):

```yaml
charts:
  kubevious:
    worldvious:
      opt_out_all: true
```


## References

- [Kubevious Official Documentation](https://kubevious.io/docs)
- [Kubevious GitHub Repository](https://github.com/kubevious/kubevious)
- [Kubevious Helm Chart](https://helm.kubevious.io)
- [Spectro Cloud Integrations — Kubevious](https://docs.spectrocloud.com/integrations/kubevious)
