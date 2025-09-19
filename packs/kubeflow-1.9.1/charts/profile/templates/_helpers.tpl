{{/*
Expand the name of the chart.
*/}}
{{- define "profile.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "profile.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "profile.labels" -}}
helm.sh/chart: {{ include "profile.chart" . }}
{{ include "profile.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Common selector labels
*/}}
{{- define "profile.selectorLabels" -}}
app.kubernetes.io/name: {{ include "profile.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Resource Names.
*/}}
{{- define "profile.authorizationpolicy.name" -}}
{{- printf "%s-%s" "ext-auth" .Values.istioIntegration.envoyExtAuthzHttpExtensionProviderName }}
{{- end }}

{{/*
Parse user email.
*/}}
{{- define "profile.parseUserEmail" -}}
{{- $email := . }}
{{- $pattern := "[.@_]" }}
{{- $replacement := "-" }}
{{- $modifiedEmail := regexReplaceAll $pattern $email $replacement }}
{{- printf "%s-%s" "user" (lower $modifiedEmail) }}
{{- end }}