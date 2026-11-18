# Description
Dell Technologies Container Storage Modules (CSM) Operator is an open-source Kubernetes operator which can be used to install and manage various CSI Drivers and CSM Modules.

This pack packages CSM Operator **v1.13.2**, which installs CSM bundle **v1.18.2** (CSI drivers in the 2.18.x line: PowerFlex v2.18.0, PowerStore/PowerScale v2.18.1, PowerMax v2.18.2, Unity v2.18.0).

CSI capabilities per driver can be found [here](https://dell.github.io/csm-docs/docs/csidriver/)
Supported components can be found [here](https://dell.github.io/csm-docs/docs/deployment/csmoperator/#supported-csm-components)


# Kubernetes versions supported:
Above 1.26

# Constraints:
Support for PowerFlex, PowerMax, PowerStore and PowerScale is available.
Support for UnityXT is not available at this time.

Please see [here](https://dell.github.io/csm-docs/docs/deployment/csmoperator/drivers/) for installation prereqs. For PowerFlex, PowerMax and PowerStore you typically need to install either the ScaleIO driver (PowerFlex) and/or Multipath, as well as iSCSI packages if iSCSI is used. The Dell page linked above contains information on these prereqs, which will need to be added to the OS layer in the cluster profile.

# Image overrides:
Every image the operator deploys is pinned through the `csm-images` ConfigMap, rendered from `charts.csm-operator.csmImages` in the pack values. The operator reads this ConfigMap on each reconcile and it takes precedence over the image defaults compiled into the operator container, so it is the place to change an image version.

Two things to be aware of:

  - The keys are not free-form. Each key must match the container name (for CSI sidecars and the PowerFlex SDC) or the module component name (for modules) that the operator looks up. In particular, PowerFlex names its health monitor container `csi-external-health-monitor-controller` while every other driver names it `external-health-monitor`, so both keys are present and must be kept in step. Clearing a value falls back to the operator default rather than failing; removing every value omits the ConfigMap entirely.
  - The `RELATED_IMAGE_*` environment variables on the operator Deployment are OLM metadata for disconnected mirroring tools and are never read at runtime. Changing them has no effect on which images get pulled.

Do not apply Dell's sample ConfigMap (`samples/v1.18.2/configmaps/k8s.yaml` in the upstream repo) on a cluster using this pack. At the v1.13.2 tag that sample is keyed on `v1.18.2`, the same version this pack sets, so the two ConfigMaps would conflict. This pack's `csmImages` already matches that sample entry for entry (plus the extra `csi-external-health-monitor-controller` key for PowerFlex). The operator searches every namespace for a ConfigMap named `csm-images`, so it takes effect regardless of where it is applied.

Dell also ships an optional `csm-image-allowlist` ConfigMap (`operatorconfig/common/csm-image-allowlist.yaml`). The operator uses it to validate image overrides placed directly in a `ContainerStorageModule` spec and `spec.customRegistry`. If you mirror images to a private registry, add that registry to the allowlist.

# Upgrade from 1.12.1:
This version moves the operator from v1.12.1 to v1.13.2 and the CSM bundle from v1.17.1 to v1.18.2. The GitHub release pages for [v1.13.0](https://github.com/dell/csm-operator/releases/tag/v1.13.0), [v1.13.1](https://github.com/dell/csm-operator/releases/tag/v1.13.1) and [v1.13.2](https://github.com/dell/csm-operator/releases/tag/v1.13.2) carry no detailed notes (v1.13.0 maps to CSM 1.18.0, v1.13.1 to CSM 1.18.1, v1.13.2 to CSM 1.18.2), so the items below come from the diff between the v1.12.1 and v1.13.2 tags.

  - CSI drivers: PowerFlex 2.17.0 to 2.18.0, PowerStore 2.17.0 to 2.18.1, PowerScale 2.17.1 to 2.18.1, PowerMax 2.17.1 to 2.18.2, Unity 2.17.0 to 2.18.0. The operator allows a direct upgrade into these drivers from driver v2.16.0 or later.
  - Modules: Authorization 2.5.0 to 2.6.1, Replication 1.15.0 to 1.16.0, Observability to 1.16.0, Resiliency (podmon) 1.16.0 to 1.17.0, PowerMax reverse proxy 2.16.1 to 2.17.1, COSI 1.1.0 to 1.2.0.
  - New in the operator: CSI-Addons based replication for PowerMax (`csi-addons-replication` v1.0.0, uses the `quay.io/csiaddons/k8s-sidecar` image), a `FAILURE_GRACE_PERIOD` setting on the operator Deployment (10m by default), and the optional `csm-image-allowlist` ConfigMap described above.
  - Operator RBAC and CRD: the ClusterRole gains rules for CSI-Addons, volume group replication, PowerMax volume journals, Prometheus `podmonitors` and `prometheusrules`, `metrics.k8s.io` pods, `volumeattributesclasses` and a few others. The `ContainerStorageModule` CRD is larger (new fields for metrics endpoints, ports and volume mounts). Helm only installs CRDs from a chart's `crds/` directory on first install and does not update them on upgrade, so confirm the updated CRD is applied on an existing cluster.
  - PowerFlex SDC: the SDC image is now `5.1.0.2`, which is also the upstream default, so this pack no longer overrides it with an explicit `image:` in the PowerFlex driver spec. The SDC entries in `csmImages` stay in step with upstream.
  - Samples: the upstream layout changed from `samples/v2.17.0/` to `samples/v1.18.2/`, keyed on the CSM version. The per-driver values files in this pack are now named `values_<driver>_v2180.yaml` and the presets `<driver>-v2180`. The presets are named for the 2.18.x line, so select the new preset when moving a cluster profile to this version.
  - Images: the third-party pins moved (nginx-unprivileged 1.30.4, cert-manager v1.21.1, kube-mgmt 11.0.14, OpenTelemetry collector 0.160.0, redis 8.10.1-alpine). `redis`, `csi-addons`, `cosi` and `objectstorage-provisioner-sidecar` are new keys in the `csm-images` ConfigMap.

Plan a maintenance window for the upgrade. A new CSM version rolls the driver pods, and PowerFlex nodes also pick up the new SDC image.

# Cloud types supported:
This pack was designed to be used with clusters on Canonical MAAS

# References:
  - https://github.com/dell/csm-operator
  - https://github.com/dell/csm-operator/releases/tag/v1.13.2
