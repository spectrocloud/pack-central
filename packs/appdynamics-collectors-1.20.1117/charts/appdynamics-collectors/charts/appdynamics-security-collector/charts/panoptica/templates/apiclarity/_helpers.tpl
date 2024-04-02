{{- define "apiclarity.name" -}}
{{- "apiclarity" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "apiclarity.fullname" -}}
{{- "apiclarity" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "apiclarity.labels" -}}
helm.sh/chart: {{ include "panoptica.chart" . }}
{{ include "apiclarity.selectorLabels" . }}
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
{{- define "apiclarity.selectorLabels" -}}
app.kubernetes.io/name: {{ include "apiclarity.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "apiclarity.serviceAccountName" -}}
{{- if .Values.apiclarity.serviceAccount.create }}
{{- default (include "apiclarity.fullname" .) .Values.apiclarity.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.apiclarity.serviceAccount.name }}
{{- end }}
{{- end }}