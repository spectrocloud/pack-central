{{/*
Expand the name of the chart.
*/}}
{{- define "node-drainer.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "node-drainer.fullname" -}}
{{- "node-drainer" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "node-drainer.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "node-drainer.labels" -}}
helm.sh/chart: {{ include "node-drainer.chart" . }}
{{ include "node-drainer.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "node-drainer.selectorLabels" -}}
app.kubernetes.io/name: {{ include "node-drainer.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
