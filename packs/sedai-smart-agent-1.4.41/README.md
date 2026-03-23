# Sedai

Sedai is the world's first self-driving cloud platform that autonomously optimizes Kubernetes workloads to reduce costs, boost performance, and improve availability — all without breaking production.

Unlike tools that only recommend changes, Sedai makes safe, continuous optimizations based on real workload behavior. Its patented ML engine learns how each service responds to traffic, validates every action against live signals, and rolls back automatically if performance drifts. Customers using Sedai typically achieve 30–50% cloud cost savings alongside measurable improvements in performance and reliability.

Sedai integrates seamlessly with your existing Kubernetes environment through standard APIs, requiring no deployment changes. The Spectro Cloud integration makes it easy to bring autonomous Kubernetes optimization into your cluster profiles with minimal setup.

## Key Features

- **Autonomous Workload Rightsizing:** Continuously tunes pod CPU and memory based on real workload behavior. No static requests, limits, or thresholds.

- **AI-Tuned Autoscalers:** Tunes HPA, VPA, KEDA, and Cluster Autoscaler policies from real behavior and SLOs — not static thresholds or manual guesswork.

- **Cluster-Level Optimization:** Evaluates your cluster beyond the pod or node level to deliver actual node reductions and real infrastructure savings.

- **Waste Detection at Every Layer:** Identifies idle and over-provisioned capacity across pods, nodes, and clusters, and removes it autonomously.

## Key Benefits

- **Safe Optimization in Production:** Every change is applied incrementally and protected by continuous validation and guardrails. Sedai rolls back automatically on any performance drift, so production stays stable.

- **Cost & Capacity Intelligence:** See exactly where Kubernetes spend lives and how optimizations reduce cost over time. Base capacity and purchasing decisions on real workload behavior, not fixed estimates.

- **Flexible Autonomy Modes:** Choose how much Sedai does for you — Datapilot (recommendations only), Copilot (review and approve), or Autopilot (fully autonomous, validated optimizations).

- **No Monitoring Changes Required:** Sedai works with the metrics and signals already exposed by your Kubernetes cluster and services, and requires no changes to your existing monitoring setup.

# Prerequisites

- A running Kubernetes cluster (EKS, AKS, GKE, OpenShift, Rancher, VMware Tanzu, IBM Cloud Kubernetes Service, Oracle OKE, Platform9, DigitalOcean, Alibaba CS, or similar).
- A Sedai account. You can [book a demo](https://sedai.io) to get started.

# Parameters

The Sedai pack supports all parameters exposed by the Sedai Helm Chart. Refer to the [Sedai documentation](https://docs.sedai.io) for the full list of configuration options.

# Usage

The Sedai pack works out-of-the-box and can be optionally configured via the pack's `values.yaml`. Add the Sedai pack to a cluster profile to get started. You can create a new cluster profile with Sedai as an add-on pack or [update an existing cluster profile](/cluster-profiles/task-update-profile) by adding the Sedai pack.

Once installed, Sedai connects to your cluster through the Sedai Smart Agent using standard Kubernetes APIs. Sedai typically needs 2–4 weeks to learn your workloads and traffic patterns before autonomous optimizations reach full effectiveness. You can monitor recommendations and savings directly from the Sedai dashboard.

Learn more about getting started at [Sedai Documentation](https://docs.sedai.io).

# References

- [Sedai Platform Overview](https://sedai.io/platform/kubernetes)

- [Sedai Documentation](https://docs.sedai.io)

- [Contact Sedai](https://sedai.io/company/contact)