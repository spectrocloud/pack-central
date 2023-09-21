## The Appdynamics Collector Cloud Helm Charts
An Add-on pack for Spectro Cloud to use the monitoring of k8s cluster with AppDynamics collectors.

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


## References
To enable log collection for your cluster, please refer:
https://docs.appdynamics.com/fso/cloud-native-app-obs/en/kubernetes-and-app-service-monitoring/log-collection/onboard-logs-from-kubernetes/configure-the-log-collector

Here is the complete product guide about the AppDynamics collectors.
https://docs.appdynamics.com/fso/cloud-native-app-obs/en/kubernetes-and-app-service-monitoring/install-kubernetes-and-app-service-monitoring