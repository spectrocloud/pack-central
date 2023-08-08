## Appdynamics Cloud Helm Charts
This repository maintains helm charts for installing Appdynamics Cloud Collector.

To install Appdynamics Cloud Collector using Helm Charts:
## Prerequisites
Kubernetes 1.19+ is required for AppDynamics Cloud Collector Installation
Helm 3.0+
AppDynamics Cloud Operator & Opentelemetry Operator Should be present and running with all the AppDynamics and Opentelemetry CRD's and their deployments

## Installation Steps
Install appdynamics-collectors chart locally:
helm install <chart-name> helm/charts/appdynamics-collectors -f <path-to-values.yaml> -n appdynamics
If you want to install using helm package then download the appdynamics-collectors helm package:

then use the package to install appdynamics-collectors chart:

helm install <chart-name> <appdynamics-collectors-package-name.tgz> -f <path-to-values.yaml> -n appdynamics