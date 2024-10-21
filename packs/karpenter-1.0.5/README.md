# Karpenter

## Contraints

Minimum Kubernetes Version is 1.25
Pack support is for EKS only today.

## Prerequisites

### AWS IAM Roles for Service Accounts (IRSA)

Karpenter requires a policy to be created that can be used by by the Service Account for it to function properly.  Detailed policy elements can be found [here](https://karpenter.sh/docs/getting-started/migrating-from-cas/#create-iam-roles).

The policy should then be added to the EKS layer in Palette so that it can be used by the Service Acount.

To do this, add the `irsaRoles` and `iamAuthenticatorConfig` sections to the layer (make sure to replace "AWS_ACCOUNT_NUMBER" with your AWS Account Number).  The Service Account will be created by the Karpenter Pack.

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

### nodePool

Th

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

### ec2NodeClass Resource

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
    - id: "${ARM_AMI_ID}"
    - id: "${AMD_AMI_ID}"
#   - id: "${GPU_AMI_ID}" # <- GPU Optimized AMD AMI 
#   - name: "amazon-eks-node-${K8S_VERSION}-*" # <- automatically upgrade when a new AL2 EKS Optimized AMI is released. This is unsafe for production workloads. Validate AMIs in lower environments before deploying them to production.
```

## Parameters

## Usage

## References

- [Karpenter Best Practices](https://aws.github.io/aws-eks-best-practices/karpenter/)
