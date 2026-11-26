{{/*
Expand the name of the chart.
*/}}
{{- define "fault-quarantine.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "fault-quarantine.fullname" -}}
{{- "fault-quarantine" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "fault-quarantine.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "fault-quarantine.labels" -}}
helm.sh/chart: {{ include "fault-quarantine.chart" . }}
{{ include "fault-quarantine.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "fault-quarantine.selectorLabels" -}}
app.kubernetes.io/name: {{ include "fault-quarantine.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
