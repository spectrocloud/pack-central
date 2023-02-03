

{{- define "kubevious-ui.fullname" -}}
{{ include "kubevious.fullname" . }}-ui
{{- end }}

{{/*
Create the name of the service account to use for the ui
*/}}
{{- define "kubevious-ui.serviceAccountName" -}}
{{- if .Values.ui.serviceAccount.create }}
{{- default (include "kubevious-ui.fullname" .) .Values.ui.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.ui.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "kubevious-ui.service.name" -}}
{{ print (include "kubevious-ui.fullname" . ) "-" (.Values.ui.service.type | lower) }}
{{- end }}

{{- define "kubevious-ui.caddyConfig" -}}
{{ print (include "kubevious-ui.fullname" . ) "-caddy" }}
{{- end }}
