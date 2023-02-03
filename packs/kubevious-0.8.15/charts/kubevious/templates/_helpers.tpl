{{/*
Expand the name of the chart.
*/}}
{{- define "kubevious.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "kubevious.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "kubevious.endpoint" -}}
{{ include "kubevious.fullname" . }}.{{ .Release.Namespace}}.svc.{{ .Values.cluster.domain}}:{{ .Values.kubevious.service.port }}
{{- end }}

{{- define "kubevious.collector" -}}
http://{{ include "kubevious.fullname" . }}.{{ .Release.Namespace}}.svc.{{ .Values.cluster.domain}}:{{ .Values.kubevious.service.port }}/api/v1/collect
{{- end }}

{{- define "kubevious-parser.fullname" -}}
{{ include "kubevious.fullname" . }}-parser
{{- end }}

{{- define "kubevious-mysql.fullname" -}}
{{ include "kubevious.fullname" . }}-mysql
{{- end }}

{{- define "kubevious-ui.fullname" -}}
{{ include "kubevious.fullname" . }}-ui
{{- end }}

{{- define "kubevious-mysql.secret" -}}
{{ include "kubevious-mysql.fullname" . }}-secret
{{- end }}

{{- define "kubevious-mysql.secret-root" -}}
{{ include "kubevious-mysql.fullname" . }}-secret-root
{{- end }}

{{- define "kubevious-worldvious.secret" -}}
{{ include "kubevious.fullname" . }}-worldvious
{{- end }}

{{- define "kubevious-worldvious.config" -}}
{{ include "kubevious.fullname" . }}-worldvious
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


{{- define "kubevious-mysql.user-password" -}}
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


{{- define "kubevious-worldvious.id" -}}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace (include "kubevious-worldvious.secret" .) ) -}}
{{- if $secret }}
{{- $secret.data.WORLDVIOUS_ID }}
{{- else }}
{{- uuidv4 | b64enc }}
{{- end }}
{{- end }}


{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "kubevious.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "kubevious.labels" -}}
app.kubernetes.io/name: {{ include "kubevious.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
helm.sh/chart: {{ include "kubevious.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Base labels
*/}}
{{- define "kubevious.base-labels" -}}
app.kubernetes.io/name: {{ include "kubevious.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Match labels
*/}}
{{- define "kubevious.match-labels" -}}
app.kubernetes.io/name: {{ include "kubevious.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}


{{/*
Create the name of the service account to use
*/}}
{{- define "kubevious-parser.serviceAccountName" -}}
{{- if .Values.parser.serviceAccount.create }}
{{- default (include "kubevious-parser.fullname" .) .Values.parser.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.parser.serviceAccount.name }}
{{- end }}
{{- end }}


{{- define "kubevious-ui.service.type" -}}
{{- if .Values.ingress.enabled }}
{{- if (eq .Values.ui.service.type "ClusterIP") }}
{{- "NodePort" }}
{{- else }}
{{- .Values.ui.service.type }}
{{- end }}
{{- else }}
{{- .Values.ui.service.type }}
{{- end }}
{{- end }}

{{- define "kubevious-ui.service.name" -}}
{{ print (include "kubevious-ui.fullname" . ) "-" (include "kubevious-ui.service.type" . | lower) }}
{{- end }}