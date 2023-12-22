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
 Create a default fully qualified app name for daemonset linux.
 We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
 If release name contains chart name it will be used as a full name.
*/}}
{{- define "appdynamics-otel-collector-daemonset.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- printf "%s-ds" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-ds-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
 Create a default fully qualified app name for statefulset linux.
 We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
 If release name contains chart name it will be used as a full name.
*/}}
{{- define "appdynamics-otel-collector-statefulset.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- printf "%s-ss" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-ss-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
 Create a default fully qualified app name for windows daemonset. Add windows suffix to release name.
*/}}
{{- define "appdynamics-otel-collector-daemonset-windows.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- printf "$s-ds-win" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-ds-win-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
 Create a default fully qualified app name for windows statefulset. Add windows suffix to release name.
*/}}
{{- define "appdynamics-otel-collector-statefulset-windows.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- printf "$s-ss-win" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-ss-win-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
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
app.appdynamics.otel.collector/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels for all
*/}}
{{- define "appdynamics-otel-collector.selectorLabels" -}}
app.appdynamics.otel.collector/name: {{ include "appdynamics-otel-collector.name" . }}
app.appdynamics.otel.collector/instance: {{ .Release.Name }}
{{- end }}

{{/*
Selector labels for daemonset
*/}}
{{- define "appdynamics-otel-collector.selectorLabelsDaemonset" -}}
{{- include "appdynamics-otel-collector.selectorLabels" . }}
app.appdynamics.otel.collector/mode: "daemonset"
{{- end }}

{{/*
Selector labels for statefulset
*/}}
{{- define "appdynamics-otel-collector.selectorLabelsStatefulset" -}}
{{- include "appdynamics-otel-collector.selectorLabels" . }}
app.appdynamics.otel.collector/mode: "statefulset"
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
Create service ports list, will be used to override default v1/Service ports also.
*/}}
{{- define "appdynamics-otel-collector.servicePorts" -}}
{{- if .Values.service.ports}}
{{- .Values.service.ports | toYaml}}
{{- end }}
{{- end}}

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

