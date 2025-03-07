# KubeArmor

KubeArmor is a cloud-native runtime security enforcement system that restricts the behavior \(such as process execution, file access, and networking operations\) of pods, containers, and nodes (VMs) at the system level.

KubeArmor leverages [Linux security modules \(LSMs\)](https://en.wikipedia.org/wiki/Linux_Security_Modules) such as [AppArmor](https://en.wikipedia.org/wiki/AppArmor), [SELinux](https://en.wikipedia.org/wiki/Security-Enhanced_Linux), or [BPF-LSM](https://docs.kernel.org/bpf/prog_lsm.html) to enforce the user-specified policies. KubeArmor generates rich alerts/telemetry events with container/pod/namespace identities by leveraging eBPF.

## Usage

To use the KubeArmor pack, first create a new add-on cluster profile, and search for the kubearmor pack

A KubeArmor policy is written in yaml and specifies the file, process, network, capabilities and syscalls that need to be monitored or blocked. Policies can be applied on the host and on containers with cluster-wide policy support.

A community-owned library of Kubernetes System and Network policies can be found in this [github repo](https://github.com/kubearmor/policy-templates)

## Least Permissive Access

KubeArmor helps organizations enforce a zero trust posture within their Kubernetes clusters. It allows users to define an allow-based policy that allows specific operations, and denies or audits all other operations. This helps to ensure that only authorized activities are allowed within the cluster, and that any deviations from the expected behavior are denied and flagged for further investigation.

## Harden Infrastructure

One of the key features of KubeArmor is that it provides hardening policies out-of-the-box, meaning that you don't have to spend time researching and configuring them yourself. Instead, you can simply apply the policies to your workloads and immediately start benefiting from the added security that they provide.

For more information refer to the [detailed documentation](https://docs.kubearmor.io/kubearmor).
