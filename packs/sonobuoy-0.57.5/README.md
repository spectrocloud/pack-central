# Sonobuoy

Sonobuoy is a diagnostic tool originally developed by VMware Tanzu that makes it easier to understand the state of a Kubernetes cluster by running a set of plugins (including Kubernetes conformance tests) in an accessible and non-destructive manner.
The tool performs automated checks, executes End-to-End (E2E) tests, and gathers cluster information to evaluate its overall health.
This addon deploys Sonobuoy as a Kubernetes Pod with its associated resources (Namespaces, RBAC, ConfigMaps) and performs an assessment of the cluster.

## Prerequisites

* Kubernetes 1.29 or later.
* Permissions to create ClusterRoles, ClusterRoleBindings, and privileged Pods (clusterAdmin).
* Worker nodes must allow the hostPath mounts required by the systemd-logs plugin.

> **Note:**
> Managed Kubernetes services such as Amazon EKS, Azure AKS, and Google GKE may restrict access to certain control plane components. As a result, some configuration checks or specific E2E tests may be skipped or reported differently compared to self-managed Kubernetes environments.

Sonobuoy plugins (like systemd-logs) require access to host filesystem paths in order to inspect Kubernetes node configuration and extract system logs.

## Parameters

| Name             | Description                                   | Type   | Default Value       | Required |
| ---------------- | --------------------------------------------- | ------ | ------------------- | -------- |
| image.repository | Container image repository used by sonobuoy   | string | sonobuoy/sonobuoy   | Yes      |
| image.tag        | sonobuoy image version                        | string | v0.57.5             | Yes      |

## Upgrade

Upgrade from previous versions of this addon is supported.

## Usage

After installation, verify that the Sonobuoy namespace and resources have been created successfully:

```sh
kubectl get all -n sonobuoy
```

Verify that the main aggregator Pod has been created and is running:

```sh
kubectl get pods -n sonobuoy | grep sonobuoy
```

Once the test plugins have completed, retrieve the aggregator logs to check the progress:

```sh
kubectl logs pod/sonobuoy -n sonobuoy
```

The output contains information about the plugin execution and results collection, similar to:

```text
level=info msg="Plugin systemd-logs completed"
level=info msg="Plugin e2e completed"
level=info msg="Results saved to /tmp/sonobuoy/results"
```

## Validation

### Verify Pod Creation

```sh
kubectl get pods -n sonobuoy
```

Expected result:

```text
NAME       READY   STATUS    RESTARTS   AGE
sonobuoy   1/1     Running   0          <age>
```

### Verify Service Status

```sh
kubectl get svc -n sonobuoy | grep sonobuoy-aggregator
```

Expected result:

```text
NAME                  TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE
sonobuoy-aggregator   ClusterIP   <ip-address> <none>        8080/TCP   <age>
```

### Verify Test Execution

```sh
kubectl logs pod/sonobuoy -n sonobuoy
```

Expected output contains logs indicating that Sonobuoy successfully executed the E2E and systemd plugins against the cluster:

```text
level=info msg="Starting aggregator"
level=info msg="Running plugins"
level=info msg="Results available"
```

These results indicate that Sonobuoy successfully executed the conformance tests and gathered the required diagnostic data.

## References

* https://github.com/vmware-tanzu/sonobuoy
* https://sonobuoy.io/


