# ovn-kubernetes-chart

![Version: 1.0.0](https://img.shields.io/badge/Version-1.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.0](https://img.shields.io/badge/AppVersion-1.0.0-informational?style=flat-square)

Helm chart to deploy ovn-kubernetes in the NVIDIA DOCA Platform Framework (DPF) context

**Homepage:** <https://ovn-kubernetes.io/>

## Source Code

* <https://github.com/ovn-org/ovn-kubernetes>
* <https://github.com/ovn-org/ovn>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
|  | ovn-kubernetes-resource-injector | 1.0.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| commonManifests | object | `{"enabled":false}` | Variables related to common manifests used by components in both DPU and Host cluster |
| controlPlaneManifests | object | `{"enabled":false,"image":{"pullPolicy":"IfNotPresent","repository":"ghcr.io/nvidia/ovn-kubernetes","tag":"v25.4.0"}}` | Variables related to manifests that are needed to setup the OVN Control Plane |
| dpuManifests | object | `{"enabled":false,"externalDHCP":false,"gatewayDiscoveryNetwork":"169.254.99.100/32","hostCIDR":null,"image":{"pullPolicy":"IfNotPresent","repository":"ghcr.io/nvidia/ovn-kubernetes","tag":"v25.4.0"},"ipamPFIPIndex":1,"ipamPool":null,"ipamPoolType":null,"ipamVTEPIPIndex":0,"kubernetesSecretName":null,"vtepCIDR":null}` | Variables related to manifests that are deployed on the DPU |
| gatewayOpts | string | `""` | Options related to setting up the gateway. Applies to all relevant manifests. |
| global.imagePullSecretName | string | `""` | The name of the secret used to pull images. Applies to all relevant manifests. |
| k8sAPIServer | string | `"https://172.25.0.2:6443"` | Endpoint of Kubernetes API server |
| leaseNamespace | string | `""` | The name of the namespace where the leases are going to be stored. This value should be the same for the host and DPU components. Defaults to Release.Namespace if it's not set. |
| mtu | int | `1400` | MTU of network interface in a Kubernetes pod |
| nameOverride | string | `"ovn-kubernetes"` |  |
| nodeWithDPUManifests | object | `{"dpuServiceAccountName":"ovn-dpu","dpuServiceAccountNamespace":"ovn-kubernetes","enabled":false,"image":{"pullPolicy":"IfNotPresent","repository":"ghcr.io/nvidia/ovn-kubernetes","tag":"v25.4.0"},"nodeMgmtPortNetdev":""}` | Variables related to manifests that are deployed for nodes with DPU |
| nodeWithoutDPUManifests | object | `{"enabled":false,"image":{"pullPolicy":"IfNotPresent","repository":"ghcr.io/nvidia/ovn-kubernetes","tag":"v25.4.0"}}` | Variables related to manifests that are deployed for nodes without DPU |
| ovn-kubernetes-resource-injector | object | `{"controllerManager":{"webhook":{"command":["/ovnkubernetesresourceinjector"],"image":{"repository":"ghcr.io/nvidia/ovn-kubernetes","tag":"v25.4.0"}}},"enabled":false,"resourceName":"nvidia.com/bf3-p0-vfs"}` | Variables related to the OVN Kubernetes Resource Injector |
| podNetwork | string | `"10.244.0.0/16/24"` | IP range for Kubernetes pods, /14 is the top level range, under which each /23 range will be assigned to a node |
| serviceDaemonSet.annotations | object | `{}` |  |
| serviceDaemonSet.labels | object | `{}` |  |
| serviceDaemonSet.updateStrategy | object | `{}` |  |
| serviceNetwork | string | `"10.96.0.0/12"` | A comma-separated set of CIDR notation IP ranges from which k8s assigns service cluster IPs. This should be the same as the value provided for kube-apiserver "--service-cluster-ip-range" option |

