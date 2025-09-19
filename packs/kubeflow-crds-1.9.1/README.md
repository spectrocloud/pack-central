# Kubeflow CRDs

This pack installs the Custom Resource Definitions for Kubeflow 1.9.1.

## Prerequisites

None

## Parameters

| **Parameter** | **Description** | **Type** | **Default Value** | **Required** |
|---|---|---|---|---|
| crds.minimized | Installs the minimum CRD schemas to pass validation. Set to `false` to install the full CRDs | Boolean | true | Yes |
| notebooks.enabled | Installs the Notebooks CRD | Boolean | true | Yes |
| notebooks.controller.enabled | Includes the controller in the Notebooks CRD | Boolean | true | Yes |
| notebooks.controller.certManager.enabled | Includes cert-manager support for the controller in the Notebooks CRD | Boolean | false | Yes |
| notebooks.controller.webhook.enabled | Includes webhook support for the controller in the Notebooks CRD | Boolean | false | Yes |
| notebooks.pvcviewerController.enabled | Includes the pvcviewerController in the Notebooks CRD | Boolean | true | Yes |
| profilesController.enabled | Installs the Profile CRD | Boolean | true | Yes |
| katib.controller.enabled | Installs the Katib CRDs | Boolean | true | Yes |
| pipelines.scheduledWorkflow.enabled | Installs the ScheduledWorkflow CRD | Boolean | true | Yes |
| pipelines.viewerCrd.enabled | Installs the Viewer CRD | Boolean | true | Yes |
| tensorboard.controller.enabled | Includes the Tensorboard CRD | Boolean | true | Yes |
| trainingOperator.enabled | Installs the Training Operator v1 CRDs | Boolean | true | Yes |


## Upgrade

This is the first version of the Kubeflow CRDs pack. There are no previous versions to upgrade from.


## Usage

To deploy this pack, add it to your cluster profile. The defaults should not need adjusting.


## References

- [Based on kromanow94/kubeflow-manifests](https://github.com/kromanow94/kubeflow-manifests/tree/helmcharts/charts/kubeflow-crds)