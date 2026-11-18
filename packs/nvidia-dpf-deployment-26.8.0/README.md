# Nvidia DPF Deployment - 26.8.0

Creates the DPF custom resources (BFB, DPUFlavor, DPUFlavorTemplate, DPUDevice,
DPUSet, DPUDeployment and the DPUService / DPUServiceChain / DPUServiceInterface /
DPUServiceIPAM / DPUServiceNAD objects) that drive DPU provisioning and service
orchestration.

This is a Spectro Cloud **wrapper chart** (`dpf-deployment`), not an upstream
NVIDIA chart. All CR `apiVersion`s and fields were checked against the DPF
v26.8.0 CRDs shipped in the `dpf-operator` v26.8.0 chart (offline schema
validation of every preset render: 0 errors).

## Presets (group "Mode")

| | Host Trusted (`host-trusted`) | Zero Trust - Passthrough (`zero-trust-pt`) | Zero Trust - HBN (`zero-trust-hbn`) | Zero Trust - Hostless (`zero-trust-hostless`) |
|---|---|---|---|---|
| NVIDIA reference | hbn-ovnk (05 + 04 manifests) | passthrough (03) | hbn, PF variant (03.1) | hostless doc (no manifests) |
| Operator preset to pair with | Host Trusted | Zero Trust (DPUDiscovery) | Zero Trust (DPUDiscovery) | Zero Trust - Hostless |
| DPU host is a k8s worker | yes | no (or not managed by DPF) | no (or not managed by DPF) | no host at all |
| DPUNodes come from | the worker Node | DPUDiscovery crawler | DPUDiscovery crawler | DPF, from hand-declared `dpuDevices[]` labelled `provisioning.dpu.nvidia.com/hostless: "true"` |
| DPUSet / DPUDeployment | DPUDeployment, `RollingUpdate`, `drain` | DPUSet, `OnDelete`, `noEffect` | DPUDeployment, `OnDelete`, `noEffect` | DPUSet, `OnDelete`, `noEffect` |
| DPUServices | OVN + HBN + DTS + Blueman, full chain, NodeSRIOVDevicePluginConfig for host VFs | none (ports chained to host PFs) | DOCA HBN (BGP EVPN, VRFs RED/BLUE) | none (ports chained to host PFs) |
| Lines to SET for your site | `hostCIDR`, pod/service CIDRs, HBN worker hostname patterns, `k8sAPIServer` on RKE2 | none | `${DPU1_SERIAL}` / `${DPU2_SERIAL}` | the `dpuDevices[]` entries |

The Host Trusted, Passthrough and HBN presets are GENERATED from NVIDIA's v26.8.0
reference manifests; a render of each is spec-identical to NVIDIA's objects
except the commented lines (HT `k8sAPIServer: auto`; ZT `nodeEffect.noEffect`
instead of NVIDIA's `hold`, the zero-trust choice validated live 2026-07).
Host Trusted also needs OVN-Kubernetes v26.8.0 as the host cluster's primary CNI,
installed outside this pack.

The deployment mode itself lives in `DPFOperatorConfig.spec.deploymentMode`
(nvidia-dpf-operator pack). `DPUFlavor.spec.dpuMode` is deprecated and ignored in
26.8, so no preset sets it and the wrapper no longer renders it.

## Component versions used by the presets (DPF 26.8.0)

| Component | Version | Source |
|---|---|---|
| BFB | `bf-bundle-3.5.0-89_26.07_ubuntu-24.04_64k_prod.bfb` (as NVIDIA's 26.8 guides; a 4K-page `..._prod.bfb` of the same build exists) | content.mellanox.com |
| OVN | `ovn-kubernetes-chart` `v26.8.0` | `oci://ghcr.io/mellanox/charts` |
| HBN | `doca-hbn` `3.5.0`, image `nvcr.io/nvidia/doca/doca_hbn:3.5.0-doca3.5.0` | `helm.ngc.nvidia.com/nvidia/doca` |
| DTS | `doca-telemetry` `1.26.5` | `helm.ngc.nvidia.com/nvidia/doca` |
| Blueman | `doca-blueman` `1.0.8` (deprecated in 26.8) | `helm.ngc.nvidia.com/nvidia/doca` |

## What changed vs 26.4.0

- Chart `26.4.0` -> `26.8.0`; BFB `3.4.0-92/26.04` -> `3.5.0-89/26.07`; CR names `*-v26.8.0`.
- Wrapper chart `26.8.1` (pack still 26.8.0, rebuilt 2026-11-01): new `nodeSRIOVDevicePluginConfigs[]`
  template (NodeSRIOVDevicePluginConfig, noderesources.dpu.nvidia.com/v1alpha1); presets regenerated
  from NVIDIA's v26.8.0 manifests, new Zero Trust - HBN preset, BFB switched to NVIDIA's 64k build,
  lab values removed from the HT OVN config (`172.25.0.2`, `mtu 8940`, custom HBN ASN pool).
- Wrapper templates:
  - BFB name `bf-bundle-v26.8.0` (overridable with `bfbName`); the BFB is only
    rendered when `bfb` is set (the 26.4.0 wrapper rendered `spec: {}` with empty values).
  - DPUFlavor: `dpuMode` dropped; new `dma`, `ewNicConfigurations`, `packages`,
    `serviceReadiness`, `systemdServices`.
  - New templates: `DPUFlavorTemplate` (`dpuFlavorTemplates[]`, per-DPU flavors
    rendered from `DPUDevice.spec.values`), `DPUDevice` (`dpuDevices[]`, hostless
    flow; renders `bmcFactoryResetPolicy: Never` unless set), `DPUServiceNAD`
    (`dpuServiceNADs[]`).
  - DPUService and DPUServiceTemplate render `security`; a DPUService with
    `deployInCluster` false/unset fails the render unless
    `security.privileged` is set (26.8 CEL rejects it at admission otherwise).
  - DPUDeployment renders `metadata.annotations` (for example the undocumented
    `svc.dpu.nvidia.com/dpudeployment-skip-chain-requestor: "true"`).
- Flavors follow the 26.8 references: no `fixrttc`, `hugepages=250`, new OVS
  script (removes ovsbr1/ovsbr2, deletes `system@ovs-system`, restarts
  openvswitch, `doca-congestion-threshold=60`, `flow-limit=500000`,
  `hw-offload-ct-unidir-udp-enabled=true`); HT adds `del-br br-hbn`,
  `hbn_uplink=p0_if`, the br-dpu/br-ovn patch layout and AppArmor overrides.
- HT: `DPUServiceInterface ovn` -> `interfaceType: patch` + `peerBridge: br-ovn`
  (the `ovn` type is deprecated, removed with v26.10.0); OVN `gatewayOpts`
  `--gateway-interface=br-dpu`; the placeholder `dpuSelector`
  (`dpudevice-pf0-name: $DPU_P0`) is replaced by a commented `dpuDeviceSelector`
  example.
- ZT keeps `strategy: OnDelete` and `nodeEffect.noEffect: true` (NVIDIA's
  passthrough reference uses `hold: true`; noEffect is the validated ZT choice and
  NVIDIA's own recommendation for hostless).

Site plumbing (NTP, oob netplan, containerd registry mirrors as
`/etc/containerd/certs.d/<reg>/hosts.toml`) is NOT in these generic presets; DPU
Manager's flavor builder adds it. Never combine a hosts.toml mirror with
`DPUFlavor.spec.containerdConfig.registryEndpoint`.

Source of truth: <https://networking-docs.nvidia.com/dpf/26.8.0> and the
v26.8.0 use-case manifests in
[NVIDIA/doca-platform](https://github.com/NVIDIA/doca-platform/tree/v26.8.0/docs/public/user-guides).
