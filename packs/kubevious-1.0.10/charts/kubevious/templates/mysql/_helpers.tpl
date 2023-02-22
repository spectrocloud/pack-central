
{{- define "kubevious-mysql.fullname" -}}
{{ include "kubevious.fullname" . }}-mysql
{{- end }}

{{- define "kubevious-mysql.config" -}}
{{ include "kubevious-mysql.fullname" . }}-config
{{- end }}

{{- define "kubevious-mysql.secret" -}}
{{ include "kubevious-mysql.fullname" . }}-secret
{{- end }}

{{- define "kubevious-mysql.secret-root" -}}
{{ include "kubevious-mysql.fullname" . }}-secret-root
{{- end }}

{{- define "kubevious-mysql.root-password" -}}
{{- if .Values.mysql.root_password }}
{{- .Values.mysql.root_password | b64enc }}
{{- else }}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace (include "kubevious-mysql.secret-root" .) ) -}}
{{- if $secret }}
{{- $secret.data.MYSQL_ROOT_PASSWORD }}
{{- else }}
{{- if .Values.mysql.generate_passwords }}
{{- randAlphaNum 16 | b64enc }}
{{- else }}
{{- "kubevious" | b64enc }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}


{{- define "kubevious-mysql.host" -}}
{{- if .Values.mysql.external.enabled }}
{{- .Values.mysql.external.host }}
{{- else }}
{{- include "kubevious-mysql.fullname" . }}
{{- end }}
{{- end }}


{{- define "kubevious-mysql.port" -}}
{{- if .Values.mysql.external.enabled }}
{{- .Values.mysql.external.port }}
{{- else }}
{{- .Values.mysql.service.port }}
{{- end }}
{{- end }}


{{- define "kubevious-mysql.database" -}}
{{- if .Values.mysql.external.enabled }}
{{- .Values.mysql.external.database }}
{{- else }}
{{- .Values.mysql.db_name }}
{{- end }}
{{- end }}


{{- define "kubevious-mysql.user" -}}
{{- if .Values.mysql.external.enabled }}
{{- .Values.mysql.external.user }}
{{- else }}
{{- .Values.mysql.db_user }}
{{- end }}
{{- end }}


{{- define "kubevious-mysql.user-password" -}}
{{- .Values.mysql.external.password | b64enc }}
{{- if .Values.mysql.external.enabled }}
{{- else }}
{{- if and (.Values.mysql.db_user) (not (eq .Values.mysql.db_user "root")) }}
{{- if .Values.mysql.db_password }}
{{- .Values.mysql.db_password | b64enc }}
{{- else }}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace (include "kubevious-mysql.secret" .) ) -}}
{{- if $secret }}
{{- $secret.data.MYSQL_PASS }}
{{- else }}
{{- if .Values.mysql.generate_passwords }}
{{- randAlphaNum 16 | b64enc }}
{{- else }}
{{- "kubevious" | b64enc }}
{{- end }}
{{- end }}
{{- end }}
{{- else }}
{{- include "kubevious-mysql.root-password" . }}
{{- end }}
{{- end }}
{{- end }}


{{/*
Create the name of the service account to use for mysql
*/}}
{{- define "kubevious-mysql.serviceAccountName" -}}
{{- if .Values.mysql.serviceAccount.create }}
{{- default (include "kubevious-mysql.fullname" .) .Values.mysql.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.mysql.serviceAccount.name }}
{{- end }}
{{- end }}