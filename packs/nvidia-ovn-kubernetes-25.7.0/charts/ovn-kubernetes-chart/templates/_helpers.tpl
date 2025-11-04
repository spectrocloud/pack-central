{{/*
Expand the name of the chart.
*/}}
{{- define "ovn-kubernetes.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 50 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 40 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ovn-kubernetes.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 40 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 40 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 40 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "ovn-kubernetes.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 50 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "ovn-kubernetes.labels" -}}
helm.sh/chart: {{ include "ovn-kubernetes.chart" . }}
{{ include "ovn-kubernetes.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ovn-kubernetes.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ovn-kubernetes.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Enable automatic lookup of k8sEndpoint from the cluster-info ConfigMap
When `auto`, it defaults to lookup for a `cluster-info` configmap on the `kube-public` namespace (kubeadm-based)
To override the namespace and configMap when using `auto`:
`.Values.k8sServiceLookupNamespace` and `.Values.k8sServiceLookupConfigMapName`
*/}}
{{- define "k8sEndpoint" }}
  {{- $configmapName := default "cluster-info" .Values.k8sServiceLookupConfigMapName }}
  {{- $configmapNamespace := default "kube-public" .Values.k8sServiceLookupNamespace }}
  {{- if and (eq .Values.k8sAPIServer "auto") (lookup "v1" "ConfigMap" $configmapNamespace $configmapName) }}
    {{- $configmap := (lookup "v1" "ConfigMap" $configmapNamespace $configmapName) }}
    {{- $kubeconfig := get $configmap.data "kubeconfig" }}
    {{- $k8sServer := get ($kubeconfig | fromYaml) "clusters" | mustFirst | dig "cluster" "server" "" }}
    {{- $k8sServer | quote }}
  {{- else }}
    {{- .Values.k8sAPIServer | quote }}
  {{- end }}
{{- end }}