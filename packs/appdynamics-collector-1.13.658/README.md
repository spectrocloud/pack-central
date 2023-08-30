## The Appdynamics Collector Cloud Helm Charts
An Add-on pack for Spectro Cloud to use the monioring of k8s cluster with AppDynamics collectors.

## Appdynamics Cloud Helm Charts
This repository maintains helm charts for installing Appdynamics Cloud Collector.

## Parameters
| Parameter | Description |
|-----------|-------------|
| clusterName | String to specify the name of the k8s cluster |
| endpoint | The endpoint Tenant to which you want to send the data to. Please refer the product guide link from References for more details |
| clientId | clientId of your Tenant . Please refer the product guide link from References for more details  | 
| clientSecret | clientSecret of your Tenant. Please refer the product guide link from References for more details  | 
| tokenUrl | tokenUrl of your Tenant. Please refer the product guide link from References for more details  | 
| tenantId | tenantId of your Tenant. Please refer the product guide link from References for more details  | 


To install Appdynamics Cloud Collector using Helm Charts:
## Prerequisites
Kubernetes 1.19+ is required for AppDynamics Cloud Collector Installation
Helm 3.0+
AppDynamics Cloud Operator & Opentelemetry Operator Should be present and running with all the AppDynamics and Opentelemetry CRD's and their deployments

## References
Here is the complete product guide about the AppDynamics collectors.
https://docs.appdynamics.com/fso/cloud-native-app-obs/en/kubernetes-and-app-service-monitoring/install-kubernetes-and-app-service-monitoring