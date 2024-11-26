{{- define "appdynamics-otel-collector.namespace" -}}
{{- if .Values.global.smartAgentInstall -}}
{{- default .Release.Namespace .Values.global.namespace }}
{{- else }}
{{- .Release.Namespace }}
{{- end }}
{{- end }}

{{- define "appdynamics-otel-collector.cluster.name" -}}
{{- if .Values.global.smartAgentInstall -}}
{{ "AGENT_PLATFORM_NAME_VALUE" }}
{{- else -}}
{{ required "clusterName needs to be specified" .Values.global.clusterName }}
{{- end }}
{{- end }}

{{- define "appdynamics-otel-collector.clusterId" -}}
{{- if .Values.global.smartAgentInstall -}}
{{ "AGENT_PLATFORM_ID_VALUE" }}
{{- else -}}
{{ (include "appdynamics-otel-collector.readClusterId" .) }}
{{- end }}
{{- end }}

{{- define "appdynamics-otel-collector.derivedOAuth" -}}
{{- if .Values.global.smartAgentInstall -}}
client_id: {{ "OAUTH_ID_VALUE" }}
client_secret: {{ "OAUTH_SECRET_PLAIN_VALUE" }}
token_url: {{ "OAUTH_URL_VALUE" }}
{{- else -}}
client_id: {{ .Values.clientId | default (.Values.global.oauth).clientId | required ".clientId is required" }}
token_url: {{ .Values.tokenUrl | default (.Values.global.oauth).tokenUrl | required ".tokenUrl is required" }}
{{- if .Values.clientSecret }}
client_secret: {{ .Values.clientSecret }}
{{- else if .Values.clientSecretEnvVar }}
client_secret: "${APPD_OTELCOL_CLIENT_SECRET}"
{{- else if .Values.clientSecretVolume }}
client_secret: {{ (include "appdynamics-otel-collector.clientSecretVolumePath" .Values.clientSecretVolume) | toYaml }}
{{- else if (.Values.global.oauth).clientSecretEnvVar }}
client_secret: "${APPD_OTELCOL_CLIENT_SECRET}"
{{- else }}
client_secret: {{required ".clientSecret is required" (.Values.global.oauth).clientSecret}}
{{- end }}
{{- end }}
{{- end }}

{{- define "appdynamics-otel-collector.endpoint" -}}
{{- if .Values.global.smartAgentInstall -}}
{{ "SERVICE_DOMAIN_VALUE" }}/data
{{- else -}}
{{ .Values.endpoint | default (.Values.global.oauth).endpoint | required ".endpoint is required" }}
{{- end }}
{{- end }}

{{/*
  Generate the secret environment variable for OAuth2.0
  */}}
{{- define "appdynamics-otel-collector.clientSecretEnvVar" -}}
{{- if .Values.clientSecretEnvVar -}}
name: APPD_OTELCOL_CLIENT_SECRET
{{- .Values.clientSecretEnvVar | toYaml | nindent 0}}
{{- else if (.Values.global.oauth).clientSecretEnvVar -}}
{{- (.Values.global.oauth).clientSecretEnvVar | toYaml | nindent 0}}
{{- end }}
{{- end }}

{{/* httpProxy */}}
{{- define "appdynamics-otel-collector.client.agent.proxy" -}}
{{- if .Values.global.smartAgentInstall -}}
agent_http_proxy: {{ "AGENT_HTTP_PROXY_VALUE" }}
agent_https_proxy: {{ "AGENT_HTTPS_PROXY_VALUE" }}
{{- else }}
{{ with .Values.global.agentManagementProxy -}}
agent_http_proxy: {{ .httpProxy }}
agent_https_proxy: {{ .httpsProxy }}
agent_no_proxy: {{- toYaml .noProxy | nindent 4 }}
{{- end }}
{{- end }}
{{- end }}

{{/* tenant id extracted from token url or from smart agent directly*/}}
{{- define "appdynamics-otel-collector.tenant.id" -}}
{{- if .Values.global.smartAgentInstall -}}
{{ "OAUTH_TENANT_ID_VALUE" }}
{{- else -}}
{{- if .Values.tenantId -}}
{{ .Values.tenantId }}
{{- else -}}
{{- $tokenUrl := .Values.tokenUrl | default (.Values.global.oauth).tokenUrl | required ".tokenUrl is required" -}}
{{- $authTenantId := (regexFind "\\/auth\\/[0-9a-z\\-]{36}" $tokenUrl) -}}
{{- if eq (len $authTenantId) (add (len "/auth/") 36) -}}
{{ substr (len "/auth/") (len $authTenantId) $authTenantId }}
{{- else -}}
{{- required "Please provide tenantId." "" }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- define "appdynamics-otel-collector.serviceURL" -}}
{{- if .Values.global.smartAgentInstall -}}
{{ "SERVICE_URL_VALUE" }}
{{- else -}}
{{- $endpoint := (include "appdynamics-otel-collector.endpoint" .) -}}
{{ substr 0 (int (sub (len $endpoint) (len "/data"))) $endpoint }}/rest/agent/service
{{- end }}
{{- end }}
