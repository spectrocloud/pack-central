{{- define "appdynamics-otel-collector.tailsampler.loadbalancing" -}}
processors:
  batch/traces:
    send_batch_size: 100 # too large size very impact loadbalancing exporter performance
exporters:
  loadbalancing:
    routing_key: "traceID"
    protocol:
      otlp:
        compression: none
        tls:
          insecure: true
        retry_on_failure:
          max_interval: 5s
    resolver:
      k8s:
        service: {{ .Values.presets.tailsampler.service.name -}}.{{ include "appdynamics-otel-collector.namespace" .}}
        ports: [24317]
service:
  pipelines:
    traces:
      exporters: [loadbalancing]
{{- end}}

{{- define "appdynamics-otel-collector.tailsampler.sampler" -}}
receivers:
  otlp/groupedtraces:
    protocols:
      grpc:
        endpoint: 0.0.0.0:24317
      http:
        endpoint: 0.0.0.0:24318
processors:
{{- $deploy_mode := split "_" .Values.presets.tailsampler.deploy_mode }}
{{- if eq $deploy_mode._0 "sidecar" }}
  k8sattributes:
    passthrough: false
{{- end}}
  trace_classification_and_sampling:
{{- .Values.presets.tailsampler.trace_classification_and_sampling | toYaml | nindent 4 }}
  consistent_proportional_sampler:
{{- .Values.presets.tailsampler.consistent_proportional_sampler | toYaml | nindent 4 }}
  groupbyattrs/compact:
  groupbytrace:
{{- .Values.presets.tailsampler.groupbytrace | toYaml | nindent 4 }}
  intermediate_sampler:
{{- .Values.presets.tailsampler.intermediate_sampler | toYaml | nindent 4 }}

service:
  pipelines:
    traces/sampler:
      receivers: [otlp/groupedtraces]
      processors:
{{- if eq $deploy_mode._0 "sidecar" }}
{{- .Values.presets.tailsampler.pipeline_sidecar_loadbalancer | toYaml | nindent 8}}
{{- else }}
{{- .Values.presets.tailsampler.pipeline | toYaml | nindent 8}}
{{- end}}
      exporters: [otlphttp]
{{- end}}

{{- define "appdynamics-otel-collector.tailsampler.tlsConfig.loadbalancing" -}}
{{- if .Values.global.tls.otelExporter.settings }}
exporters:
  loadbalancing:
    protocol:
      otlp:
        compression: none
        tls:
{{- deepCopy .Values.global.tls.otelExporter.settings | toYaml | nindent 10}}
{{- end}}
{{- end}}

{{- define "appdynamics-otel-collector.tailsampler.tlsConfig.tracegrouping" -}}
{{- if .Values.global.tls.otelReceiver.settings }}
receivers:
  otlp/groupedtraces:
    protocols:
      grpc:
        tls:
{{- deepCopy .Values.global.tls.otelReceiver.settings | toYaml | nindent 10}}
      http:
        tls:
{{- deepCopy .Values.global.tls.otelReceiver.settings | toYaml | nindent 10}}
{{- end}}
{{- end}}

{{- define "appdynamics-otel-collector.tailsampler.samplingLoadBalancerDefaultPaths" -}}
{{- if .secret }}
{{ $path := .path | default "/etc/otel/certs/receiver"}}
{{- if .secret.secretKeys.caCert}}
ca_file: {{$path}}/{{.secret.secretKeys.caCert}}
{{- end}}
cert_file: {{$path}}/{{.secret.secretKeys.tlsCert}}
key_file: {{$path}}/{{.secret.secretKeys.tlsKey}}
{{- end}}
{{- end}}

{{- define "appdynamics-otel-collector.tailsampler.tlsConfigFromSecrets.loadbalancing" -}}
{{- with .Values.global.tls.otelReceiver}}
{{- if .secret }}
exporters:
  loadbalancing:
    protocol:
      otlp:
        tls:
{{- (include "appdynamics-otel-collector.tailsampler.samplingLoadBalancerDefaultPaths" .)  | nindent 10}}
          insecure_skip_verify: true
          insecure: false
{{- end}}
{{- end}}
{{- end}}


{{- define "appdynamics-otel-collector.tailsampler.tlsConfigFromSecrets.tracegrouping" -}}
{{- with .Values.global.tls.otelReceiver}}
receivers:
  otlp/groupedtraces:
    protocols:
      grpc:
        tls:
{{- (include "appdynamics-otel-collector.serverDefaultPaths" .)  | nindent 10}}
      http:
        tls:
{{- (include "appdynamics-otel-collector.serverDefaultPaths" .)  | nindent 10}}
{{- end}}
{{- end}}

{{- define "appdynamics-otel-collector.presampler" -}}
{{- if .Values.presets.presampler.enable }}
processors:
  consistent_proportional_sampler/presampler:
{{- .Values.presets.presampler.consistent_proportional_sampler | toYaml | nindent 4 }}
  consistent_sampler/presampler:
{{- .Values.presets.presampler.consistent_sampler | toYaml | nindent 4 }}
service:
  pipelines:
    traces:
      processors:
{{- if eq .Values.presets.presampler.deploy_mode "gateway"}}
{{- .Values.presets.presampler.pipeline | toYaml | nindent 8}}
{{- else }}
{{- .Values.presets.presampler.pipeline_sidecar | toYaml | nindent 8}}
{{- end }}
{{- end }}
{{- end }}

{{- define "appdynamics-otel-collector.samplerdebug" -}}
{{- if .Values.presets.samplerDebug.enable }}
{{- .Values.presets.samplerDebug.config | toYaml }}
{{- end }}
{{- end }}
