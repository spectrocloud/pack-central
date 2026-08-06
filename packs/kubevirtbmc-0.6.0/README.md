# KubeVirtBMC

[KubeVirtBMC](https://kubevirtbmc.io) provides out-of-band management for [KubeVirt](https://kubevirt.io) virtual machines
running on Kubernetes, exposing each VM through the same [IPMI](https://www.intel.com/content/www/us/en/products/docs/servers/ipmi/ipmi-second-gen-interface-spec-v2-rev1-1.html)
and [Redfish](https://www.dmtf.org/standards/redfish) interfaces you would use to talk to a physical server's BMC. That
lets you power a VM on, off, or reset it, set its boot device, and attach virtual media using bare-metal provisioning
tooling that has no knowledge of Kubernetes — for example [Tinkerbell](https://github.com/tinkerbell/tink),
[Harvester Seeder](https://github.com/harvester/seeder), MAAS, or Ironic.

The pack installs two things:

- **virtbmc-controller** — a controller manager that reconciles `VirtualMachineBMC` custom resources. This is the
  workload the pack deploys, and it runs as a single replica in the `kubevirtbmc-system` namespace.
- **virtbmc** — a BMC emulator. The controller creates one `virtbmc` pod and Service per `VirtualMachineBMC` resource
  you define, translating incoming IPMI/Redfish requests into Kubernetes API calls against the referenced VM. These pods
  are created on demand at runtime, not by the pack itself.

This pack packages chart version `0.6.0`, which deploys KubeVirtBMC `v0.9.0`.


## Prerequisites

- A Kubernetes cluster running v1.32.0 or later.
- [KubeVirt](https://kubevirt.io) installed and healthy in the cluster. KubeVirt v1.6.0 or later. Upstream validates this release against KubeVirt v1.8.4.
  KubeVirtBMC's controller watches `VirtualMachine` and `VirtualMachineInstance` resources, so the KubeVirt CRDs must
  exist before this pack is deployed.
- [cert-manager](https://cert-manager.io) installed and healthy in the cluster. This is a hard requirement, not an
  option — the chart unconditionally creates a cert-manager `Issuer` and `Certificate`, and the admission webhooks rely
  on cert-manager's `cert-manager.io/inject-ca-from` annotation to have their CA bundle injected. Without cert-manager
  the pack will fail to install because the `cert-manager.io/v1` API is not registered.

This pack declares a **required** dependency on the
[Virtual Machine Orchestrator](https://docs.spectrocloud.com/vm-management/) (VMO) pack, version 4.8.3 or later, which
is how Palette delivers a curated KubeVirt. 4.8.3 is the first VMO release to ship KubeVirt v1.6.0 or newer; 4.8.2 and
earlier ship v1.5.2 and will not satisfy KubeVirtBMC. Palette blocks a cluster profile that includes this pack without
a satisfying VMO layer.

If you run upstream KubeVirt rather than VMO, the software works the same, but you will need to remove this dependency
from `pack.json` in your own copy of the pack — Palette dependency constraints have no "one of" semantics.

cert-manager needs no dependency entry: Palette installs and manages it on its clusters. The requirement is listed
above because it still applies when the chart is installed outside Palette.

Order matters. In a Palette cluster profile, place the VMO layer **above** this pack so it is reconciled first.


## Parameters

The pack exposes the upstream Helm chart values under the `charts.kubevirtbmc` key. The defaults work as-is; the
parameters below are the ones most likely to need changing.

| **Parameter** | **Description** | **Type** | **Default Value** | **Required** |
|---|---|---|---|---|
| `charts.kubevirtbmc.replicaCount` | Number of controller-manager replicas. The controller uses leader election, so more than one replica gives you failover rather than added throughput. | Int | `1` | No |
| `charts.kubevirtbmc.image.repository` | Controller image repository. Change this when mirroring images into a private registry. | String | `kubevirtbmc/virtbmc-controller` | No |
| `charts.kubevirtbmc.image.tag` | Controller image tag. Empty means the chart's `appVersion` (`v0.9.0`). | String | `""` | No |
| `charts.kubevirtbmc.imagePullSecrets` | Image pull secrets, for private or authenticated registries. | List | `[]` | No |
| `charts.kubevirtbmc.resources` | CPU/memory requests and limits for the controller container. Unset by default. | Object | `{}` | No |
| `charts.kubevirtbmc.serviceMonitor.create` | Create a Prometheus `ServiceMonitor` for the controller's metrics endpoint. Requires the Prometheus Operator CRDs to be present. | Bool | `false` | No |
| `charts.kubevirtbmc.manager.args` | Arguments passed to the manager binary, including the metrics bind address and leader election. | List | See values | No |
| `charts.kubevirtbmc.nodeSelector` | Node selector for the controller pod. | Object | `{}` | No |
| `charts.kubevirtbmc.tolerations` | Tolerations for the controller pod. | List | `[]` | No |

> [!CAUTION]
> Do not change `pack.namespace`. KubeVirtBMC hardcodes `kubevirtbmc-system` as the namespace it uses internally, so
> installing the pack elsewhere will leave the controller unable to manage its own resources.


## Upgrade

Upgrade by adding a newer version of this pack to your cluster profile. There are no manual migration steps between the
versions published here, but note the following.

- Helm does not upgrade CRDs that ship in a chart's `crds/` directory. `VirtualMachineBMC` gained new
  `spec.ipmi` and `status.bootOverride` fields across these releases, so when upgrading an existing installation apply
  the new CRD manually before or alongside the pack upgrade:
  ```shell
  kubectl apply -f https://raw.githubusercontent.com/kubevirtbmc/kubevirtbmc/v0.9.0/config/crd/bases/bmc.kubevirt.io_virtualmachinebmcs.yaml
  ```
  Existing `VirtualMachineBMC` resources are unaffected — the added fields are optional.
- The container images moved organizations at chart version `0.6.0`: releases up to `0.5.1` publish
  `starbops/virtbmc-controller` and `starbops/virtbmc`, and `0.6.0` onwards publish `kubevirtbmc/virtbmc-controller`
  and `kubevirtbmc/virtbmc`. If you mirror images into a private registry, mirror the new repository names before
  upgrading across that boundary.
- Chart version `0.6.0` makes the IPMI simulator opt-in. After upgrading to it, `VirtualMachineBMC` resources that
  previously served IPMI stop publishing UDP 623 until you add `spec.ipmi.enabled: true` to them. Redfish is
  unaffected.


## Usage

Add this pack as a layer in an [add-on cluster profile](https://docs.spectrocloud.com/profiles/cluster-profiles/create-cluster-profiles/create-addon-profile/),
placing it below your cert-manager and KubeVirt layers. The default values need no changes for a standard install.

Once the cluster reconciles, confirm the controller is up and the CRD is registered:

```shell
kubectl get pods -n kubevirtbmc-system
kubectl get crd virtualmachinebmcs.bmc.kubevirt.io
```

To expose a VM through IPMI and Redfish, create a Secret holding the BMC credentials and a `VirtualMachineBMC` that
references both the Secret and the VM. Both objects live in the same namespace as the VM.

```shell
kubectl create secret generic bmc-secret \
  --from-literal=username=admin \
  --from-literal=password=admin123 \
  --namespace default
```

```yaml
apiVersion: bmc.kubevirt.io/v1beta1
kind: VirtualMachineBMC
metadata:
  name: testvm-bmc
  namespace: default
spec:
  virtualMachineRef:
    name: testvm
  authSecretRef:
    name: bmc-secret
  ipmi:
    # In this release the IPMI simulator is opt-in. Redfish is always served.
    # Omit this block to expose Redfish only.
    enabled: true
```

In this release the IPMI simulator is opt-in: the generated Service only publishes UDP 623 when the resource sets `spec.ipmi.enabled: true`. Redfish on TCP 80 is always served.

The controller creates a `virtbmc` pod and a Service for the resource, and publishes the Service address on the
resource's status:

```shell
kubectl get virtualmachinebmc testvm-bmc -n default -o jsonpath='{.status.clusterIP}'
```

From a pod inside the cluster you can then drive the VM with `ipmitool` against port 623, or with any Redfish client
against port 80:

```shell
ipmitool -I lanplus -H <CLUSTER_IP> -U admin -P admin123 chassis power status
ipmitool -I lanplus -H <CLUSTER_IP> -U admin -P admin123 chassis power on
```

To reach a VM's BMC from outside the cluster — which is what a provisioning system such as Tinkerbell or MAAS needs —
expose the generated Service through a LoadBalancer or NodePort. The IPMI port is UDP 623 and the Redfish port is TCP
80.


## References

- [KubeVirtBMC documentation](https://docs.kubevirtbmc.io)
- [KubeVirtBMC on GitHub](https://github.com/kubevirtbmc/kubevirtbmc)
- [KubeVirtBMC Helm chart](https://github.com/kubevirtbmc/chart)
- [IPMI guide](https://docs.kubevirtbmc.io/ipmi-guide/)
- [Redfish guide](https://docs.kubevirtbmc.io/redfish-guide/)
- [Virtual media guide](https://docs.kubevirtbmc.io/virtual-media/)
- [KubeVirt documentation](https://kubevirt.io/user-guide/)
- [cert-manager installation](https://cert-manager.io/docs/installation/)
