{{/*
Kubeflow Tensorboard Tensorboards Web App object names.
*/}}
{{- define "kubeflow.tensorboard.tensorboardsWebApp.baseName" -}}
{{- printf "tensorboards-web-app" }}
{{- end }}

{{- define "kubeflow.tensorboard.tensorboardsWebApp.name" -}}
{{- include "kubeflow.component.name" (
    list
    (include "kubeflow.tensorboard.tensorboardsWebApp.baseName" .)
    .
)}}
{{- end }}

{{/*
Kubeflow Tensorboard Tensorboards Web App object labels.
*/}}
{{- define "kubeflow.tensorboard.tensorboardsWebApp.labels" -}}
{{ include "kubeflow.common.labels" . }}
{{ include "kubeflow.component.labels" (include "kubeflow.tensorboard.name" .) }}
{{ include "kubeflow.component.subcomponent.labels" (include "kubeflow.tensorboard.tensorboardsWebApp.name" .) }}
{{- end }}

{{- define "kubeflow.tensorboard.tensorboardsWebApp.selectorLabels" -}}
{{ include "kubeflow.common.selectorLabels" . }}
{{ include "kubeflow.component.selectorLabels" (include "kubeflow.tensorboard.name" .) }}
{{ include "kubeflow.component.subcomponent.labels" (include "kubeflow.tensorboard.tensorboardsWebApp.name" .) }}
{{- end }}

{{- define "kubeflow.tensorboard.tensorboardsWebApp.image" -}}
{{ include "kubeflow.component.image" (list .Values.defaults.image .Values.tensorboard.tensorboardsWebApp.image) }}
{{- end }}

{{- define "kubeflow.tensorboard.tensorboardsWebApp.imagePullPolicy" -}}
{{ include "kubeflow.component.imagePullPolicy" (list .Values.defaults.image .Values.tensorboard.tensorboardsWebApp.image) }}
{{- end }}

{{- define "kubeflow.tensorboard.tensorboardsWebApp.autoscaling.enabled" -}}
{{ include "kubeflow.component.autoscaling.enabled" (list .Values.defaults.autoscaling .Values.tensorboard.tensorboardsWebApp.autoscaling) }}
{{- end }}

{{- define "kubeflow.tensorboard.tensorboardsWebApp.autoscaling.minReplicas" -}}
{{ include "kubeflow.component.autoscaling.minReplicas" (list .Values.defaults.autoscaling .Values.tensorboard.tensorboardsWebApp.autoscaling) }}
{{- end }}

{{- define "kubeflow.tensorboard.tensorboardsWebApp.autoscaling.maxReplicas" -}}
{{ include "kubeflow.component.autoscaling.maxReplicas" (list .Values.defaults.autoscaling .Values.tensorboard.tensorboardsWebApp.autoscaling) }}
{{- end }}

{{- define "kubeflow.tensorboard.tensorboardsWebApp.autoscaling.targetCPUUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetCPUUtilizationPercentage" (list .Values.defaults.autoscaling .Values.tensorboard.tensorboardsWebApp.autoscaling) }}
{{- end }}

{{- define "kubeflow.tensorboard.tensorboardsWebApp.autoscaling.targetMemoryUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetMemoryUtilizationPercentage" (list .Values.defaults.autoscaling .Values.tensorboard.tensorboardsWebApp.autoscaling) }}
{{- end }}

{{- define "kubeflow.tensorboard.tensorboardsWebApp.mainClusterRoleName" -}}
{{- printf "%s-%s"
    (include "kubeflow.fullname" .)
    (include "kubeflow.tensorboard.tensorboardsWebApp.name" .)
}}
{{- end }}

{{- define "kubeflow.tensorboard.tensorboardsWebApp.mainClusterRoleBindingName" -}}
{{- include "kubeflow.tensorboard.tensorboardsWebApp.mainClusterRoleName" . }}
{{- end }}

{{- define "kubeflow.tensorboard.tensorboardsWebApp.kfTenUiAdminClusterRoleName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) "tensorboards-ui-admin" }}
{{- end }}

{{- define "kubeflow.tensorboard.tensorboardsWebApp.kfTenUiEditClusterRoleName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) "tensorboards-ui-edit" }}
{{- end }}

{{- define "kubeflow.tensorboard.tensorboardsWebApp.kfTenUiViewClusterRoleName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) "tensorboards-ui-view" }}
{{- end }}

{{/*
Kubeflow Tensorboard Tensorboards Web App enable and create toggles.
*/}}
{{- define "kubeflow.tensorboard.tensorboardsWebApp.enabled" -}}
{{- ternary true "" (
    and
    (include "kubeflow.tensorboard.enabled" . | eq "true")
    .Values.tensorboard.tensorboardsWebApp.enabled
)}}
{{- end }}

{{- define "kubeflow.tensorboard.tensorboardsWebApp.createIstioIntegrationObjects" -}}
{{- ternary true "" (
    and
        .Values.istioIntegration.enabled
        (include "kubeflow.tensorboard.tensorboardsWebApp.enabled" . | eq "true" )
)}}
{{- end }}

{{- define "kubeflow.tensorboard.tensorboardsWebApp.rbac.createRoles" -}}
{{- ternary true "" (
    and
    (include "kubeflow.tensorboard.tensorboardsWebApp.enabled" . | eq "true")
    .Values.tensorboard.tensorboardsWebApp.rbac.create
)}}
{{- end }}

{{- define "kubeflow.tensorboard.tensorboardsWebApp.createServiceAccount" -}}
{{- ternary true "" (
and
    (include "kubeflow.tensorboard.tensorboardsWebApp.enabled" . | eq "true")
    .Values.tensorboard.tensorboardsWebApp.serviceAccount.create
)}}
{{- end }}

{{- define "kubeflow.tensorboard.tensorboardsWebApp.serviceAccountName" -}}
{{- include "kubeflow.component.serviceAccountName"  (list (include "kubeflow.tensorboard.tensorboardsWebApp.name" .) .Values.tensorboard.tensorboardsWebApp.serviceAccount) }}
{{- end }}

{{- define "kubeflow.tensorboard.tensorboardsWebApp.authorizationPolicyExtAuthName" -}}
{{ include "kubeflow.component.authorizationPolicyExtAuthName" (
    list
    (include "kubeflow.tensorboard.tensorboardsWebApp.name" .)
    .Values.istioIntegration
)}}
{{- end }}

{{/*
Kubeflow Tensorboard Tensorboards Web App Service.
*/}}
{{- define "kubeflow.tensorboard.tensorboardsWebApp.svc.name" -}}
{{ include "kubeflow.component.svc.name" (
    include "kubeflow.tensorboard.tensorboardsWebApp.name" .
)}}
{{- end }}

{{- define "kubeflow.tensorboard.tensorboardsWebApp.svc.addressWithNs" -}}
{{ include "kubeflow.component.svc.addressWithNs"  (
    list
    .
    (include "kubeflow.tensorboard.tensorboardsWebApp.name" .)
)}}
{{- end }}

{{- define "kubeflow.tensorboard.tensorboardsWebApp.svc.addressWithSvc" -}}
{{ include "kubeflow.component.svc.addressWithSvc"  (
    list
    .
    (include "kubeflow.tensorboard.tensorboardsWebApp.name" .)
)}}
{{- end }}

{{- define "kubeflow.tensorboard.tensorboardsWebApp.svc.fqdn" -}}
{{ include "kubeflow.component.svc.fqdn"  (
    list
    .
    (include "kubeflow.tensorboard.tensorboardsWebApp.name" .)
)}}
{{- end }}

{{/*
Kubeflow Tensorboard Tensorboards Web App Security Context.
*/}}
{{- define "kubeflow.tensorboard.tensorboardsWebApp.containerSecurityContext" -}}
{{ include "kubeflow.component.containerSecurityContext" (
    list
    .Values.defaults.containerSecurityContext
    .Values.tensorboard.tensorboardsWebApp.containerSecurityContext
)}}
{{- end }}

{{- define "kubeflow.tensorboard.tensorboardsWebApp.topologySpreadConstraints" -}}
{{ include "kubeflow.component.topologySpreadConstraints" (
    list
    .Values.defaults.topologySpreadConstraints
    .Values.tensorboard.tensorboardsWebApp.topologySpreadConstraints
)}}
{{- end }}

{{- define "kubeflow.tensorboard.tensorboardsWebApp.nodeSelector" -}}
{{ include "kubeflow.component.nodeSelector" (
    list
    .Values.defaults.nodeSelector
    .Values.tensorboard.tensorboardsWebApp.nodeSelector
)}}
{{- end }}

{{- define "kubeflow.tensorboard.tensorboardsWebApp.tolerations" -}}
{{ include "kubeflow.component.tolerations" (
    list
    .Values.defaults.tolerations
    .Values.tensorboard.tensorboardsWebApp.tolerations
)}}
{{- end }}

{{- define "kubeflow.tensorboard.tensorboardsWebApp.affinity" -}}
{{ include "kubeflow.component.affinity" (
    list
    .Values.defaults.affinity
    .Values.tensorboard.tensorboardsWebApp.affinity
)}}
{{- end }}

{{- define "kubeflow.tensorboard.tensorboardsWebApp.pdb.create" -}}
{{- include "kubeflow.component.pdb.create" (
    list
    (include "kubeflow.tensorboard.tensorboardsWebApp.enabled" .)
    .Values.defaults.podDisruptionBudget
    .Values.tensorboard.tensorboardsWebApp.podDisruptionBudget
)}}
{{- end }}

{{- define "kubeflow.tensorboard.tensorboardsWebApp.pdb.values" -}}
{{- include "kubeflow.component.pdb.values" (
    list
    .Values.defaults.podDisruptionBudget
    .Values.tensorboard.tensorboardsWebApp.podDisruptionBudget
)}}
{{- end }}
