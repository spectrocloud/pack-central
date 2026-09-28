
{{- define "kubevious-parser.fullname" -}}
{{ include "kubevious.fullname" . }}-parser
{{- end }}

{{/*
Create the name of the service account to use for the parser
*/}}
{{- define "kubevious-parser.serviceAccountName" -}}
{{- default (include "kubevious-parser.fullname" .) .Values.parser.serviceAccount.name }}
{{- end }}

{{- define "kubevious-parser.service.name" -}}
{{ print (include "kubevious-parser.fullname" . ) "-" (.Values.parser.service.type | lower) }}
{{- end }}


{{- define "kubevious-parser.baseUrl" -}}
http://{{ include "kubevious-parser.service.name" . }}:{{ .Values.parser.service.port }}
{{- end }}