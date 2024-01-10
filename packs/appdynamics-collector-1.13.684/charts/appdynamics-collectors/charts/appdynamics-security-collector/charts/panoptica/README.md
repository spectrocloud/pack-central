# panoptica

![Version: 1.208.0](https://img.shields.io/badge/Version-1.208.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.208.0](https://img.shields.io/badge/AppVersion-1.208.0-informational?style=flat-square)

Charts for Panoptica deployments.

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | apiclarity-postgresql(postgresql) | 11.6.12 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| apiclarity-postgresql.auth.database | string | `"apiclarity"` |  |
| apiclarity-postgresql.auth.existingSecret | string | `"apiclarity-postgresql-secret"` |  |
| apiclarity-postgresql.containerSecurityContext.enabled | bool | `true` |  |
| apiclarity-postgresql.containerSecurityContext.runAsNonRoot | bool | `true` |  |
| apiclarity-postgresql.containerSecurityContext.runAsUser | int | `1001` |  |
| apiclarity-postgresql.fullnameOverride | string | `"apiclarity-postgresql"` |  |
| apiclarity-postgresql.image.pullPolicy | string | `"IfNotPresent"` |  |
| apiclarity-postgresql.image.registry | string | `"gcr.io/eticloud/k8sec"` | Image registry, must be set to override the dependency registry. |
| apiclarity-postgresql.image.repository | string | `"bitnami/postgresql"` |  |
| apiclarity-postgresql.image.tag | string | `"14.4.0-debian-11-r4"` |  |
| apiclarity.affinity | object | `{}` |  |
| apiclarity.fuzzer.affinity | object | `{}` |  |
| apiclarity.fuzzer.debug | bool | `false` |  |
| apiclarity.fuzzer.enabled | bool | `false` |  |
| apiclarity.fuzzer.image.pullPolicy | string | `"Always"` |  |
| apiclarity.fuzzer.image.registry | string | `""` | Image registry, used to override global.registry if needed. |
| apiclarity.fuzzer.image.repository | string | `"scn-dast"` |  |
| apiclarity.fuzzer.image.tag | string | `"b0e698ea50aa701d22a1f8fbe549d45c340e0b91"` |  |
| apiclarity.fuzzer.labels | object | `{"app":"fuzzer"}` | Configure fuzzer labels |
| apiclarity.fuzzer.nodeSelector | object | `{"kubernetes.io/os":"linux"}` | Node labels for pod assignment |
| apiclarity.fuzzer.resources.limits.cpu | string | `"200m"` |  |
| apiclarity.fuzzer.resources.limits.memory | string | `"1000Mi"` |  |
| apiclarity.fuzzer.resources.requests.cpu | string | `"100m"` |  |
| apiclarity.fuzzer.resources.requests.memory | string | `"200Mi"` |  |
| apiclarity.fuzzer.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| apiclarity.fuzzer.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| apiclarity.fuzzer.securityContext.privileged | bool | `false` |  |
| apiclarity.fuzzer.securityContext.readOnlyRootFilesystem | bool | `true` |  |
| apiclarity.fuzzer.securityContext.runAsGroup | int | `1001` |  |
| apiclarity.fuzzer.securityContext.runAsNonRoot | bool | `true` |  |
| apiclarity.fuzzer.securityContext.runAsUser | int | `1001` |  |
| apiclarity.image.pullPolicy | string | `"IfNotPresent"` |  |
| apiclarity.image.registry | string | `""` | Image registry, used to override global.registry if needed. |
| apiclarity.image.repository | string | `"apiclarity"` |  |
| apiclarity.image.tag | string | `"9a09d167c27046e6d76a96e6e4f248f166b9fc8f"` |  |
| apiclarity.imagePullSecrets | list | `[]` |  |
| apiclarity.logLevel | string | `"warning"` | Logging level (debug, info, warning, error, fatal, panic). |
| apiclarity.nodeSelector | object | `{"kubernetes.io/os":"linux"}` | Node labels for pod assignment |
| apiclarity.persistence.accessMode | string | `"ReadWriteOnce"` |  |
| apiclarity.persistence.size | string | `"100Mi"` | The storage space that should be claimed from the persistent volume |
| apiclarity.persistence.storageClass | string | `nil` | If defined, storageClassName will be set to the defined storageClass. If set to "-", storageClassName will be set to an empty string (""), which disables dynamic provisioning. If undefined or set to null (the default), no storageClassName spec is set, choosing 'standard' storage class available with the default provisioner (gcd-pd on GKE, hostpath on minikube, etc). |
| apiclarity.podSecurityContext.fsGroup | int | `1000` |  |
| apiclarity.resources.limits.cpu | string | `"1000m"` |  |
| apiclarity.resources.limits.memory | string | `"1000Mi"` |  |
| apiclarity.resources.requests.cpu | string | `"100m"` |  |
| apiclarity.resources.requests.memory | string | `"200Mi"` |  |
| apiclarity.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| apiclarity.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| apiclarity.securityContext.privileged | bool | `false` |  |
| apiclarity.securityContext.readOnlyRootFilesystem | bool | `true` |  |
| apiclarity.securityContext.runAsGroup | int | `1000` |  |
| apiclarity.securityContext.runAsNonRoot | bool | `true` |  |
| apiclarity.securityContext.runAsUser | int | `1000` |  |
| apiclarity.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| apiclarity.serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| apiclarity.serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| apiclarity.tolerations | list | `[]` |  |
| apiclarity.traceSource.external | bool | `false` | Indicates whether external GWs supply traces. |
| apiclarity.traceSource.istio | bool | `false` | Indicates whether istio supply traces. |
| apiclarity.traceWasmFilterSHA256 | string | `"bf881f216b4f58c3dfe5c3fed269c849b5063b701854ff3110b165f7dcd7c80b"` |  |
| busybox.image.pullPolicy | string | `"IfNotPresent"` |  |
| busybox.image.registry | string | `""` | Image registry, used to override global.registry if needed. |
| busybox.image.repository | string | `"yauritux/busybox-curl"` |  |
| busybox.image.tag | string | `"latest"` |  |
| busybox.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| busybox.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| busybox.securityContext.privileged | bool | `false` |  |
| busybox.securityContext.readOnlyRootFilesystem | bool | `true` |  |
| busybox.securityContext.runAsGroup | int | `1001` |  |
| busybox.securityContext.runAsNonRoot | bool | `true` |  |
| busybox.securityContext.runAsUser | int | `1001` |  |
| controller.affinity | object | `{}` |  |
| controller.agentID | string | `""` | [Required] Controller identification, should be extracted from SaaS after cluster creation. |
| controller.autoscaling.enabled | bool | `true` |  |
| controller.autoscaling.maxReplicas | int | `5` |  |
| controller.autoscaling.minReplicas | int | `1` |  |
| controller.autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| controller.fullnameOverride | string | `"portshift-agent"` |  |
| controller.image.pullPolicy | string | `"IfNotPresent"` |  |
| controller.image.registry | string | `""` | Image registry, used to override global.registry if needed. |
| controller.image.repository | string | `"k8s_agent"` |  |
| controller.image.tag | string | `"55eb9b34d19c71da0cfd064383a3f8342e01f432"` |  |
| controller.imagePullSecrets | list | `[]` |  |
| controller.logLevel | string | `"warning"` | Logging level (debug, info, warning, error, fatal, panic). |
| controller.nameOverride | string | `"portshift-agent"` |  |
| controller.nodeSelector | object | `{"kubernetes.io/os":"linux"}` | Node labels for controller pod assignment |
| controller.pdb.create | bool | `true` |  |
| controller.pdb.minAvailable | int | `1` |  |
| controller.persistence.accessMode | string | `"ReadWriteOnce"` |  |
| controller.persistence.enabled | bool | `false` | Enable persistence using Persistent Volume Claims |
| controller.persistence.pvcSuffix | string | `"pvc-55eb9b34d19c71da0cfd064383a3f8342e01f432"` |  |
| controller.persistence.size | string | `"100Mi"` | The storage space that should be claimed from the persistent volume |
| controller.persistence.storageClass | string | `nil` | If defined, storageClassName will be set to the defined storageClass. If set to "-", storageClassName will be set to an empty string (""), which disables dynamic provisioning. If undefined or set to null (the default), no storageClassName spec is set, choosing 'standard' storage class available with the default provisioner (gcd-pd on GKE, hostpath on minikube, etc). |
| controller.podSecurityContext.fsGroup | int | `1001` |  |
| controller.replicaCount | int | `1` | Configure controller replica count number in case autoscaling is disabled. |
| controller.resources.requests.cpu | string | `"500m"` |  |
| controller.resources.requests.memory | string | `"2048Mi"` |  |
| controller.secret.sharedSecret | string | `""` | [Required] Shared secret used by the controller to communicate with the SaaS, should be extracted from SaaS after cluster creation. |
| controller.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| controller.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| controller.securityContext.privileged | bool | `false` |  |
| controller.securityContext.readOnlyRootFilesystem | bool | `true` |  |
| controller.securityContext.runAsGroup | int | `1001` |  |
| controller.securityContext.runAsNonRoot | bool | `true` |  |
| controller.securityContext.runAsUser | int | `1001` |  |
| controller.service.type | string | `"ClusterIP"` |  |
| controller.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| controller.serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| controller.serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| controller.tolerations | list | `[]` |  |
| dnsDetector.image.pullPolicy | string | `"IfNotPresent"` |  |
| dnsDetector.image.registry | string | `""` | Image registry, used to override global.registry if needed. |
| dnsDetector.image.repository | string | `"gopassivedns"` |  |
| dnsDetector.image.tag | string | `"0c7330b51a07cdebe13e57b1d1a33134cbbe04ce"` |  |
| dnsDetector.resources.limits.cpu | string | `"200m"` |  |
| dnsDetector.resources.limits.memory | string | `"100Mi"` |  |
| dnsDetector.resources.requests.cpu | string | `"20m"` |  |
| dnsDetector.resources.requests.memory | string | `"50Mi"` |  |
| global.autoLabelEnabled | bool | `false` | Indicates whether auto label is enabled. If true, new namespaces will be labeled with the protection label. |
| global.automatedPolicyRequiresDeployer | bool | `true` | If true, policies created via Panoptica CRDs will require deployer. See https://panoptica.readme.io/docs/deployers for more info about deployers. |
| global.cdValidation | bool | `false` | Indicates whether to identity pods whose templates originated from the Panoptica CD plugin. See `CD Pod template` section in https://panoptica.readme.io/docs/deploy-on-a-kubernetes-cluster for more info. |
| global.ciImageSignatureValidation | bool | `false` | Indicates whether to identity pods only if all images are signed by a trusted signer. See https://panoptica.readme.io/docs/trusted-signers for more info. |
| global.ciImageValidation | bool | `false` | Indicates whether to identity pods only if all image hashes are known to Panoptica. See `CI image hash validation` section in https://panoptica.readme.io/docs/deploy-on-a-kubernetes-cluster for more info. |
| global.connectionFailPolicyAllow | bool | `true` | If false, connections on protected namespaces will be blocked if the controller is not responding. |
| global.dummyPlaceHolderForTest | bool | `false` | Placeholder used for tests. |
| global.enableTlsInspection | bool | `false` | Indicates whether TLS inspection is enabled. If true, the controller will be able to decrypt and re-encrypt HTTPS traffic for connections to be inspected via layer 7 attributes. |
| global.environmentFailurePolicyAllow | bool | `true` | If false, pods creation on protected namespaces will be blocked if the controller is not responding. |
| global.extraLabels | object | `{}` | Allow labelling resources with custom key/value pairs. |
| global.httpProxy | string | `""` | Proxy address to use for HTTP request if needed. |
| global.httpsProxy | string | `""` | Proxy address to use for HTTPs request if needed. In most cases, this is the same as `httpProxy`. |
| global.isAPISecurityEnabled | bool | `false` | Indicates whether API security is enabled. |
| global.isConnectionEnforcementEnabled | bool | `false` | Indicates whether connection enforcement is enabled. If true, make sure istio is installed by using panoptica istio chart or an upstream istio is already installed. |
| global.isContainerSecurityEnabled | bool | `true` | Indicates whether kubernetes security is enabled. |
| global.isExternalCaEnabled | bool | `false` | Indicates whether istio should provision workload certificates using a custom certificate authority that integrates with the Kubernetes CSR API. |
| global.isOpenShift | bool | `false` | Indicates whether installed in an OpenShift environment. |
| global.isSSHMonitorEnabled | bool | `true` | Indicates whether SSH monitoring is enabled. |
| global.k8sCisBenchmarkEnabled | bool | `true` | Indicates whether K8s CIS benchmark is enabled. |
| global.k8sEventsEnabled | bool | `true` | Indicates whether K8s Events monitoring is enabled. |
| global.kubeVersionOverride | string | `""` | Override detected cluster version. |
| global.mgmtHostname | string | `""` | Panoptica SaaS URL. Used to override default URL for local testing. |
| global.preserveOriginalSourceIp | bool | `false` | Indicates whether the controller should preserve the original source ip of inbound connections. |
| global.productNameOverride | string | `"portshift"` | Override product name. Defaults to chart name. |
| global.registry | string | `"gcr.io/eticloud/k8sec"` | Registry for the Panoptica images. If replaced with a local registry need to make sure all images are pulled into the local registry. |
| global.restrictRegistries | bool | `false` | Indicates whether to identity pods only if all images are pulled from trusted registries. See `Restrict Registries` section in https://panoptica.readme.io/docs/deploy-on-a-kubernetes-cluster for more info. |
| global.sendTelemetriesIntervalSec | int | `30` | Configures telemetry frequency (in seconds) for reporting duration. |
| global.tokenInjectionEnabled | bool | `false` | Indicates whether token injection feature is enabled. If true, make sure vault is installed by using panoptica vault chart. |
| global.validateDeployerPolicy | bool | `false` | Indicates whether Deployer Policy enforcement is enabled. |
| grypeServer.affinity | object | `{}` |  |
| grypeServer.image.pullPolicy | string | `"Always"` |  |
| grypeServer.image.registry | string | `""` | Image registry, used to override global.registry if needed. |
| grypeServer.image.repository | string | `"grype-server"` |  |
| grypeServer.image.tag | string | `"4f0c4f8acaa29a9d4220fae3b9bf4f30abb87b52"` |  |
| grypeServer.logLevel | string | `"warning"` | Logging level (debug, info, warning, error, fatal, panic). |
| grypeServer.nodeSelector | object | `{"kubernetes.io/os":"linux"}` | Node labels for pod assignment |
| grypeServer.podSecurityContext.fsGroup | int | `1001` |  |
| grypeServer.replicaCount | int | `1` | Configure grype server replica count number. |
| grypeServer.resources.limits.cpu | string | `"1000m"` |  |
| grypeServer.resources.limits.memory | string | `"1G"` |  |
| grypeServer.resources.requests.cpu | string | `"200m"` |  |
| grypeServer.resources.requests.memory | string | `"200Mi"` |  |
| grypeServer.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| grypeServer.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| grypeServer.securityContext.privileged | bool | `false` |  |
| grypeServer.securityContext.readOnlyRootFilesystem | bool | `true` |  |
| grypeServer.securityContext.runAsGroup | int | `1001` |  |
| grypeServer.securityContext.runAsNonRoot | bool | `true` |  |
| grypeServer.securityContext.runAsUser | int | `1001` |  |
| grypeServer.service.type | string | `"ClusterIP"` |  |
| imageAnalysis.cisDockerBenchmark.enabled | bool | `true` |  |
| imageAnalysis.cisDockerBenchmark.image.registry | string | `""` | Image registry, used to override global.registry if needed. |
| imageAnalysis.cisDockerBenchmark.image.repository | string | `"cis-docker-benchmark"` |  |
| imageAnalysis.cisDockerBenchmark.image.tag | string | `"ba3768df0217b6356cec526f161c8dcf834b270c"` |  |
| imageAnalysis.cisDockerBenchmark.podSecurityContext.fsGroup | int | `1001` |  |
| imageAnalysis.cisDockerBenchmark.resources.limits.cpu | string | `"1000m"` |  |
| imageAnalysis.cisDockerBenchmark.resources.limits.memory | string | `"1000Mi"` |  |
| imageAnalysis.cisDockerBenchmark.resources.requests.cpu | string | `"50m"` |  |
| imageAnalysis.cisDockerBenchmark.resources.requests.memory | string | `"50Mi"` |  |
| imageAnalysis.cisDockerBenchmark.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| imageAnalysis.cisDockerBenchmark.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| imageAnalysis.cisDockerBenchmark.securityContext.privileged | bool | `false` |  |
| imageAnalysis.cisDockerBenchmark.securityContext.readOnlyRootFilesystem | bool | `true` |  |
| imageAnalysis.cisDockerBenchmark.securityContext.runAsGroup | int | `1001` |  |
| imageAnalysis.cisDockerBenchmark.securityContext.runAsNonRoot | bool | `true` |  |
| imageAnalysis.cisDockerBenchmark.securityContext.runAsUser | int | `1001` |  |
| imageAnalysis.jobDefaultNamespace | string | `""` | Scanner jobs namespace. If left blank, the scanner jobs will run in release namespace. If set, the scanner jobs will run in the given namespace unless the image requires image pull secrets which are located in a target pod |
| imageAnalysis.nodeSelector | object | `{"kubernetes.io/os":"linux"}` | Node labels for controller pod assignment |
| imageAnalysis.parallelScanners | int | `4` | The max number of scanner jobs that will run in the cluster in parallel for image analysis in total |
| imageAnalysis.registry.skipVerifyTlS | string | `"false"` |  |
| imageAnalysis.registry.useHTTP | string | `"false"` |  |
| imageAnalysis.sbom.enabled | bool | `true` |  |
| imageAnalysis.sbom.image.registry | string | `""` | Image registry, used to override global.registry if needed. |
| imageAnalysis.sbom.image.repository | string | `"image-analyzer"` |  |
| imageAnalysis.sbom.image.tag | string | `"06e343816b1ac0b160d682e7b6aa84750517ce7f"` |  |
| imageAnalysis.sbom.podSecurityContext.fsGroup | int | `1001` |  |
| imageAnalysis.sbom.resources.limits.cpu | string | `"1000m"` |  |
| imageAnalysis.sbom.resources.limits.memory | string | `"1000Mi"` |  |
| imageAnalysis.sbom.resources.requests.cpu | string | `"50m"` |  |
| imageAnalysis.sbom.resources.requests.memory | string | `"50Mi"` |  |
| imageAnalysis.sbom.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| imageAnalysis.sbom.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| imageAnalysis.sbom.securityContext.privileged | bool | `false` |  |
| imageAnalysis.sbom.securityContext.readOnlyRootFilesystem | bool | `true` |  |
| imageAnalysis.sbom.securityContext.runAsGroup | int | `1001` |  |
| imageAnalysis.sbom.securityContext.runAsNonRoot | bool | `true` |  |
| imageAnalysis.sbom.securityContext.runAsUser | int | `1001` |  |
| istio.expansion.enabled | bool | `false` |  |
| istio.global.alreadyInstalled | bool | `false` | Indicates whether istio is already installed and not by Panoptica charts. |
| istio.global.serviceDiscoveryIsolationEnabled | bool | `false` |  |
| istio.global.version | string | `"1.16.1"` | Indicates what version of istio is running, change only if `alreadyInstalled` is set to true. |
| k8sCISBenchmark.image.registry | string | `""` | Image registry, used to override global.registry if needed. |
| k8sCISBenchmark.image.repository | string | `"k8s-cis-benchmark"` |  |
| k8sCISBenchmark.image.tag | string | `"595b2bc627a9b191a8f0ec032196f824aa783d9c"` |  |
| k8sCISBenchmark.nodeSelector | object | `{"kubernetes.io/os":"linux"}` | Node labels for pod assignment |
| kafkaAuthzInjector.image.pullPolicy | string | `"Always"` |  |
| kafkaAuthzInjector.image.registry | string | `""` | Image registry, used to override global.registry if needed. |
| kafkaAuthzInjector.image.repository | string | `"kafka-authz"` |  |
| kafkaAuthzInjector.image.tag | string | `"e647ba66cf10897ee6e07a3d6d81b2148d0a47be"` |  |
| kafkaAuthzInjector.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| kafkaAuthzInjector.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| kafkaAuthzInjector.securityContext.privileged | bool | `false` |  |
| kafkaAuthzInjector.securityContext.readOnlyRootFilesystem | bool | `true` |  |
| kafkaAuthzInjector.securityContext.runAsGroup | int | `1001` |  |
| kafkaAuthzInjector.securityContext.runAsNonRoot | bool | `true` |  |
| kafkaAuthzInjector.securityContext.runAsUser | int | `1001` |  |
| kubeclarity-runtime-scan.cis-docker-benchmark-scanner.image.pullPolicy | string | `"Always"` |  |
| kubeclarity-runtime-scan.cis-docker-benchmark-scanner.image.registry | string | `""` | Image registry, used to override global.registry if needed. |
| kubeclarity-runtime-scan.cis-docker-benchmark-scanner.image.repository | string | `"kubeclarity-cis-docker-benchmark-scanner"` |  |
| kubeclarity-runtime-scan.cis-docker-benchmark-scanner.image.tag | string | `"4f0c4f8acaa29a9d4220fae3b9bf4f30abb87b52"` |  |
| kubeclarity-runtime-scan.cis-docker-benchmark-scanner.resources.limits.cpu | string | `"1000m"` |  |
| kubeclarity-runtime-scan.cis-docker-benchmark-scanner.resources.limits.memory | string | `"1000Mi"` |  |
| kubeclarity-runtime-scan.cis-docker-benchmark-scanner.resources.requests.cpu | string | `"50m"` |  |
| kubeclarity-runtime-scan.cis-docker-benchmark-scanner.resources.requests.memory | string | `"50Mi"` |  |
| kubeclarity-runtime-scan.cis-docker-benchmark-scanner.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| kubeclarity-runtime-scan.cis-docker-benchmark-scanner.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| kubeclarity-runtime-scan.cis-docker-benchmark-scanner.securityContext.privileged | bool | `false` |  |
| kubeclarity-runtime-scan.cis-docker-benchmark-scanner.securityContext.readOnlyRootFilesystem | bool | `true` |  |
| kubeclarity-runtime-scan.cis-docker-benchmark-scanner.securityContext.runAsGroup | int | `1001` |  |
| kubeclarity-runtime-scan.cis-docker-benchmark-scanner.securityContext.runAsNonRoot | bool | `true` |  |
| kubeclarity-runtime-scan.cis-docker-benchmark-scanner.securityContext.runAsUser | int | `1001` |  |
| kubeclarity-runtime-scan.labels | object | `{"app":"scanner","kuma.io/sidecar-injection":"disabled","sidecar.istio.io/inject":"false"}` | Scanner jobs and pods labels. |
| kubeclarity-runtime-scan.nodeSelector | object | `{"kubernetes.io/os":"linux"}` | Node labels for scanner pod assignment |
| kubeclarity-runtime-scan.registry.skipVerifyTlS | string | `"false"` |  |
| kubeclarity-runtime-scan.registry.useHTTP | string | `"false"` |  |
| kubeclarity-runtime-scan.tolerations | string | `nil` | Scanner pods tolerations. |
| kubeclarity-runtime-scan.vulnerability-scanner.image.pullPolicy | string | `"Always"` |  |
| kubeclarity-runtime-scan.vulnerability-scanner.image.registry | string | `""` | Image registry, used to override global.registry if needed. |
| kubeclarity-runtime-scan.vulnerability-scanner.image.repository | string | `"kubeclarity-runtime-k8s-scanner"` |  |
| kubeclarity-runtime-scan.vulnerability-scanner.image.tag | string | `"4f0c4f8acaa29a9d4220fae3b9bf4f30abb87b52"` |  |
| kubeclarity-runtime-scan.vulnerability-scanner.resources.limits.cpu | string | `"1000m"` |  |
| kubeclarity-runtime-scan.vulnerability-scanner.resources.limits.memory | string | `"1000Mi"` |  |
| kubeclarity-runtime-scan.vulnerability-scanner.resources.requests.cpu | string | `"50m"` |  |
| kubeclarity-runtime-scan.vulnerability-scanner.resources.requests.memory | string | `"50Mi"` |  |
| kubeclarity-runtime-scan.vulnerability-scanner.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| kubeclarity-runtime-scan.vulnerability-scanner.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| kubeclarity-runtime-scan.vulnerability-scanner.securityContext.privileged | bool | `false` |  |
| kubeclarity-runtime-scan.vulnerability-scanner.securityContext.readOnlyRootFilesystem | bool | `true` |  |
| kubeclarity-runtime-scan.vulnerability-scanner.securityContext.runAsGroup | int | `1001` |  |
| kubeclarity-runtime-scan.vulnerability-scanner.securityContext.runAsNonRoot | bool | `true` |  |
| kubeclarity-runtime-scan.vulnerability-scanner.securityContext.runAsUser | int | `1001` |  |
| sbomDb.affinity | object | `{}` |  |
| sbomDb.image.pullPolicy | string | `"Always"` |  |
| sbomDb.image.registry | string | `""` | Image registry, used to override global.registry if needed. |
| sbomDb.image.repository | string | `"kubeclarity-sbom-db"` |  |
| sbomDb.image.tag | string | `"4f0c4f8acaa29a9d4220fae3b9bf4f30abb87b52"` |  |
| sbomDb.logLevel | string | `"warning"` | Logging level (debug, info, warning, error, fatal, panic). |
| sbomDb.nodeSelector | object | `{"kubernetes.io/os":"linux"}` | Node labels for pod assignment |
| sbomDb.podSecurityContext.fsGroup | int | `1000` |  |
| sbomDb.resources.limits.cpu | string | `"200m"` |  |
| sbomDb.resources.limits.memory | string | `"1Gi"` |  |
| sbomDb.resources.requests.cpu | string | `"10m"` |  |
| sbomDb.resources.requests.memory | string | `"20Mi"` |  |
| sbomDb.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| sbomDb.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| sbomDb.securityContext.privileged | bool | `false` |  |
| sbomDb.securityContext.readOnlyRootFilesystem | bool | `true` |  |
| sbomDb.securityContext.runAsGroup | int | `1000` |  |
| sbomDb.securityContext.runAsNonRoot | bool | `true` |  |
| sbomDb.securityContext.runAsUser | int | `1000` |  |
| sbomDb.service.type | string | `"ClusterIP"` |  |
| sbomDb.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| sbomDb.serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| sbomDb.serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| seccompInstaller.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| seccompInstaller.serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| seccompInstaller.serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| upgrader.image.pullPolicy | string | `"Always"` |  |
| upgrader.nodeSelector | object | `{"kubernetes.io/os":"linux"}` | Node labels for pod assignment |
| upgrader.podSecurityContext.fsGroup | int | `1001` |  |
| upgrader.resources.limits.cpu | string | `"1000m"` |  |
| upgrader.resources.limits.memory | string | `"1000Mi"` |  |
| upgrader.resources.requests.cpu | string | `"50m"` |  |
| upgrader.resources.requests.memory | string | `"50Mi"` |  |
| upgrader.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| upgrader.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| upgrader.securityContext.privileged | bool | `false` |  |
| upgrader.securityContext.readOnlyRootFilesystem | bool | `true` |  |
| upgrader.securityContext.runAsGroup | int | `1001` |  |
| upgrader.securityContext.runAsNonRoot | bool | `true` |  |
| upgrader.securityContext.runAsUser | int | `1001` |  |
| vaultEnv.image.registry | string | `""` | Image registry, used to override global.registry if needed. |
| vaultEnv.image.repository | string | `"bank-vaults/vault-env"` |  |
| vaultEnv.image.tag | string | `"v1.21.0"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
