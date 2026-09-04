{{/*
Copyright (c) 2025, NVIDIA CORPORATION.  All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/}}

{{/*
Expand the name of the chart.
*/}}
{{- define "preflight.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "preflight.fullname" -}}
{{- "preflight" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "preflight.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "preflight.labels" -}}
helm.sh/chart: {{ include "preflight.chart" . }}
{{ include "preflight.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "preflight.selectorLabels" -}}
app.kubernetes.io/name: {{ include "preflight.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Image cache DaemonSet name.
*/}}
{{- define "preflight.imageCacheName" -}}
{{- printf "%s-image-cache" (include "preflight.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Image cache selector labels. Keep these distinct from the webhook Deployment selector.
*/}}
{{- define "preflight.imageCacheSelectorLabels" -}}
app.kubernetes.io/name: {{ printf "%s-image-cache" (include "preflight.name" .) | trunc 63 | trimSuffix "-" }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: image-cache
{{- end }}

{{/*
Image cache common labels.
*/}}
{{- define "preflight.imageCacheLabels" -}}
helm.sh/chart: {{ include "preflight.chart" . }}
{{ include "preflight.imageCacheSelectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/part-of: {{ include "preflight.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Resolve a configured preflight init container image, honoring global.image.tag.
*/}}
{{- define "preflight.initContainerImage" -}}
{{- $root := .root -}}
{{- $container := .container -}}
{{- $image := $container.image -}}
{{- if kindIs "string" $image -}}
{{- $image -}}
{{- else -}}
{{- $global := $root.Values.global | default dict -}}
{{- $globalImage := $global.image | default dict -}}
{{- $tag := $image.tag | default $globalImage.tag | default $root.Chart.AppVersion -}}
{{- printf "%s:%s" $image.repository $tag -}}
{{- end -}}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "preflight.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "preflight.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Webhook name for MutatingWebhookConfiguration
*/}}
{{- define "preflight.webhookName" -}}
{{ include "preflight.name" . }}.nvsentinel.nvidia.com
{{- end }}

{{/*
Certificate secret name
*/}}
{{- define "preflight.certSecretName" -}}
{{ include "preflight.fullname" . }}-webhook-tls
{{- end }}

{{/*
Certificate DNS names
*/}}
{{- define "preflight.certDnsNames" -}}
- {{ include "preflight.fullname" . }}
- {{ include "preflight.fullname" . }}.{{ .Release.Namespace }}
- {{ include "preflight.fullname" . }}.{{ .Release.Namespace }}.svc
- {{ include "preflight.fullname" . }}.{{ .Release.Namespace }}.svc.cluster.local
{{- end }}

{{/*
Event processing strategy
*/}}
{{- define "preflight.processingStrategy" -}}
{{- .Values.processingStrategy | default "EXECUTE_REMEDIATION" }}
{{- end }}

{{/*
Platform connector socket path for health event reporting
Uses global.socketPath with unix:// prefix
*/}}
{{- define "preflight.connectorSocket" -}}
{{- if and .Values.global .Values.global.socketPath }}
{{- printf "unix://%s" .Values.global.socketPath }}
{{- else }}
{{- "unix:///var/run/nvsentinel.sock" }}
{{- end }}
{{- end }}

