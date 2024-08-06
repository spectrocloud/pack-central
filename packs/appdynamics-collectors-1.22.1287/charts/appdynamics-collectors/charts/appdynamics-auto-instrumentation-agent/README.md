# Appdynamics Helm Chart

### Add AppDynamics helm repo

### Create values yaml to override default ones
```yaml
imageInfo:
  agentImage: docker.io/appdynamics/auto-instrumentation-agent
  agentTag: 24.4.0
  imagePullPolicy: Always
  imagePullSecret: null                          

controllerInfo:
  url: <controller-url>
  account: <controller-account>
  username: <controller-username>
  password: <controller-password>
  accessKey: <controller-accesskey>

agentServiceAccount: appdynamics-auto-instrumentation-agent

instrumentationConfig:
  enabled: true
  containerAppCorrelationMethod: proxy
```
### Install auto-instrumentation-agent using helm chart
```bash
helm install auto-instrumentation-agent appdynamics-charts/auto-instrumentation-agent -f <values-file>.yaml --namespace appdynamics
```

### Note:
auto instrumentation agent installation is independent of otel collector.