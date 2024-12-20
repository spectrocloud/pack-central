# Helm chart for Appd collector with Opentelemetry Operator

## Required Values
Some components, if used, required user input value.

### OtlpHttp Exporter
OtlpHttp exporter need to specify backend endpoint and Ouath2 related properties:
These are required values:
```yaml
clientId: "id" # clientId for oauth2 extension
tokenUrl: "https://token_ur.com/oauth2l" # tokenUrl for oauth2 extension
endpoint: "https://data.appdynamics.com" # endpoint for otlphttp exporeter
```
Client secret can be presented in plain text(clientSecret) or environment variable(clientSecretEnvVar) and at least one of them must be provided. 
when clientSecret and clientSecretEnvVar are both provided, clientSecret will be used.
```yaml
# clientSecret plain text for oauth2 extension
clientSecret: "secret" 

# clientSecret set by environment variable for oauth2 extension
# When using this format, the value will be set to environment variable APPD_OTELCOL_CLIENT_SECRET, and
# collector config will read the secret from ${APPD_OTELCOL_CLIENT_SECRET}.
clientSecretEnvVar: 
  value: "secret" 
```
clientSecretEnvVar can be used for kubernetes secret.
```yaml
# clientSecret set by environment variable which value is read from kubernetes secret.
clientSecret: 
  valueFrom:
    secretKeyRef:
      name: "oauth-client-secret"
      key: "secret"
```
example for configuring values by helm command line:
```shell
helm install release-name appdynamics-otel-collector \ 
  --set clientId="clientId" \
  --set clientSecretEnvVar.secretKeyRef.name="oauth-client-secret" \
  --set clientSecretEnvVar.secretKeyRef.key="secret" \
  --set tokenUrl="https://example-token-url" \
  --set endpoint="https://example:443/v1beta/metrics" 
```
You can also disable Oauth2 for testing, please be aware you will also need to remove all related configs manually include exporter config and pipeline.
see examples/remove_oauth.yaml.

### Prometheus Receiver
Prometheus receiver if used, must have at least one scrape config, following showed an example k8s pod discovery config.
```yaml
prometheus:
  config:
    scrape_configs:
      - job_name: k8s
        kubernetes_sd_configs:
          - role: pod
            # namespace must be manually specified, otherwise prometheus will explore all namespaces.
            namespaces:
              names: [ "default" ]
        relabel_configs:
          - source_labels: [ __meta_kubernetes_pod_annotation_prometheus_io_scrape ]
            regex: "true"
            action: keep
```
If using k8s discovery scape, don't forget to give necessary rbac rules.
```yaml
rbac:
  rules:
    - apiGroups: [ "" ]
      resources: [ "pods" ]
      verbs: [ "get", "list", "watch" ]
```