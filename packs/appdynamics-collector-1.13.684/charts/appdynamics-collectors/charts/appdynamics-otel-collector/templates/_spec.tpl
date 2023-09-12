{{/*
  Derived configuation from top level properties
*/}}
{{- define "appdynamics-otel-collector.podUIDEnvVar" -}}
{{- if .Values.setPodUID }}
name: POD_UID
valueFrom:
  fieldRef:
    fieldPath: metadata.uid
{{- end }}
{{- end }}

{{- define "appdynamics-otel-collector.derivedConfig" -}}
extensions:
  oauth2client:
    client_id: {{required ".clientId is required" .Values.clientId}}
{{- if .Values.clientSecret }}
    client_secret: {{ .Values.clientSecret }}
{{- else if .Values.clientSecretEnvVar }}
    client_secret: "${APPD_OTELCOL_CLIENT_SECRET}"
{{- end }}
    token_url: {{required ".tokenUrl is required" .Values.tokenUrl}}
exporters:
  otlphttp:
    metrics_endpoint: {{required ".endpoint is required" .Values.endpoint}}/v1/metrics
    traces_endpoint: {{.Values.endpoint}}/v1/trace
    logs_endpoint: {{.Values.endpoint}}/v1/logs
    retry_on_failure:
      max_elapsed_time: 180
{{- end }}

{{- define "appdynamics-otel-collector.tlsConfig" -}}
{{- if .Values.global.tls.otelReceiver.settings }}
receivers:
  otlp:
    protocols:
      grpc:
        tls:
{{- deepCopy .Values.global.tls.otelReceiver.settings | toYaml | nindent 10}}
      http:
        tls:
{{- deepCopy .Values.global.tls.otelReceiver.settings | toYaml | nindent 10}}
  otlp/lca:
    protocols:
      grpc:
        tls:
{{- deepCopy .Values.global.tls.otelReceiver.settings | toYaml | nindent 10}}
      http:
        tls:
{{- deepCopy .Values.global.tls.otelReceiver.settings | toYaml | nindent 10}}
{{- end }}
{{- if .Values.global.tls.otelExporter.settings }}
extensions:
  oauth2client:
    tls:
{{- deepCopy .Values.global.tls.otelExporter.settings | toYaml | nindent 6}}
exporters:
  otlphttp:
    tls:
{{- deepCopy .Values.global.tls.otelExporter.settings | toYaml | nindent 6}}
{{- end }}
{{- end }}

{{- define "appdynamics-otel-collector.traceContextPropagation" -}}
{{- if .Values.traceContextPropagation }}
service:
  telemetry:
    traces:
      propagators:
        - tracecontext
{{- end }}
{{- end }}


{{- define "appdynamics-otel-collector.selfTelemetry" -}}
{{- if .Values.selfTelemetry }}
receivers:
  prometheus/self:
    config:
      scrape_configs:
        - job_name: {{ .Values.selfTelemetryServiceName | default "appd-otel-collector" | quote }}
          scrape_interval: 60s
          static_configs:
            - targets: ["localhost:8888"]
exporters:
  logging:
    verbosity: detailed
processors:
  batch/self:
  transform/self:
      metric_statements:
        - context: resource
          statements:
          - set(attributes["prometheus.targets"],attributes["service.instance.id"]) where attributes["prometheus.targets"] == nil
          - set(attributes["service.namespace"], "otelcol")
          - set(attributes["otel.collector.description"], "AppDynamics Distribution of OpenTelemetry collector.")
          - set(attributes["service.version"],attributes["service_version"])
          - set(attributes["telemetry.sdk.name"],"opentelemetry")
          - set(attributes["k8s.pod.uid"], "${POD_UID}" )
          - set(attributes["k8s.cluster.name"], "test-cluster")
        - context: datapoint
          statements:
          - set(resource.attributes["service.instance.id"],attributes["service_instance_id"])
{{- if .Values.setPodUID }}             
          - set(resource.attributes["k8s.pod.uid"], "${POD_UID}" )
{{- end }}
{{- if .Values.global.clusterName }}
          - set(resource.attributes["k8s.cluster.name"], {{ .Values.global.clusterName | quote }})
{{- end }}
{{- $clusterId := "" }}
{{- if (lookup "v1" "Namespace" "" "kube-system").metadata }}
{{- $clusterId = required "could not fetch kube-system uid to populate clusterID!" (lookup "v1" "Namespace" "" "kube-system").metadata.uid }}
{{- else }}
{{- $clusterId = required "clusterId needs to be specified when kube-system namespace metadata is not accessible." .Values.global.clusterId }}
{{- end }}
          - set(resource.attributes["k8s.cluster.id"], {{ $clusterId | quote}})
service:
  pipelines:
    metrics/self:
      receivers: [prometheus/self]
      processors: [ memory_limiter, transform/self, batch/self]
      exporters: [otlphttp]
{{- end }}
{{- end }}

{{- define "appdynamics-otel-collector.chartInfo" -}}
{{- if .Values.sendChartInfo }}
exporters:
  otlphttp:
    headers:
        appd-collector-helm-chart-version: "{{ tpl .Chart.Version . }}"
        appd-collector-helm-chart-name: "{{ tpl .Chart.Name . }}"
{{- end }}
{{- end }}

{{/*
  Generate the secret environment variable for OAuth2.0
*/}}
{{- define "appdynamics-otel-collector.clientSecretEnvVar" -}}
{{- if .Values.clientSecretEnvVar -}}
name: APPD_OTELCOL_CLIENT_SECRET
{{- .Values.clientSecretEnvVar | toYaml | nindent 0}}
{{- end }}
{{- end }}

{{/*
  Default memory limiter configuration for appdynamics-otel-collector based on k8s resource limits.
*/}}
{{- define "appdynamics-otel-collector.memoryLimiter" -}}
processors:
  memory_limiter:
# check_interval is the time between measurements of memory usage.
    check_interval: 5s
# By default limit_mib is set to 80% of ".Values.spec.resources.limits.memory"
    limit_mib: {{ include "appdynamics-otel-collector.getMemLimitMib" .memory }}
# By default spike_limit_mib is set to 25% of ".Values.spec.resources.limits.memory"
    spike_limit_mib: {{ include "appdynamics-otel-collector.getMemSpikeLimitMib" .memory }}
{{- end }}

{{/*
Get memory_limiter limit_mib value based on 80% of resources.limits.memory.
*/}}
{{- define "appdynamics-otel-collector.getMemLimitMib" -}}
{{- div (mul (include "appdynamics-otel-collector.convertMemToMib" .) 80) 100 }}
{{- end -}}

{{/*
Get memory_limiter spike_limit_mib value based on 25% of resources.limits.memory.
*/}}
{{- define "appdynamics-otel-collector.getMemSpikeLimitMib" -}}
{{- div (mul (include "appdynamics-otel-collector.convertMemToMib" .) 25) 100 }}
{{- end -}}

{{/*
Convert memory value from resources.limit to numeric value in MiB to be used by otel memory_limiter processor.
*/}}
{{- define "appdynamics-otel-collector.convertMemToMib" -}}
{{- $mem := lower . -}}
{{- if hasSuffix "e" $mem -}}
{{- trimSuffix "e" $mem | atoi | mul 1000 | mul 1000 | mul 1000 | mul 1000 -}}
{{- else if hasSuffix "ei" $mem -}}
{{- trimSuffix "ei" $mem | atoi | mul 1024 | mul 1024 | mul 1024 | mul 1024 -}}
{{- else if hasSuffix "p" $mem -}}
{{- trimSuffix "p" $mem | atoi | mul 1000 | mul 1000 | mul 1000 -}}
{{- else if hasSuffix "pi" $mem -}}
{{- trimSuffix "pi" $mem | atoi | mul 1024 | mul 1024 | mul 1024 -}}
{{- else if hasSuffix "t" $mem -}}
{{- trimSuffix "t" $mem | atoi | mul 1000 | mul 1000 -}}
{{- else if hasSuffix "ti" $mem -}}
{{- trimSuffix "ti" $mem | atoi | mul 1024 | mul 1024 -}}
{{- else if hasSuffix "g" $mem -}}
{{- trimSuffix "g" $mem | atoi | mul 1000 -}}
{{- else if hasSuffix "gi" $mem -}}
{{- trimSuffix "gi" $mem | atoi | mul 1024 -}}
{{- else if hasSuffix "m" $mem -}}
{{- div (trimSuffix "m" $mem | atoi | mul 1000) 1024 -}}
{{- else if hasSuffix "mi" $mem -}}
{{- trimSuffix "mi" $mem | atoi -}}
{{- else if hasSuffix "k" $mem -}}
{{- div (trimSuffix "k" $mem | atoi) 1000 -}}
{{- else if hasSuffix "ki" $mem -}}
{{- div (trimSuffix "ki" $mem | atoi) 1024 -}}
{{- else -}}
{{- div (div ($mem | atoi) 1024) 1024 -}}
{{- end -}}
{{- end -}}

{{- define "appdynamics-otel-collector.nonAppDTransformConfig" -}}
processors:
  transform/logs:
    log_statements:
      - context: resource
        statements:
{{- if .Values.global.clusterName }}
        - set(attributes["k8s.cluster.name"], {{ .Values.global.clusterName | quote }})
{{- end }}
{{- $clusterId := "" }}
{{- if (lookup "v1" "Namespace" "" "kube-system").metadata }}
{{- $clusterId = required "could not fetch kube-system uid to populate clusterID!" (lookup "v1" "Namespace" "" "kube-system").metadata.uid }}
{{- else }}
{{- $clusterId = required "clusterId needs to be specified when kube-system namespace metadata is not accessible." .Values.global.clusterId }}
{{- end }}
        - set(attributes["k8s.cluster.id"], {{ $clusterId | quote}})
        - set(attributes["internal.container.encapsulating_object_id"],Concat([attributes["k8s.cluster.id"],attributes["k8s.pod.uid"]],":"))
  k8sattributes/logs:
    passthrough: false
    extract:
      metadata:
        - k8s.pod.name
        - k8s.pod.uid
        - k8s.deployment.name
        - k8s.namespace.name
        - k8s.node.name
        - k8s.pod.start_time
        - container.id
        - k8s.container.name
        - container.image.name
        - container.image.tag
{{- end}}

{{/* 
  Append auto generated env to spec
*/}}
{{- define "appdynamics-otel-collector.appendEnv" -}}
{{- $spec := get .Values "spec" }}
{{- $specEnv := get $spec "env" | deepCopy }}
{{- if not $specEnv }}
{{- $specEnv = list }}
{{- end }}
{{- if.Values.setPodUID }}
{{- $specEnv = append $specEnv (include "appdynamics-otel-collector.podUIDEnvVar" . | fromYaml ) }}
{{- end}}
{{- if .Values.clientSecretEnvVar -}}
{{- $specEnv = append $specEnv (include "appdynamics-otel-collector.clientSecretEnvVar" . | fromYaml ) }}
{{- end }}
env:
{{- $specEnv | toYaml | nindent 2}}
{{- end }}

{{/*
  Set serviceAccount.name into spec.serviceAccount in the value file.
  If the spec.serviceAccount is already set, the serviceAccount.name won't take any effect.
  If neither spec.serviceAccount and serviceAccount.name are set, the default value will be populated to spec.serviceAccount.
*/}}
{{- define "appdynamics-otel-collector.valueServiceAccount" -}}
{{- if not .Values.spec.serviceAccount }}
serviceAccount: {{(.Values.serviceAccount.name | default (include "appdynamics-otel-collector.serviceAccountName" .))}}
{{- end }}
{{- end}}

{{/*
  Calculate the target allocator service account name.
  When enable the prometheuse, the prority for finding target allocator service account is (from high to low)
  - spec.targetAllocator.name
  - targetAllocatorServiceServiceAccount.name
  - default value - collector name concat with -target-allocator, e.g. "my-collector-target-allocator"
*/}}
{{- define "appdynamics-otel-collector.valueTargetAllocatorServiceAccount" -}}
{{- if .Values.spec.targetAllocator }}
{{- .Values.spec.targetAllocator.serviceAccount | default .Values.targetAllocatorServiceAccount.name | default (include "appdynamics-otel-collector.targetAllocatorServiceAccountName" .) }}
{{- else }}
{{- .Values.targetAllocatorServiceAccount.name | default (include "appdynamics-otel-collector.targetAllocatorServiceAccountName" .) -}}
{{- end }}
{{- end }}


{{- define "appdynamics-otel-collector.serverDefaultPaths" -}}
{{- if .secret }}
{{ $path := .path | default "/etc/otel/certs/receiver"}}
{{- if .secret.secretKeys.caCert}}
ca_file: {{$path}}/{{.secret.secretKeys.caCert}}
{{- if .mtlsEnabled}}
client_ca_file: {{$path}}/{{.secret.secretKeys.caCert}}
{{- end}}
{{- end}}
cert_file: {{$path}}/{{.secret.secretKeys.tlsCert}}
key_file: {{$path}}/{{.secret.secretKeys.tlsKey}}
{{- end}}
{{- end}}

{{- define "appdynamics-otel-collector.clientDefaultPaths" -}}
{{ $path := .path | default "/etc/otel/certs/exporter"}}
{{- if .secretKeys.caCert}}
ca_file: {{$path}}/{{.secretKeys.caCert}}
{{- end}}
cert_file: {{$path}}/{{.secretKeys.tlsCert}}
key_file: {{$path}}/{{.secretKeys.tlsKey}}
{{- end}}


{{- define "appdynamics-otel-collector.secrets" -}}
secret:
  secretName: {{.secretName}}
  items:
  {{- if .secretKeys.caCert}}
    - key: {{.secretKeys.caCert}}
      path: {{.secretKeys.caCert}}
  {{- end }}
    - key: {{required ".secretKeys.tlsCert is required" .secretKeys.tlsCert}}
      path: {{.secretKeys.tlsCert}}
    - key: {{required ".secretKeys.tlsKey is required" .secretKeys.tlsKey}}
      path: {{.secretKeys.tlsKey}}
{{- end}}

{{/*
  mount the tls cert files in case tls certs are derived from k8s secrets.
*/}}

{{- define "appdynamics-otel-collector.valueTLSVolume" -}}
{{- if or .Values.global.tls.otelReceiver.secret .Values.global.tls.otelExporter.secret }}
volumeMounts:
{{- with  .Values.global.tls.otelReceiver.secret}}
{{ $path := .path | default "/etc/otel/certs/receiver"}}
- name: tlsotelreceiversecrets
  mountPath: {{$path}}
{{- end}}
{{- with  .Values.global.tls.otelExporter.secret}}
{{ $path := .path | default "/etc/otel/certs/exporter"}}
- name: tlsotelexportersecrets
  mountPath: {{$path}}
{{- end}}

volumes:
{{- with  .Values.global.tls.otelReceiver.secret}}
- name: tlsotelreceiversecrets
{{- (include "appdynamics-otel-collector.secrets" .)  | nindent 2}}
{{- end}}
{{- with .Values.global.tls.otelExporter.secret}}
- name: tlsotelexportersecrets
{{- (include "appdynamics-otel-collector.secrets" .)  | nindent 2}}
{{- end}}
{{- end}}
{{- end}}

{{/*
  Generate tls cert paths from  volume mounts dervied from secrets
*/}}
{{- define "appdynamics-otel-collector.tlsConfigFromSecrets" -}}
{{- with .Values.global.tls.otelReceiver}}
receivers:
  otlp:
    protocols:
      grpc:
        tls:
{{- (include "appdynamics-otel-collector.serverDefaultPaths" .)  | nindent 10}}
      http:
        tls:
{{- (include "appdynamics-otel-collector.serverDefaultPaths" .)  | nindent 10}}
  otlp/lca:
    protocols:
      grpc:
        tls:
{{- (include "appdynamics-otel-collector.serverDefaultPaths" .)  | nindent 10}}
      http:
        tls:
{{- (include "appdynamics-otel-collector.serverDefaultPaths" .)  | nindent 10}}
{{- end }}
{{- with .Values.global.tls.otelExporter.secret }}
extensions:
  oauth2client:
    tls:
{{- (include "appdynamics-otel-collector.clientDefaultPaths" .)  | nindent 6}}
exporters:
  otlphttp:
    tls:
{{- (include "appdynamics-otel-collector.clientDefaultPaths" .)  | nindent 6}}
{{- end }}
{{- end }}

{{/*
  Auto generated otel collector configs. We need to compute memoryLimiter config from spec, thus we defined to template variable
   var1 - global scope
   var2 - computed spec
*/}}
{{- define "appdynamics-otel-collector.autoValueConfig" -}}
{{- $otelConfig := tpl (get .var1.Values "config" | deepCopy | toYaml) .var1 | fromYaml}}
{{- $mergedConfig := mustMergeOverwrite $otelConfig (include "appdynamics-otel-collector.derivedConfig" .var1 | fromYaml )}}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.tlsConfigFromSecrets" .var1 | fromYaml ) }}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.tlsConfig" .var1 | fromYaml ) }}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.memoryLimiter" .var2.resources.limits | fromYaml ) }}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.selfTelemetry" .var1 | fromYaml ) }}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.traceContextPropagation" .var1 | fromYaml ) }}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.chartInfo" .var1 | fromYaml ) }}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.nonAppDTransformConfig" .var1 | fromYaml ) }}
{{- $mergedConfig := tpl ($mergedConfig | toYaml) .var1 | fromYaml }}
{{- if .var1.Values.configOverride }}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (deepCopy .var1.Values.configOverride)}}
{{- end }}
{{- toYaml $mergedConfig }}
{{- end }}


{{/*
  convert config map to yaml multiline string
*/}}
{{- define "appdynamics-otel-collector.configToYamlString" -}}
config: |-
{{- . | toYaml | nindent 2 }}
{{- end }}

{{/*
   Basic spec. Combine the sections into spec.
*/}}
{{- define "appdynamics-otel-collector.spec" -}}
{{- $spec := .Values.spec | deepCopy }}
{{- $spec := include "appdynamics-otel-collector.appendEnv" . | fromYaml | deepCopy | mustMergeOverwrite $spec }}
{{- $spec := include "appdynamics-otel-collector.valueTLSVolume" . | fromYaml | deepCopy | mustMergeOverwrite $spec }}
{{- $spec := include "appdynamics-otel-collector.valueServiceAccount" . | fromYaml | deepCopy | mustMergeOverwrite $spec }}
{{- $config := include "appdynamics-otel-collector.autoValueConfig" (dict "var1" . "var2" $spec) | deepCopy | fromYaml }}
{{- $spec := include "appdynamics-otel-collector.configToYamlString" $config | fromYaml | deepCopy | mustMergeOverwrite $spec }}
{{- toYaml $spec }}
{{- end }}
