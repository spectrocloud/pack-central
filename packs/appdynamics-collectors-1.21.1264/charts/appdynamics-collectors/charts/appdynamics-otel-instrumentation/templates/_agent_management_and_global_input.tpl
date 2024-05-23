{{- define "appdynamics-otel-collector.namespace" -}}
{{- if .Values.global.smartAgentInstall -}}
{{- default .Release.Namespace .Values.global.namespace }}
{{- else }}
{{- .Release.Namespace }}
{{- end }}
{{- end }}

{{- define "appdynamics-otel-collector.endpoint" -}}
{{- if (.Values.global.customService).enable -}}
{{.Values.global.customService.name}}.{{.Values.global.customService.namespace}}.svc.cluster.local
{{- else -}}
appdynamics-otel-collector-service.{{ include "appdynamics-otel-collector.namespace" .}}.svc.cluster.local
{{- end }}
{{- end }}