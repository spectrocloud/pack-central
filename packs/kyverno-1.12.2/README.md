# Kyverno

Kyverno (Greek for “govern”) is a policy engine designed specifically for Kubernetes. Some of its many features include:

    policies as Kubernetes resources (no new language to learn!)
    validate, mutate, generate, or cleanup (remove) any resource
    verify container images for software supply chain security
    inspect image metadata
    match resources using label selectors and wildcards
    validate and mutate using overlays (like Kustomize!)
    synchronize configurations across Namespaces
    block non-conformant resources using admission controls, or report policy violations
    self-service reports (no proprietary audit log!)
    self-service policy exceptions
    test policies and validate resources using the Kyverno CLI, in your CI/CD pipeline, before applying to your cluster
    manage policies as code using familiar tools like git and kustomize

Kyverno allows cluster administrators to manage environment specific configurations independently of workload configurations and enforce configuration best practices for their clusters. Kyverno can be used to scan existing workloads for best practices, or can be used to enforce best practices by blocking or mutating API requests.our applications, APIs, or other resources while also offloading network ingress and middleware execution to ngrok's platform.

## Prerequisites

- kubernetes version >= 1.26.0

## Usage
To use the Kyverno pack, first create a new [add-on cluster profile](https://docs.spectrocloud.com/profiles/cluster-profiles/create-cluster-profiles/create-addon-profile/), search for the **kyverno** Kyverno  pack:


A Kyverno policy is a collection of rules. Each rule consists of a [`match`](https://kyverno.io/docs/writing-policies/match-exclude/) declaration, an optional [`exclude`](https://kyverno.io/docs/writing-policies/match-exclude/) declaration, and one of a [`validate`](https://kyverno.io/docs/writing-policies/validate/), [`mutate`](https://kyverno.io/docs/writing-policies/mutate/), [`generate`](https://kyverno.io/docs/writing-policies/generate/), or [`verifyImages`](https://kyverno.io/docs/writing-policies/verify-images) declaration. Each rule can contain only a single `validate`, `mutate`, `generate`, or `verifyImages` child declaration.

<img src="https://kyverno.io/images/Kyverno-Policy-Structure.png" alt="Kyverno Policy" width="65%"/>
<br/>
<br/>

Policies can be defined as cluster-wide resources (using the kind `ClusterPolicy`) or namespaced resources (using the kind `Policy`). As expected, namespaced policies will only apply to resources within the namespace in which they are defined while cluster-wide policies are applied to matching resources across all namespaces. Otherwise, there is no difference between the two types.

Additional policy types include [Policy Exceptions](https://kyverno.io/docs/writing-policies/exceptions/) and [Cleanup Policies](https://kyverno.io/docs/writing-policies/cleanup/) which are separate resources and described further in the documentation.

Learn more about [Applying Policies](https://kyverno.io/docs/applying-policies/) and [Writing Policies](https://kyverno.io/docs/writing-policies/) in the upcoming chapters.


## References

- [Kyverno Docs](https://kyverno.io/docs/introduction/)
- [Kyverno](https://kyverno.io/)
- [Kyverno Github](https://github.com/kyverno/kyverno/)