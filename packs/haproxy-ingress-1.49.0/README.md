# Description
An ingress controller is a Kubernetes resource that routes traffic from outside your cluster to services within the cluster. HAProxy Kubernetes Ingress Controller uses ConfigMap to store the haproxy configuration.

Detailed documentation can be found within the [Official Documentation](https://www.haproxy.com/documentation/kubernetes/latest/).

Additional configuration details can be found in [annotation reference](https://github.com/haproxytech/kubernetes-ingress/tree/master/documentation) and in image [arguments reference](https://github.com/haproxytech/kubernetes-ingress/blob/master/documentation/controller.md).

This chart bootstraps an HAProxy kubernetes-ingress deployment/daemonset on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

# Kubernetes versions supported:
Kubernetes 1.24+

# Cloud types supported:
All

# More information:
https://github.com/haproxytech/helm-charts/blob/main/kubernetes-ingress/README.md

# References:
  - https://github.com/haproxytech/helm-charts
  - https://github.com/haproxytech/helm-charts/blob/main/kubernetes-ingress/README.md
