{{/*
Kubeflow Notebooks Volumes Web App object names.
*/}}
{{- define "kubeflow.notebooks.volumesWebApp.baseName" -}}
{{- printf "volumes-web-app" }}
{{- end }}

{{- define "kubeflow.notebooks.volumesWebApp.name" -}}
{{- include "kubeflow.component.name" (
    list
    (include "kubeflow.notebooks.volumesWebApp.baseName" .)
    .
)}}
{{- end }}

{{/*
Kubeflow Notebooks Volumes Web App object labels.
*/}}
{{- define "kubeflow.notebooks.volumesWebApp.labels" -}}
{{ include "kubeflow.common.labels" . }}
{{ include "kubeflow.component.labels" (include "kubeflow.notebooks.name" .) }}
{{ include "kubeflow.component.subcomponent.labels" (include "kubeflow.notebooks.volumesWebApp.name" .) }}
{{- end }}

{{- define "kubeflow.notebooks.volumesWebApp.selectorLabels" -}}
{{ include "kubeflow.common.selectorLabels" . }}
{{ include "kubeflow.component.selectorLabels" (include "kubeflow.notebooks.name" .) }}
{{ include "kubeflow.component.subcomponent.labels" (include "kubeflow.notebooks.volumesWebApp.name" .) }}
{{- end }}

{{- define "kubeflow.notebooks.volumesWebApp.image" -}}
{{ include "kubeflow.component.image" (list .Values.defaults.image .Values.notebooks.volumesWebApp.image) }}
{{- end }}

{{- define "kubeflow.notebooks.volumesWebApp.viewerImage" -}}
{{ include "kubeflow.component.image" (list .Values.defaults.image .Values.notebooks.volumesWebApp.config.viewer.image) }}
{{- end }}

{{- define "kubeflow.notebooks.volumesWebApp.imagePullPolicy" -}}
{{ include "kubeflow.component.imagePullPolicy" (list .Values.defaults.image .Values.notebooks.volumesWebApp.image) }}
{{- end }}

{{- define "kubeflow.notebooks.volumesWebApp.autoscaling.enabled" -}}
{{ include "kubeflow.component.autoscaling.enabled" (list .Values.defaults.autoscaling .Values.notebooks.volumesWebApp.autoscaling) }}
{{- end }}

{{- define "kubeflow.notebooks.volumesWebApp.autoscaling.minReplicas" -}}
{{ include "kubeflow.component.autoscaling.minReplicas" (list .Values.defaults.autoscaling .Values.notebooks.volumesWebApp.autoscaling) }}
{{- end }}

{{- define "kubeflow.notebooks.volumesWebApp.autoscaling.maxReplicas" -}}
{{ include "kubeflow.component.autoscaling.maxReplicas" (list .Values.defaults.autoscaling .Values.notebooks.volumesWebApp.autoscaling) }}
{{- end }}

{{- define "kubeflow.notebooks.volumesWebApp.autoscaling.targetCPUUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetCPUUtilizationPercentage" (list .Values.defaults.autoscaling .Values.notebooks.volumesWebApp.autoscaling) }}
{{- end }}

{{- define "kubeflow.notebooks.volumesWebApp.autoscaling.targetMemoryUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetMemoryUtilizationPercentage" (list .Values.defaults.autoscaling .Values.notebooks.volumesWebApp.autoscaling) }}
{{- end }}


{{- define "kubeflow.notebooks.volumesWebApp.configMapName" -}}
{{- printf "%s-%s" (include "kubeflow.notebooks.volumesWebApp.name" .) "viewer-spec" }}
{{- end }}

{{- define "kubeflow.notebooks.volumesWebApp.mainClusterRoleName" -}}
{{- printf "%s-%s"
    (include "kubeflow.fullname" .)
    (include "kubeflow.notebooks.volumesWebApp.name" .)
}}
{{- end }}

{{- define "kubeflow.notebooks.volumesWebApp.mainClusterRoleBindingName" -}}
{{- include "kubeflow.notebooks.volumesWebApp.mainClusterRoleName" . }}
{{- end }}

{{- define "kubeflow.notebooks.volumesWebApp.kfVolUiAdminClusterRoleName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) "volumes-ui-admin" }}
{{- end }}

{{- define "kubeflow.notebooks.volumesWebApp.kfVolUiEditClusterRoleName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) "volumes-ui-edit" }}
{{- end }}

{{- define "kubeflow.notebooks.volumesWebApp.kfVolUiViewClusterRoleName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) "volumes-ui-view" }}
{{- end }}

{{/*
Kubeflow Notebooks Volumes Web App enable and create toggles.
*/}}
{{- define "kubeflow.notebooks.volumesWebApp.enabled" -}}
{{- ternary true "" (
    and
    (include "kubeflow.notebooks.enabled" . | eq "true")
    .Values.notebooks.volumesWebApp.enabled
)}}
{{- end }}

{{- define "kubeflow.notebooks.volumesWebApp.createIstioIntegrationObjects" -}}
{{- ternary true "" (
    and
        .Values.istioIntegration.enabled
        (include "kubeflow.notebooks.volumesWebApp.enabled" . | eq "true" )
)}}
{{- end }}

{{- define "kubeflow.notebooks.volumesWebApp.rbac.createRoles" -}}
{{- ternary true "" (
    and
    (include "kubeflow.notebooks.volumesWebApp.enabled" . | eq "true")
    .Values.notebooks.volumesWebApp.rbac.create
)}}
{{- end }}

{{- define "kubeflow.notebooks.volumesWebApp.createServiceAccount" -}}
{{- ternary true "" (
and
    (include "kubeflow.notebooks.volumesWebApp.enabled" . | eq "true")
    .Values.notebooks.volumesWebApp.serviceAccount.create
)}}
{{- end }}

{{- define "kubeflow.notebooks.volumesWebApp.serviceAccountName" -}}
{{- include "kubeflow.component.serviceAccountName"  (list (include "kubeflow.notebooks.volumesWebApp.name" .) .Values.notebooks.volumesWebApp.serviceAccount) }}
{{- end }}

{{- define "kubeflow.notebooks.volumesWebApp.authorizationPolicyExtAuthName" -}}
{{ include "kubeflow.component.authorizationPolicyExtAuthName" (
    list
    (include "kubeflow.notebooks.volumesWebApp.name" .)
    .Values.istioIntegration
)}}
{{- end }}

{{/*
Kubeflow Notebooks Volumes Web App Service.
*/}}
{{- define "kubeflow.notebooks.volumesWebApp.svc.name" -}}
{{ include "kubeflow.component.svc.name" (
    include "kubeflow.notebooks.volumesWebApp.name" .
)}}
{{- end }}

{{- define "kubeflow.notebooks.volumesWebApp.svc.addressWithNs" -}}
{{ include "kubeflow.component.svc.addressWithNs"  (
    list
    .
    (include "kubeflow.notebooks.volumesWebApp.name" .)
)}}
{{- end }}

{{- define "kubeflow.notebooks.volumesWebApp.svc.addressWithSvc" -}}
{{ include "kubeflow.component.svc.addressWithSvc"  (
    list
    .
    (include "kubeflow.notebooks.volumesWebApp.name" .)
)}}
{{- end }}

{{- define "kubeflow.notebooks.volumesWebApp.svc.fqdn" -}}
{{ include "kubeflow.component.svc.fqdn"  (
    list
    .
    (include "kubeflow.notebooks.volumesWebApp.name" .)
)}}
{{- end }}

{{/*
Kubeflow Notebooks Volumes Web App Security Context.
*/}}
{{- define "kubeflow.notebooks.volumesWebApp.containerSecurityContext" -}}
{{ include "kubeflow.component.containerSecurityContext" (
    list
    .Values.defaults.containerSecurityContext
    .Values.notebooks.volumesWebApp.containerSecurityContext
)}}
{{- end }}

{{- define "kubeflow.notebooks.volumesWebApp.topologySpreadConstraints" -}}
{{ include "kubeflow.component.topologySpreadConstraints" (
    list
    .Values.defaults.topologySpreadConstraints
    .Values.notebooks.volumesWebApp.topologySpreadConstraints
)}}
{{- end }}

{{- define "kubeflow.notebooks.volumesWebApp.nodeSelector" -}}
{{ include "kubeflow.component.nodeSelector" (
    list
    .Values.defaults.nodeSelector
    .Values.notebooks.volumesWebApp.nodeSelector
)}}
{{- end }}

{{- define "kubeflow.notebooks.volumesWebApp.tolerations" -}}
{{ include "kubeflow.component.tolerations" (
    list
    .Values.defaults.tolerations
    .Values.notebooks.volumesWebApp.tolerations
)}}
{{- end }}

{{- define "kubeflow.notebooks.volumesWebApp.affinity" -}}
{{ include "kubeflow.component.affinity" (
    list
    .Values.defaults.affinity
    .Values.notebooks.volumesWebApp.affinity
)}}
{{- end }}

{{- define "kubeflow.notebooks.volumesWebApp.pdb.create" -}}
{{- include "kubeflow.component.pdb.create" (
    list
    (include "kubeflow.notebooks.volumesWebApp.enabled" .)
    .Values.defaults.podDisruptionBudget
    .Values.notebooks.volumesWebApp.podDisruptionBudget
)}}
{{- end }}

{{- define "kubeflow.notebooks.volumesWebApp.pdb.values" -}}
{{- include "kubeflow.component.pdb.values" (
    list
    .Values.defaults.podDisruptionBudget
    .Values.notebooks.volumesWebApp.podDisruptionBudget
)}}
{{- end }}
