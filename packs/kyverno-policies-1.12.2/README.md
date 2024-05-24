# Kyverno-Policies

This chart contains Kyverno's implementation of the Kubernetes Pod Security Standards (PSS) as documented at and are a Helm packaged version of those found at

. The goal of the PSS controls is to provide a good starting point for general Kubernetes cluster operational security. These controls are broken down into two categories, Baseline and Restricted. Baseline policies implement the most basic of Pod security controls while Restricted implements more strict controls. Restricted is cumulative and encompasses those listed in Baseline.

The following policies are included in each profile.

Baseline

    disallow-capabilities
    disallow-host-namespaces
    disallow-host-path
    disallow-host-ports
    disallow-host-process
    disallow-privileged-containers
    disallow-proc-mount
    disallow-selinux
    restrict-apparmor-profiles
    restrict-seccomp
    restrict-sysctls

Restricted

    disallow-capabilities-strict
    disallow-privilege-escalation
    require-run-as-non-root-user
    require-run-as-nonroot
    restrict-seccomp-strict
    restrict-volume-types

An additional policy "require-non-root-groups" is included in an other group as this was previously included in the official PSS controls but since removed.

For the latest version of these PSS policies, always refer to the kyverno/policies repo at https://github.com/kyverno/policies/tree/main/pod-security.

## Prerequisites

- kubernetes version >= 1.26.0
- Kyverno version >= 1.6.0


## Usage

To use the Kyverno-Policies pack, first create a new [add-on cluster profile](https://docs.spectrocloud.com/profiles/cluster-profiles/create-cluster-profiles/create-addon-profile/), search for the **kyverno** Kyverno Policies pack:
*Kyverno must be installed prior to this*  Kyverno can also be found as a pack in the pack repo.  Make sure the install order of the policies is after tha pack is installed.

## References

- [Ingress Controller for Kubernetes on GitHub](https://github.com/ngrok/kubernetes-ingress-controller)
- [ngrok documentation](https://ngrok.com/docs/)
- [Get started with the ngrok Ingress Controller for Kubernetes](https://ngrok.com/docs/using-ngrok-with/k8s/)
- [ngrok Ingress Controller Helm Documentation](https://github.com/ngrok/kubernetes-ingress-controller/tree/main/docs)