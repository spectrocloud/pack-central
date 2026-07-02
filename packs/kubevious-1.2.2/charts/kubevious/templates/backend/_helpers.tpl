
{{- define "kubevious-backend.fullname" -}}
{{ include "kubevious.fullname" . }}-backend
{{- end }}

{{/*
Create the name of the service account to use for kubevious
*/}}
{{- define "kubevious-backend.serviceAccountName" -}}
{{- if .Values.backend.serviceAccount.create }}
{{- default (include "kubevious-backend.fullname" .) .Values.backend.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.backend.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "kubevious-backend.service.name" -}}
{{ print (include "kubevious-backend.fullname" . ) "-" (.Values.backend.service.type | lower) }}
{{- end }}

{{- define "kubevious-backend.baseUrl" -}}
http://{{ include "kubevious-backend.service.name" . }}:{{ .Values.backend.service.port }}
{{- end }}
