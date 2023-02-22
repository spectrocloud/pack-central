{{- define "kubevious-guard.fullname" -}}
{{ include "kubevious.fullname" . }}-guard
{{- end }}

{{/*
Create the name of the service account to use for kubevious
*/}}
{{- define "kubevious-guard.serviceAccountName" -}}
{{- if .Values.guard.serviceAccount.create }}
{{- default (include "kubevious-guard.fullname" .) .Values.guard.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.guard.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "kubevious-guard.service.name" -}}
{{ print (include "kubevious-guard.fullname" . ) "-" (.Values.guard.service.type | lower) }}
{{- end }}

{{- define "kubevious-guard.baseUrl" -}}
http://{{ include "kubevious-guard.service.name" . }}:{{ .Values.guard.service.port }}
{{- end }}
