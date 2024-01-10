{{- define "kubeclarity.name" -}}
{{- "kubeclarity" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "kubeclarity.labels" -}}
helm.sh/chart: {{ include "panoptica.chart" . }}
{{ include "kubeclarity.selectorLabels" . }}
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
{{- define "kubeclarity.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kubeclarity.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
