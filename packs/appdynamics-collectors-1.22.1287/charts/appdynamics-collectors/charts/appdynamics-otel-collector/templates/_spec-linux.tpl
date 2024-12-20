{{/*
  daemonset linux config
  var1 - global scope
  var2 - computed spec
*/}}
{{- define "appdynamics-otel-collector-daemonset-linux.autoValueConfig" -}}
{{- $mergedConfig :=  (include "appdynamics-otel-collector-daemonset.autoValueConfig" . | fromYaml ) }}
{{- $mergedConfig :=  mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.agentManagementNameConfig" (dict "name" (include "appdynamics-otel-collector.daemonset.fullname" .var1) "var1" .var1) | fromYaml ) }}
{{- with .var1.Values.env.linux.configOverride }}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (deepCopy .) }}
{{- end }}
{{- with ((.var1.Values.env.linux.mode).daemonset).configOverride }}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (deepCopy .) }}
{{- end }}
{{- toYaml $mergedConfig }}
{{- end }}


{{/*
  daemonset linux spec
*/}}
{{- define "appdynamics-otel-collector-daemonset-linux.spec" -}}
{{- $spec := (include "appdynamics-otel-collector-daemonset.spec" . | fromYaml) }}
{{- if .Values.env.linux.spec -}}
{{- $spec := .Values.env.linux.spec | deepCopy | mustMergeOverwrite $spec }}
{{- end }}
{{- with ((.Values.env.linux.mode).daemonset).spec }}
{{- $spec := . | deepCopy | mustMergeOverwrite $spec }}
{{- end }}
{{- $spec := include "appdynamics-otel-collector.appendGoMemLimitEnv" (dict "spec" $spec "Values" .Values) | fromYaml | deepCopy | mustMergeOverwrite $spec }}
{{- $config := include "appdynamics-otel-collector-daemonset-linux.autoValueConfig" (dict "var1" . "var2" $spec) | deepCopy | fromYaml }}
{{- $spec := include "appdynamics-otel-collector.configToYamlString" $config | fromYaml | deepCopy | mustMergeOverwrite $spec }}
{{- toYaml $spec }}
{{- end }}


{{/*
  statefulset linux config
  var1 - global scope
  var2 - computed spec
*/}}
{{- define "appdynamics-otel-collector-statefulset-linux.autoValueConfig" -}}
{{- $mergedConfig :=  (include "appdynamics-otel-collector-statefulset.autoValueConfig" . | fromYaml ) }}
{{- $mergedConfig :=  mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.agentManagementNameConfig" (dict "name" (include "appdynamics-otel-collector.statefulset.fullname"  .var1) "var1" .var1) | fromYaml ) }}
{{- with .var1.Values.env.linux.configOverride }}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (deepCopy .) }}
{{- end }}
{{- with ((.var1.Values.env.linux.mode).statefulset).configOverride }}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (deepCopy .) }}
{{- end }}
{{- toYaml $mergedConfig }}
{{- end }}

{{/*
  statefulset linux spec
*/}}
{{- define "appdynamics-otel-collector-statefulset-linux.spec" -}}
{{- $spec := (include "appdynamics-otel-collector-statefulset.spec" . | fromYaml) }}
{{- $config := include "appdynamics-otel-collector-statefulset-linux.autoValueConfig" (dict "var1" . "var2" $spec) | deepCopy | fromYaml }}
{{- $spec := include "appdynamics-otel-collector.configToYamlString" $config | fromYaml | deepCopy | mustMergeOverwrite $spec }}
{{- if .Values.env.linux.spec -}}
{{- $spec := .Values.env.linux.spec | deepCopy | mustMergeOverwrite $spec }}
{{- end }}
{{- with ((.Values.env.linux.mode).statefulset).spec }}
{{- $spec := . | deepCopy | mustMergeOverwrite $spec }}
{{- end }}
{{- $spec := include "appdynamics-otel-collector.appendGoMemLimitEnv" (dict "spec" $spec "Values" .Values) | fromYaml | deepCopy | mustMergeOverwrite $spec }}
{{- toYaml $spec }}
{{- end }}