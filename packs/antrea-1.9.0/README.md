
# Antrea

## Description:
Antrea is a Kubernetes networking solution intended to be Kubernetes native. It operates at Layer 3/4 to provide networking and security services for a Kubernetes cluster, leveraging Open vSwitch as the networking data plane.

### 1. CIDRs:
Antrea CIDR doesn’t work with K8s CIDR. It’s an either or situation and since we enable node IPAM while running kubeadm init , we cannot disable it. We can use the CIDR fields in the k8s pack (Recommended).

### 2. Loadbalancers:
The ServiceExternalIP feature gate of antrea-agent and antrea-controller must be enabled for the feature to work.
Create an ExternalIPPool custom resource.

### 3. Network policies:
K8s network policies are enabled by default.

## Kubernetes compatibility
Supported on Kubernetes v1.16.0 & above

## CloudType:
* vsphere

## References:
[Antrea](https://antrea.io/docs/v1.9.0/)

[Github](https://github.com/antrea-io/antrea)
