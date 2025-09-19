{{/*
Expand the name of the chart.
*/}}
{{- define "kubeflowCrds.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "kubeflowCrds.fullname" -}}
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

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "kubeflowCrds.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "kubeflowCrds.common.labels" -}}
helm.sh/chart: {{ include "kubeflowCrds.chart" . }}
{{ include "kubeflowCrds.common.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Common selector labels
*/}}
{{- define "kubeflowCrds.common.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kubeflowCrds.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Kubeflow Component Names.

Changing this function will reflect on all component and subcomponent names.
*/}}
{{- define "kubeflowCrds.component.name" -}}
{{- $componentName := index . 0 -}}
{{- $context := index . 1 -}}
{{- $componentName }}
{{- end }}

{{- define "kubeflowCrds.common.group" -}}
kubeflow.org
{{- end }}

{{/*
Component specific labels
*/}}
{{- define "kubeflowCrds.component.labels" -}}
{{ include "kubeflowCrds.component.selectorLabels" . }}
{{- end }}

{{/*
Component specific selector labels
*/}}
{{- define "kubeflowCrds.component.selectorLabels" -}}
app.kubernetes.io/component: {{ . }}
{{- end }}

{{/*
subcomponent specific labels
*/}}
{{- define "kubeflowCrds.component.subcomponent.labels" -}}
{{ include "kubeflowCrds.component.subcomponent.selectorLabels" . }}
{{- end }}

{{/*
subcomponent specific selector labels
*/}}
{{- define "kubeflowCrds.component.subcomponent.selectorLabels" -}}
app.kubernetes.io/subcomponent: {{ . }}
{{- end }}

{{/*
Namespace for all resources to be installed into
If not defined in values file then the helm release namespace is used
By default this is not set so the helm release namespace will be used

This gets around an problem within helm discussed here
https://github.com/helm/helm/issues/5358
{{- default .Values.namespace .Release.Namespace }}
*/}}
{{- define "kubeflowCrds.namespace" -}}
{{- default .Release.Namespace .Values.namespace }}
{{- end -}}
