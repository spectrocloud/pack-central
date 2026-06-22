# Peer Pods (Cloud API Adaptor)

Peer Pods enables running Kata Containers workloads in cloud VMs instead of
local VMMs. This chart includes the
[Cloud API Adaptor (CAA)](https://github.com/confidential-containers/cloud-api-adaptor)
as an optional subchart, deployed when `values/kata-remote.yaml` is used.

For detailed documentation on CAA, provider configuration, and architecture,
see the [peerpods chart README](https://github.com/confidential-containers/cloud-api-adaptor/tree/main/src/cloud-api-adaptor/install/charts/peerpods).

> [!WARNING]
> When peerpods is enabled via `values/kata-remote.yaml`, all non-remote shims
> are disabled. This means peerpods replaces other kata runtime configurations
> rather than running alongside them. A mixed deployment (peerpods + local VMM
> shims) is not currently supported.

## Prerequisites

- [cert-manager](https://cert-manager.io/docs/installation/) installed in the
  cluster (required by the peerpods webhook)
- Worker nodes labeled with `node.kubernetes.io/worker=`

## General Installation

The installation uses `values/kata-remote.yaml` to enable the peerpods
subchart and configure the kata `remote` shim:

```bash
# Label worker nodes
kubectl label node <node-name> node.kubernetes.io/worker=

# Install with peer-pods enabled
helm install coco oci://ghcr.io/confidential-containers/charts/confidential-containers \
  -f https://raw.githubusercontent.com/confidential-containers/charts/main/values/kata-remote.yaml \
  --set peerpods.provider=<provider> \
  -f <provider>.yaml \
  --namespace coco-system \
  --create-namespace
```

Each cloud provider requires its own configuration values and secrets. Refer to
the [peerpods chart documentation](https://github.com/confidential-containers/cloud-api-adaptor/tree/main/src/cloud-api-adaptor/install/charts/peerpods)
for provider-specific setup instructions, secrets management, and available
configuration options.

## How It Works

When `values/kata-remote.yaml` is used, the chart deploys the kata `remote`
shim via the parent chart's `kata-as-coco-runtime` and enables the peerpods
subchart (CAA, peerpod controller, and webhook). The peerpods subchart's own
`kata-deploy` dependency is disabled to avoid duplication.

## Testing

Detailed e2e tests for peerpods are maintained in the
[CAA repository](https://github.com/confidential-containers/cloud-api-adaptor).
The following providers are currently tested in CI:

- AWS
- Azure
- IBMCloud
- libvirt
- docker

## Uninstallation

```bash
helm uninstall coco --namespace coco-system
```
