# Validator <!-- It must be the pack’s name -->


## Prerequisites

<!-- List the required software version or hardware the user is required to have installed and available in order to integrate the pack. -->
- Kubernetes 1.25+

## Parameters

<!-- If applicable, list and describe only the most commonly used parameters, especially if there are 10 or more that might apply. 

You can use a table to list parameters with a **Parameter** and a **Description** column. Additionally, include a **Type** column to specify the parameter's type and a **Default Value** column for the parameter's default values. Last, you can include a **Required** column to indicate that the user must provide a value for it.

| **Parameter** | **Description** | **Type** | **Default Value** | **Required** |
|---|---|---|---|---|
| Parameter 1   | Description for Parameter 1 | String | “always” | Yes |
| Parameter 2   | Description for Parameter 2 | Int | 10 | No |

-->

The following table lists the configurable parameters of the Validator chart and their default values.

| Parameter                | Description             | Default        |
| ------------------------ | ----------------------- | -------------- |
| `controllerManager.kubeRbacProxy.args` |  | `["--secure-listen-address=0.0.0.0:8443", "--upstream=http://127.0.0.1:8080/", "--logtostderr=true", "--v=0"]` |
| `controllerManager.kubeRbacProxy.containerSecurityContext.allowPrivilegeEscalation` |  | `false` |
| `controllerManager.kubeRbacProxy.containerSecurityContext.capabilities.drop` |  | `["ALL"]` |
| `controllerManager.kubeRbacProxy.image.repository` |  | `"gcr.io/kubebuilder/kube-rbac-proxy"` |
| `controllerManager.kubeRbacProxy.image.tag` |  | `"v0.15.0"` |
| `controllerManager.kubeRbacProxy.resources.limits.cpu` |  | `"500m"` |
| `controllerManager.kubeRbacProxy.resources.limits.memory` |  | `"128Mi"` |
| `controllerManager.kubeRbacProxy.resources.requests.cpu` |  | `"5m"` |
| `controllerManager.kubeRbacProxy.resources.requests.memory` |  | `"64Mi"` |
| `controllerManager.manager.args` |  | `["--health-probe-bind-address=:8081", "--leader-elect"]` |
| `controllerManager.manager.containerSecurityContext.allowPrivilegeEscalation` |  | `false` |
| `controllerManager.manager.containerSecurityContext.capabilities.drop` |  | `["ALL"]` |
| `controllerManager.manager.image.repository` |  | `"quay.io/validator-labs/validator"` |
| `controllerManager.manager.image.tag` | x-release-please-version | `"v0.0.40"` |
| `controllerManager.manager.resources.limits.cpu` |  | `"500m"` |
| `controllerManager.manager.resources.limits.memory` |  | `"512Mi"` |
| `controllerManager.manager.resources.requests.cpu` |  | `"10m"` |
| `controllerManager.manager.resources.requests.memory` |  | `"64Mi"` |
| `controllerManager.manager.sinkWebhookTimeout` |  | `"30s"` |
| `controllerManager.replicas` |  | `1` |
| `controllerManager.serviceAccount.annotations` |  | `{}` |
| `kubernetesClusterDomain` |  | `"cluster.local"` |
| `metricsService.ports` |  | `[{"name": "https", "port": 8443, "protocol": "TCP", "targetPort": "https"}]` |
| `metricsService.type` |  | `"ClusterIP"` |
| `env` |  | `[]` |
| `proxy.enabled` |  | `false` |
| `proxy.image` |  | `"quay.io/validator-labs/validator-certs-init:latest"` |
| `proxy.secretName` |  | `"proxy-cert"` |
| `proxy.createSecret` |  | `false` |
| `proxy.caCert` |  | `"-----BEGIN CERTIFICATE-----\n<your certificate content here>\n-----END CERTIFICATE-----\n"` |
| `sink` |  | `{}` |
| `cleanup.image` |  | `"gcr.io/spectro-images-public/release/spectro-cleanup:1.2.0"` |
| `cleanup.grpcServerEnabled` |  | `true` |
| `cleanup.hostname` |  | `"validator-cleanup-service"` |
| `cleanup.port` |  | `3006` |
| `plugins` | Configure various plugin validations here | `[{"Chart": {"name": "validator-plugin-aws", "repository": "https://validator-labs.github.io/validator-plugin-aws", "version": "v0.0.26"}, "values": "controllerManager:\n  kubeRbacProxy:\n    args:\n    - --secure-listen-address=0.0.0.0:8443\n    - --upstream=http://127.0.0.1:8080/\n    - --logtostderr=true\n    - --v=0\n    containerSecurityContext:\n      allowPrivilegeEscalation: false\n      capabilities:\n        drop:\n        - ALL\n    image:\n      repository: gcr.io/kubebuilder/kube-rbac-proxy\n      tag: v0.15.0\n    resources:\n      limits:\n        cpu: 500m\n        memory: 128Mi\n      requests:\n        cpu: 5m\n        memory: 64Mi\n  manager:\n    args:\n    - --health-probe-bind-address=:8081\n    - --leader-elect\n    containerSecurityContext:\n      allowPrivilegeEscalation: false\n      capabilities:\n        drop:\n        - ALL\n    image:\n      repository: quay.io/validator-labs/validator-plugin-aws\n      tag: v0.0.26\n    resources:\n      limits:\n        cpu: 500m\n        memory: 128Mi\n      requests:\n        cpu: 10m\n        memory: 64Mi\n  replicas: 1\n  serviceAccount:\n    annotations: {}\nkubernetesClusterDomain: cluster.local\nmetricsService:\n  ports:\n  - name: https\n    port: 8443\n    protocol: TCP\n    targetPort: https\n  type: ClusterIP\nauth:\n  # Option 1: Leave secret undefined for implicit auth (node instance IAM role, IMDSv2, etc.)\n  # Option 2: Create a secret via pluginSecrets (see below). Note: secretName and pluginSecrets.aws.secretName must match.\n  # Option 3: Specify the name of a preexisting secret in your target cluster and leave pluginSecrets.aws undefined.\n  #\n  secret: {}  # Delete these curly braces if you're specifying secretName!\n    # secretName: aws-creds\n\n  # Override the service account used by AWS validator (optional, could be used for IMDSv2 on EKS)\n  # WARNING: the chosen service account must include all RBAC privileges found in the AWS plugin template:\n  #          https://github.com/validator-labs/validator-plugin-aws/blob/main/chart/validator-plugin-aws/templates/manager-rbac.yaml\n  serviceAccountName: \"\""}, {"chart": {"name": "validator-plugin-azure", "repository": "https://validator-labs.github.io/validator-plugin-azure", "version": "v0.0.11"}, "values": "controllerManager:\n  kubeRbacProxy:\n    args:\n    - --secure-listen-address=0.0.0.0:8443\n    - --upstream=http://127.0.0.1:8080/\n    - --logtostderr=true\n    - --v=0\n    containerSecurityContext:\n      allowPrivilegeEscalation: false\n      capabilities:\n        drop:\n        - ALL\n    image:\n      repository: gcr.io/kubebuilder/kube-rbac-proxy\n      tag: v0.15.0\n    resources:\n      limits:\n        cpu: 500m\n        memory: 128Mi\n      requests:\n        cpu: 5m\n        memory: 64Mi\n  manager:\n    args:\n    - --health-probe-bind-address=:8081\n    - --leader-elect\n    containerSecurityContext:\n      allowPrivilegeEscalation: false\n      capabilities:\n        drop:\n        - ALL\n    image:\n      repository: quay.io/validator-labs/validator-plugin-azure\n      tag: v0.0.11\n    resources:\n      limits:\n        cpu: 500m\n        memory: 128Mi\n      requests:\n        cpu: 10m\n        memory: 64Mi\n    # Optionally specify a volumeMount to mount a volume containing a private key\n    # to leverage Azure Service principal with certificate authentication.\n    volumeMounts: []\n  replicas: 1\n  serviceAccount:\n    annotations: {}\n  # Optionally specify a volume containing a private key to leverage Azure Service\n  # principal with certificate authentication.\n  volumes: []\nkubernetesClusterDomain: cluster.local\nmetricsService:\n  ports:\n  - name: https\n    port: 8443\n    protocol: TCP\n    targetPort: https\n  type: ClusterIP\nauth:\n  # Option 1: Leave secret undefined for WorkloadIdentityCredential authentication.\n  # Option 2: Create a secret via pluginSecrets (see below). Note: secretName and pluginSecrets.azure.secretName must match.\n  # Option 3: Specify the name of a preexisting secret in your target cluster and leave pluginSecrets.azure undefined.\n  #\n  secret: {}  # Delete these curly braces if you're specifying secretName!\n    # secretName: azure-creds\n\n  # Override the service account used by Azure validator (optional, could be used for WorkloadIdentityCredentials on AKS)\n  # WARNING: the chosen service account must include all RBAC privileges found in the Azure plugin template:\n  #          https://github.com/validator-labs/validator-plugin-aws/blob/main/chart/validator-plugin-azure/templates/manager-rbac.yaml\n  serviceAccountName: \"\""}, {"chart": {"name": "validator-plugin-vsphere", "repository": "https://validator-labs.github.io/validator-plugin-vsphere", "version": "v0.0.20"}, "values": "controllerManager:\n  kubeRbacProxy:\n    args:\n    - --secure-listen-address=0.0.0.0:8443\n    - --upstream=http://127.0.0.1:8080/\n    - --logtostderr=true\n    - --v=0\n    containerSecurityContext:\n      allowPrivilegeEscalation: false\n      capabilities:\n        drop:\n        - ALL\n    image:\n      repository: gcr.io/kubebuilder/kube-rbac-proxy\n      tag: v0.15.0\n    resources:\n      limits:\n        cpu: 500m\n        memory: 128Mi\n      requests:\n        cpu: 5m\n        memory: 64Mi\n  manager:\n    args:\n    - --health-probe-bind-address=:8081\n    - --leader-elect\n    containerSecurityContext:\n      allowPrivilegeEscalation: false\n      capabilities:\n        drop:\n        - ALL\n    image:\n      repository: quay.io/validator-labs/validator-plugin-vsphere\n      tag: v0.0.20\n    resources:\n      limits:\n        cpu: 500m\n        memory: 128Mi\n      requests:\n        cpu: 10m\n        memory: 64Mi\n  replicas: 1\n  serviceAccount:\n    annotations: {}\nkubernetesClusterDomain: cluster.local\nmetricsService:\n  ports:\n  - name: https\n    port: 8443\n    protocol: TCP\n    targetPort: https\n  type: ClusterIP\nauth:\n  # Option 1: Create a secret via pluginSecrets (see below). Note: secretName and pluginSecrets.vSphere.secretName must match.\n  # Option 2: Specify the name of a preexisting secret in your target cluster and leave pluginSecrets.vSphere undefined.\n  secretName: vsphere-creds"}, {"chart": {"name": "validator-plugin-network", "repository": "https://validator-labs.github.io/validator-plugin-network", "version": "v0.0.16"}, "values": "controllerManager:\n  kubeRbacProxy:\n    args:\n    - --secure-listen-address=0.0.0.0:8443\n    - --upstream=http://127.0.0.1:8080/\n    - --logtostderr=true\n    - --v=0\n    containerSecurityContext:\n      allowPrivilegeEscalation: false\n      capabilities:\n        drop:\n        - ALL\n    image:\n      repository: gcr.io/kubebuilder/kube-rbac-proxy\n      tag: v0.15.0\n    resources:\n      limits:\n        cpu: 500m\n        memory: 128Mi\n      requests:\n        cpu: 5m\n        memory: 64Mi\n  manager:\n    args:\n    - --health-probe-bind-address=:8081\n    - --leader-elect\n    containerSecurityContext:\n      allowPrivilegeEscalation: true\n      capabilities:\n        add:\n        - NET_RAW\n        drop:\n        - ALL\n    image:\n      repository: quay.io/validator-labs/validator-plugin-network\n      tag: v0.0.16\n    resources:\n      limits:\n        cpu: 500m\n        memory: 128Mi\n      requests:\n        cpu: 10m\n        memory: 64Mi\n  replicas: 1\n  serviceAccount:\n    annotations: {}\nkubernetesClusterDomain: cluster.local\nmetricsService:\n  ports:\n  - name: https\n    port: 8443\n    protocol: TCP\n    targetPort: https\n  type: ClusterIP"}, {"chart": {"name": "validator-plugin-oci", "repository": "https://validator-labs.github.io/validator-plugin-oci", "version": "v0.0.10"}, "values": "controllerManager:\n  kubeRbacProxy:\n    args:\n    - --secure-listen-address=0.0.0.0:8443\n    - --upstream=http://127.0.0.1:8080/\n    - --logtostderr=true\n    - --v=0\n    containerSecurityContext:\n      allowPrivilegeEscalation: false\n      capabilities:\n        drop:\n        - ALL\n    image:\n      repository: gcr.io/kubebuilder/kube-rbac-proxy\n      tag: v0.15.0\n    resources:\n      limits:\n        cpu: 500m\n        memory: 128Mi\n      requests:\n        cpu: 5m\n        memory: 64Mi\n  manager:\n    args:\n    - --health-probe-bind-address=:8081\n    - --leader-elect\n    containerSecurityContext:\n      allowPrivilegeEscalation: false\n      capabilities:\n        drop:\n        - ALL\n    image:\n      repository: quay.io/validator-labs/validator-plugin-oci\n      tag: v0.0.10\n    resources:\n      limits:\n        cpu: 500m\n        memory: 128Mi\n      requests:\n        cpu: 10m\n        memory: 64Mi\n  replicas: 1\n  serviceAccount:\n    annotations: {}\nkubernetesClusterDomain: cluster.local\nmetricsService:\n  ports:\n  - name: https\n    port: 8443\n    protocol: TCP\n    targetPort: https\n  type: ClusterIP"}, {"chart": {"name": "validator-plugin-kubescape", "repository": "https://validator-labs.github.io/validator-plugin-kubescape", "version": "v0.0.3"}, "values": "controllerManager:\n  kubeRbacProxy:\n    args:\n    - --secure-listen-address=0.0.0.0:8443\n    - --upstream=http://127.0.0.1:8080/\n    - --logtostderr=true\n    - --v=0\n    containerSecurityContext:\n      allowPrivilegeEscalation: false\n      capabilities:\n        drop:\n        - ALL\n    image:\n      repository: gcr.io/kubebuilder/kube-rbac-proxy\n      tag: v0.15.0\n    resources:\n      limits:\n        cpu: 500m\n        memory: 128Mi\n      requests:\n        cpu: 5m\n        memory: 64Mi\n  manager:\n    args:\n    - --health-probe-bind-address=:8081\n    - --leader-elect\n    containerSecurityContext:\n      allowPrivilegeEscalation: false\n      capabilities:\n        drop:\n        - ALL\n    image:\n      repository: quay.io/validator-labs/validator-plugin-kubescape\n      tag: v0.0.3\n    resources:\n      limits:\n        cpu: 500m\n        memory: 128Mi\n      requests:\n        cpu: 10m\n        memory: 64Mi\n  replicas: 1\n  serviceAccount:\n    annotations: {}\nkubernetesClusterDomain: cluster.local\nmetricsService:\n  ports:\n  - name: https\n    port: 8443\n    protocol: TCP\n    targetPort: https\n  type: ClusterIP"}]` |
| `pluginSecrets.aws` | Don't forget to delete these curly braces if you're specifying credentials here! | `{}` |
| `pluginSecrets.azure` | Don't forget to delete these curly braces if you're specifying credentials here! | `{}` |
| `pluginSecrets.vSphere` | Don't forget to delete these curly braces if you're specifying credentials here! | `{}` |
| `pluginSecrets.oci.auth` | Don't forget to delete these square brackets if you're specifying credentials here! | `[]` |
| `pluginSecrets.oci.pubKeys` | Don't forget to delete these square brackets if you're specifying public keys here! | `[]` |

## References

<!-- List one or more sources users can reference to learn more about the pack. References can comprise the official application or service documentation, a dedicated tutorial, the Helm Chart documentation, and more. 
References must be in a bullet list that adheres to the standard MarkDown link format.
- [link_label](https://link) -->

- [validator](https://github.com/validator-labs/validator)
- [validator-plugin-aws](https://github.com/validator-labs/validator-plugin-aws)
- [validator-plugin-azure](https://github.com/validator-labs/validator-plugin-azure)
- [validator-plugin-kubescape](https://github.com/validator-labs/validator-plugin-kubescape)
- [validator-plugin-network](https://github.com/validator-labs/validator-plugin-network)
- [validator-plugin-oci](https://github.com/validator-labs/validator-plugin-oci)
- [validator-plugin-vsphere](https://github.com/validator-labs/validator-plugin-vsphere)
