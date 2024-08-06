# Appdynamics Helm Chart

### Add AppDynamics helm repo

### Create values yaml to override default ones
```yaml
installClusterAgent: true
installInfraViz: false

imageInfo:
  agentImage: docker.io/appdynamics/cluster-agent
  agentTag: 22.1.0         # Will be used for operator pod
  machineAgentImage: docker.io/appdynamics/machine-agent
  machineAgentTag: latest
  machineAgentWinImage: docker.io/appdynamics/machine-agent-analytics
  machineAgentWinTag: win-latest
  netVizImage: docker.io/appdynamics/machine-agent-netviz
  netvizTag: latest                            

controllerInfo:
  url: <controller-url>
  account: <controller-account>
  username: <controller-username>
  password: <controller-password>
  accessKey: <controller-accesskey>
  globalAccount: <controller-global-account>   # To be provided when using machineAgent Window Image

agentServiceAccount: appdynamics-cluster-agent
infravizServiceAccount: appdynamics-infraviz
```
### Install cluster agent or machine agent using helm chart
```bash
helm install cluster-agent appdynamics-charts/cluster-agent -f <values-file>.yaml --namespace appdynamics
```

### Note:
cluster agent installation is independent of otel collector.