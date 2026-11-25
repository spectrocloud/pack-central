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
- **virtbmc** — a BMC emulator. The controller creates one `virtbmc` Deployment (one replica) and one Service per
  `VirtualMachineBMC` resource you define, in the same namespace as that resource, translating incoming IPMI/Redfish
  requests into Kubernetes API calls against the referenced VM. These are created on demand at runtime, not by the
  pack itself.

This pack packages chart version `0.8.0`, which deploys KubeVirtBMC `v0.11.0`.

> [!WARNING]
> KubeVirtBMC `v0.11.0` contains a breaking API change: `spec.storageClassName` on `VirtualMachineBMC` moved to
> `spec.redfish.virtualMedia.storage.storageClassName`. Update existing manifests before upgrading. See
> [Upgrade](#upgrade).


## Prerequisites

- A Kubernetes cluster running v1.32.0 or later.
- [KubeVirt](https://kubevirt.io) installed and healthy in the cluster. KubeVirt v1.6.0 or later. Upstream validates this
  release against KubeVirt v1.9.0 and CDI v1.66.0. KubeVirtBMC's controller watches `VirtualMachine` and
  `VirtualMachineInstance` resources, so the KubeVirt CRDs must exist before this pack is deployed.
- [Containerized Data Importer](https://github.com/kubevirt/containerized-data-importer) (CDI) if you use Redfish
  virtual media. Inserting virtual media creates a CDI `DataVolume`.
- [cert-manager](https://cert-manager.io) available in the cluster. The chart unconditionally creates a cert-manager
  `Issuer` and `Certificate`, and the admission webhooks rely on cert-manager's `cert-manager.io/inject-ca-from`
  annotation to have their CA bundle injected. Palette installs and manages cert-manager on its clusters, so no action
  is needed there; outside Palette you must install it yourself, or the pack fails to install because the
  `cert-manager.io/v1` API is not registered.

KubeVirt and CDI are satisfied through the [Virtual Machine Orchestrator](https://docs.spectrocloud.com/vm-management/)
(VMO) pack, which is how Palette delivers a curated KubeVirt. This pack declares a **required** dependency on VMO 4.8.3
or later, so Palette blocks any cluster profile that includes this pack without a satisfying VMO layer. 4.8.3 is the
first VMO release to ship KubeVirt v1.6.0 or newer — 4.8.2 and earlier ship v1.5.2, which does not satisfy KubeVirtBMC.

Order matters. In a Palette cluster profile, place the VMO layer **above** this pack so it is reconciled first.


## Parameters

The pack exposes the upstream Helm chart values under the `charts.kubevirtbmc` key. The defaults work as-is; the
parameters below are the ones most likely to need changing.

| **Parameter** | **Description** | **Type** | **Default Value** | **Required** |
|---|---|---|---|---|
| `charts.kubevirtbmc.replicaCount` | Number of controller-manager replicas. The controller uses leader election, so more than one replica gives you failover rather than added throughput. | Int | `1` | No |
| `charts.kubevirtbmc.image.repository` | Controller image repository. Change this when mirroring images into a private registry. | String | `kubevirtbmc/virtbmc-controller` | No |
| `charts.kubevirtbmc.image.tag` | Controller image tag. Empty means the chart's `appVersion` (`v0.11.0`). | String | `""` | No |
| `charts.kubevirtbmc.imagePullSecrets` | Image pull secrets, for private or authenticated registries. | List | `[]` | No |
| `charts.kubevirtbmc.resources` | CPU/memory requests and limits for the controller container. Unset by default. | Object | `{}` | No |
| `charts.kubevirtbmc.serviceMonitor.create` | Create a Prometheus `ServiceMonitor` for the controller's metrics endpoint. Requires the Prometheus Operator CRDs to be present. | Bool | `false` | No |
| `charts.kubevirtbmc.manager.args` | Arguments passed to the manager binary, including the metrics bind address and leader election. The agent image defaults to `kubevirtbmc/virtbmc:<appVersion>`; when mirroring images, add `--agent-image-name=<registry>/virtbmc` here (and `--agent-image-tag` if needed). | List | See values | No |
| `charts.kubevirtbmc.nodeSelector` | Node selector for the controller pod. | Object | `{}` | No |
| `charts.kubevirtbmc.tolerations` | Tolerations for the controller pod. | List | `[]` | No |

The pack is validated with the controller in `kubevirtbmc-system`, the upstream default namespace. Keep `pack.namespace`
at that value.


## Upgrade

Upgrade by adding a newer version of this pack to your cluster profile. Read the following before upgrading.

- **Breaking change in `v0.11.0` (chart `0.8.0`).** `spec.storageClassName` moved to
  `spec.redfish.virtualMedia.storage.storageClassName`, next to the new `volumeMode` field
  ([release notes](https://github.com/kubevirtbmc/kubevirtbmc/releases/tag/v0.11.0)). If you are upgrading from chart
  `0.7.0` and any `VirtualMachineBMC` sets `spec.storageClassName`, rewrite it before upgrading:

  Before:
  ```yaml
  spec:
    storageClassName: <storage-class>
  ```

  After:
  ```yaml
  spec:
    redfish:
      virtualMedia:
        storage:
          storageClassName: <storage-class>
  ```

  The old field is no longer in the schema, so once the new CRD is applied the API server drops it from stored
  objects and virtual media falls back to the cluster default StorageClass. Upgrades from chart `0.6.0` or earlier are
  unaffected, because `spec.storageClassName` was introduced in `0.7.0`.
- Helm does not upgrade CRDs that ship in a chart's `crds/` directory. `VirtualMachineBMC` changed in both `0.7.0` and
  `0.8.0`, so when upgrading an existing installation apply the new CRD manually before or alongside the pack upgrade:
  ```shell
  kubectl apply -f https://raw.githubusercontent.com/kubevirtbmc/kubevirtbmc/v0.11.0/config/crd/bases/bmc.kubevirt.io_virtualmachinebmcs.yaml
  ```
- From chart `0.7.0` (`v0.10.0`) the controller manages each BMC agent as a `Deployment` instead of a standalone `Pod`.
  Upstream states existing installations transition on upgrade with no manual action
  ([release notes](https://github.com/kubevirtbmc/kubevirtbmc/releases/tag/v0.10.0)). The agent Deployment still runs
  a single replica.
- From chart `0.7.0` the CRD marks `spec.virtualMachineRef` and `spec.authSecretRef` as required, and the `READY`
  printer column is replaced by `SERVICEREADY`.
- The container images moved organizations at chart version `0.6.0`: releases up to `0.5.1` publish
  `starbops/virtbmc-controller` and `starbops/virtbmc`, and `0.6.0` onwards publish `kubevirtbmc/virtbmc-controller`
  and `kubevirtbmc/virtbmc`. If you mirror images into a private registry, mirror the new repository names before
  upgrading across that boundary.
- Chart version `0.6.0` made the IPMI simulator opt-in. `VirtualMachineBMC` resources that need IPMI must set
  `spec.ipmi.enabled: true`. Redfish is unaffected.


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
    # The IPMI simulator is opt-in. Redfish is always served.
    # Omit this block to expose Redfish only.
    enabled: true
  service:
    # ClusterIP (default), NodePort or LoadBalancer.
    type: ClusterIP
  redfish:
    virtualMedia:
      storage:
        # Optional. StorageClass for the DataVolume created on virtual media insert.
        # Unset uses the cluster default.
        storageClassName: ""
```

The generated Service only publishes UDP 623 when the resource sets `spec.ipmi.enabled: true`. Redfish on TCP 80 is
always served.

The controller creates a `virtbmc` Deployment and a Service for the resource, and publishes the Service address on the
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

To reach a VM's BMC from outside the cluster, which is what a provisioning system such as Tinkerbell or MAAS needs,
set `spec.service.type` to `LoadBalancer` or `NodePort`. With `LoadBalancer`, the address is published in
`.status.loadBalancerIP`. Use `spec.service.annotations` and `spec.service.labels` to pass settings to your load
balancer implementation.

### Virtual media

Redfish virtual media inserts an ISO by creating a CDI `DataVolume` in the VM's namespace. This release adds:

- `spec.redfish.virtualMedia.storage.volumeMode`: `Filesystem` (default) or `Block`. `Block` avoids CDI filesystem
  overhead, which helps when an image must fit an exact size.
- `spec.redfish.virtualMedia.tls`: fetch images over HTTPS with a custom CA, by referencing a ConfigMap in the
  resource's namespace that holds the bundle under the key `ca.pem` (`caBundleConfigMapRef`), or skip verification with
  `insecureSkipVerify: true`.
- The `bmc.kubevirt.io/datavolume-size-margin` annotation on the `VirtualMachineBMC`, which pads the DataVolume size
  by the given percentage (for example `"10"`).

See the [virtual media guide](https://docs.kubevirtbmc.io/virtual-media/) for details.


## References

- [KubeVirtBMC documentation](https://docs.kubevirtbmc.io)
- [KubeVirtBMC on GitHub](https://github.com/kubevirtbmc/kubevirtbmc)
- [KubeVirtBMC v0.11.0 release notes](https://github.com/kubevirtbmc/kubevirtbmc/releases/tag/v0.11.0)
- [KubeVirtBMC Helm chart](https://github.com/kubevirtbmc/chart)
- [IPMI guide](https://docs.kubevirtbmc.io/ipmi-guide/)
- [Redfish guide](https://docs.kubevirtbmc.io/redfish-guide/)
- [Virtual media guide](https://docs.kubevirtbmc.io/virtual-media/)
- [KubeVirt documentation](https://kubevirt.io/user-guide/)
- [cert-manager installation](https://cert-manager.io/docs/installation/)
