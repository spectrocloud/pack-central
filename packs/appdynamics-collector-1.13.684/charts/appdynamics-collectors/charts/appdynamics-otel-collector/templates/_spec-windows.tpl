{{/*
  daemonset windows config
  @param .var1 global scope
  @param .var2 computed spec
*/}}
{{- define "appdynamics-otel-collector-daemonset-windows.autoValueConfig" -}}
{{- $mergedConfig :=  (include "appdynamics-otel-collector-daemonset.autoValueConfig" . | fromYaml ) }}
{{- with .var1.Values.env.windows.configOverride }}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (deepCopy .) }}
{{- end }}
{{- with ((.var1.Values.env.windows.mode).daemonset).configOverride }}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (deepCopy .) }}
{{- end }}
{{- toYaml $mergedConfig }}
{{- end }}


{{/*
  daemonset windows spec
*/}}
{{- define "appdynamics-otel-collector-daemonset-windows.spec" -}}
{{- $spec := include "appdynamics-otel-collector-daemonset.spec" . | fromYaml }}
{{- if .Values.env.windows.spec -}}
{{- $spec := .Values.env.windows.spec | deepCopy | mustMergeOverwrite $spec }}
{{- end }}
{{- with ((.Values.env.windows.mode).daemonset).spec }}
{{- $spec := . | deepCopy | mustMergeOverwrite $spec }}
{{- end }}
{{- $config := (include "appdynamics-otel-collector-daemonset-windows.autoValueConfig" (dict "var1" . "var2" $spec)) | deepCopy | fromYaml }}
{{- $spec := include "appdynamics-otel-collector.configToYamlString" $config | fromYaml | deepCopy | mustMergeOverwrite $spec }}
{{- toYaml $spec }}
{{- end }}


{{/*
  statefulset windows config
  @param .var1 global scope
  @param .var2 computed spec
*/}}
{{- define "appdynamics-otel-collector-statefulset-windows.autoValueConfig" -}}
{{- $mergedConfig :=  (include "appdynamics-otel-collector-statefulset.autoValueConfig" . | fromYaml ) }}
{{- with .var1.Values.env.windows.configOverride }}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (deepCopy .) }}
{{- end }}
{{- with ((.var1.Values.env.windows.mode).statefulset).configOverride }}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (deepCopy .) }}
{{- end }}
{{- toYaml $mergedConfig }}
{{- end }}

{{/*
  statefulset windows spec
*/}}
{{- define "appdynamics-otel-collector-statefulset-windows.spec" -}}
{{- $spec := (include "appdynamics-otel-collector-statefulset.spec" . | fromYaml) }}
{{- $config := include "appdynamics-otel-collector-statefulset-windows.autoValueConfig" (dict "var1" . "var2" $spec) | deepCopy | fromYaml }}
{{- $spec := include "appdynamics-otel-collector.configToYamlString" $config | fromYaml | deepCopy | mustMergeOverwrite $spec }}
{{- if .Values.env.windows.spec -}}
{{- $spec := .Values.env.windows.spec | deepCopy | mustMergeOverwrite $spec }}
{{- end }}
{{- with ((.Values.env.windows.mode).statefulset).spec }}
{{- $spec := . | deepCopy | mustMergeOverwrite $spec }}
{{- end }}
{{- toYaml $spec }}
{{- end }}