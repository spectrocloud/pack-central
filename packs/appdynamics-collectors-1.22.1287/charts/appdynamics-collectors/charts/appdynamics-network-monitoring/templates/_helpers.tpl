{{/*
Fully qualified app name for the kernel-collector daemonset.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "appdynamics-network-monitoring-kernel-collector.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-kernel-collector" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-kernel-collector" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use for the kernel-collector
*/}}
{{- define "appdynamics-network-monitoring-kernel-collector.serviceAccountName" -}}
{{- if .Values.kernelCollector.serviceAccount.create }}
{{- default (include "appdynamics-network-monitoring-kernel-collector.fullname" .) .Values.kernelCollector.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.kernelCollector.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Fully qualified app name for the k8s-collector deployment.
*/}}
{{- define "appdynamics-network-monitoring-k8s-collector.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-k8s-collector" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-k8s-collector" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use for the k8s-collector
*/}}
{{- define "appdynamics-network-monitoring-k8s-collector.serviceAccountName" -}}
{{- if .Values.k8sCollector.serviceAccount.create }}
{{- default (include "appdynamics-network-monitoring-k8s-collector.fullname" .) .Values.k8sCollector.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.k8sCollector.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Fully qualified app name for the reducer deployment.
*/}}
{{- define "appdynamics-network-monitoring-reducer.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-reducer" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-reducer" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "appdynamics-network-monitoring.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}