{{/*
Kubeflow Pipelines object names.
*/}}
{{- define "kubeflow.pipelines.baseName" -}}
{{- printf "pipelines" }}
{{- end }}

{{- define "kubeflow.pipelines.baseRbacName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) (include "kubeflow.pipelines.name" .) }}
{{- end }}

{{- define "kubeflow.pipelines.name" -}}
{{- include "kubeflow.component.name" (
    list
    (include "kubeflow.pipelines.baseName" .)
    .
)}}
{{- end }}

{{- define "kubeflow.pipelines.rbac.cacheDeployer.serviceAccountName" -}}
{{- $saName := printf "%s-%s" (include "kubeflow.pipelines.baseRbacName" .) "cache-deployer" -}}
{{- include "kubeflow.component.serviceAccountName"  (list $saName .Values.pipelines.serviceAccount) }}
{{- end }}

{{- define "kubeflow.pipelines.rbac.cacheDeployer.clusterRoleName" -}}
{{- printf "%s-%s" (include "kubeflow.pipelines.baseRbacName" .) "cache-deployer" }}
{{- end }}

{{- define "kubeflow.pipelines.rbac.cacheDeployer.clusterRoleBindingName" -}}
{{- include "kubeflow.pipelines.rbac.cacheDeployer.clusterRoleName" . }}
{{- end }}

{{/*
Kubeflow Pipelines object labels.
*/}}
{{- define "kubeflow.pipelines.labels" -}}
{{ include "kubeflow.common.labels" . }}
{{ include "kubeflow.component.labels" (include "kubeflow.pipelines.name" .) }}
{{- end }}

{{- define "kubeflow.pipelines.selectorLabels" -}}
{{ include "kubeflow.common.selectorLabels" . }}
{{ include "kubeflow.component.selectorLabels" (include "kubeflow.pipelines.name" .) }}
{{- end }}

{{/*
Kubeflow Pipelines container image settings.
*/}}

{{- define "kubeflow.pipelines.image" -}}
{{- $default := index . 0 -}}
{{- $pipelinesDefault := index . 1 -}}
{{- $component := index . 2 -}}
{{- $registry := default $default.registry (default $pipelinesDefault.registry $component.registryOverwrite) -}}
{{- $repository := $component.repository -}}
{{- $tag := default $pipelinesDefault.tag $component.tagOverwrite -}}
{{- printf "%s/%s:%s" $registry $repository $tag }}
{{- end }}

{{- define "kubeflow.pipelines.imagePullPolicy" -}}
{{- $default := index . 0 -}}
{{- $pipelinesDefault := index . 1 -}}
{{- $component := index . 2 -}}
{{- $imagePullPolicy := default $default.pullPolicy (default $pipelinesDefault.pullPolicy $component.pullPolicyOverwrite) -}}
{{- $imagePullPolicy }}
{{- end }}

{{/*
Kubeflow Pipelines Autoscaling and Availability.
*/}}
{{- define "kubeflow.pipelines.autoscaling.enabled" -}}
{{ include "kubeflow.component.autoscaling.enabled" (list .Values.defaults.autoscaling .Values.pipelines.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.autoscaling.minReplicas" -}}
{{ include "kubeflow.component.autoscaling.minReplicas" (list .Values.defaults.autoscaling .Values.pipelines.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.autoscaling.maxReplicas" -}}
{{ include "kubeflow.component.autoscaling.maxReplicas" (list .Values.defaults.autoscaling .Values.pipelines.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.autoscaling.targetCPUUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetCPUUtilizationPercentage" (list .Values.defaults.autoscaling .Values.pipelines.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.autoscaling.targetMemoryUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetMemoryUtilizationPercentage" (list .Values.defaults.autoscaling .Values.pipelines.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.pdb.values" -}}
{{- include "kubeflow.component.pdb.values" (
    list
    .Values.defaults.podDisruptionBudget
    .Values.pipelines.podDisruptionBudget
)}}
{{- end }}

{{/*
Kubeflow Pipelines Security Context.
*/}}
{{- define "kubeflow.pipelines.containerSecurityContext" -}}
{{ include "kubeflow.component.containerSecurityContext" (
    list
    .Values.defaults.containerSecurityContext
    .Values.pipelines.containerSecurityContext
)}}
{{- end }}

{{/*
Kubeflow Pipelines Scheduling.
*/}}
{{- define "kubeflow.pipelines.topologySpreadConstraints" -}}
{{ include "kubeflow.component.topologySpreadConstraints" (
    list
    .Values.defaults.topologySpreadConstraints
    .Values.pipelines.topologySpreadConstraints
)}}
{{- end }}

{{- define "kubeflow.pipelines.nodeSelector" -}}
{{ include "kubeflow.component.nodeSelector" (
    list
    .Values.defaults.nodeSelector
    .Values.pipelines.nodeSelector
)}}
{{- end }}

{{- define "kubeflow.pipelines.tolerations" -}}
{{ include "kubeflow.component.tolerations" (
    list
    .Values.defaults.tolerations
    .Values.pipelines.tolerations
)}}
{{- end }}

{{- define "kubeflow.pipelines.affinity" -}}
{{ include "kubeflow.component.affinity" (
    list
    .Values.defaults.affinity
    .Values.pipelines.affinity
)}}
{{- end }}

{{/*
Kubeflow Pipelines enable and create toggles.
*/}}
{{- define "kubeflow.pipelines.enabled" -}}
{{- ternary true "" .Values.pipelines.enabled }}
{{- end }}
