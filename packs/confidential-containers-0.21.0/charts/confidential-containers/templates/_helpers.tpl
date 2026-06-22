{{/*
Expand the name of the chart.
*/}}
{{- define "confidential-containers.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "confidential-containers.fullname" -}}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "confidential-containers.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "confidential-containers.labels" -}}
helm.sh/chart: {{ include "confidential-containers.chart" . }}
{{ include "confidential-containers.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "confidential-containers.selectorLabels" -}}
app.kubernetes.io/name: {{ include "confidential-containers.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Get the architecture display name
*/}}
{{- define "confidential-containers.architectureDisplayName" -}}
{{- if .Values.architecture }}
{{- if eq .Values.architecture "x86_64" }}
{{- "x86_64" }}
{{- else if eq .Values.architecture "s390x" }}
{{- "s390x (IBM Z)" }}
{{- else }}
{{- .Values.architecture }}
{{- end }}
{{- else }}
{{- "x86_64" }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "confidential-containers.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "confidential-containers.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

