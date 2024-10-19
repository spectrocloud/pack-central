{{/*
Expand the name of the chart.
*/}}
{{- define "appdynamics-otel-collector.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
 Create a default fully qualified app name.
 We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
 If release name contains chart name it will be used as a full name.
*/}}
{{- define "appdynamics-otel-collector.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
 Create a default fully qualified app name.
 We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
 If release name contains chart name it will be used as a full name.
*/}}
{{- define "appdynamics-otel-collector.deployFullname" -}}
{{- if .var1.Values.fullnameOverride }}
{{- printf "%s%s-%s" .var1.Values.fullnameOverride .os .type | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .var1.Chart.Name .var1.Values.nameOverride }}
{{- if contains $name .var1.Release.Name }}
{{- printf "%s%s-%s" .var1.Release.Name .os .type | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s%s-%s-%s" .var1.Release.Name .os .type $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
  Create a default fully qualified app name for linux daemonset gateway.
  */}}
{{- define "appdynamics-otel-collector.daemonset.fullname" -}}
{{ include "appdynamics-otel-collector.deployFullname" (dict "var1" . "os" "" "type" "ds") | trunc 42 | trimSuffix "-" }}
{{- end }}

{{/*
  Create a default fully qualified app name for daemonset gateway.
  */}}
{{- define "appdynamics-otel-collector.daemonset.windows.fullname" -}}
{{ include "appdynamics-otel-collector.deployFullname" (dict "var1" . "os" "-win" "type" "ds") | trunc 42 | trimSuffix "-" }}
{{- end }}


{{/*
  Create a default fully qualified app name for linux statefulset gateway.
  */}}
{{- define "appdynamics-otel-collector.statefulset.fullname" -}}
{{ include "appdynamics-otel-collector.deployFullname" (dict "var1" . "os" "" "type" "ss") | trunc 42 | trimSuffix "-" }}
{{- end }}

{{/*
  Create a default fully qualified app name for statefulset gateway.
  */}}
{{- define "appdynamics-otel-collector.statefulset.windows.fullname" -}}
{{ include "appdynamics-otel-collector.deployFullname" (dict "var1" . "os" "-win" "type" "ss") | trunc 42 | trimSuffix "-" }}
{{- end }}

{{/*
 Create a default fully qualified app name for linux sampler.
*/}}
{{- define "appdynamics-otel-collector.tailsampler.fullname" -}}
{{ include "appdynamics-otel-collector.deployFullname" (dict "var1" . "os" "" "type" "ts") | trunc 42 | trimSuffix "-" }}
{{- end }}

{{/*
 Create a default fully qualified app name for windows sampler.
*/}}
{{- define "appdynamics-otel-collector.tailsampler.windows.fullname" -}}
{{ include "appdynamics-otel-collector.deployFullname" (dict "var1" . "os" "-win" "type" "ts") | trunc 42 | trimSuffix "-" }}
{{- end }}

{{/*
  Create a default fully qualified app name for linux sampler.
  */}}
{{- define "appdynamics-otel-collector.sidecar.fullname" -}}
{{ include "appdynamics-otel-collector.deployFullname" (dict "var1" . "os" "" "type" "sc") | trunc 42 | trimSuffix "-" }}
{{- end }}

{{/*
  Create a default fully qualified app name for windows sampler.
  */}}
{{- define "appdynamics-otel-collector.sidecar.windows.fullname" -}}
{{ include "appdynamics-otel-collector.deployFullname" (dict "var1" . "os" "-win" "type" "sc") | trunc 42 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "appdynamics-otel-collector.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
Open telemetry operator assigns recommended labels like "app.kubernetes.io/instance" automatically, to avoid conflict,
we change to to use app.appdynamics.otel.collector.
*/}}
{{- define "appdynamics-otel-collector.labels" -}}
helm.sh/chart: {{ include "appdynamics-otel-collector.chart" . }}
{{- if .Chart.AppVersion }}
app.appdynamics.otel.collector/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.appdynamics.otel.collector/managed-by: Helm
{{- end }}

{{/*
Selector labels for all
*/}}
{{- define "appdynamics-otel-collector.selectorLabels" -}}
app.appdynamics.otel.collector/name: {{ include "appdynamics-otel-collector.name" . }}
app.appdynamics.otel.collector/instance: {{ .Release.Name }}
{{- end }}

{{/*
Selector labels for gateway
*/}}
{{- define "appdynamics-otel-collector.gateway.selectorLabels" -}}
{{- include "appdynamics-otel-collector.selectorLabels" . }}
{{- $deploy_mode := split "_" .Values.presets.tailsampler.deploy_mode }}
{{- if and .Values.presets.tailsampler.enable (eq $deploy_mode._1 "gateway")}}
app.appdynamics.otel.collector/tailsampler: "true"
{{- end }}
app.appdynamics.otel.collector/gateway: "true"
{{- end }}

{{/*
Selector labels for daemonset
*/}}
{{- define "appdynamics-otel-collector.selectorLabelsDaemonset" -}}
{{- include "appdynamics-otel-collector.gateway.selectorLabels" . }}
app.appdynamics.otel.collector/mode: "daemonset"
{{- end }}

{{/*
Selector labels for statefulset
*/}}
{{- define "appdynamics-otel-collector.selectorLabelsStatefulset" -}}
{{- include "appdynamics-otel-collector.gateway.selectorLabels" . }}
app.appdynamics.otel.collector/mode: "statefulset"
{{- end }}

{{/*
Selector labels for sampler
*/}}
{{- define "appdynamics-otel-collector.tailsampler.selectorLabels" -}}
{{- include "appdynamics-otel-collector.selectorLabels" . }}
app.appdynamics.otel.collector/tailsampler: "true"
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "appdynamics-otel-collector.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "appdynamics-otel-collector.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account for target allocator to use
*/}}
{{- define "appdynamics-otel-collector.targetAllocatorServiceAccountName" -}}
{{- if .Values.targetAllocatorServiceAccount.create }}
{{- default (printf "%s%s" (include "appdynamics-otel-collector.fullname" .) "-target-allocator") .Values.targetAllocatorServiceAccount.name }}
{{- else }}
{{- default "default" .Values.targetAllocatorServiceAccount.name }}
{{- end }}
{{- end }}

{{/*
Merge labels from user inputs
*/}}
{{- define "appdynamics-otel-collector.finalLabelsDaemonset" -}}
{{- $labels := fromYaml (include "appdynamics-otel-collector.labels" .) -}}
{{- $labels := (include "appdynamics-otel-collector.selectorLabelsDaemonset" .) | fromYaml | mustMergeOverwrite $labels }}
{{- $labels := mustMergeOverwrite .Values.labels $labels -}}
{{ toYaml $labels }}
{{- end }}

{{/*
Merge labels from user inputs
*/}}
{{- define "appdynamics-otel-collector.finalLabelsStatefulset" -}}
{{- $labels := fromYaml (include "appdynamics-otel-collector.labels" .) -}}
{{- $labels := (include "appdynamics-otel-collector.selectorLabelsStatefulset" .) | fromYaml | mustMergeOverwrite $labels }}
{{- $labels := mustMergeOverwrite .Values.labels $labels -}}
{{ toYaml $labels }}
{{- end }}

{{/*
  Merge labels from user inputs
  */}}
{{- define "appdynamics-otel-collector.tailsampler.finalLabels" -}}
{{- $labels := fromYaml (include "appdynamics-otel-collector.labels" .) -}}
{{- $labels := (include "appdynamics-otel-collector.tailsampler.selectorLabels" .) | fromYaml | mustMergeOverwrite $labels }}
{{- $labels := mustMergeOverwrite $labels .Values.labels  -}}
{{ toYaml $labels }}
{{- end }}

{{/*
Generate agent management k8s deployment naming config
example input - (dict "var1" . "os" "win" "type" "ss")
*/}}
{{- define "appdynamics-otel-collector.agentManagementNameConfig" -}}
{{- if or .var1.Values.agentManagement .var1.Values.agentManagementSelfTelemetry }}
extensions:
  appdagentmanagementextension:
    deployment:
      name: {{.name}}-collector
{{- end }}
{{- end }}

{{- define "appdynamics-otel-collector.agentManagementModeConfig" -}}
{{- if or .var1.Values.agentManagement .var1.Values.agentManagementSelfTelemetry }}
extensions:
  appdagentmanagementextension:
    deployment:
      type: {{.mode}}
{{- end }}
{{- end }}

