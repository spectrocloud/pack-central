{{- define "appdynamics-otel-collector.sidecar.clientSideBalancing" -}}
{{- if .Values.presets.multi_tier.sidecar.client_side_loadbalancing }}
exporters:
  otlp:
    endpoint: dns:///appdynamics-otel-collector-service-headless.{{.Release.Namespace}}.svc.cluster.local:4317
    balancer_name: round_robin
    tls:
      insecure: true
{{- end }}
{{- end }}

{{- define "appdynamics-otel-collector.sidecar.selfTelemetryOverride" -}}
{{- if .Values.selfTelemetry }}
processors:
  batch/self:
    send_batch_size: 100
    timeout: 1s
service:
  pipelines:
    metrics/self:
      exporters: [otlp]
{{- end }}
{{- end }}

{{- define "appdynamics-otel-collector.sidecar.autoValueConfig" -}}
{{- $mergedConfig := tpl (get .var1.Values.presets.multi_tier.sidecar "config" | deepCopy | toYaml) .var1 | fromYaml}}
{{- if eq .var1.Values.presets.presampler.deploy_mode "sidecar"}}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.presampler" .var1 | fromYaml )}}
{{- end }}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.samplerdebug" .var1 | fromYaml )}}
{{- $deploy_mode := split "_" .var1.Values.presets.tailsampler.deploy_mode }}
{{- if and .var1.Values.presets.tailsampler.enable (eq $deploy_mode._0 "sidecar")}}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.tailsampler.loadbalancing" .var1 | fromYaml )}}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.tailsampler.tlsConfig.loadbalancing" .var1 | fromYaml )}}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.tailsampler.tlsConfigFromSecrets.loadbalancing" .var1 | fromYaml )}}
{{- end }}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.memoryLimiter" .var2.resources.limits | fromYaml ) }}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.selfTelemetry" (dict "var1" .var1 "var2" "appd-otel-col-sidecar") | fromYaml ) }}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.sidecar.selfTelemetryOverride" .var1 | fromYaml ) }}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.traceContextPropagation" .var1 | fromYaml ) }}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.chartInfo" .var1 | fromYaml ) }}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.sidecar.clientSideBalancing" .var1 | fromYaml ) }}
{{- $mergedConfig := tpl ($mergedConfig | toYaml) .var1 | fromYaml }}
{{- if .var1.Values.presets.multi_tier.sidecar.configOverride }}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (deepCopy .var1.Values.presets.multi_tier.sidecar.configOverride)}}
{{- end }}
{{- toYaml $mergedConfig }}
{{- end }}

{{- define "appdynamics-otel-collector.sidecar.spec" -}}
{{- $spec := .Values.presets.multi_tier.sidecar.spec | deepCopy }}
{{- $spec := include "appdynamics-otel-collector.valueTLSVolume" . | fromYaml | deepCopy | mustMergeOverwrite $spec }}
{{- $spec := include "appdynamics-otel-collector.valueServiceAccount" . | fromYaml | deepCopy | mustMergeOverwrite $spec }}
{{- $config := include "appdynamics-otel-collector.sidecar.autoValueConfig" (dict "var1" . "var2" $spec) | deepCopy | fromYaml }}
{{- $spec := include "appdynamics-otel-collector.selfTelemetry.spec" . | fromYaml | deepCopy | mustMergeOverwrite $spec }}
{{- $spec := include "appdynamics-otel-collector.configToYamlString" $config | fromYaml | deepCopy | mustMergeOverwrite $spec }}
{{- toYaml $spec }}
{{- end }}

{{- define "appdynamics-otel-collector.sidecar.linux.spec" -}}
{{- $spec := (include "appdynamics-otel-collector.sidecar.spec" . | fromYaml) }}
{{- if .Values.presets.multi_tier.sidecar.env.linux.spec -}}
{{- $spec := .Values.presets.multi_tier.sidecar.env.linux.spec | deepCopy | mustMergeOverwrite $spec }}
{{- end }}
{{- toYaml $spec }}
{{- end }}

{{- define "appdynamics-otel-collector.sidecar.windows.spec" -}}
{{- $spec := (include "appdynamics-otel-collector.sidecar.spec" . | fromYaml) }}
{{- if .Values.presets.multi_tier.sidecar.env.windows.spec -}}
{{- $spec := .Values.presets.multi_tier.sidecar.env.windows.spec | deepCopy | mustMergeOverwrite $spec }}
{{- end }}
{{- toYaml $spec }}
{{- end }}