## ngrok Kubernetes Ingress Controller

An Add-on Pack for Spectro Cloud to use the ngrok Kubernetes Ingress Controller.

# Versions Supported

**0.7.0**

## Prerequisites

To get started with the ngrok Ingress Controller for Kubernetes:

1. Access the [ngrok Dashboard](https://dashboard.ngrok.com/get-started/setup) with your Pro account.
1. Click [Your Authtoken](https://dashboard.ngrok.com/get-started/your-authtoken). Copy the Authtoken to a text editor.
1. Click [API](https://dashboard.ngrok.com/api) and follow the instructions to create a new API key. Copy the API key to a text editor.

See the [ngrok documentation](https://ngrok.com/docs/using-ngrok-with/k8s/#step-1-get-your-ngrok-authtoken-and-api-key) for more information.

## Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| fullnameOverride | String to fully override the resource naming | "ngrok-ingress-controller" |
| replicaCount | Number of replicas to deploy | 2 |

## Usage

The cluster must be setup with a secret named `ngrok-ingress-controller-credentials` with the following keys:
* AUTHTOKEN
* API\_KEY

Example: 

```bash
kubectl --namespace ngrok-ingress-controller create secret generic ngrok-ingress-controller-credentials \
  --from-literal=API_KEY=<api_key> \
  --from-literal=AUTHTOKEN=<authtoken>
```

Then the ingress controller can be used as part of an application's manifest.

See the [ngrok documentation](https://ngrok.com/docs/using-ngrok-with/k8s/#step-2-setup-your-kubernetes-cluster-and-install-the-ngrok-ingress-controller) for more information.

# References

[Documentation](https://ngrok.com/docs/using-ngrok-with/k8s/) on the ingress controller.

[Github](https://github.com/ngrok/kubernetes-ingress-controller) repository.
