# KAI Scheduler
KAI Scheduler is a robust, efficient, and scalable [Kubernetes scheduler](https://kubernetes.io/docs/concepts/scheduling-eviction/kube-scheduler/) that optimizes GPU resource allocation for AI and machine learning workloads.

Designed to manage large-scale GPU clusters, including thousands of nodes, and high-throughput of workloads, makes the KAI Scheduler ideal for extensive and demanding environments.
KAI Scheduler allows administrators of Kubernetes clusters to dynamically allocate GPU resources to workloads. 

KAI Scheduler supports the entire AI lifecycle, from small, interactive jobs that require minimal resources to large training and inference, all within the same cluster. 
It ensures optimal resource allocation while maintaining resource fairness between the different consumers.
It can run alongside other schedulers installed on the cluster.

## Key Features
* **Batch Scheduling**: Ensure all pods in a group are scheduled simultaneously or not at all.
* **Bin Packing & Spread Scheduling**: Optimize node usage either by minimizing fragmentation (bin-packing) or increasing resiliency and load balancing (spread scheduling).
* **Workload Priority**: Prioritize workloads effectively within queues.
* **Hierarchical Queues**: Manage workloads with two-level queue hierarchies for flexible organizational control.
* **Resource distribution**: Customize quotas, over-quota weights, limits, and priorities per queue.
* **Fairness Policies**: Ensure equitable resource distribution using Dominant Resource Fairness (DRF) and resource reclamation across queues.
* **Workload Consolidation**: Reallocate running workloads intelligently to reduce fragmentation and increase cluster utilization.
* **Elastic Workloads**: Dynamically scale workloads within defined minimum and maximum pod counts.
* **Dynamic Resource Allocation (DRA)**: Support vendor-specific hardware resources through Kubernetes ResourceClaims (e.g., GPUs from NVIDIA or AMD).
* **GPU Sharing**: Allow multiple workloads to efficiently share single or multiple GPUs, maximizing resource utilization.
* **Cloud & On-premise Support**: Fully compatible with dynamic cloud infrastructures (including auto-scalers like Karpenter) as well as static on-premise deployments.

## Prerequisites
Before installing KAI Scheduler, ensure you have:

- [NVIDIA GPU-Operator](https://docs.spectrocloud.com/integrations/packs/?pack=nvidia-gpu-operator-ai) pack installed in order to schedule workloads that request GPU resources

## Installation
KAI Scheduler will be installed in `kai-scheduler` namespace.
> ⚠️ When submitting workloads, make sure to use a dedicated namespace. Do not use the `kai-scheduler` namespace for workload submission.


### Parameters

| Key | Description | Default |
|-----|-------------|---------|
| `global.registry` | OCI registry hosting KAI images | `ghcr.io/nvidia/kai-scheduler` |
| `global.tag` | Global image tag override | `""` |
| `global.imagePullPolicy` | Pull policy for all images | `IfNotPresent` |
| `global.securityContext` | Pod/container securityContext defaults | `{}` |
| `global.imagePullSecrets` | Image pull secrets for private registries | `[]` |
| `global.leaderElection` | Enable leader election for components | `false` |
| `global.gpuSharing` | Enable GPU sharing | `false` |
| `global.clusterAutoscaling` | Enable autoscaling coordination support | `false` |
| `global.resourceReservation.namespace` | Namespace for reservation pods | `kai-resource-reservation` |
| `global.resourceReservation.appLabel` | App label for resource reservation | `kai-resource-reservation` |
| `operator.qps` | Kubernetes client QPS | `50` |
| `operator.burst` | Kubernetes client burst | `300` |
| `podgrouper.queueLabelKey` | Pod label key for queue assignment | `kai.scheduler/queue` |
| `scheduler.placementStrategy` | Scheduling strategy (`binpack` or `spread`) | `binpack` |
| `admission.cdi` | Use Container Device Interface | `false` |
| `admission.gpuPodRuntimeClassName` | Runtime class for GPU pods | `nvidia` |
| `defaultQueue.createDefaultQueue` | Whether to create the default queue on install | `true` |
| `defaultQueue.parentName` | Parent queue name | `default-parent-queue` |
| `defaultQueue.childName` | Child queue name | `default-queue` |


## Support & Breaking changes
Refer to the [Breaking Changes](https://github.com/NVIDIA/KAI-Scheduler/blob/main/docs/migrationguides/README.md) doc for more info

## Quick Start
To start scheduling workloads with KAI Scheduler, please continue to [Quick Start example](docs/quickstart/README.md)