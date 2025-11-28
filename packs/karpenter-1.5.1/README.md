# Karpenter

*NOTE* - Karpenter ships with a few Custom Resource Definitions (CRDs). These CRDs are updated as part of this pack release.


Karpenter is an open-source node lifecycle management project built for Kubernetes. Adding Karpenter to a Kubernetes cluster can dramatically improve the efficiency and cost of active workloads in the cluster. Karpenter automatically launches the right compute resources to handle your cluster's applications. Karpenter works by:

* Watching for pods that the Kubernetes scheduler has marked as unschedulable
* Evaluating scheduling constraints (resource requests, nodeselectors, affinities, tolerations, and topology spread constraints) requested by the pods
* Provisioning nodes that meet the requirements of the pods
    Disrupting the nodes when the nodes are no longer needed

## Prerequisites

* Minimum EKS Version is 1.28
* Pack support is for EKS only today.
* IRSA Roles must be created and used.  Review the following section for additional guidance.
* AWS Account Number - This is a required value in the pack for annotations of the service account

### Pack Values

Provide your AWS Account Number in the `awsAccountNumber` value of the pack.

### AWS IAM Roles for Service Accounts (IRSA)

Karpenter requires a policy to be created that can be used by the Service Account for it to function properly.  Detailed policy elements can be found [here](https://karpenter.sh/docs/getting-started/migrating-from-cas/#create-iam-roles).

The policy should then be added to the EKS layer in Palette so that it can be used by the Service Acount.

To do this, add the `irsaRoles` and `iamAuthenticatorConfig` sections to the Kubernetes layer (make sure to replace "AWS_ACCOUNT_NUMBER" with your AWS Account Number).  The Service Account will be created by the Karpenter Pack.

```yaml
managedControlPlane:
    irsaRoles:
    - name: "{{.spectro.system.cluster.name}}-karpenterControllerRole"
        policies:
        - arn:aws:iam::<AWS_ACCOUNT_NUMBER>:policy/karpenterControllerPolicy
        serviceAccount:
        name: karpenter
        namespace: karpenter
iamAuthenticatorConfig:
    mapRoles:
        - groups:
        - system:bootstrappers
        - system:nodes
        rolearn: "arn:aws:iam::<AWS_ACCOUNT_NUMBER>:role/{{.spectro.system.cluster.name}}-nodeRole"
        username: system:node:{{EC2PrivateDNSName}}
```

### Node Role

Palette dynamically creates a role for the worker nodes that has the appropriale policies attached.  We need to make the name predictable so that Karpenter can attach the role to the worker nodes that it spawns.  To do this, we add a `roleName` to the EKS layer and provide the name we want like this.

```yaml
managedMachinePool:
    roleName: "{{.spectro.system.cluster.name}}-nodeRole"
```

### Tags

Karpenter uses tags in AWS to discover the resources needed to autoscale.  Palette creates several tags on resources it creates, but in most uses cases Palette is not managing the Security Groups and Subnets.  Because of this, tags should be added to those resources for Karpenter to auto discover.  The tag is then referenced in the `ec2NodeClass` Custom Resource that you create after Karpenter is installed.

## Usage

Make sure to checkout the [Karpenter Best Practices](https://aws.github.io/aws-eks-best-practices/karpenter/) when using Karpenter.

### EXAMPLE - Node Pool

```yaml
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
name: default
spec:
template:
    spec:
    requirements:
        - key: kubernetes.io/arch
        operator: In
        values: ["amd64"]
        - key: kubernetes.io/os
        operator: In
        values: ["linux"]
        - key: karpenter.sh/capacity-type
        operator: In
        values: ["spot"]
        - key: karpenter.k8s.aws/instance-category
        operator: In
        values: ["c", "m", "r"]
        - key: karpenter.k8s.aws/instance-generation
        operator: Gt
        values: ["2"]
    nodeClassRef:
        group: karpenter.k8s.aws
        kind: EC2NodeClass
        name: default
    expireAfter: 720h # 30 * 24h = 720h
limits:
    cpu: 1000
disruption:
    consolidationPolicy: WhenEmptyOrUnderutilized
    consolidateAfter: 1m
```

### EXAMPLE - EC2 Node Class Resource

```yaml
apiVersion: karpenter.k8s.aws/v1
kind: EC2NodeClass
metadata:
name: default
spec:
amiFamily: AL2 # Amazon Linux 2
role: "KarpenterNodeRole-${CLUSTER_NAME}" # replace with your cluster name
subnetSelectorTerms:
    - tags:
        karpenter.sh/discovery: "${CLUSTER_NAME}" # replace with your cluster name
securityGroupSelectorTerms:
    - tags:
        karpenter.sh/discovery: "${CLUSTER_NAME}" # replace with your cluster name
  amiSelectorTerms:
    - alias: al2@v20241011 # example Alias for looking up images.
```

For more information on AMI selectors and how to find other AMIs, reference the [Karpenter Docs](https://karpenter.sh/docs/concepts/nodeclasses/#specamiselectorterms)

## References

* [Karpenter Best Practices](https://aws.github.io/aws-eks-best-practices/karpenter/)

* [Karpenter Troubleshooting](https://karpenter.sh/docs/troubleshooting/)
