{{/*
Kubeflow Pipelines Profile Controller object names.
*/}}
{{- define "kubeflow.pipelines.profileController.baseName" -}}
{{- printf "ml-pipeline-profile-controller" }}
{{- end }}

{{- define "kubeflow.pipelines.profileController.name" -}}
{{- include "kubeflow.component.name" (
    list
    (include "kubeflow.pipelines.profileController.baseName" .)
    .
)}}
{{- end }}

{{- define "kubeflow.pipelines.profileController.serviceAccountName" -}}
{{- include "kubeflow.component.serviceAccountName"  (
    list
    (include "kubeflow.pipelines.profileController.name" .)
    .Values.pipelines.profileController.serviceAccount)
}}
{{- end }}

{{- define "kubeflow.pipelines.profileController.serviceAccountPrincipal" -}}
{{- include "kubeflow.component.serviceAccountPrincipal" (
    list
    .
    (include "kubeflow.pipelines.profileController.serviceAccountName" .)
)}}
{{- end }}

{{- define "kubeflow.pipelines.profileController.roleName" -}}
{{- include "kubeflow.pipelines.profileController.name" . }}
{{- end }}

{{- define "kubeflow.pipelines.profileController.roleBindingName" -}}
{{- include "kubeflow.pipelines.profileController.roleName" . }}
{{- end }}

{{- define "kubeflow.pipelines.profileController.configMapName" -}}
{{- printf "%s-%s"
    (include "kubeflow.pipelines.profileController.name" .)
    "sync"
}}
{{- end }}

{{/*
Kubeflow Pipelines ML Pipeline Service.
*/}}
{{- define "kubeflow.pipelines.profileController.svc.name" -}}
{{ include "kubeflow.component.svc.name" (
    include "kubeflow.pipelines.profileController.name" .
)}}
{{- end }}

{{- define "kubeflow.pipelines.profileController.svc.addressWithNs" -}}
{{ include "kubeflow.component.svc.addressWithNs"  (
    list
    .
    (include "kubeflow.pipelines.profileController.name" .)
)}}
{{- end }}

{{- define "kubeflow.pipelines.profileController.svc.addressWithSvc" -}}
{{ include "kubeflow.component.svc.addressWithSvc"  (
    list
    .
    (include "kubeflow.pipelines.profileController.name" .)
)}}
{{- end }}

{{- define "kubeflow.pipelines.profileController.svc.fqdn" -}}
{{ include "kubeflow.component.svc.fqdn"  (
    list
    .
    (include "kubeflow.pipelines.profileController.name" .)
)}}
{{- end }}

{{/*
Kubeflow Pipelines ML Pipeline object labels.
*/}}
{{- define "kubeflow.pipelines.profileController.labels" -}}
{{ include "kubeflow.common.labels" . }}
{{ include "kubeflow.component.labels" (include "kubeflow.pipelines.name" .) }}
{{ include "kubeflow.component.subcomponent.labels" (include "kubeflow.pipelines.profileController.name" .) }}
{{- end }}

{{- define "kubeflow.pipelines.profileController.selectorLabels" -}}
{{ include "kubeflow.common.selectorLabels" . }}
{{ include "kubeflow.component.selectorLabels" (include "kubeflow.pipelines.name" .) }}
{{ include "kubeflow.component.subcomponent.labels" (include "kubeflow.pipelines.profileController.name" .) }}
{{- end }}

{{/*
Kubeflow Pipelines ML Pipeline container image settings.
*/}}
{{- define "kubeflow.pipelines.profileController.image" -}}
{{- include "kubeflow.pipelines.image" (
    list
    .Values.defaults.image
    .Values.pipelines.defaults.image
    .Values.pipelines.profileController.image
)}}
{{- end }}

{{- define "kubeflow.pipelines.profileController.imagePullPolicy" -}}
{{- include "kubeflow.pipelines.imagePullPolicy" (
    list
    .Values.defaults.image
    .Values.pipelines.defaults.image
    .Values.pipelines.profileController.image
)}}
{{- end }}


{{/*
Kubeflow Pipelines ML Pipeline Autoscaling and Availability.
*/}}
{{- define "kubeflow.pipelines.profileController.autoscaling.enabled" -}}
{{ include "kubeflow.component.autoscaling.enabled" (list .Values.defaults.autoscaling .Values.pipelines.profileController.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.profileController.autoscaling.minReplicas" -}}
{{ include "kubeflow.component.autoscaling.minReplicas" (list .Values.defaults.autoscaling .Values.pipelines.profileController.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.profileController.autoscaling.maxReplicas" -}}
{{ include "kubeflow.component.autoscaling.maxReplicas" (list .Values.defaults.autoscaling .Values.pipelines.profileController.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.profileController.autoscaling.targetCPUUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetCPUUtilizationPercentage" (list .Values.defaults.autoscaling .Values.pipelines.profileController.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.profileController.autoscaling.targetMemoryUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetMemoryUtilizationPercentage" (list .Values.defaults.autoscaling .Values.pipelines.profileController.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.profileController.pdb.values" -}}
{{- include "kubeflow.component.pdb.values" (
    list
    .Values.defaults.podDisruptionBudget
    .Values.pipelines.profileController.podDisruptionBudget
)}}
{{- end }}

{{/*
Kubeflow Pipelines ML Pipeline Security Context.
*/}}
{{- define "kubeflow.pipelines.profileController.containerSecurityContext" -}}
{{- include "kubeflow.component.containerSecurityContext" (
    list
    .Values.defaults.containerSecurityContext
    .Values.pipelines.profileController.containerSecurityContext
)}}
{{- end }}

{{/*
Kubeflow Pipelines ML Pipeline Scheduling.
*/}}
{{- define "kubeflow.pipelines.profileController.topologySpreadConstraints" -}}
{{ include "kubeflow.component.topologySpreadConstraints" (
    list
    .Values.defaults.topologySpreadConstraints
    .Values.pipelines.profileController.topologySpreadConstraints
)}}
{{- end }}

{{- define "kubeflow.pipelines.profileController.nodeSelector" -}}
{{ include "kubeflow.component.nodeSelector" (
    list
    .Values.defaults.nodeSelector
    .Values.pipelines.profileController.nodeSelector
)}}
{{- end }}

{{- define "kubeflow.pipelines.profileController.tolerations" -}}
{{ include "kubeflow.component.tolerations" (
    list
    .Values.defaults.tolerations
    .Values.pipelines.profileController.tolerations
)}}
{{- end }}

{{- define "kubeflow.pipelines.profileController.affinity" -}}
{{ include "kubeflow.component.affinity" (
    list
    .Values.defaults.affinity
    .Values.pipelines.profileController.affinity
)}}
{{- end }}

{{/*
Kubeflow Pipelines ML Pipeline enable and create toggles.
*/}}
{{- define "kubeflow.pipelines.profileController.enabled" -}}
{{- ternary true "" (
    and
    (include "kubeflow.pipelines.enabled" . | eq "true")
    .Values.pipelines.profileController.enabled
)}}
{{- end }}

{{- define "kubeflow.pipelines.profileController.rbac.createRoles" -}}
{{- ternary true "" (
    and
    (include "kubeflow.pipelines.profileController.enabled" . | eq "true")
    .Values.pipelines.profileController.rbac.create
)}}
{{- end }}

{{- define "kubeflow.pipelines.profileController.createServiceAccount" -}}
{{- ternary true "" (
    and
    (include "kubeflow.pipelines.profileController.enabled" . | eq "true")
    .Values.pipelines.profileController.serviceAccount.create
)}}
{{- end }}

{{- define "kubeflow.pipelines.profileController.createIstioIntegrationObjects" -}}
{{- ternary true "" (
    and
        (include "kubeflow.pipelines.profileController.enabled" . | eq "true" )
        .Values.istioIntegration.enabled
)}}
{{- end }}
