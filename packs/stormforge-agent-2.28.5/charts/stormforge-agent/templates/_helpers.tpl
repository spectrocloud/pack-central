{{/*
Expand the name of the chart.
*/}}
{{- define "stormforge-agent.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "stormforge-agent.fullname" -}}
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

{{/* Component Names */}}

{{- define "stormforge-agent.agentComponent" -}}
agent
{{- end -}}

{{- define "stormforge-agent.agentName" -}}
{{ .Release.Name }}-workload-controller
{{- end -}}

{{- define "stormforge-agent.metricsForwarderComponent" -}}
metrics-forwarder
{{- end -}}

{{- define "stormforge-agent.metricsForwarderName" -}}
{{ .Release.Name }}-{{ include "stormforge-agent.metricsForwarderComponent" . }}
{{- end -}}

{{- define "stormforge-agent.envSecret" -}}
{{- if .Values.envSecret }}{{ .Values.envSecret }}{{ else }}{{ printf "%s-env" (include "stormforge-agent.fullname" .) }}{{ end }}
{{- end -}}

{{- define "stormforge-agent.authSecret" -}}
{{- if .Values.authSecret }}{{ .Values.authSecret }}{{ else }}{{ printf "%s-auth" (include "stormforge-agent.fullname" .) }}{{ end }}
{{- end -}}

{{- define "stormforge-agent.defaultsConfigMap" -}}
cluster-defaults
{{- end -}}

{{/* Create chart name and version as used by the chart label */}}
{{- define "stormforge-agent.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Validator and deprecation access function for clusterName */}}
{{- define "stormforge-agent.clusterName" -}}
    {{- if ne nil (.Values.AsMap | dig "stormforge" "clusterName" nil) -}}
        {{- fail "Chart value `stormforge.clusterName` has been deprecated; please use `clusterName` instead" -}}
    {{- end -}}
    {{- if gt (semver .Chart.Version).Major 2 -}}
        {{- fail "Developer note: remove all .Values.stormforge.clusterName references from templates and values.schema.json before incrementing Chart major version" -}}
    {{- end -}}
    {{- if and .Values.clusterName .Values.clusterNameSeed -}}
        {{- fail "Chart values `clusterName` and `clusterNameSeed` are mutually exclusive! You must set at least one of these values to `null`" -}}
    {{- end -}}

    {{/* Usually, the clusterName will simply be given. If given, it is validated by values.schema.json. */}}
    {{- $name := .Values.clusterName -}}

    {{/* As a mutually exclusive alternative, the name can be generated from a seed. This is often used to de-duplicate clusters
         with the same name but on different EKS regions (the region will be given as a clusterNameSuffix). If using a name seed,
         we will sanitize and munge the final name value to ensure that the string passed to the API is unique and compliant. */}}
    {{- if .Values.clusterNameSeed -}}
        {{- $name = .Values.clusterNameSeed | lower | replace "_" "-" -}}
        {{/* Ensure that a generated name will have a legal length, even if the seed did not. */}}
        {{- $clusterNameMaxLen := 63 -}}
        {{- if .Values.clusterNameSuffix -}}
            {{/* Account for the length of a suffix that will be added, if configured. */}}
            {{- $clusterNameMaxLen = sub 63 (len .Values.clusterNameSuffix | add1) | int -}}
        {{- end -}}
        {{- if gt (len $name | int) $clusterNameMaxLen -}}
            {{- $nameHash := sha1sum (printf "%s-%s" .Values.clusterNameSeed .Values.clusterNameSuffix) | lower | trunc 8 -}}
            {{- $name = printf "%s-%s" ($name | trunc (sub $clusterNameMaxLen 9 | int)) $nameHash -}}
        {{- end -}}
    {{- end -}}

    {{/* Add a suffix to the name, if specified. Fall through to `required` below if there is no name. */}}
    {{- if and $name .Values.clusterNameSuffix -}}
        {{- $name = printf "%s-%s" $name .Values.clusterNameSuffix -}}
        {{- if gt (len $name) 63 -}}
            {{- fail (printf "Chart values `clusterName` and `clusterNameSuffix` are invalid together. \"%s\" exceeds 63 characters." $name) -}}
        {{- end -}}
    {{- end -}}

    {{/* At this point, if the input was valid, we should have a value. */}}
    {{- required "Chart value `clusterName` is required!" $name -}}
{{- end -}}

{{/* Common labels */}}

{{- define "stormforge-agent.commonSelectorLabels" -}}
app.kubernetes.io/name: {{ include "stormforge-agent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "stormforge-agent.agentSelectorLabels" -}}
{{- include "stormforge-agent.commonSelectorLabels" . }}
app.kubernetes.io/component: {{ include "stormforge-agent.agentComponent" . }}
{{- end }}

{{- define "stormforge-agent.metricsForwarderSelectorLabels" -}}
{{- include "stormforge-agent.commonSelectorLabels" . }}
app.kubernetes.io/component: {{ include "stormforge-agent.metricsForwarderComponent" . }}
{{- end }}

{{- define "stormforge-agent.labels" -}}
helm.sh/chart: {{ include "stormforge-agent.chart" . }}
{{ include "stormforge-agent.commonSelectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- with .Values.commonMetaLabels}}
{{ toYaml . }}
{{- end }}
app.kubernetes.io/managed-by: Helm
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "stormforge-agent.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "stormforge-agent.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the clusterrolebinding view name
*/}}
{{- define "stormforge-agent.roleBindingViewName" -}}
{{- printf "%s-view" (include "stormforge-agent.fullname" .) -}}
{{- end -}}

{{/* StormForge Labels to keep */}}
{{- define "stormforge-agent.workload.labels-to-keep" -}}
{{- printf "%s"
      (list
         "__name__"
         "cluster_name"
         "container"
         "instance"
         "name"
         "node"
         "kubernetes_io_arch"
         "node_kubernetes_io_instance_type"
         "pod"
         "topology_kubernetes_io_region"
         "kubernetes_io_hostname"
         "topology_kubernetes_io_zone"
         "kubernetes_io_os"
         "namespace"
         "address"
         "job"
         "interface"
       | join "|") -}}
{{- end -}}

{{/* StormForge Labels to keep after ingest */}}
{{- define "stormforge-agent.workload.labels-to-keep-postingest" -}}
{{- $labels := include "stormforge-agent.workload.labels-to-keep" . -}}
{{- printf "^(%s)$" ($labels) -}}
{{- end -}}

{{/* StormForge Labels to keep during ingest, same as before plus all metadata because they are required for autogenerated metrics */}}
{{- define "stormforge-agent.workload.labels-to-keep-duringingest" -}}
{{- $postlabels := include "stormforge-agent.workload.labels-to-keep" . -}}
{{- $labelsspace := cat $postlabels "|__.*" -}}
{{- $labels := $labelsspace | replace " " "" -}}
{{- printf "^(%s)$" ($labels) -}}
{{- end -}}

{{/* Next major Chart version should rename component Values fields */}}
{{- if gt (semver .Chart.Version).Major 2 -}}
    {{- fail "Developer note: rename .Values.workload to .Values.workloadController and .Values.prom to .Values.metricsForwarder before incrementing Chart major version" -}}
{{- end -}}