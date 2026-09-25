# nodeprep Helm chart

Packages the NodePrep solution for Helm-based deployment: the cluster
controller (Deployment), the privileged node agent (DaemonSet), the RBAC
contract, and the NodePrepProfile/NodePrep CRDs.

This mirrors `manifests/*.yaml` 1:1 — that directory stays the
externally-enforced source of truth (Palette); the chart is the packaged
form for Helm-consuming deployers. When behavior changes, the manifests
change first and the chart follows.

## Install

```sh
# Standalone (chart creates the namespace and CRDs):
helm upgrade --install nodeprep chart/nodeprep \
  --set agent.args.hostMutations=true \
  --set agent.args.allowReboot=true

# Namespace and/or CRDs managed externally (e.g. Palette enforces both):
helm upgrade --install nodeprep chart/nodeprep \
  --set namespace.create=false \
  --set agent.args.hostMutations=true \
  --set agent.args.allowReboot=true

# CRDs managed by an external system only — skip the chart's copies:
helm upgrade --install nodeprep chart/nodeprep \
  --set crds.create=false \
  --set agent.args.hostMutations=true \
  --set agent.args.allowReboot=true
```

## CRDs: templates, not a crds/ directory

The two CRDs live in `templates/` (wrapped in `{{- if .Values.crds.create }}`,
default on) rather than the conventional `crds/` subdirectory. That is a
deliberate choice: `crds/` contents are installed once at `helm install` and
**never upgraded** by `helm upgrade` — Helm's documented limitation — so a
schema evolution would silently keep the old CRD forever. As templates they
ride every upgrade. The trade-off, accepted knowingly: `helm uninstall` deletes
the CRDs (removing all NodePrep/NodePrepProfile objects and their ledgers), and
Helm "owns" objects other tools may also manage. On clusters where an external
system (e.g. Palette) enforces the CRDs, set `crds.create=false` to avoid two
owners fighting.

Manual `kubectl apply` of the raw CRD manifests on a chart-managed cluster
re-stamps Helm's ownership markers afterwards (`make crd-apply` does it) —
without `meta.helm.sh/release-*` and `app.kubernetes.io/managed-by: Helm` the
next `helm upgrade` that must create or adopt the CRD fails the ownership
validation.

## What it deploys

| Template | Kind | Notes |
|---|---|---|
| `namespace.yaml` | Namespace | PSA `privileged` (agent needs it). Kept on uninstall. Skippable via `namespace.create=false`. |
| `crd-nodeprep*.yaml` | 2 CRDs | Rendered templates (`crds.create=false` to skip); upgraded on every `helm upgrade` — see the section above for the trade-offs. |
| `serviceaccounts.yaml` | 2 SAs | controller + agent. |
| `clusterroles.yaml` | 2 ClusterRoles + 2 bindings | Mirrors `manifests/rbac.yaml` (the agent's `pods list/delete` backs the 0.1.62 device-plugin bounce). |
| `controller-deployment.yaml` | Deployment | Hardened (non-root, read-only fs, caps dropped), tolerates the nodeprep + control-plane taints. |
| `agent-daemonset.yaml` | DaemonSet | `hostPID`, privileged, `/sys` + `/dev` + `/` host mounts, tolerates the nodeprep + control-plane taints (load-bearing: the taint survives reboots and only the agent releases it). |

## Values that matter

| Value | Default | Meaning |
|---|---|---|
| `controller.image.tag` | `<appVersion>-controller` | Pin to override (registry mirror). |
| `agent.image.tag` | `<appVersion>-agent` | Same. One tag per version — tags are never re-pushed. |
| `agent.args.hostMutations` | `false` | Detect-only posture when false: mutating steps report Blocked instead of touching the host. |
| `agent.args.allowReboot` | `false` | The agent also requires this to reboot the host. |
| `agent.args.interval` | `5s` | Walk poll cadence. |
| `agent.args.verbose` / `NODEPREP_VERBOSE` env | off | Full host-exec trace for troubleshooting; the env toggle works without a rollout. |
| `agent.args.rebootCommand` | binary default | `nsenter -t 1 -m -u -i -n -- systemctl reboot`. |
| `namespace.create` | `true` | false when the namespace (and its PSA labels) is external. |

## Versioning

`Chart.yaml` `version` and `appVersion` both track the release (e.g. `0.1.81`).
`appVersion` drives both default image tags (`<appVersion>-agent` /
`-controller`); `version` names the packaged tarball
(`nodeprep-<version>.tgz`), which the Palette pack's `charts` array points at.
Bump both together with the manifests `VERSION` bump.

## Sync helper

The CRD templates must stay byte-identical to `manifests/crd-*.yaml`:

```sh
make chart-sync-crds
```

## Example NodePrepProfile

In order to trigger nodeprep on nodes, deploy a NodePrepProfile resource:

```
apiVersion: nodeprep.spectrocloud.com/v1alpha1
kind: NodePrepProfile
metadata:
  name: basic-profile
spec:
  mode: allNodes
  # mode: labelSelector
  # nodeSelector:
  #   matchLabels:
  #     node.spectrocloud.com/ai-worker: "true"
  excludeLabel: node.spectrocloud.com/ai-worker=false

  controlPlane:
    bootstrapGate: auto
    expectedCount: 0
    prep: false
    strategy: serial
  eastWest:
    linkType: "Ethernet"
    numVFs: 0
    mtu: 9000
    eswitchMode: legacy
    manageOVS: false
    roceCC: true
  firmware:
    aptUpgrade: true
    bfb:
      name: bf-fwbundle-3.5.0-89_26.07-prod.bfb
      sha256: 2d02f198b952b3e6a652beccbd7740ed4ab78ded3d00c3939acd1d707c93391d
    doca:
      deb: doca-host_3.5.0-082000-26.07-ubuntu2404_amd64.deb
      sha256: a2312bb04b980fae370fb5de483fda8cc6bc590553bf3c8dc77f980e3840740a
      packages:
      - linux-headers-$(uname -r)
      - gcc-12
      - libgcc-12-dev
      - doca-all
      - lldpd
      - mft
      - netplan.io
      - pv
      - psmisc
    source: "http://maas.internal:8069/rcp" # base URL for artifacts (MAAS mirror)
  hostBoot:
    kubeletStateReset: always
    mlnxInterfaceMgr: wait
    rdmaNetnsMode: exclusive # or shared
    iommu: auto
    hugepages:
      defaultSize: 2M
      pages1G: 0
      pages2M: 0
  nfsRdma:
    enabled: true
  northSouth:
    linkType: "Ethernet"
    numVFs: 0
    offloadEngine: false
  policy:
    capiPause: true
    controlDPU: false
    disableACS: true
    hostMutations: true
    labelCompat: false
    maxConcurrentFlashes: 1
    rebootEnabled: true
    taintEnabled: true
    workerRoleLabel: manage
  rails: []
    # - rail: r0
    #   pciFunction: "05:00"
    # - rail: r1
    #   pciFunction: "06:00"
    # - rail: r2
    #   pciFunction: "07:00"
    # - rail: r3
    #   pciFunction: "08:00"
    # - rail: r4
    #   pciFunction: "09:00"
    # - rail: r5
    #   pciFunction: "0a:00"
    # - rail: r6
    #   pciFunction: "0b:00"
    # - rail: r7
    #   pciFunction: "0c:00"
```