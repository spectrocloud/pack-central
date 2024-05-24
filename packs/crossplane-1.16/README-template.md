# Crossplane

Crossplane is an open source Kubernetes extension that transforms your Kubernetes cluster into a universal control plane.

Crossplane lets you manage anything, anywhere, all through standard Kubernetes APIs. Crossplane can even let you order a pizza directly from Kubernetes. If it has an API, Crossplane can connect to it.

With Crossplane, platform teams can create new abstractions and custom APIs with the full power of Kubernetes policies, namespaces, role based access controls and more. Crossplane brings all your non-Kubernetes resources under one roof.

Custom APIs, created by platform teams, allow security and compliance enforcement across resources or clouds, without exposing any complexity to the developers. A single API call can create multiple resources, in multiple clouds and use Kubernetes as the control plane for everything.

## Prerequisites

Kuberernetes >= 1.27.0
## Usage

Installing a provider creates new Kubernetes resources representing the Provider’s APIs. Installing a provider also creates a Provider pod that’s responsible for reconciling the Provider’s APIs into the Kubernetes cluster. Providers constantly watch the state of the desired managed resources and create any external resources that are missing.

Install a Provider with a Crossplane Provider object setting the spec.package value to the location of the provider package.

*For Example*
Install the [Palette Provider](https://marketplace.upbound.io/providers/crossplane-contrib/provider-palette/v0.19.2)

```yaml
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-palette
spec:
  package: xpkg.upbound.io/crossplane-contrib/provider-palette:v0.19.2
```
## References

Crossplane Provider Guide - https://docs.crossplane.io/latest/concepts/providers/
Crossplane Concepts - https://docs.crossplane.io/latest/concepts/