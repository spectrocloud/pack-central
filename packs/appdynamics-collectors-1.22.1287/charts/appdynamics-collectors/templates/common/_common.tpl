{{/*
Common labels
*/}}
{{- define "appdynamics-collectors.labels" -}}
helm.sh/chart: {{ include "appdynamics-collectors.chart" . }}
{{ include "appdynamics-collectors.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}