{{- define "kubevious-collector.fullname" -}}
{{ include "kubevious.fullname" . }}-collector
{{- end }}

{{/*
Create the name of the service account to use for kubevious
*/}}
{{- define "kubevious-collector.serviceAccountName" -}}
{{- if .Values.collector.serviceAccount.create }}
{{- default (include "kubevious-collector.fullname" .) .Values.collector.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.collector.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "kubevious-collector.service.name" -}}
{{ print (include "kubevious-collector.fullname" . ) "-" (.Values.collector.service.type | lower) }}
{{- end }}

{{- define "kubevious-collector.baseUrl" -}}
http://{{ include "kubevious-collector.service.name" . }}:{{ .Values.collector.service.port }}
{{- end }}
