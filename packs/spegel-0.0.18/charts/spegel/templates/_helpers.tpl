{{/*
Expand the name of the chart.
*/}}
{{- define "spegel.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "spegel.fullname" -}}
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
Creates the namespace for the chart. 
Defaults to the Release namespace unless the namespaceOverride is defined.
*/}}
{{- define "spegel.namespace" -}}
{{- if .Values.namespaceOverride }}
{{- printf "%s" .Values.namespaceOverride -}}
{{- else }}
{{- printf "%s" .Release.Namespace -}}
{{- end }}
{{- end }}


{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "spegel.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "spegel.labels" -}}
helm.sh/chart: {{ include "spegel.chart" . }}
{{ include "spegel.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "spegel.selectorLabels" -}}
app.kubernetes.io/name: {{ include "spegel.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "spegel.serviceAccountName" -}}
{{- default (include "spegel.fullname" .) .Values.serviceAccount.name }}
{{- end }}

{{/*
Image reference
*/}}
{{- define "spegel.image" -}}
{{- if .Values.image.digest }}
{{- .Values.image.repository }}@{{ .Values.image.digest }}
{{- else }}
{{- .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}
{{- end }}
{{- end }}
