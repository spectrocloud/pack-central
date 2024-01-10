# ngrok

The ngrok [Ingress Controller for Kubernetes](https://github.com/ngrok/kubernetes-ingress-controller) adds public and secure ingress traffic to Kubernetes applications. This open-source [Ingress Controller](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers) works with Palette to provide ingress to your applications, APIs, or other resources while also offloading network ingress and middleware execution to ngrok's platform.


## Prerequisites

- An active [ngrok account](https://ngrok.com/signup).
  - An ngrok authentication token. You can find your token in the dashboard. Visit the [Your Authtoken](https://dashboard.ngrok.com/get-started/your-authtoken) section to review your access token.
  - An ngrok API key. You can generate an API key from the ngrok dashboard. Visit the [API section](https://dashboard.ngrok.com/api) of the dashboard to review existing keys.
- A static subdomain. You can obtain a static subdomain by navigating to the [**Domains**](https://dashboard.ngrok.com/cloud-edge/domains) section of the ngrok dashboard and clicking on **Create Domain** or **New Domain**.


## Parameters

To deploy the ngrok Ingress Controller, you need to set, at minimum, the following parameters in the pack's YAML.

| Name | Description | Type | Default Value | Required |
| --- | --- | --- | --- | --- |
| `kubernetes-ingress-controller.credentials.apiKey` | Your ngrok API key for this application and domain. | String  | - | Yes |
| `kubernetes-ingress-controller.credentials.authtoken` | The authentication token for your active ngrok account. | String  | - | Yes |
| `kubernetes-ingress-controller.rules.host`    | A static subdomain hosted by ngrok and associated with your account. | String  | - | Yes |


Review the [common overrides](https://github.com/ngrok/kubernetes-ingress-controller/blob/main/docs/deployment-guide/common-helm-k8s-overrides.md) document for more details on parameters. Refer to the [user guide](https://github.com/ngrok/kubernetes-ingress-controller/tree/main/docs/user-guide) for advanced configurations.

> [!CAUTION]
>If you have a free ngrok account, you can only have one ngrok agent >active at a time. This means that you will need to set the number of >replicas to `1` to ensure that your ngrok agent operates properly.
>```yaml
>charts:
>  kubernetes-ingress-controller:
>    replicaCount: 1
>```

## Upgrade

This version of the pack changes the ownership model for https edge and tunnel Custom Resources (CRs). Issue the [`migrate-edges.sh`](https://github.com/ngrok/kubernetes-ingress-controller/blob/main/scripts/migrate-edges.sh) and [`migrate-tunnels.sh`](https://github.com/ngrok/kubernetes-ingress-controller/blob/main/scripts/migrate-tunnels.sh) scripts before using the new version to ease the transition to the new ownership.


## Usage

To use the ngrok Ingress Controller pack, first create a new [add-on cluster profile](https://docs.spectrocloud.com/profiles/cluster-profiles/create-cluster-profiles/create-addon-profile/), search for the **ngrok** Ingress Controller pack, and overwrite the default pack configuration with your API key and authentication token like the following example YAML content:

```yaml
charts:  
  kubernetes-ingress-controller:
    ...
    credentials:
      apiKey: API_KEY
      authtoken: AUTHTOKEN
```

Next, you must create an ingress service definition for your application, which requires a new manifest layer. Click on the **Add Manifest** button to create a new manifest layer.

The following YAML content demonstrates an example ingress service where the ngrok Ingress Controller creates a new edge to route traffic on your ngrok subdomain `example.com` to an existing `example-app` deployed on your Kubernetes cluster in Palette.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
  namespace: ngrok-ingress-controller
spec:
  ingressClassName: ngrok
  rules:
    - host: example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: example-app
                port:
                  number: 80
```

Once you have defined the ngrok Ingress Controller pack, you can add it to an existing cluster profile, as an add-on profile, or as a new add-on layer to a deployed cluster.


## References

- [Ingress Controller for Kubernetes on GitHub](https://github.com/ngrok/kubernetes-ingress-controller)
- [ngrok documentation](https://ngrok.com/docs/)
- [Get started with the ngrok Ingress Controller for Kubernetes](https://ngrok.com/docs/using-ngrok-with/k8s/)
- [ngrok Ingress Controller Helm Documentation](https://github.com/ngrok/kubernetes-ingress-controller/tree/main/docs)