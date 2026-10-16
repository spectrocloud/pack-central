{{/*
Expand the name of the chart.
*/}}
{{- define "health-events-analyzer.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "health-events-analyzer.fullname" -}}
{{- "health-events-analyzer" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "health-events-analyzer.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "health-events-analyzer.labels" -}}
helm.sh/chart: {{ include "health-events-analyzer.chart" . }}
{{ include "health-events-analyzer.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "health-events-analyzer.selectorLabels" -}}
app.kubernetes.io/name: {{ include "health-events-analyzer.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
