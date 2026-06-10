
{{- define "kubevious-redis.fullname" -}}
{{ include "kubevious.fullname" . }}-redis
{{- end }}

{{- define "kubevious-redis.config" -}}
{{ include "kubevious-redis.fullname" . }}-config
{{- end }}

{{- define "kubevious-redis.host" -}}
{{- include "kubevious-redis.fullname" . }}
{{- end }}

{{- define "kubevious-redis.port" -}}
{{- .Values.redis.service.port }}
{{- end }}

{{/*
Create the name of the service account to use for redis
*/}}
{{- define "kubevious-redis.serviceAccountName" -}}
{{- if .Values.redis.serviceAccount.create }}
{{- default (include "kubevious-redis.fullname" .) .Values.redis.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.redis.serviceAccount.name }}
{{- end }}
{{- end }}