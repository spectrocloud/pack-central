{{- define "grype-server.name" -}}
{{- "grype-server" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "grype-server.fullname" -}}
{{- "grype-server" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "grype-server.labels" -}}
helm.sh/chart: {{ include "panoptica.chart" . }}
{{ include "grype-server.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.global.extraLabels }}
{{ toYaml $.Values.global.extraLabels }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "grype-server.selectorLabels" -}}
app.kubernetes.io/name: {{ include "grype-server.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
