{{/*
Kubeflow Katib ui object names.
*/}}
{{- define "kubeflow.katib.ui.baseName" -}}
{{- printf "katib-ui" }}
{{- end }}

{{- define "kubeflow.katib.ui.name" -}}
{{- include "kubeflow.component.name" (
    list
    (include "kubeflow.katib.ui.baseName" .)
    .
)}}
{{- end }}

{{- define "kubeflow.katib.ui.serviceAccountName" -}}
{{- include "kubeflow.component.serviceAccountName"  (
    list
    (include "kubeflow.katib.ui.name" .)
    .Values.katib.ui.serviceAccount
)}}
{{- end }}

{{- define "kubeflow.katib.ui.serviceAccountPrincipal" -}}
{{- include "kubeflow.component.serviceAccountPrincipal" (
    list
    .
    (include "kubeflow.katib.ui.serviceAccountName" .)
)}}
{{- end }}

{{- define "kubeflow.katib.ui.mainClusterRoleName" -}}
{{- include "kubeflow.katib.ui.name" . }}
{{- end }}

{{- define "kubeflow.katib.ui.mainClusterRoleBindingName" -}}
{{- include "kubeflow.katib.ui.mainClusterRoleName" . }}
{{- end }}

{{- define "kubeflow.katib.ui.leaderElectionRoleName" -}}
{{- printf "%s-%s-%s"
    (include "kubeflow.fullname" .)
    (include "kubeflow.katib.ui.name" .)
    "leader-election"
}}
{{- end }}

{{- define "kubeflow.katib.ui.leaderElectionRoleBindingName" -}}
{{- include "kubeflow.katib.ui.leaderElectionRoleName" . }}
{{- end }}

{{- define "kubeflow.katib.ui.kfNbAdminClusterRoleName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) "katib-admin" }}
{{- end }}

{{- define "kubeflow.katib.ui.kfNbEditClusterRoleName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) "katib-edit" }}
{{- end }}

{{- define "kubeflow.katib.ui.kfNbViewClusterRoleName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) "katib-view" }}
{{- end }}

{{/*
Role Aggregation Rule Labels
*/}}
{{- define "kubeflow.katib.ui.kfNbAdminClusterRoleLabel" -}}
{{- include "kubeflow.aggregationRule.labelBase" (include "kubeflow.katib.ui.kfNbAdminClusterRoleName" .) -}}
{{- end }}

{{/*
Kubeflow Katib ui Service.
*/}}
{{- define "kubeflow.katib.ui.svc.name" -}}
{{ include "kubeflow.component.svc.name" (
    include "kubeflow.katib.ui.name" .
)}}
{{- end }}

{{- define "kubeflow.katib.ui.svc.addressWithNs" -}}
{{ include "kubeflow.component.svc.addressWithNs"  (
    list
    .
    (include "kubeflow.katib.ui.name" .)
)}}
{{- end }}

{{- define "kubeflow.katib.ui.svc.addressWithSvc" -}}
{{ include "kubeflow.component.svc.addressWithSvc"  (
    list
    .
    (include "kubeflow.katib.ui.name" .)
)}}
{{- end }}

{{- define "kubeflow.katib.ui.svc.fqdn" -}}
{{ include "kubeflow.component.svc.fqdn"  (
    list
    .
    (include "kubeflow.katib.ui.name" .)
)}}
{{- end }}

{{/*
Kubeflow Katib ui object labels.
*/}}
{{- define "kubeflow.katib.ui.labels" -}}
{{ include "kubeflow.common.labels" . }}
{{ include "kubeflow.component.labels" (include "kubeflow.katib.name" .) }}
{{ include "kubeflow.component.subcomponent.labels" (include "kubeflow.katib.ui.name" .) }}
{{- end }}

{{- define "kubeflow.katib.ui.selectorLabels" -}}
{{ include "kubeflow.common.selectorLabels" . }}
{{ include "kubeflow.component.selectorLabels" (include "kubeflow.katib.name" .) }}
{{ include "kubeflow.component.subcomponent.labels" (include "kubeflow.katib.ui.name" .) }}
{{- end }}

{{/*
Kubeflow Katib ui container image settings.
*/}}
{{- define "kubeflow.katib.ui.image" -}}
{{ include "kubeflow.component.image" (
    list
    .Values.defaults.image
    .Values.katib.ui.image
)}}
{{- end }}

{{- define "kubeflow.katib.ui.imagePullPolicy" -}}
{{ include "kubeflow.component.imagePullPolicy" (
    list
    .Values.defaults.image
    .Values.katib.ui.image
)}}
{{- end }}

{{/*
Kubeflow Katib ui Autoscaling and Availability.
*/}}
{{- define "kubeflow.katib.ui.autoscaling.minReplicas" -}}
{{ include "kubeflow.component.autoscaling.minReplicas" (
    list
    .Values.defaults.autoscaling
    .Values.katib.ui.autoscaling
)}}
{{- end }}

{{- define "kubeflow.katib.ui.autoscaling.maxReplicas" -}}
{{ include "kubeflow.component.autoscaling.maxReplicas" (
    list
    .Values.defaults.autoscaling
    .Values.katib.ui.autoscaling
)}}
{{- end }}

{{- define "kubeflow.katib.ui.autoscaling.targetCPUUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetCPUUtilizationPercentage" (
    list
    .Values.defaults.autoscaling
    .Values.katib.ui.autoscaling
)}}
{{- end }}

{{- define "kubeflow.katib.ui.autoscaling.targetMemoryUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetMemoryUtilizationPercentage" (
    list
    .Values.defaults.autoscaling
    .Values.katib.ui.autoscaling
)}}
{{- end }}

{{- define "kubeflow.katib.ui.pdb.values" -}}
{{- include "kubeflow.component.pdb.values" (
    list
    .Values.defaults.podDisruptionBudget
    .Values.katib.ui.podDisruptionBudget
)}}
{{- end }}

{{/*
Kubeflow Katib ui Security Context.
*/}}
{{- define "kubeflow.katib.ui.containerSecurityContext" -}}
{{ include "kubeflow.component.containerSecurityContext" (
    list
    .Values.defaults.containerSecurityContext
    .Values.katib.ui.containerSecurityContext
)}}
{{- end }}

{{/*
Kubeflow Katib ui Scheduling.
*/}}
{{- define "kubeflow.katib.ui.topologySpreadConstraints" -}}
{{ include "kubeflow.component.topologySpreadConstraints" (
    list
    .Values.defaults.topologySpreadConstraints
    .Values.katib.ui.topologySpreadConstraints
)}}
{{- end }}

{{- define "kubeflow.katib.ui.nodeSelector" -}}
{{ include "kubeflow.component.nodeSelector" (
    list
    .Values.defaults.nodeSelector
    .Values.katib.ui.nodeSelector
)}}
{{- end }}

{{- define "kubeflow.katib.ui.tolerations" -}}
{{ include "kubeflow.component.tolerations" (
    list
    .Values.defaults.tolerations
    .Values.katib.ui.tolerations
)}}
{{- end }}

{{- define "kubeflow.katib.ui.affinity" -}}
{{ include "kubeflow.component.affinity" (
    list
    .Values.defaults.affinity
    .Values.katib.ui.affinity
)}}
{{- end }}

{{/*
Kubeflow Katib ui enable and create toggles.
*/}}
{{- define "kubeflow.katib.ui.enabled" -}}
{{- ternary true "" (
    and
    (include "kubeflow.katib.enabled" . | eq "true")
    .Values.katib.ui.enabled
)}}
{{- end }}

{{- define "kubeflow.katib.ui.autoscaling.enabled" -}}
{{ include "kubeflow.component.autoscaling.enabled" (
    list
    .Values.defaults.autoscaling
    .Values.katib.ui.autoscaling
)}}
{{- end }}

{{- define "kubeflow.katib.ui.rbac.createRoles" -}}
{{- ternary true "" (
    and
    (include "kubeflow.katib.ui.enabled" . | eq "true")
    .Values.katib.ui.rbac.create
)}}
{{- end }}

{{- define "kubeflow.katib.ui.createServiceAccount" -}}
{{- ternary true "" (
and
    (include "kubeflow.katib.ui.enabled" . | eq "true")
    .Values.katib.ui.serviceAccount.create
)}}
{{- end }}

{{- define "kubeflow.katib.ui.pdb.create" -}}
{{- include "kubeflow.component.pdb.create" (
    list
    (include "kubeflow.katib.ui.enabled" .)
    .Values.defaults.podDisruptionBudget
    .Values.katib.ui.podDisruptionBudget
)}}
{{- end }}

{{- define "kubeflow.katib.ui.createIstioIntegrationObjects" -}}
{{- ternary true "" (
    and
        (include "kubeflow.katib.ui.enabled" . | eq "true" )
        .Values.istioIntegration.enabled
)}}
{{- end }}
