# KubeRay

KubeRay is a powerful, open-source Kubernetes operator that simplifies the deployment and management of [Ray](https://github.com/ray-project/ray) applications on Kubernetes. It offers several key components:

**KubeRay core**: This is the official, fully-maintained component of KubeRay that provides three custom resource definitions, RayCluster, RayJob, and RayService. These resources are designed to help you run a wide range of workloads with ease.

* **RayCluster**: KubeRay fully manages the lifecycle of RayCluster, including cluster creation/deletion, autoscaling, and ensuring fault tolerance.

* **RayJob**: With RayJob, KubeRay automatically creates a RayCluster and submits a job when the cluster is ready. You can also configure RayJob to automatically delete the RayCluster once the job finishes.

* **RayService**: RayService is made up of two parts: a RayCluster and a Ray Serve deployment graph. RayService offers zero-downtime upgrades for RayCluster and high availability.

**KubeRay ecosystem**: Some optional components.

* **Kubectl Plugin** (Beta): Starting from KubeRay v1.3.0, you can use the `kubectl ray` plugin to simplify
common workflows when deploying Ray on Kubernetes. If you aren’t familiar with Kubernetes, this
plugin simplifies running Ray on Kubernetes. See [kubectl-plugin](https://docs.ray.io/en/latest/cluster/kubernetes/user-guides/kubectl-plugin.html#kubectl-plugin) for more details.

* **KubeRay APIServer** (Alpha): It provides a layer of simplified configuration for KubeRay resources. The KubeRay API server is used internally
by some organizations to back user interfaces for KubeRay resource management.

* **KubeRay Dashboard** (Experimental): Starting from KubeRay v1.4.0, we have introduced a new dashboard that enables users to view and manage KubeRay resources.
While it is not yet production-ready, we welcome your feedback.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| nameOverride | string | `"kuberay-operator"` | String to partially override release name. |
| fullnameOverride | string | `"kuberay-operator"` | String to fully override release name. |
| componentOverride | string | `"kuberay-operator"` | String to override component name. |
| replicas | int | `1` | Number of replicas for the KubeRay operator Deployment. |
| image.repository | string | `"quay.io/kuberay/operator"` | Image repository. |
| image.tag | string | `"v1.5.1"` | Image tag. |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| imagePullSecrets | list | `[]` | Secrets with credentials to pull images from a private registry |
| nodeSelector | object | `{}` | Restrict to run on particular nodes. |
| priorityClassName | string | `""` | Pod priorityClassName |
| labels | object | `{}` | Extra labels. |
| annotations | object | `{}` | Extra annotations. |
| affinity | object | `{}` | Pod affinity |
| tolerations | list | `[]` | Pod tolerations |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created. |
| serviceAccount.name | string | `"kuberay-operator"` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template. |
| logging.stdoutEncoder | string | `"json"` | Log encoder to use for stdout (one of `json` or `console`). |
| logging.fileEncoder | string | `"json"` | Log encoder to use for file logging (one of `json` or `console`). |
| logging.baseDir | string | `""` | Directory for kuberay-operator log file. |
| logging.fileName | string | `""` | File name for kuberay-operator log file. |
| logging.sizeLimit | string | `""` | EmptyDir volume size limit for kuberay-operator log file. |
| batchScheduler.enabled | bool | `false` |  |
| batchScheduler.name | string | `""` |  |
| configuration.enabled | bool | `false` | Whether to enable the configuration feature. If enabled, a ConfigMap will be created and mounted to the operator. |
| configuration.defaultContainerEnvs | list | `[]` | Default environment variables to inject into all Ray containers in all RayCluster CRs. This allows user to set feature flags across all Ray pods. Example: defaultContainerEnvs: - name: RAY_enable_open_telemetry   value: "true" - name: RAY_metric_cardinality_level   value: "recommended" |
| featureGates[0].name | string | `"RayClusterStatusConditions"` |  |
| featureGates[0].enabled | bool | `true` |  |
| featureGates[1].name | string | `"RayJobDeletionPolicy"` |  |
| featureGates[1].enabled | bool | `false` |  |
| featureGates[2].name | string | `"RayMultiHostIndexing"` |  |
| featureGates[2].enabled | bool | `false` |  |
| featureGates[3].name | string | `"RayServiceIncrementalUpgrade"` |  |
| featureGates[3].enabled | bool | `false` |  |
| metrics.enabled | bool | `true` | Whether KubeRay operator should emit control plane metrics. |
| metrics.serviceMonitor.enabled | bool | `false` | Enable a prometheus ServiceMonitor |
| metrics.serviceMonitor.interval | string | `"30s"` | Prometheus ServiceMonitor interval |
| metrics.serviceMonitor.honorLabels | bool | `true` | When true, honorLabels preserves the metric’s labels when they collide with the target’s labels. |
| metrics.serviceMonitor.selector | object | `{}` | Prometheus ServiceMonitor selector |
| metrics.serviceMonitor.namespace | string | `""` | Prometheus ServiceMonitor namespace |
| operatorCommand | string | `"/manager"` | Path to the operator binary |
| leaderElectionEnabled | bool | `true` | If leaderElectionEnabled is set to true, the KubeRay operator will use leader election for high availability. |
| reconcileConcurrency | int | `1` | The maximum number of reconcile operations that can be performed simultaneously. This setting controls the concurrency of the controller reconciliation loops. Higher values can improve throughput in clusters with many resources, but may increase resource consumption. |
| kubeClient | object | `{"burst":200,"qps":100}` | Kube Client configuration for QPS and burst settings. This setting controls the QPS and burst rate of the kube client when sending requests to the Kubernetes API server. If the QPS and burst values are too low, we may easily hit rate limits on the API server and slow down the controller reconciliation loops. |
| kubeClient.qps | float | `100` | The QPS value for the client communicating with the Kubernetes API server. Must be a float number. |
| kubeClient.burst | int | `200` | The maximum burst for throttling requests from this client to the Kubernetes API server. Must be a non-negative integer. |
| rbacEnable | bool | `true` | If rbacEnable is set to false, no RBAC resources will be created, including the Role for leader election, the Role for Pods and Services, and so on. |
| crNamespacedRbacEnable | bool | `true` | When crNamespacedRbacEnable is set to true, the KubeRay operator will create a Role for RayCluster preparation (e.g., Pods, Services) and a corresponding RoleBinding for each namespace listed in the "watchNamespace" parameter. Please note that even if crNamespacedRbacEnable is set to false, the Role and RoleBinding for leader election will still be created.  Note: (1) This variable is only effective when rbacEnable and singleNamespaceInstall are both set to true. (2) In most cases, it should be set to true, unless you are using a Kubernetes cluster managed by GitOps tools such as ArgoCD. |
| singleNamespaceInstall | bool | `false` | When singleNamespaceInstall is true: - Install namespaced RBAC resources such as Role and RoleBinding instead of cluster-scoped ones like ClusterRole and ClusterRoleBinding so that   the chart can be installed by users with permissions restricted to a single namespace.   (Please note that this excludes the CRDs, which can only be installed at the cluster scope.) - If "watchNamespace" is not set, the KubeRay operator will, by default, only listen   to resource events within its own namespace. |
| env | string | `nil` | Environment variables. |
| resources | object | `{"limits":{"cpu":"100m","memory":"512Mi"}}` | Resource requests and limits for containers. |
| livenessProbe.initialDelaySeconds | int | `10` |  |
| livenessProbe.periodSeconds | int | `5` |  |
| livenessProbe.failureThreshold | int | `5` |  |
| readinessProbe.initialDelaySeconds | int | `10` |  |
| readinessProbe.periodSeconds | int | `5` |  |
| readinessProbe.failureThreshold | int | `5` |  |
| podSecurityContext | object | `{}` | Set up `securityContext` to improve Pod security. |
| service.type | string | `"ClusterIP"` | Service type. |
| service.port | int | `8080` | Service port. |

## Quick Start

* [RayCluster Quickstart](https://docs.ray.io/en/master/cluster/kubernetes/getting-started/raycluster-quick-start.html)
* [RayJob Quickstart](https://docs.ray.io/en/master/cluster/kubernetes/getting-started/rayjob-quick-start.html)
* [RayService Quickstart](https://docs.ray.io/en/master/cluster/kubernetes/getting-started/rayservice-quick-start.html)

## Examples

KubeRay examples are hosted on the [Ray documentation](https://docs.ray.io/en/latest/cluster/kubernetes/examples.html).
Examples span a wide range of use cases, including training, LLM online inference, batch inference, and more.

## Kubernetes Ecosystem

KubeRay integrates with the Kubernetes ecosystem, including observability tools (e.g., Prometheus, Grafana, py-spy), queuing systems (e.g., Volcano, Apache YuniKorn, Kueue), ingress controllers (e.g., Nginx), and more.
See [KubeRay Ecosystem](https://docs.ray.io/en/latest/cluster/kubernetes/k8s-ecosystem.html) for more details.

## License

This project is licensed under the [Apache-2.0 License](LICENSE).
