# Archivista

![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

Helm chart for Archivista - a graph and storage service for in-toto attestations.

## Prerequisites

A MySQL database and S3 compatible store are needed to successfully install this Helm chart.
Refer to the [Archivista configuration](https://github.com/in-toto/archivista#configuration) configuration guide for environment variables needed
to establish connections to each datastore. These environment variables can be added to this Helm chart using the value `deployment.env[]`.

## Parameters

| Key                                        | Type   | Default       |
|---                                         |---     |---            |
| affinity                                   | object | `{}`          |
| autoscaling.enabled                        | bool   | `false`       |
| autoscaling.maxReplicas                    | int    | `10`          |
| autoscaling.minReplicas                    | int    | `1`           |
| autoscaling.targetCPUUtilizationPercentage | int    | `80`          |
| deployment.env                             | list   | `[]`          |
| fullnameOverride                           | string | `""`          |
| image.pullPolicy                           | string | `"IfNotPresent"` |
| image.repository                           | string | `"ghcr.io/testifysec/archivista"` |
| image.tag                                  | string | `"0.1.1"`     |
| ingress.annotations                        | object | `{}`          |
| ingress.className                          | string | `""`          |
| ingress.enabled                            | bool   | `true`        |
| ingress.hosts[0].host                      | string | `"archivista.localhost"` |
| ingress.hosts[0].path                      | string | `"/"`         |
| ingress.tls                                | list   | `[]`          |
| nameOverride                               | string | `""`          |
| nodeSelector                               | object | `{}`          |
| podAnnotations                             | object | `{}`          |
| podSecurityContext                         | object | `{}`          |
| replicaCount                               | int    | `1`           |
| resources                                  | object | `{}`          |
| serviceAccount.annotations                 | object | `{}`          |
| serviceAccount.create                      | bool   | `false`       |
| serviceAccount.name                        | string | `""`          |
| service.port                               | int    | `8082`        |
| service.type                               | string | `"ClusterIP"` |
| tolerations                                | list   | `[]`          |

## Usage
You can find additional guidance in the [Archivista Github](https://github.com/in-toto/archivista/blob/main/README.md) README.

## References

- [Archivista Helm Chart](https://github.com/in-toto/archivista/chart)
- [Archivista](https://github.com/in-toto/archivista)
- [in-toto](https://in-toto.io/)