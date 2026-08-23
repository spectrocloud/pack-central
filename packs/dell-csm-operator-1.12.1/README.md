# Description
Dell Technologies Container Storage Modules (CSM) Operator is an open-source Kubernetes operator which can be used to install and manage various CSI Drivers and CSM Modules.

This pack packages CSM Operator **v1.12.1**, which installs CSM bundle **v1.17.1** (CSI drivers in the 2.17.x line: PowerFlex/PowerStore v2.17.0, PowerMax/PowerScale v2.17.1).

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

Do not apply Dell's sample ConfigMap (`samples/v2.17.0/k8s_configmap.yaml` in the upstream repo) on a cluster using this pack. At the v1.12.1 tag that sample is keyed on `v1.17.1`, the same version this pack sets, and it pins the PowerFlex SDC to 5.0, which would override the 5.1 pin here. The operator searches every namespace for a ConfigMap named `csm-images`, so it takes effect regardless of where it is applied.

# Cloud types supported:
This pack was designed to be used with clusters on Canonical MAAS

# References:
  - https://github.com/dell/csm-operator
  - https://github.com/dell/csm-operator/releases/tag/v1.12.1
