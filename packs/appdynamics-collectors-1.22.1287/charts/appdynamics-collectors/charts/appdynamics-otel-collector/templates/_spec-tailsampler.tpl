{{- define "appdynamics-otel-collector.tailsampler.autoValueConfig" -}}
{{- $otelConfig := tpl (get .var1.Values.presets.multi_tier.tailsampler "config" | deepCopy | toYaml) .var1 | fromYaml}}
{{- $mergedConfig := mustMergeOverwrite $otelConfig (include "appdynamics-otel-collector.derivedConfig" .var1 | fromYaml )}}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.samplerdebug" .var1 | fromYaml )}}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.tailsampler.sampler" .var1 | fromYaml )}}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.tailsampler.tlsConfig.tracegrouping" .var1 | fromYaml )}}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.tailsampler.tlsConfigFromSecrets.tracegrouping" .var1 | fromYaml )}}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.memoryLimiter" .var2.resources.limits | fromYaml ) }}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.selfTelemetry" .var1 | fromYaml ) }}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.agentManagement" .var1 | fromYaml ) }}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.agentManagementSelfTelemetry" .var1 | fromYaml ) }}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.traceContextPropagation" .var1 | fromYaml ) }}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.chartInfo" .var1 | fromYaml ) }}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.agentManagementModeConfig" (dict "mode" "deployment" "var1" .var1) | fromYaml ) }}
{{- $mergedConfig := tpl ($mergedConfig | toYaml) .var1 | fromYaml }}
{{- if .var1.Values.presets.multi_tier.tailsampler.configOverride }}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (deepCopy .var1.Values.presets.multi_tier.tailsampler.configOverride)}}
{{- end }}
{{- toYaml $mergedConfig }}
{{- end }}

{{/*
  Set service.ports into spec.ports in the value file.
  If the spec.ports is already set, the service.ports section won't take any effect.
*/}}
{{- define "appdynamics-otel-collector.tailsampler.valueServicePorts" -}}
{{- if not .Values.presets.multi_tier.tailsampler.spec.ports }}
ports:
{{- .Values.presets.tailsampler.service.ports | toYaml | nindent 2}}
{{- end }}
{{- end }}

{{- define "appdynamics-otel-collector.tailsampler.linux.autoValueConfig" -}}
{{- $mergedConfig :=  (include "appdynamics-otel-collector.tailsampler.autoValueConfig" . | fromYaml ) }}
{{- $mergedConfig :=  mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.agentManagementNameConfig" (dict "name" (include "appdynamics-otel-collector.tailsampler.fullname" .var1) "var1" .var1) | fromYaml ) }}
{{- with .var1.Values.presets.multi_tier.tailsampler.env.linux.configOverride }}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (deepCopy .) }}
{{- end }}
{{- toYaml $mergedConfig }}
{{- end }}

{{- define "appdynamics-otel-collector.tailsampler.replicas" -}}
replicas: {{ .Values.presets.tailsampler.replicas }}
{{- end }}

{{- define "appdynamics-otel-collector.tailsampler.spec" -}}
{{- $spec := .Values.presets.multi_tier.tailsampler.spec | deepCopy }}
{{- $spec := include "appdynamics-otel-collector.tailsampler.replicas" . | fromYaml | deepCopy | mustMergeOverwrite $spec }}
{{- $spec := include "appdynamics-otel-collector.appendEnv" . | fromYaml | deepCopy | mustMergeOverwrite $spec }}
{{- $spec := include "appdynamics-otel-collector.valuesVolume" . | fromYaml | deepCopy | mustMergeOverwrite $spec }}
{{- $spec := include "appdynamics-otel-collector.tailsampler.valueServicePorts" . | fromYaml | deepCopy | mustMergeOverwrite $spec }}
{{- $spec := include "appdynamics-otel-collector.valueServiceAccount" . | fromYaml | deepCopy | mustMergeOverwrite $spec }}
{{- $spec := include "appdynamics-otel-collector.selfTelemetry.spec" . | fromYaml | deepCopy | mustMergeOverwrite $spec }}
{{- toYaml $spec }}
{{- end }}

{{- define "appdynamics-otel-collector.tailsampler.linux.spec" -}}
{{- $spec := (include "appdynamics-otel-collector.tailsampler.spec" . | fromYaml) }}
{{- if .Values.presets.multi_tier.tailsampler.env.linux.spec -}}
{{- $spec := .Values.presets.multi_tier.tailsampler.env.linux.spec | deepCopy | mustMergeOverwrite $spec }}
{{- end }}
{{- $spec := include "appdynamics-otel-collector.appendGoMemLimitEnv" (dict "spec" $spec "Values" .Values) | fromYaml | deepCopy | mustMergeOverwrite $spec }}
{{- $config := include "appdynamics-otel-collector.tailsampler.linux.autoValueConfig" (dict "var1" . "var2" $spec) | deepCopy | fromYaml }}
{{- $spec := include "appdynamics-otel-collector.configToYamlString" $config | fromYaml | deepCopy | mustMergeOverwrite $spec }}
{{- toYaml $spec }}
{{- end }}

{{- define "appdynamics-otel-collector.tailsampler.windows.autoValueConfig" -}}
{{- $mergedConfig :=  (include "appdynamics-otel-collector.tailsampler.autoValueConfig" . | fromYaml ) }}
{{- $mergedConfig :=  mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.agentManagementNameConfig" (dict "name" (include "appdynamics-otel-collector.tailsampler.windows.fullname" .var1) "var1" .var1) | fromYaml ) }}
{{- with .var1.Values.presets.multi_tier.tailsampler.env.windows.configOverride }}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (deepCopy .) }}
{{- end }}
{{- toYaml $mergedConfig }}
{{- end }}

{{- define "appdynamics-otel-collector.tailsampler.windows.spec" -}}
{{- $spec := (include "appdynamics-otel-collector.tailsampler.spec" . | fromYaml) }}
{{- if .Values.presets.multi_tier.tailsampler.env.windows.spec -}}
{{- $spec := .Values.presets.multi_tier.tailsampler.env.windows.spec | deepCopy | mustMergeOverwrite $spec }}
{{- end }}
{{- $spec := include "appdynamics-otel-collector.appendGoMemLimitEnv" (dict "spec" $spec "Values" .Values) | fromYaml | deepCopy | mustMergeOverwrite $spec }}
{{- $config := include "appdynamics-otel-collector.tailsampler.windows.autoValueConfig" (dict "var1" . "var2" $spec) | deepCopy | fromYaml }}
{{- $spec := include "appdynamics-otel-collector.configToYamlString" $config | fromYaml | deepCopy | mustMergeOverwrite $spec }}
{{- toYaml $spec }}
{{- end }}