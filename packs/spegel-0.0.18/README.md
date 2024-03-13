# Description
Spegel, mirror in Swedish, is a stateless cluster local OCI registry mirror.
Spegel is for you if you are looking to do any of the following:
* Locally cache images from external registries with no explicit configuration.
* Avoid cluster failure during external registry downtime.
* I mprove image pull speed and pod startup time by pulling images from the local cache first.
* Avoid rate-limiting when pulling images from external registries (e.g. Docker Hub).
* Decrease egressing traffic outside of the clusters network.
* Increase image pull efficiency in edge node deployments.

# Kubernetes versions supported:
Above 1.21

# Contraints:
Currently, Spegel only works with Containerd, in the future other container runtime interfaces may be supported. Spegel relies on [Containerd registry mirroring](https://github.com/containerd/containerd/blob/main/docs/hosts.md#cri) to route requests to the correct destination. This requires Containerd to be properly configured, if it is not Spegel will exit. First of all the registry config path needs to be set, this is not done by default in Containerd. Second of all discarding unpacked layers cannot be enabled. Some Kubernetes flavors come with this setting out of the box, while others do not. Spegel is not able to write this configuration for you as it requires a restart of Containerd to take effect.

```
version = 2

imports = ["/etc/containerd/conf.d/*.toml"]

[plugins]
  [plugins."io.containerd.grpc.v1.cri"]
    sandbox_image = "registry.k8s.io/pause:3.9"
  [plugins."io.containerd.grpc.v1.cri".containerd]
   discard_unpacked_layers = false
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
    runtime_type = "io.containerd.runc.v2"
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
    SystemdCgroup = true
  [plugins."io.containerd.grpc.v1.cri".registry]
    config_path = "/etc/containerd/certs.d"
```

# Cloud types supported:
Everything except GKE

# References:
  - https://github.com/XenitAB/spegel
