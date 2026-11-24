{{/*
Expand the name of the chart.
*/}}
{{- define "collectord.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "collectord.fullname" -}}
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
{{- define "collectord.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels applied to all resources
*/}}
{{- define "collectord.labels" -}}
helm.sh/chart: {{ include "collectord.chart" . }}
{{ include "collectord.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels for the release (common to all workloads)
*/}}
{{- define "collectord.selectorLabels" -}}
app.kubernetes.io/name: {{ include "collectord.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
DaemonSet selector labels
*/}}
{{- define "collectord.daemonset.selectorLabels" -}}
{{ include "collectord.selectorLabels" . }}
app.kubernetes.io/component: worker
{{- with .Values.daemonset.selectorLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
DaemonSet Master selector labels
*/}}
{{- define "collectord.daemonsetMaster.selectorLabels" -}}
{{ include "collectord.selectorLabels" . }}
app.kubernetes.io/component: master
{{- with .Values.daemonsetMaster.selectorLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Deployment selector labels
*/}}
{{- define "collectord.deployment.selectorLabels" -}}
{{ include "collectord.selectorLabels" . }}
app.kubernetes.io/component: addon
{{- with .Values.deployment.selectorLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Generate volume mounts for a workload
*/}}
{{- define "collectord.volumeMounts" -}}
{{- $workloadType := .workloadType -}}
{{- $values := .values -}}
{{- range $mount := (index $values.volumeMounts $workloadType) }}
- name: {{ $mount.name }}
  mountPath: {{ $mount.mountPath }}
  {{- if $mount.subPath }}
  subPath: {{ $mount.subPath }}
  {{- end }}
  readOnly: {{ $mount.readOnly | default true }}
{{- end }}
{{- range $projectedVol := (index $values.projectedVolumes $workloadType) }}
- name: {{ $projectedVol.name }}
  mountPath: {{ $projectedVol.mountPath }}
  readOnly: {{ $projectedVol.readOnly | default true }}
{{- end }}
{{- end }}

{{/*
Generate volumes for a workload
*/}}
{{- define "collectord.volumes" -}}
{{- $workloadType := .workloadType -}}
{{- $values := .values -}}
{{- range $mount := (index $values.volumeMounts $workloadType) }}
- name: {{ $mount.name }}
  {{- if $mount.configMap }}
  configMap:
    name: {{ $mount.configMap.name }}
    {{- if $mount.configMap.items }}
    items:
    {{- range $item := $mount.configMap.items }}
    - key: {{ $item.key }}
      path: {{ $item.path }}
      {{- if $item.mode }}
      mode: {{ $item.mode }}
      {{- end }}
    {{- end }}
    {{- end }}
    {{- if $mount.configMap.defaultMode }}
    defaultMode: {{ $mount.configMap.defaultMode }}
    {{- end }}
  {{- else if $mount.secret }}
  secret:
    secretName: {{ $mount.secret.secretName }}
    {{- if $mount.secret.items }}
    items:
    {{- range $item := $mount.secret.items }}
    - key: {{ $item.key }}
      path: {{ $item.path }}
      {{- if $item.mode }}
      mode: {{ $item.mode }}
      {{- end }}
    {{- end }}
    {{- end }}
    {{- if $mount.secret.defaultMode }}
    defaultMode: {{ $mount.secret.defaultMode }}
    {{- end }}
  {{- end }}
{{- end }}
{{- range $projectedVol := (index $values.projectedVolumes $workloadType) }}
- name: {{ $projectedVol.name }}
  projected:
    sources:
    {{- range $source := $projectedVol.sources }}
    {{- if $source.configMap }}
    - configMap:
        name: {{ $source.configMap.name }}
        {{- if $source.configMap.items }}
        items:
        {{- range $item := $source.configMap.items }}
        - key: {{ $item.key }}
          path: {{ $item.path }}
          {{- if $item.mode }}
          mode: {{ $item.mode }}
          {{- end }}
        {{- end }}
        {{- end }}
        {{- if hasKey $source.configMap "optional" }}
        optional: {{ $source.configMap.optional }}
        {{- end }}
    {{- else if $source.secret }}
    - secret:
        name: {{ $source.secret.name }}
        {{- if $source.secret.items }}
        items:
        {{- range $item := $source.secret.items }}
        - key: {{ $item.key }}
          path: {{ $item.path }}
          {{- if $item.mode }}
          mode: {{ $item.mode }}
          {{- end }}
        {{- end }}
        {{- end }}
        {{- if hasKey $source.secret "optional" }}
        optional: {{ $source.secret.optional }}
        {{- end }}
    {{- else if $source.downwardAPI }}
    - downwardAPI:
        items:
        {{- range $item := $source.downwardAPI.items }}
        - path: {{ $item.path }}
          {{- if $item.fieldRef }}
          fieldRef:
            fieldPath: {{ $item.fieldRef.fieldPath }}
            {{- if $item.fieldRef.apiVersion }}
            apiVersion: {{ $item.fieldRef.apiVersion }}
            {{- end }}
          {{- else if $item.resourceFieldRef }}
          resourceFieldRef:
            containerName: {{ $item.resourceFieldRef.containerName }}
            resource: {{ $item.resourceFieldRef.resource }}
            {{- if $item.resourceFieldRef.divisor }}
            divisor: {{ $item.resourceFieldRef.divisor }}
            {{- end }}
          {{- end }}
          {{- if $item.mode }}
          mode: {{ $item.mode }}
          {{- end }}
        {{- end }}
    {{- else if $source.serviceAccountToken }}
    - serviceAccountToken:
        audience: {{ $source.serviceAccountToken.audience }}
        expirationSeconds: {{ $source.serviceAccountToken.expirationSeconds }}
        path: {{ $source.serviceAccountToken.path }}
    {{- end }}
    {{- end }}
    {{- if $projectedVol.defaultMode }}
    defaultMode: {{ $projectedVol.defaultMode }}
    {{- end }}
{{- end }}
{{- end }}