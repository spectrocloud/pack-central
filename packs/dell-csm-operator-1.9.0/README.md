# Description
Dell Technologies Container Storage Modules (CSM) Operator is an open-source Kubernetes operator which can be used to install and manage various CSI Drivers and CSM Modules.

CSI capabilities per driver can be found [here](https://dell.github.io/csm-docs/docs/csidriver/)
Supported components can be found [here](https://dell.github.io/csm-docs/docs/deployment/csmoperator/#supported-csm-components)


# Kubernetes versions supported:
Above 1.26

# Constraints:
Support for PowerFlex, PowerMax and PowerStore is available.
Support for PowerScale and UnityXT is not available at this time.

Please see [here](https://dell.github.io/csm-docs/docs/deployment/csmoperator/drivers/) for installation prereqs. For PowerFlex, PowerMax and PowerStore you typically need to install either the ScaleIO driver (PowerFlex) and/or Multipath, as well as iSCSI packages if iSCSI is used. The Dell page linked above contains information on these prereqs, which will need to be added to the OS layer in the cluster profile.

# Cloud types supported:
This pack was designed to be used with clusters on Canonical MAAS

# References:
  - https://github.com/dell/csm-operator
