{{/*
  Derived configuation from top level properties
*/}}
{{/*
  downward api environment variable
  https://kubernetes.io/docs/concepts/workloads/pods/downward-api/
  params
  envName - environment variable name
  path - field path
*/}}
{{- define "appdynamics-otel-collector.downwardEnvVar" -}}
name: {{.envName}}
valueFrom:
  fieldRef:
    fieldPath: {{.path}}
{{- end }}

{{- define "appdynamics-otel-collector.derivedOAuth" -}}
client_id: {{required ".clientId is required" .Values.clientId}}
token_url: {{required ".tokenUrl is required" .Values.tokenUrl}}
{{- if .Values.clientSecret }}
client_secret: {{ .Values.clientSecret }}
{{- else if .Values.clientSecretEnvVar }}
client_secret: "${APPD_OTELCOL_CLIENT_SECRET}"
{{- else if .Values.clientSecretVolume }}
client_secret: {{ (include "appdynamics-otel-collector.clientSecretVolumePath" .Values.clientSecretVolume) | toYaml }}
{{- end }}
{{- end }}

{{- define "appdynamics-otel-collector.derivedConfig" -}}
extensions:
  oauth2client:
{{- (include "appdynamics-otel-collector.derivedOAuth" .) | nindent 4}}
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

{{- define "appdynamics-otel-collector.agentManagement" -}}
{{- if or .Values.agentManagement .Values.agentManagementSelfTelemetry }}
extensions:
  appdagentmanagementextension:
    service_url: {{ substr 0 (int (sub (len .Values.endpoint) (len "/data"))) .Values.endpoint}}/rest/agent/service
    agent_descriptor_type: "otel_collector"
    agent_namespace: "otelcollector"
    agent_name: {{.Release.Name}}
    node_config:
      node_name: "$NODE_NAME"
    disable_opamp: {{.Values.disableOpamp}}
    oauth:
    {{- (include "appdynamics-otel-collector.derivedOAuth" .) | nindent 6}}
    {{/* tenant id extracted from token url*/}}
    {{- if .Values.tenantId }}
      tenant_id: {{ .Values.tenantId }}
    {{- else }}
    {{- $authTenantId := (regexFind "\\/auth\\/[0-9a-z\\-]{36}" .Values.tokenUrl) -}}
    {{- if eq (len $authTenantId) (add (len "/auth/") 36) }}
      tenant_id: {{ substr (len "/auth/") (len $authTenantId) $authTenantId }}
    {{- else }}
    {{- required "Please provide tenantId." "" }}
    {{- end }}
    {{- end }}
    platform:
      id: {{ (include "appdynamics-otel-collector.clusterId" .) | quote}}
      name: {{ .Values.global.clusterName | default "" }}
      type: k8s
    deployment:
      scope: {{ .Release.Namespace }}
      unit: "${POD_NAME}"
service:
  extensions: [health_check, oauth2client, appdagentmanagementextension]
{{- end }}
{{- end }}

{{- define "appdynamics-otel-collector.agentManagementSelfTelemetry" -}}
{{- if .Values.agentManagementSelfTelemetry }}
receivers:
  prometheus/self:
    config:
      scrape_configs:
        - job_name: {{ .Values.selfTelemetryServiceName | default "appd-otel-collector" | quote }}
          scrape_interval: 60s
          static_configs:
            - targets: ["localhost:8888"]

processors:
  batch/self:
  agentmanagementresource:
    appd_agent_management_ext: appdagentmanagementextension
    resource:
      "service.name": ""
      "service.instance.id": ""
      "net.host.port": ""
      "http.scheme": ""
      "telemetry.sdk.name": opentelemetry
      "service_name": ""
      "service_instance_id": ""
      "service_version": ""

service:
  pipelines:
    metrics/agent_management_self_telemetry:
      receivers: [prometheus/self]
      processors: [memory_limiter, agentmanagementresource, batch/self]
      exporters: [otlphttp]
{{- end }}
{{- end }}

{{- define "appdynamics-otel-collector.networkMonitoring" -}}
receivers:
  otlp/ebpf:
    protocols:
      grpc:
        endpoint: 0.0.0.0:24317
      http:
        endpoint: 0.0.0.0:24318
processors:
  resource/ebpf:
    attributes:
      - key: telemetry.sdk.name
        value: agent:otelnet_collector:collector
        action: upsert
      - key: netperf.platform.id
        action: upsert
        value: {{ include "appdynamics-otel-collector.clusterId" . | quote}}
      - key: netperf.platform.type
        action: upsert
        value: k8s
  filter/ebpf:
    metrics:
      metric:
        - 'not (HasAttrOnDatapoint("source.resolution_type", "K8S_CONTAINER") or HasAttrOnDatapoint("dest.resolution_type", "K8S_CONTAINER"))'
  metricstransform/ebpf:
    transforms:
      - include: tcp.bytes
        action: insert
        new_name: dummy.endpoint.bytes
        operations:
          - action: update_label
            label: source.workload.name
            new_label: source.endpoint.name
      - include: udp.bytes
        action: insert
        new_name: dummy.endpoint.bytes
        operations:
          - action: update_label
            label: source.workload.name
            new_label: source.endpoint.name
  attributes/ebpf:
    actions:
      - key: source.availability_zone
        action: delete
      - key: dest.availability_zone
        action: delete
      - key: az_equal
        action: delete
      - key: sf_product
        action: delete
      - key: source.environment
        action: delete
      - key: dest.environment
        action: delete
service:
  pipelines:
    metrics/ebpf:
      receivers: [otlp/ebpf]
      processors: [memory_limiter, resource/ebpf, filter/ebpf, metricstransform/ebpf, attributes/ebpf, batch/metrics]
      exporters: [otlphttp]
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
        - set(attributes["k8s.cluster.id"], {{ (include "appdynamics-otel-collector.clusterId" .) | quote}})
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
{{- $specEnv = append $specEnv (include "appdynamics-otel-collector.downwardEnvVar" (dict "envName" "POD_UID" "path" "metadata.uid") | fromYaml ) }}
{{- end}}
{{- if .Values.clientSecretEnvVar -}}
{{- $specEnv = append $specEnv (include "appdynamics-otel-collector.clientSecretEnvVar" . | fromYaml ) }}
{{- end }}

{{- $specEnv = append $specEnv  (include "appdynamics-otel-collector.downwardEnvVar" (dict "envName" "NODE_NAME" "path" "spec.nodeName") | fromYaml)}}
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
{{- end }}
{{- end }}

{{- define "appdynamics-otel-collector.clientDefaultPaths" -}}
{{ $path := .path | default "/etc/otel/certs/exporter"}}
{{- if .secretKeys.caCert}}
ca_file: {{$path}}/{{.secretKeys.caCert}}
{{- end }}
cert_file: {{$path}}/{{.secretKeys.tlsCert}}
key_file: {{$path}}/{{.secretKeys.tlsKey}}
{{- end }}

{{- define "appdynamics-otel-collector.clientSecretVolumePath" -}}
{{- $path := .path | default "/etc/otel/oauth/secret" -}}
${file:{{$path}}/{{.secretKey}}}
{{- end }}

{{- define "appdynamics-otel-collector.tlsSecrets" -}}
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

{{- define "appdynamics-otel-collector.clientSecret" -}}
secret:
  secretName: {{.secretName}}
  items:
  - key: {{.secretKey}}
    path: {{.secretKey}}
{{- end }}

{{/*
  calculate volume mounts for tls secret and client secret
*/}}
{{- define "appdynamics-otel-collector.valuesVolume" -}}
{{- if or .Values.clientSecretVolume (or .Values.global.tls.otelReceiver.secret .Values.global.tls.otelExporter.secret)}}
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
{{- with  .Values.clientSecretVolume}}
{{ $path := .path | default "/etc/otel/oauth/secret"}}
- name: clientsecret
  mountPath: {{$path}}
{{- end }}

volumes:
{{- with  .Values.global.tls.otelReceiver.secret}}
- name: tlsotelreceiversecrets
{{- (include "appdynamics-otel-collector.tlsSecrets" .)  | nindent 2}}
{{- end }}
{{- with .Values.global.tls.otelExporter.secret}}
- name: tlsotelexportersecrets
{{- (include "appdynamics-otel-collector.tlsSecrets" .)  | nindent 2}}
{{- end }}
{{- with .Values.clientSecretVolume}}
- name: clientsecret
{{- (include "appdynamics-otel-collector.clientSecret" .)  | nindent 2}}
{{- end }}

{{- end }}
{{- end }}

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

{{- define "appdynamics-otel-collector.truncated" -}}
processors:
  transform/truncate:
    error_mode: ignore
    trace_statements:
  {{- if .Values.presets.truncated.trace.span }}
    - context: span
      statements:
        - truncate_all(attributes, {{.Values.presets.truncated.trace.span}})
  {{- end }}
  {{- if .Values.presets.truncated.trace.spanevent }}
    - context: spanevent
      statements:
      - truncate_all(attributes, {{.Values.presets.truncated.trace.spanevent}})
  {{- end }}
  {{- if .Values.presets.truncated.trace.resource }}
    - context: resource
      statements:
      - truncate_all(attributes, {{.Values.presets.truncated.trace.resource}})
  {{- end }}
  {{- if .Values.presets.truncated.trace.scope }}
    - context: scope
      statements:
        - truncate_all(attributes, {{.Values.presets.truncated.trace.scope}})
  {{- end }}
    metric_statements:
  {{- if .Values.presets.truncated.metric.resource }}
    - context: resource
      statements:
        - truncate_all(attributes, {{.Values.presets.truncated.metric.resource}})
  {{- end }}
  {{- if .Values.presets.truncated.metric.scope }}
    - context: scope
      statements:
        - truncate_all(attributes, {{.Values.presets.truncated.metric.scope}})
  {{- end }}
  {{- if .Values.presets.truncated.metric.datapoint }}
    - context: datapoint
      statements:
        - truncate_all(attributes, {{.Values.presets.truncated.metric.datapoint}})
  {{- end }}
    log_statements:  
  {{- if .Values.presets.truncated.log.resource }}
    - context: resource
      statements:
        - truncate_all(attributes, {{.Values.presets.truncated.log.resource}})
  {{- end }}
  {{- if .Values.presets.truncated.log.scope }}
    - context: scope
      statements:
        - truncate_all(attributes, {{.Values.presets.truncated.log.scope}})
  {{- end }}
  {{- if .Values.presets.truncated.log.log }}
    - context: log
      statements:
        - truncate_all(attributes, {{.Values.presets.truncated.log.log}})
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
{{- if eq .var1.Values.presets.presampler.deploy_mode "gateway"}}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.presampler" .var1 | fromYaml )}}
{{- end }}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.samplerdebug" .var1 | fromYaml )}}

{{- $deploy_mode := split "_" .var1.Values.presets.tailsampler.deploy_mode }}
{{- if and .var1.Values.presets.tailsampler.enable (eq $deploy_mode._0 "gateway")}}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.tailsampler.loadbalancing" .var1 | fromYaml )}}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.tailsampler.tlsConfig.loadbalancing" .var1 | fromYaml )}}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.tailsampler.tlsConfigFromSecrets.loadbalancing" .var1 | fromYaml )}}
{{- end }}

{{- if and .var1.Values.presets.tailsampler.enable (eq $deploy_mode._1 "gateway")}}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.tailsampler.sampler" .var1 | fromYaml )}}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.tailsampler.tlsConfig.tracegrouping" .var1 | fromYaml )}}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.tailsampler.tlsConfigFromSecrets.tracegrouping" .var1 | fromYaml )}}
{{- end }}

{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.tlsConfigFromSecrets" .var1 | fromYaml ) }}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.tlsConfig" .var1 | fromYaml ) }}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.memoryLimiter" .var2.resources.limits | fromYaml ) }}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.truncated" .var1 | fromYaml ) }}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.selfTelemetry" .var1 | fromYaml ) }}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.agentManagement" .var1 | fromYaml ) }}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.agentManagementSelfTelemetry" .var1 | fromYaml ) }}
{{- if .var1.Values.enableNetworkMonitoring }}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.networkMonitoring" .var1 | fromYaml ) }}
{{- end }}
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

{{- define "appdynamics-otel-collector.selfTelemetry.spec" -}}
#{{- if .Values.selfTelemetry }}
#args:
#  "feature-gates": "telemetry.useOtelForInternalMetrics,telemetry.useOtelWithSDKConfigurationForInternalTelemetry"
{{- end }}
{{- end }}

{{/*
   Basic spec. Combine the sections into spec.
*/}}
{{- define "appdynamics-otel-collector.spec" -}}
{{- $spec := .Values.spec | deepCopy }}
{{- $spec := include "appdynamics-otel-collector.appendEnv" . | fromYaml | deepCopy | mustMergeOverwrite $spec }}
{{- $spec := include "appdynamics-otel-collector.valuesVolume" . | fromYaml | deepCopy | mustMergeOverwrite $spec }}
{{- $spec := include "appdynamics-otel-collector.valueServiceAccount" . | fromYaml | deepCopy | mustMergeOverwrite $spec }}
{{- $spec := include "appdynamics-otel-collector.selfTelemetry.spec" . | fromYaml | deepCopy | mustMergeOverwrite $spec }}
{{- $config := include "appdynamics-otel-collector.autoValueConfig" (dict "var1" . "var2" $spec) | deepCopy | fromYaml }}
{{- $spec := include "appdynamics-otel-collector.configToYamlString" $config | fromYaml | deepCopy | mustMergeOverwrite $spec }}
{{- toYaml $spec }}
{{- end }}
