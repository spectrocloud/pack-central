# StormForge Agent Helm Installation

The StormForge Agent is a helm chart which combines the stormforge-agent that surfaces minimum Kubernetes resource (pods, hpa) metrics and a prometheus agent to forward these metrics to StormForge backend.

## Installation

Generating the credentials:

```
stormforge auth create AUTH_NAME
```

This command will generate the following file. Save the file locally, i.e. as `AUTH_NAME-credentials.yaml`:

```
stormforge:
  address: https://api.stormforge.io/
authorization:
  issuer: https://api.stormforge.io/
  clientID: <CLIENT_ID> # AUTH_NAME
  clientSecret: <CLIENT_SECRET>
```

Running the installation (replace `LATEST_VERSION` and `CLUSTER_NAME` in example with appropriate values)

```
helm install stormforge-agent oci://registry.stormforge.io/library/stormforge-agent \
  --version LATEST_VERSION \
  --namespace stormforge-system \
  --create-namespace \
  --values AUTH_NAME-credentials.yaml \
  --set clusterName=CLUSTER_NAME
```

## Upgrade

A typical upgrade might look something like the following.

```
helm upgrade stormforge-agent oci://registry.stormforge.io/library/stormforge-agent \
  --version LATEST_VERSION \
  --namespace stormforge-system \
  --values AUTH_NAME-credentials.yaml \
  --set clusterName=CLUSTER_NAME
```

If you no longer have access to the Chart values used to install the agent but don't need to change any of them, you might be able to retrive and reuse the existing values using `helm get values` as follows.

```
helm get values -n stormforge-system stormforge-agent -o yaml > existing-stormforge-agent-values.yaml
helm upgrade stormforge-agent oci://registry.stormforge.io/library/stormforge-agent \
  --version LATEST_VERSION \
  --namespace stormforge-system \
  --values existing-stormforge-agent-values.yaml
```

> Note: It is strongly suggested that you **do not** use Helm's `--reuse-values` flag when upgrading to new versions. This flag can result in default Chart values defined in an old Chart version being incorrectly carried forward and used in the new one, compromising the configuration in unpredictable ways.

## Helm Config

Please look at the charts/stormforge-agent/values.yaml file for Helm configuration options.

```
helm show values oci://registry.stormforge.io/library/stormforge-agent --version LATEST_VERSION
```

### Configuration

The following Helm configuration values address most common scenarios. Additional configuration parameters exist. For a listing of all available values, see the [values.yaml](values.yaml) file.

#### Required Parameters:

- **`clusterName`**: value is `string`. Set from helm installation.
- **`authorization`**: value is `dict`. This value will be supplied by `stormforge auth create` or obtained from the StormForge app.

#### Optional Parameters:

- **`proxyUrl`**: value is `string`. Set to configure a proxy used to access `stormforge.io` services. Example: `https://proxy.example.com`.
- **`noProxy`**: value is `string`. If using a proxy, this value should at a minimum be set to the subnet(s) for the cluster. Example: `10.76.0.0/16`.
- **`workload.watchWorkloadResources`**: value is `boolean`. Default is `true`. Agent proactively identifies workloads with zero replicas.
 If set, workload controller will watch create/delete pod events and derive StormForge workloads from them. When `false`, the only way to optimize workloads is by using WorkloadOptimizer resources.
- **`workload.allowNamespaces`**: values are `[]string`. If set, only these namespaces will be visible for workload discovery.
- **`workload.denyNamespaces`**: values are `[]string`. If set, all namespaces but these will be visible for workload discovery.

Attention: `workload.allowNamespaces` and `workload.denyNamespaces` are mutually exclusive, with `workload.allowNamespaces` taking precedence.

The namespace `"kube-system"` is always excluded from the workload discovery (unless set by `allowNamespaces`).

## Workload Metrics

Here are the workload metrics we produce.

| Metric                                           | Source                              | Why                                                                           |
| ------------------------------------------------ | ----------------------------------- | ----------------------------------------------------------------------------- |
| sf_workload_pod_owner                        | Consolidated metric for ownership              | With this metric, we have pod owner and workload, replacing KSM kube_pod_owner and kube_replicaset_owner                                               |
| sf_workload_spec_replicas                        | Consolidated metric for desired replicas number              | With this metric, we have all desired replica metrics regardless type of pod owner. The pod owner must have the subresource scale.                                            |
| sf_workload_status_replicas                        | Consolidated metric for observed replicas number              | With this metric, we have all observed replica metrics regardless type of pod owner.                                             |
| sf_workload_pod_container_resource_requests    | Consolidated pod metric with  requests              | With this metric, we have all requests metrics in a single metric.                                       |
| sf_workload_pod_container_resource_limits    | Consolidated pod metric with  limits              | With this metric, we have all limits metrics in a single metric.                                        |
| sf_workload_terminated_count                   | Consolidated metric for workload termination events | With this metric, we track the count of times a workload was terminated (e.g. OOMKilled) |
| sf_horizontalpodautoscaler_spec_min_replicas   | KSM-like/horizontalpodautoscaler-metrics | Track minimum replicas for each HPA                                           |
| sf_horizontalpodautoscaler_spec_max_replicas   | KSM-like/horizontalpodautoscaler-metrics | Track maximum replicas for each HPA                                           |
| sf_horizontalpodautoscaler_spec_target_metric  | KSM-like/horizontalpodautoscaler-metrics | Track target metric for each HPA                                              |
| sf_node_allocated_requests | Custom node metrics | The number of allocated requests on the node. |
| sf_node_allocated_limits | Custom node metrics | The number of allocated limits on the node. |
| sf_node_allocated_pods | Custom node metrics | The number of non terminated pods running on the node. |
| sf_node_allocatable_resources | Custom node metrics | The amount of resources available to be allocated on the node |
| sf_node_capacity_resources | Custom node metrics | The total amount of resources that a node has. Used in calculating the average cluster CPU and memory utilization. |
| container_cpu_usage_seconds_total                | cadvisor                            | Track cpu usage for each container                                            |
| container_memory_working_set_bytes               | cadvisor                            | Track memory usage for each container                                         |
| container_cpu_cfs_throttled_seconds_total              | cadvisor                            | Total time duration the container has been throttled                                         |
| container_cpu_cfs_throttled_periods_total      | cadvisor                            | Number of throttled period intervals                                                         |
| container_cpu_cfs_periods_total                | cadvisor                            | Number of elapsed enforcement period intervals                                               |
| container_memory_max_usage_bytes              | cadvisor                            | Maximum memory usage recorded                                         |
| node_cpu_usage_seconds_total   | Resource metrics | Used in calculating the average cluster CPU utilization |
| node_memory_working_set_bytes  | Resource metrics | Used in calculating the average cluster memory utilization |

Individual tenants could have additional metrics.

### Extra GO / Controller-Runtime Metrics

Starting on version `2.20.1`, by default, we have started to forward to our backend all GO and controller-runtime metrics.
These are generated by the runtime, and it is outside the scope document them in detail.

Here are the metrics:

```
certwatcher_read_certificate_errors_total
certwatcher_read_certificate_total
controller_runtime_active_workers
controller_runtime_max_concurrent_reconciles
controller_runtime_reconcile_errors_total
controller_runtime_reconcile_panics_total
controller_runtime_reconcile_time_seconds_bucket
controller_runtime_reconcile_time_seconds_count
controller_runtime_reconcile_time_seconds_sum
controller_runtime_reconcile_total
controller_runtime_terminal_reconcile_errors_total
controller_runtime_webhook_panics_total
go_gc_duration_seconds
go_gc_duration_seconds_count
go_gc_duration_seconds_sum
go_gc_gogc_percent
go_gc_gomemlimit_bytes
go_goroutines
go_info
go_memstats_alloc_bytes
go_memstats_alloc_bytes_total
go_memstats_buck_hash_sys_bytes
go_memstats_frees_total
go_memstats_gc_sys_bytes
go_memstats_heap_alloc_bytes
go_memstats_heap_idle_bytes
go_memstats_heap_inuse_bytes
go_memstats_heap_objects
go_memstats_heap_released_bytes
go_memstats_heap_sys_bytes
go_memstats_last_gc_time_seconds
go_memstats_mallocs_total
go_memstats_mcache_inuse_bytes
go_memstats_mcache_sys_bytes
go_memstats_mspan_inuse_bytes
go_memstats_mspan_sys_bytes
go_memstats_next_gc_bytes
go_memstats_other_sys_bytes
go_memstats_stack_inuse_bytes
go_memstats_stack_sys_bytes
go_memstats_sys_bytes
go_sched_gomaxprocs_threads
go_threads
rest_client_requests_total
workqueue_adds_total
workqueue_depth
workqueue_longest_running_processor_seconds
workqueue_queue_duration_seconds_bucket
workqueue_queue_duration_seconds_count
workqueue_queue_duration_seconds_sum
workqueue_retries_total
workqueue_unfinished_work_seconds
workqueue_work_duration_seconds_bucket
workqueue_work_duration_seconds_count
workqueue_work_duration_seconds_sum
```

## Troubleshooting StormForge Agent

### Getting Logs from Prometheus Agent

In case one does not see data on AMP, check the prometheus agent logs. In this example below, the agent is running on namespace `stormforge-system`. Please be aware there are two deployments, one for the prometheus agent and another for the stormforge workload controller:

```sh
# workload controller
kubectl logs -l app.kubernetes.io/component=agent --tail=-1 -n stormforge-system

# prometheus agent
kubectl logs -l app.kubernetes.io/component=metrics-forwarder --tail=-1 -n stormforge-system

```

If there is no errors, see the next steps.

### Verify Prometheus Targets

When you install the agent, you should be sure to verify it is actually able to scrape the workload metrics. In particular, stormforge-agent has a static url config which makes it config error prone, which is `https://<>:8080/metrics`. In this example below, the agent is running on namespace `stormforge-system`

```sh
# e.g.
kubectl expose deploy/stormforge-agent-metrics-forwarder -n stormforge-system
kubectl port-forward deploy/stormforge-agent-metrics-forwarder  9090:9090 -n stormforge-system
# http://localhost:9090/targets?search= to validate targets are being collected
```

To look at the actual metrics from the perspective of the stormforge-agent controller:

```sh
# e.g.
kubectl expose deploy/stormforge-agent-workload-controller -n stormforge-system
kubectl port-forward deploy/stormforge-agent-workload-controller 8080:8080 -n stormforge-system
# http://localhost:8080/metrics to validate targets are being collected
```

### Checking Prometheus WAL

Data should be on the WAL. In this example below, the agent is running on namespace `stormforge-system`:

```sh
# e.g.
kubectl exec $(kubectl get pods -n stormforge-system -l app.kubernetes.io/component=metrics-forwarder | grep -v NAME | awk '{print $1}') -n stormforge-system -it -c prometheus -- sh

# inside the pod
$ promtool tsdb dump data-agent/ | head

# check sf workload metrics
$ promtool tsdb dump data-agent/ | grep sf_workload | head -5

# check horizontal metrics
$ promtool tsdb dump data-agent/ | grep horizontal | head -5

```

By default, we are holding 30 minutes on data on WAL.

### Credentials

Credentials are not authorized, ask permission:

```
# kubectl logs --tail=-1 -n stormforge-system -l app.kubernetes.io/component=metrics-forwarder -c prometheus

ts=2023-02-13T22:21:55.813Z caller=dedupe.go:112 component=remote level=error remote_name=d24ad1 url=https://in.dev-1.dev.gramlabs.dev/prometheus/write msg="non-recoverable error" count=77 exemplarCount=0 err="server returned HTTP status 404 Not Found: {\"message\":null}"
```

Bad credentials, double check parameters passed during installation (i.e. secrets):

```
# kubectl logs --tail=-1 -n stormforge-system -l app.kubernetes.io/component=metrics-forwarder -c prometheus

ts=2023-02-13T22:25:48.460Z caller=dedupe.go:112 component=remote level=error remote_name=0745da url=https://in.dev-1.dev.gramlabs.dev/prometheus/write msg="non-recoverable error" count=35 exemplarCount=0 err="server returned HTTP status 401 Unauthorized: Authorization malformed or invalid"
ts=2023-02-13T22:26:03.506Z caller=dedupe.go:112 component=remote level=error remote_name=0745da url=https://in.dev-1.dev.gramlabs.dev/prometheus/write msg="non-recoverable error" count=77 exemplarCount=0 err="server returned HTTP status 401 Unauthorized: Authorization malformed or invalid"
```

### Enable debug logging

Debug logging can now be enabled via http requests.
This should make it more useful to enable debug logging for a short period.

The default log level is `1` ( info ).

This can be changed by:
```
kubectl port-forward -n stormforge-system <stormforge-agent-workload pod> 6060:6060

# Default info level logging
curl -X PUT localhost:6060/debug/loglevel -d level=1
# Verbose/Debug logging
curl -X PUT localhost:6060/debug/loglevel -d level=5
# Trace logging
curl -X PUT localhost:6060/debug/loglevel -d level=9
```
