{{/*
Kubeflow Pipelines UI (aka ml-pipeline-ui) object names.
*/}}
{{- define "kubeflow.pipelines.ui.baseName" -}}
{{- printf "ml-pipeline-ui" }}
{{- end }}

{{- define "kubeflow.pipelines.ui.name" -}}
{{- include "kubeflow.component.name" (
    list
    (include "kubeflow.pipelines.ui.baseName" .)
    .
)}}
{{- end }}

{{- define "kubeflow.pipelines.ui.serviceAccountName" -}}
{{- include "kubeflow.component.serviceAccountName"  (
    list
    (include "kubeflow.pipelines.ui.name" .)
    .Values.pipelines.ui.serviceAccount)
}}
{{- end }}

{{- define "kubeflow.pipelines.ui.serviceAccountPrincipal" -}}
{{- include "kubeflow.component.serviceAccountPrincipal" (
    list
    .
    (include "kubeflow.pipelines.ui.serviceAccountName" .)
)}}
{{- end }}

{{- define "kubeflow.pipelines.ui.configMapName" -}}
{{- include "kubeflow.pipelines.ui.name" . }}
{{- end }}

{{- define "kubeflow.pipelines.ui.roleName" -}}
{{- include "kubeflow.pipelines.ui.name" . }}
{{- end }}

{{- define "kubeflow.pipelines.ui.roleBindingName" -}}
{{- include "kubeflow.pipelines.ui.roleName" . }}
{{- end }}

{{- define "kubeflow.pipelines.ui.authorizationPolicyExtAuthName" -}}
{{ include "kubeflow.component.authorizationPolicyExtAuthName" (
    list
    (include "kubeflow.pipelines.ui.name" .)
    .Values.istioIntegration
)}}
{{- end }}

{{/*
Kubeflow Pipelines UI Service.
*/}}
{{- define "kubeflow.pipelines.ui.svc.name" -}}
{{ include "kubeflow.component.svc.name" (
    include "kubeflow.pipelines.ui.name" .
)}}
{{- end }}

{{- define "kubeflow.pipelines.ui.svc.addressWithNs" -}}
{{ include "kubeflow.component.svc.addressWithNs"  (
    list
    .
    (include "kubeflow.pipelines.ui.name" .)
)}}
{{- end }}

{{- define "kubeflow.pipelines.ui.svc.addressWithSvc" -}}
{{ include "kubeflow.component.svc.addressWithSvc"  (
    list
    .
    (include "kubeflow.pipelines.ui.name" .)
)}}
{{- end }}

{{- define "kubeflow.pipelines.ui.svc.fqdn" -}}
{{ include "kubeflow.component.svc.fqdn"  (
    list
    .
    (include "kubeflow.pipelines.ui.name" .)
)}}
{{- end }}

{{/*
Kubeflow Pipelines UI object labels.
*/}}
{{- define "kubeflow.pipelines.ui.labels" -}}
{{ include "kubeflow.common.labels" . }}
{{ include "kubeflow.component.labels" (include "kubeflow.pipelines.name" .) }}
{{ include "kubeflow.component.subcomponent.labels" (include "kubeflow.pipelines.ui.name" .) }}
{{- end }}

{{- define "kubeflow.pipelines.ui.selectorLabels" -}}
{{ include "kubeflow.common.selectorLabels" . }}
{{ include "kubeflow.component.selectorLabels" (include "kubeflow.pipelines.name" .) }}
{{ include "kubeflow.component.subcomponent.labels" (include "kubeflow.pipelines.ui.name" .) }}
{{- end }}

{{/*
Kubeflow Pipelines UI container image settings.
*/}}
{{- define "kubeflow.pipelines.ui.image" -}}
{{- include "kubeflow.pipelines.image" (
    list
    .Values.defaults.image
    .Values.pipelines.defaults.image
    .Values.pipelines.ui.image
)}}

{{- end }}

{{- define "kubeflow.pipelines.ui.imagePullPolicy" -}}
{{- include "kubeflow.pipelines.imagePullPolicy" (
    list
    .Values.defaults.image
    .Values.pipelines.defaults.image
    .Values.pipelines.ui.image
)}}
{{- end }}


{{/*
Kubeflow Pipelines UI Autoscaling and Availability.
*/}}
{{- define "kubeflow.pipelines.ui.autoscaling.enabled" -}}
{{ include "kubeflow.component.autoscaling.enabled" (list .Values.defaults.autoscaling .Values.pipelines.ui.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.ui.autoscaling.minReplicas" -}}
{{ include "kubeflow.component.autoscaling.minReplicas" (list .Values.defaults.autoscaling .Values.pipelines.ui.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.ui.autoscaling.maxReplicas" -}}
{{ include "kubeflow.component.autoscaling.maxReplicas" (list .Values.defaults.autoscaling .Values.pipelines.ui.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.ui.autoscaling.targetCPUUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetCPUUtilizationPercentage" (list .Values.defaults.autoscaling .Values.pipelines.ui.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.ui.autoscaling.targetMemoryUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetMemoryUtilizationPercentage" (list .Values.defaults.autoscaling .Values.pipelines.ui.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.ui.pdb.values" -}}
{{- include "kubeflow.component.pdb.values" (
    list
    .Values.defaults.podDisruptionBudget
    .Values.pipelines.ui.podDisruptionBudget
)}}
{{- end }}

{{/*
Kubeflow Pipelines UI Security Context.
*/}}
{{- define "kubeflow.pipelines.ui.containerSecurityContext" -}}
{{- include "kubeflow.component.containerSecurityContext" (
    list
    .Values.defaults.containerSecurityContext
    .Values.pipelines.ui.containerSecurityContext
)}}
{{- end }}

{{/*
Kubeflow Pipelines UI Scheduling.
*/}}
{{- define "kubeflow.pipelines.ui.topologySpreadConstraints" -}}
{{ include "kubeflow.component.topologySpreadConstraints" (
    list
    .Values.defaults.topologySpreadConstraints
    .Values.pipelines.ui.topologySpreadConstraints
)}}
{{- end }}

{{- define "kubeflow.pipelines.ui.nodeSelector" -}}
{{ include "kubeflow.component.nodeSelector" (
    list
    .Values.defaults.nodeSelector
    .Values.pipelines.ui.nodeSelector
)}}
{{- end }}

{{- define "kubeflow.pipelines.ui.tolerations" -}}
{{ include "kubeflow.component.tolerations" (
    list
    .Values.defaults.tolerations
    .Values.pipelines.ui.tolerations
)}}
{{- end }}

{{- define "kubeflow.pipelines.ui.affinity" -}}
{{ include "kubeflow.component.affinity" (
    list
    .Values.defaults.affinity
    .Values.pipelines.ui.affinity
)}}
{{- end }}

{{/*
Kubeflow Pipelines UI enable and create toggles.
*/}}
{{- define "kubeflow.pipelines.ui.enabled" -}}
{{- ternary true "" (
    and
    (include "kubeflow.pipelines.enabled" . | eq "true")
    .Values.pipelines.ui.enabled
)}}
{{- end }}

{{- define "kubeflow.pipelines.ui.rbac.createRoles" -}}
{{- ternary true "" (
    and
    (include "kubeflow.pipelines.ui.enabled" . | eq "true")
    .Values.pipelines.ui.rbac.create
)}}
{{- end }}

{{- define "kubeflow.pipelines.ui.createServiceAccount" -}}
{{- ternary true "" (
    and
    (include "kubeflow.pipelines.ui.enabled" . | eq "true")
    .Values.pipelines.ui.serviceAccount.create
)}}
{{- end }}

{{- define "kubeflow.pipelines.ui.createIstioIntegrationObjects" -}}
{{- ternary true "" (
    and
        (include "kubeflow.pipelines.ui.enabled" . | eq "true" )
        .Values.istioIntegration.enabled
)}}
{{- end }}
