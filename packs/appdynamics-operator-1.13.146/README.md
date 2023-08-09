## Appdynamics Cloud Helm Charts
This repository maintains single helm charts in "helm/charts" directory for installing Appdynamics Cloud.

To install Appdynamics Cloud Full Stack Observability using Helm Charts:
## Prerequisites
Kubernetes 1.19+ is required for OpenTelemetry Operator installation
Helm 3.0+

## TLS Certificate Requirement
In Kubernetes, in order for the API server to communicate with the webhook component, the webhook requires a TLS certificate that the API server is configured to trust. There are three ways for you to generate the required TLS certificate.

The easiest and default method is to install the cert-manager and set admissionWebhooks.certManager.enabled to true. In this way, cert-manager will generate a self-signed certificate. See cert-manager installation for more details.
You can also provide your own Issuer by configuring the admissionWebhooks.certManager.issuerRef value. You will need to specify the kind (Issuer or ClusterIssuer) and the name. Note that this method also requires the installation of cert-manager.
The last way is to manually modify the secret where the TLS certificate is stored. Make sure you set admissionWebhooks.certManager.enabled to false first.

Create the namespace for the OpenTelemetry Operator and the secret

$ kubectl create namespace opentelemetry-operator-system 

Config the TLS certificate using

$ kubectl create secret tls opentelemetry-operator-controller-manager-service-cert \
--cert=path/to/cert/file --key=path/to/key/file -n opentelemetry-operator-system 

You can also do this by applying the secret configuration.

"$ kubectl apply -f - <<EOF
  apiVersion: v1
  kind: Secret
  metadata:
  name: opentelemetry-operator-controller-manager-service-cert
  namespace: opentelemetry-operator-system
  type: kubernetes.io/tls
  data:
  tls.crt: |
# your signed cert
tls.key: |
# your private key
EOF"


## Installation Steps

Deploy cert-manager required for installing Otel-Collector Operator:
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.8.0/cert-manager.yaml

Now you can proceed with the installation of the Operator from the profile.