{{/*
Expand the name of the chart.
*/}}
{{- define "fault-remediation.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "fault-remediation.fullname" -}}
{{- "fault-remediation" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "fault-remediation.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "fault-remediation.labels" -}}
helm.sh/chart: {{ include "fault-remediation.chart" . }}
{{ include "fault-remediation.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "fault-remediation.selectorLabels" -}}
app.kubernetes.io/name: {{ include "fault-remediation.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
