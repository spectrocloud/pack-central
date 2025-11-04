{{/*
Kubeflow Notebooks Controller object names.
*/}}
{{- define "kubeflow.notebooks.controller.baseName" -}}
{{- printf "notebooks-controller" }}
{{- end }}

{{- define "kubeflow.notebooks.controller.name" -}}
{{- include "kubeflow.component.name" (
    list
    (include "kubeflow.notebooks.controller.baseName" .)
    .
)}}
{{- end }}

{{- define "kubeflow.notebooks.controller.serviceAccountName" -}}
{{- include "kubeflow.component.serviceAccountName"  (
    list
    (include "kubeflow.notebooks.controller.name" .)
    .Values.notebooks.controller.serviceAccount
)}}
{{- end }}

{{- define "kubeflow.notebooks.controller.serviceAccountPrincipal" -}}
{{- include "kubeflow.component.serviceAccountPrincipal" (
    list
    .
    (include "kubeflow.notebooks.controller.serviceAccountName" .)
)}}
{{- end }}

{{- define "kubeflow.notebooks.controller.mainClusterRoleName" -}}
{{- printf "%s-%s"
    (include "kubeflow.fullname" .)
    (include "kubeflow.notebooks.controller.name" .)
}}
{{- end }}

{{- define "kubeflow.notebooks.controller.mainClusterRoleBindingName" -}}
{{- include "kubeflow.notebooks.controller.mainClusterRoleName" . }}
{{- end }}

{{- define "kubeflow.notebooks.controller.leaderElectionRoleName" -}}
{{- printf "%s-%s-%s"
    (include "kubeflow.fullname" .)
    (include "kubeflow.notebooks.controller.name" .)
    "leader-election"
}}
{{- end }}

{{- define "kubeflow.notebooks.controller.leaderElectionRoleBindingName" -}}
{{- include "kubeflow.notebooks.controller.leaderElectionRoleName" . }}
{{- end }}

{{- define "kubeflow.notebooks.controller.kfNbAdminClusterRoleName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) "notebooks-admin" }}
{{- end }}

{{- define "kubeflow.notebooks.controller.kfNbEditClusterRoleName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) "notebooks-edit" }}
{{- end }}

{{- define "kubeflow.notebooks.controller.kfNbViewClusterRoleName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) "notebooks-view" }}
{{- end }}

{{/*
Role Aggregation Rule Labels
*/}}
{{- define "kubeflow.notebooks.controller.kfNbAdminClusterRoleLabel" -}}
{{- include "kubeflow.aggregationRule.labelBase" (include "kubeflow.notebooks.controller.kfNbAdminClusterRoleName" .) -}}
{{- end }}

{{/*
Kubeflow Notebooks Controller Service.
*/}}
{{- define "kubeflow.notebooks.controller.svc.name" -}}
{{ include "kubeflow.component.svc.name" (
    include "kubeflow.notebooks.controller.name" .
)}}
{{- end }}

{{- define "kubeflow.notebooks.controller.svc.addressWithNs" -}}
{{ include "kubeflow.component.svc.addressWithNs"  (
    list
    .
    (include "kubeflow.notebooks.controller.name" .)
)}}
{{- end }}

{{- define "kubeflow.notebooks.controller.svc.addressWithSvc" -}}
{{ include "kubeflow.component.svc.addressWithSvc"  (
    list
    .
    (include "kubeflow.notebooks.controller.name" .)
)}}
{{- end }}

{{- define "kubeflow.notebooks.controller.svc.fqdn" -}}
{{ include "kubeflow.component.svc.fqdn"  (
    list
    .
    (include "kubeflow.notebooks.controller.name" .)
)}}
{{- end }}

{{/*
Kubeflow Notebooks Controller object labels.
*/}}
{{- define "kubeflow.notebooks.controller.labels" -}}
{{ include "kubeflow.common.labels" . }}
{{ include "kubeflow.component.labels" (include "kubeflow.notebooks.name" .) }}
{{ include "kubeflow.component.subcomponent.labels" (include "kubeflow.notebooks.controller.name" .) }}
{{- end }}

{{- define "kubeflow.notebooks.controller.selectorLabels" -}}
{{ include "kubeflow.common.selectorLabels" . }}
{{ include "kubeflow.component.selectorLabels" (include "kubeflow.notebooks.name" .) }}
{{ include "kubeflow.component.subcomponent.labels" (include "kubeflow.notebooks.controller.name" .) }}
{{- end }}

{{/*
Kubeflow Notebooks Controller container image settings.
*/}}
{{- define "kubeflow.notebooks.controller.image" -}}
{{ include "kubeflow.component.image" (
    list
    .Values.defaults.image
    .Values.notebooks.controller.image
)}}
{{- end }}

{{- define "kubeflow.notebooks.controller.imagePullPolicy" -}}
{{ include "kubeflow.component.imagePullPolicy" (
    list
    .Values.defaults.image
    .Values.notebooks.controller.image
)}}
{{- end }}

{{/*
Kubeflow Notebooks Controller Autoscaling and Availability.
*/}}
{{- define "kubeflow.notebooks.controller.autoscaling.minReplicas" -}}
{{ include "kubeflow.component.autoscaling.minReplicas" (
    list
    .Values.defaults.autoscaling
    .Values.notebooks.controller.autoscaling
)}}
{{- end }}

{{- define "kubeflow.notebooks.controller.autoscaling.maxReplicas" -}}
{{ include "kubeflow.component.autoscaling.maxReplicas" (
    list
    .Values.defaults.autoscaling
    .Values.notebooks.controller.autoscaling
)}}
{{- end }}

{{- define "kubeflow.notebooks.controller.autoscaling.targetCPUUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetCPUUtilizationPercentage" (
    list
    .Values.defaults.autoscaling
    .Values.notebooks.controller.autoscaling
)}}
{{- end }}

{{- define "kubeflow.notebooks.controller.autoscaling.targetMemoryUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetMemoryUtilizationPercentage" (
    list
    .Values.defaults.autoscaling
    .Values.notebooks.controller.autoscaling
)}}
{{- end }}

{{- define "kubeflow.notebooks.controller.pdb.values" -}}
{{- include "kubeflow.component.pdb.values" (
    list
    .Values.defaults.podDisruptionBudget
    .Values.notebooks.controller.podDisruptionBudget
)}}
{{- end }}

{{/*
Kubeflow Notebooks Controller Security Context.
*/}}
{{- define "kubeflow.notebooks.controller.containerSecurityContext" -}}
{{ include "kubeflow.component.containerSecurityContext" (
    list
    .Values.defaults.containerSecurityContext
    .Values.notebooks.controller.containerSecurityContext
)}}
{{- end }}

{{/*
Kubeflow Notebooks Controller Scheduling.
*/}}
{{- define "kubeflow.notebooks.controller.topologySpreadConstraints" -}}
{{ include "kubeflow.component.topologySpreadConstraints" (
    list
    .Values.defaults.topologySpreadConstraints
    .Values.notebooks.controller.topologySpreadConstraints
)}}
{{- end }}

{{- define "kubeflow.notebooks.controller.nodeSelector" -}}
{{ include "kubeflow.component.nodeSelector" (
    list
    .Values.defaults.nodeSelector
    .Values.notebooks.controller.nodeSelector
)}}
{{- end }}

{{- define "kubeflow.notebooks.controller.tolerations" -}}
{{ include "kubeflow.component.tolerations" (
    list
    .Values.defaults.tolerations
    .Values.notebooks.controller.tolerations
)}}
{{- end }}

{{- define "kubeflow.notebooks.controller.affinity" -}}
{{ include "kubeflow.component.affinity" (
    list
    .Values.defaults.affinity
    .Values.notebooks.controller.affinity
)}}
{{- end }}

{{/*
Kubeflow Notebooks Controller enable and create toggles.
*/}}
{{- define "kubeflow.notebooks.controller.enabled" -}}
{{- ternary true "" (
    and
    (include "kubeflow.notebooks.enabled" . | eq "true")
    .Values.notebooks.controller.enabled
)}}
{{- end }}

{{- define "kubeflow.notebooks.controller.autoscaling.enabled" -}}
{{ include "kubeflow.component.autoscaling.enabled" (
    list
    .Values.defaults.autoscaling
    .Values.notebooks.controller.autoscaling
)}}
{{- end }}

{{- define "kubeflow.notebooks.controller.rbac.createRoles" -}}
{{- ternary true "" (
    and
    (include "kubeflow.notebooks.controller.enabled" . | eq "true")
    .Values.notebooks.controller.rbac.create
)}}
{{- end }}

{{- define "kubeflow.notebooks.controller.createServiceAccount" -}}
{{- ternary true "" (
and
    (include "kubeflow.notebooks.controller.enabled" . | eq "true")
    .Values.notebooks.controller.serviceAccount.create
)}}
{{- end }}

{{- define "kubeflow.notebooks.controller.pdb.create" -}}
{{- include "kubeflow.component.pdb.create" (
    list
    (include "kubeflow.notebooks.controller.enabled" .)
    .Values.defaults.podDisruptionBudget
    .Values.notebooks.controller.podDisruptionBudget
)}}
{{- end }}
