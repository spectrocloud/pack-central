{{- define "kubevious-worldvious.fullname" -}}
{{ include "kubevious.fullname" . }}-worldvious
{{- end }}

{{- define "kubevious-worldvious.secret" -}}
{{ include "kubevious-worldvious.fullname" . }}
{{- end }}

{{- define "kubevious-worldvious.config" -}}
{{ include "kubevious-worldvious.fullname" . }}
{{- end }}


{{- define "kubevious-worldvious.id" -}}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace (include "kubevious-worldvious.secret" .) ) -}}
{{- if $secret }}
{{- $secret.data.WORLDVIOUS_ID }}
{{- else }}
{{- uuidv4 | b64enc }}
{{- end }}
{{- end }}
