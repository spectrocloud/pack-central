# Nvidia DPF Prereqs - 26.4.0

Cluster-level prerequisites that must be installed **before** the DPF Operator.
This pack mirrors the official DPF 26.4.0 prerequisite set, defined upstream in
`deploy/helmfiles/prereqs.yaml` on the `public-release-v26.4` branch of
[NVIDIA/doca-platform](https://github.com/NVIDIA/doca-platform/blob/public-release-v26.4/deploy/helmfiles/prereqs.yaml).

## Charts in this pack (the official 26.4.0 set)

| Chart | Version | Source repo |
| ----- | ------- | ----------- |
| kamaji | `1.2.0` | `oci://ghcr.io/nvidia/charts/kamaji` |
| maintenance-operator-chart | `0.3.0` | `oci://ghcr.io/mellanox/maintenance-operator-chart` |
| argo-cd | `9.4.1` | `https://argoproj.github.io/argo-helm` |
| node-feature-discovery | `0.18.3` | `https://kubernetes-sigs.github.io/node-feature-discovery/charts` |
| local-path-provisioner | `0.0.34` | `git+https://github.com/rancher/local-path-provisioner@deploy/chart?ref=v0.0.34` |

## What is DIFFERENT vs the old nvidia-dpf-prereqs 25.10.1 pack

The 26.4.0 prerequisite set was restructured upstream. This is a real composition
change, not just a version bump:

**Removed from the prereqs (no longer part of the official prereq set):**
- `grafana` (was 8.4.6)
- `prometheus` (was 25.26.0)
- `kube-state-metrics` (was 5.25.1)
- `kamaji-crds` (was 26.2.2) - CRDs are now applied by the upstream helmfile's
  `apply-crds.sh` hook directly from the kamaji chart, so a separate kamaji-crds
  chart is no longer shipped.

  > The observability stack (grafana/prometheus/kube-state-metrics) is no longer a
  > DPF *prerequisite* in 26.4.0; it moved to an optional, separately-installed
  > monitoring layer (upstream now references `kube-prometheus-stack`, `loki`,
  > `opentelemetry-collector` as optional add-ons). If you still want dashboards,
  > install them as a separate addon pack - they are not required for DPF to run.
  > The DPF Operator's own dashboards/metrics toggles still live in the
  > `nvidia-dpf-operator` pack (`grafanaDashboards`, `prometheusSecureMetrics`,
  > `kubeStateMetricsCRDMetrics`).

**Added (new core prerequisites in 26.4.0):**
- `cert-manager v1.19.3` - now a hard upstream prerequisite (kamaji,
  maintenance-operator and the DPF webhooks depend on it). **NOT shipped in this
  pack (removed 2026-07-28)**: the target Palette environment installs
  cert-manager itself, and shipping a second copy collides with it. If a target
  cluster has no cert-manager, add it as its own profile layer BEFORE this pack
  (upstream reference values: dpf-operator chart `dev/helmfiles/values/cert-manager.yaml`).
- `local-path-provisioner v0.0.34` - provides the `local-path` StorageClass that
  kamaji-etcd's PVCs use. (The old pack relied on an externally-provided
  `local-path-provisioner` StorageClass; in 26.4.0 it is shipped as a prereq.)

**Changed versions (carried over, bumped):**
- `kamaji` 26.2.2 -> `1.2.0`, and the source moved from a mirrored chart to
  `oci://ghcr.io/nvidia/charts/kamaji`; image `ghcr.io/nvidia/kamaji:v1.34.0-25.9.3`.
  The etcd PVC StorageClass name is now `local-path` (was `local-path-provisioner`).
- `maintenance-operator-chart` 0.2.0 -> `0.3.0` (now `oci://ghcr.io/mellanox/...`).
- `argo-cd` 7.8.2 -> `9.4.1` (Argo CD app version v3.3.0).
- `node-feature-discovery` 0.17.1 -> `0.18.3`. Note: from 0.18.3 the chart's
  default values dropped the control-plane/master toleration, so it is set
  explicitly here to keep NFD scheduling on control-plane nodes.

## Namespace note (Palette packaging deviation)

The upstream helmfile installs local-path-provisioner in the
`local-path-provisioner` namespace, with the rest in `dpf-operator-system`.
A single Palette system-app pack deploys all of its charts into one pack
namespace, so this pack installs **everything into `dpf-operator-system`**.
All of these components are cluster-scoped or namespace-agnostic (the
local-path StorageClass, the NFD NodeFeatureRules, etc.), so this is
functionally equivalent and matches the convention used by the previous
25.10.1 pack.

## Zero Trust (ZT) vs Host Trusted (HT)

The prerequisites are **identical for ZT and HT** - none of these charts or values
change between the two modes. The ZT/HT distinction is made in the
`nvidia-dpf-operator` pack (provisioning interface) and the `nvidia-dpf-deployment`
pack (which CRs are needed), not here.

Source of truth: <https://networking-docs.nvidia.com/dpf/26.4.0> and the
`deploy/helmfiles/prereqs.yaml` linked above.
