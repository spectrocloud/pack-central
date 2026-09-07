{{/*
Expand the name of the chart.
*/}}
{{- define "csp-health-monitor.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "csp-health-monitor.fullname" -}}
{{- "csp-health-monitor" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "csp-health-monitor.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "csp-health-monitor.labels" -}}
helm.sh/chart: {{ include "csp-health-monitor.chart" . }}
{{ include "csp-health-monitor.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "csp-health-monitor.selectorLabels" -}}
app.kubernetes.io/name: {{ include "csp-health-monitor.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
