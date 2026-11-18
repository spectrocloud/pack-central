# Nvidia DPF Deployment - 26.4.0

Creates the DPF custom resources (BFB, DPUFlavor, DPUSet, DPUDeployment, and the
DPUService/DPUServiceChain/DPUServiceInterface/DPUServiceIPAM objects) that drive
DPU provisioning and service orchestration.

This is a Spectro Cloud **wrapper chart** (`dpf-deployment`) - there is no upstream
NVIDIA chart of this name. It templatizes the DPF reference deployment so the CRs
can be driven from pack values / presets. All CR `apiVersion`s and fields were
verified against the DPF v26.4.0 CRDs shipped in the `dpf-operator` v26.4.0 chart.

## CR validation against the 26.4.0 schema

All CRs are `provisioning.dpu.nvidia.com/v1alpha1` or `svc.dpu.nvidia.com/v1alpha1`
(unchanged from 25.10.1). Every field the templates emit still exists in the
26.4.0 CRDs - no removals. New 26.4.0 fields added to the templates:

- `DPUSet.dpuDeviceSelector` - select DPUs by discovered **device** (Zero Trust /
  host-less), as opposed to `dpuNodeSelector` (Host Trusted).
- `dpuClusterSelector` on `DPUService`, `DPUServiceChain`, `DPUServiceInterface`,
  `DPUServiceIPAM` - target a specific DPUCluster in multi-cluster setups.

## Zero Trust (ZT) vs Host Trusted (HT)

Two presets are shipped; pick one in the Palette UI to populate a starting config:

| | Host Trusted (`host-trusted`) | Zero Trust (`zero-trust-pt`) |
|---|---|---|
| DPU host is a k8s worker | Yes | No |
| DPUFlavor `dpuMode` | (unset / trusted) | `zero-trust` |
| DPU selection | `dpuNodeSelector` on the worker | `dpuDeviceSelector` on the discovered DPUDevice (host-less) |
| DPUServices | OVN + HBN + DTS + Blueman, full service chain | none (passthrough) |
| Service chain | physical ports -> HBN -> OVN | physical ports -> host PFs (pf0hpf/pf1hpf) |
| BFB + DPUFlavor CRs | required | required |

> The DPU **provisioning interface** (Redfish for ZT vs rshim for HT) is set in the
> `nvidia-dpf-operator` pack, not here.

## Component versions used by the presets (DPF 26.4.0)

| Component | Version | Source |
|---|---|---|
| BFB | `bf-bundle-3.4.0-92_26.04_ubuntu-24.04_64k_prod.bfb` | content.mellanox.com |
| OVN | `ovn-kubernetes-chart` `v26.4.0` | `oci://ghcr.io/mellanox/charts` (moved from ghcr.io/nvidia in 26.4.0) |
| HBN | `doca-hbn` `3.4.0`, image `nvcr.io/nvidia/doca/doca_hbn:3.4.0-doca3.4.0` | `helm.ngc.nvidia.com/nvidia/doca` |
| DTS | `doca-telemetry` `1.25.5` | `helm.ngc.nvidia.com/nvidia/doca` |
| Blueman | `doca-blueman` `1.0.8` | `helm.ngc.nvidia.com/nvidia/doca` |

## What changed vs 25.10.1

- Chart `25.10.1` -> `26.4.0`; BFB `3.2.1/25.11` -> `3.4.0/26.04`.
- OVN chart moved `oci://ghcr.io/nvidia` `v25.10.1` -> `oci://ghcr.io/mellanox/charts` `v26.4.0`.
- HBN `doca-hbn` `1.0.5` (image `3.2.1-doca3.2.1`) -> `3.4.0` (image `3.4.0-doca3.4.0`).
- DTS `doca-telemetry` `1.23.4` -> `1.25.5`.
- Added `dpuDeviceSelector` + `dpuClusterSelector` template support (new in 26.4.0).
- Flavor/BFB CR names bumped to `*-v26.4.0`.

Source of truth: <https://networking-docs.nvidia.com/dpf/26.4.0> and the
`public-release-v26.4` use-case manifests in
[NVIDIA/doca-platform](https://github.com/NVIDIA/doca-platform/tree/public-release-v26.4/docs/public/user-guides).
