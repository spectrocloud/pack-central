# Istio

Istio is an open source service mesh that layers transparently onto existing distributed applications.

We install following components of Istio:

**Gateway plugin** has been added and is disabled by default. It can be enabled from presets.

**Kiali dashboard** plugin is also added and disabled by default. It can be enabled from presets.

Kiali requires Prometheus to generate the topology graph, show metrics, calculate health and for several other features. If Prometheus is missing or Kiali can’t reach it, Kiali won’t work properly.

Please configure the following property to allow kiali to access the prometheus server:

```kiali-server.spec.external_services.prometheus.url```

Default value is - `http://prometheus.istio-system:9090/`

### Note:
**You don’t need to expose Prometheus outside the cluster. It is enough to provide the Kubernetes internal service URL. 

**To upgrade or downgrade pack, please uninstall the pack and remove the crds using following command and then proceed installing the new pack.

```kubectl get crd -oname | grep --color=never 'istio.io' | xargs kubectl delete```

Kiali dashboard can be accessed using the following command:

```kubectl port-forward svc/kiali 20001:20001 -n istio-system```

## Kubernetes compatibility
Kubernetes 1.23 and higher are supported.

## Cloud types
All cloud types are supported

## References
[Istio](https://istio.io/latest/docs/setup/getting-started/)

[Kiali](https://v1-65.kiali.io/docs/installation/quick-start/)

[Github Istio](https://github.com/istio/istio)

[Github Kiali](https://github.com/kiali/kiali)
