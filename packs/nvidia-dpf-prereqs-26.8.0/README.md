# Nvidia DPF Prereqs - 26.8.0

Cluster-level prerequisites that must be installed **before** the DPF Operator.
This pack mirrors the official DPF 26.8.0 prerequisite set, defined upstream in
[`deploy/helmfiles/prereqs.yaml@v26.8.0`](https://github.com/NVIDIA/doca-platform/blob/v26.8.0/deploy/helmfiles/prereqs.yaml)
and [`helm-prerequisites.md@v26.8.0`](https://github.com/NVIDIA/doca-platform/blob/v26.8.0/docs/public/getting-started/helm-prerequisites.md).

## Charts in this pack (install order = pack.json order)

| # | Chart | Version | Source repo |
|---|-------|---------|-------------|
| 0 | dpf-prereqs-crds | `26.8.0` | Spectro chart: CRD sync Job (see below) |
| 1 | local-path-provisioner | `0.0.34` | `git+https://github.com/rancher/local-path-provisioner@deploy/chart?ref=v0.0.34` |
| 2 | node-feature-discovery | `0.18.3` | `https://kubernetes-sigs.github.io/node-feature-discovery/charts` |
| 3 | maintenance-operator-chart | `0.3.0` | `oci://ghcr.io/mellanox/maintenance-operator-chart` |
| 4 | argo-cd | `9.4.1` | `https://argoproj.github.io/argo-helm` |
| 5 | kamaji | **`1.4.0`** | `oci://ghcr.io/nvidia/charts/kamaji` (image `ghcr.io/nvidia/kamaji:v1.36.0-26.6.4`) |
| 6 | dpf-monitoring | `26.8.0` | Spectro umbrella over NVIDIA's optional monitoring helmfile, all OFF by default |

**dpf-prereqs-crds** runs first. NVIDIA's helmfile applies the CRDs of kamaji,
maintenance-operator and NFD with a preapply hook (`apply-crds.sh`) because Helm
installs a chart's `crds/` folder only on first install and never upgrades it.
Palette has no such hook: an in-place 26.4 -> 26.8 upgrade kept the kamaji 1.2.0
CRDs, DPF's kamaji-cluster-manager failed every DPUCluster reconcile
(`.spec.writePermissions: field not declared in schema`) and the kamaji 1.4.0 Helm
upgrade deadlocked on the removed `vdatastore.kb.io` webhook (found live
2026-11-01). The chart's post-install/post-upgrade Job (alpine/k8s 1.34.12,
non-root, RBAC limited to those 8 CRDs and that one webhook config) server-side
applies the CRDs, waits for Established, and deletes
`kamaji-validating-webhook-configuration` only while it still lists
`vdatastore.kb.io`. Tested on kind: 1.2.0 state upgraded, 1.4.0 webhook left alone.
Refresh `charts/dpf-prereqs-crds/files/` whenever one of those charts changes version.

Install order matters: local-path-provisioner creates the `local-path`
StorageClass that the kamaji-etcd PVCs need (live failure 2026-07-29 when
kamaji came first). NVIDIA's helmfile still has no ordering between the two.

cert-manager v1.19.3 is a hard upstream prerequisite but is **not shipped**:
the target Palette environment installs it. Add it as its own layer before this
pack on clusters without it. openbao, external-secrets and kata-deploy (optional
in 26.8, off upstream) are not shipped.

## What changed vs 26.4.0

- **kamaji 1.2.0 -> 1.4.0** (image `v1.34.0-25.9.3` -> `v1.36.0-26.6.4`), with
  NVIDIA's 26.8 values: `kamaji-etcd.selfSignedCertificates.enabled: true`,
  `kamaji-etcd.certManager.enabled: false` (the 1.4.0 parent chart defaults
  certManager on), cfssl tag moved to `kamaji-etcd.jobs.cfssl.tag:
  v1.6.5@sha256:c9018c2d...`; top-level `cfssl.image.tag` dropped (it was a dead
  key: the 26.4.0 pack actually ran `cfssl/cfssl:latest`).
- **Our kamaji divergence is kept** (chart 1.4.0 still defaults to a 200m CPU
  limit, NVIDIA values still `resources: null`): cpu 2 / 512Mi limits, 250m /
  128Mi requests, probe timeout 10s / failureThreshold 6, one replica. The
  replica setting now uses the key the chart reads (`replicaCount: 1`): the
  `replicas` key in NVIDIA's values and in our 26.4.0 pack was never read.
- `content.images`: kamaji image bumped, cfssl pinned by digest, and
  `quay.io/coreos/etcd:v3.5.6` added (the kamaji-etcd setup Job uses it; it was
  missing from the 26.4.0 airgap list).
- **dpf-monitoring 26.4.0 -> 26.8.0**: values resynced with NVIDIA's 26.8
  helmfile (metric allowlists on apiserver/controller-manager/scheduler/KSM/otel/
  DPF scrape job with the `dpf_` prefix, `defaultRules.create: false`,
  `enableRemoteWriteReceiver: true`, open rule selectors, KSM collector list,
  otel `transform/kamaji`), plus two new templates that replace upstream's
  helmfile hooks: the `dpf-monitoring-grafana-dashboards` ConfigMap (DPF alerts
  dashboard) and the 7 DPF PrometheusRules. Both render only when
  kube-prometheus-stack is enabled. Disabled render = 0 objects (CRDs included).
  Also fixed the Grafana Loki derived-field URL to NVIDIA's `$${__value.raw}`
  (Grafana provisioning expands `${...}`; the 26.4.0 umbrella had a single `$`).

## Namespace note (Palette packaging deviation)

A single Palette pack deploys all its charts into one namespace, so everything
installs into `dpf-operator-system` (upstream puts local-path-provisioner in its
own namespace). Functionally equivalent: the StorageClass is cluster-scoped.

## Zero Trust (ZT) vs Host Trusted (HT)

The prerequisites are identical for ZT and HT. The mode is chosen in the
`nvidia-dpf-operator` pack (deploymentMode) and the `nvidia-dpf-deployment` pack.

Source of truth: <https://networking-docs.nvidia.com/dpf/26.8.0>.
