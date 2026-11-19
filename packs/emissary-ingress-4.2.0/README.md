# Emissary Ingress

## Overview

Emissary Ingress is a CNCF-hosted API Gateway built on Envoy Proxy that provides ingress routing, load balancing, TLS termination, traffic management, and observability for Kubernetes applications.

This pack packages the official upstream Helm charts required to deploy Emissary Ingress on Kubernetes through Palette. It includes the Emissary Ingress chart together with the required Custom Resource Definitions (CRDs), allowing the application to be deployed as a single addon.

## Prerequisites

Before deploying this pack, ensure that:

* A supported Kubernetes cluster is available.
* The Kubernetes version satisfies the requirements of the bundled Helm chart.
* A cloud provider or networking solution is available if using a `LoadBalancer` Service.

## Pack Contents

This pack includes:

* Emissary Ingress Helm chart
* Emissary CRDs Helm chart
* Required container images
* Default Palette configuration

## Configuration

The pack exposes the upstream Helm chart configuration through the `values.yaml` file while adding the metadata required by Palette.

Common configuration options include:

* Replica count
* Service type
* Resource requests and limits
* Horizontal Pod Autoscaler
* IngressClass configuration
* Node scheduling
* Security settings
* Environment variables
* TLS and listener configuration

Refer to the `values.yaml` file for the complete list of supported configuration options.

## Deployment

After importing this pack into a Palette registry, it can be attached to a Cluster Profile or directly to a cluster as an addon.

By default, the pack installs Emissary Ingress into the `emissary-system` namespace.

## Usage

After deployment, Emissary Ingress watches Kubernetes resources and can be configured using its Custom Resource Definitions (CRDs), including resources such as `Host`, `Listener`, `Mapping`, `Module`, and `TLSContext`.

A typical workflow is:

1. Deploy your application and Kubernetes Service.
2. Create the appropriate Emissary custom resources to define routing behavior.
3. Verify that the Emissary Service is reachable through its external endpoint.
4. Access your application using the configured host or route.

Refer to the official Quick Start guide for complete examples and configuration details.

## Documentation

* Official Documentation: https://emissary-ingress.dev/docs/
* Quick Start Guide: https://emissary-ingress.dev/docs/latest/quick-start/
* GitHub Repository: https://github.com/emissary-ingress/emissary

## Support

For issues related to Emissary Ingress functionality, refer to the upstream project documentation or GitHub repository.

For Palette-specific packaging or deployment guidance, refer to the Spectro Cloud documentation.
