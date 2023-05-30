# The ngrok Kubernetes Ingress Controller

An Add-on Pack for Spectro Cloud to use the ngrok Kubernetes Ingress Controller.

# Versions Supported

**0.9.0**

## Prerequisites

To get started with the ngrok Ingress Controller for Kubernetes make sure you meet the following requirements.

1. Access to the [ngrok Dashboard](https://dashboard.ngrok.com/get-started/setup), logging in with your Pro account.
1. A ngrok authentication token. Use [this link](https://dashboard.ngrok.com/get-started/your-authtoken) to access your authentication token. Copy the Authtoken to a text editor.
1. A ngrok API key. Use [this link](https://dashboard.ngrok.com/api) and follow the instructions to create a new API key. Copy the API key to a text editor.

Refer to the [ngrok documentation](https://ngrok.com/docs/using-ngrok-with/k8s/#step-1-get-your-ngrok-authtoken-and-api-key) for more information.

## Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| fullnameOverride | String to fully override the resource naming | "ngrok-ingress-controller" |
| replicaCount | Number of replicas to deploy | 2 |
| credentials.apiKey | A ngrok apiKey secret can be set in the pack configuration | "" |
| credentials.authtoken | A ngrok authtoken secret can be set in the pack configuration | "" |

## Usage

For production use the cluster must be setup with a secret named `ngrok-ingress-controller-credentials` with the following keys:
* AUTHTOKEN
* API\_KEY

Example of creating the secret directly in the cluster, if not specified in the pack configuration as described above: 

```bash
kubectl --namespace ngrok-ingress-controller create secret generic ngrok-ingress-controller-credentials \
  --from-literal=API_KEY=<api_key> \
  --from-literal=AUTHTOKEN=<authtoken>
```

Once the secret is created, the ingress controller can be used as part of an application's manifest.

Refer to the [ngrok documentation](https://ngrok.com/docs/using-ngrok-with/k8s/#step-2-setup-your-kubernetes-cluster-and-install-the-ngrok-ingress-controller) for more information.

# References

[Documentation](https://ngrok.com/docs/using-ngrok-with/k8s/) on the ingress controller.

[Github](https://github.com/ngrok/kubernetes-ingress-controller) repository.
