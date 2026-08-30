# Kube-bench

Kube-bench is an open-source tool developed by Aqua Security that checks whether Kubernetes is deployed according to the CIS Kubernetes Benchmark recommendations.
The tool performs automated security checks against Kubernetes components and node configuration, generating findings categorized as PASS, FAIL, WARN, and INFO.
This addon deploys kube-bench as a Kubernetes Job and performs a one-time security assessment of the cluster.

## Prerequisites

* Kubernetes 1.29 or later.
* Permissions to create and execute Kubernetes Jobs.
* Worker nodes must allow the hostPath mounts required by kube-bench.

> **Note:**
> Managed Kubernetes services such as Amazon EKS, Azure AKS, and Google GKE may restrict access to certain control plane components. As a result, some benchmark checks may be skipped or reported differently compared to self-managed Kubernetes environments.

Kube-bench requires access to host filesystem paths in order to inspect Kubernetes node configuration and evaluate CIS benchmark compliance.

## Parameters

| Name             | Description                                   | Type   | Default Value      | Required |
| ---------------- | --------------------------------------------- | ------ | ------------------ | -------- |
| image.repository | Container image repository used by kube-bench | string | aquasec/kube-bench | Yes      |
| image.tag        | kube-bench image version                      | string | v0.15.6            | Yes      |

## Upgrade

Upgrade from previous versions of this addon is supported.

## Usage

After installation, verify that the Job has been created successfully:

```sh
kubectl get jobs -A
```

Verify that the Pod associated with the Job has been created:

```sh
kubectl get pods -A | grep kube-bench
```

Once the Job has completed, retrieve the benchmark results:

```sh
kubectl logs job/kube-bench
```

The output contains CIS benchmark findings similar to:

```text
PASS
FAIL
WARN
INFO
```

## Validation

### Verify Job Completion

```sh
kubectl get jobs -A
```

Expected result:

```text
NAME         COMPLETIONS   DURATION   AGE
kube-bench   1/1           <time>     <age>
```

### Verify Pod Status

```sh
kubectl get pods -A | grep kube-bench
```

Expected result:

```text
STATUS
Completed
```

### Verify Benchmark Results

```sh
kubectl logs job/kube-bench
```

Expected output contains one or more of the following result types:

```text
PASS
FAIL
WARN
INFO
```

These results indicate that kube-bench successfully executed the CIS benchmark checks against the cluster.

## References

* https://github.com/aquasecurity/kube-bench
* https://aquasecurity.github.io/kube-bench/
