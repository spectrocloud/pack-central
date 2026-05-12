{{/*
Expand the name of the chart.
*/}}
{{- define "labeler.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "labeler.fullname" -}}
{{- "labeler" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "labeler.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "labeler.labels" -}}
helm.sh/chart: {{ include "labeler.chart" . }}
{{ include "labeler.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "labeler.selectorLabels" -}}
app.kubernetes.io/name: {{ include "labeler.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
