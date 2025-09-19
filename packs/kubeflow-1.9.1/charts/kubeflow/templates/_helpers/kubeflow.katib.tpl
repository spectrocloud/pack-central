{{/*
Kubeflow Katib object names.
*/}}
{{- define "kubeflow.katib.baseName" -}}
{{- printf "katib" }}
{{- end }}

{{- define "kubeflow.katib.name" -}}
{{- include "kubeflow.component.name" (
    list
    (include "kubeflow.katib.baseName" .)
    .
)}}
{{- end }}

{{- define "kubeflow.katib.serviceAccountName" -}}
{{- include "kubeflow.component.serviceAccountName"  (
    list
    (include "kubeflow.katib.name" .)
    .Values.katib.serviceAccount
)}}
{{- end }}

{{- define "kubeflow.katib.serviceAccountPrincipal" -}}
{{- include "kubeflow.component.serviceAccountPrincipal" (
    list
    .
    (include "kubeflow.katib.serviceAccountName" .)
)}}
{{- end }}

{{- define "kubeflow.katib.mainClusterRoleName" -}}
{{- include "kubeflow.katib.name" . }}
{{- end }}

{{- define "kubeflow.katib.mainClusterRoleBindingName" -}}
{{- include "kubeflow.katib.mainClusterRoleName" . }}
{{- end }}

{{- define "kubeflow.katib.leaderElectionRoleName" -}}
{{- printf "%s-%s-%s"
    (include "kubeflow.fullname" .)
    (include "kubeflow.katib.name" .)
    "leader-election"
}}
{{- end }}

{{- define "kubeflow.katib.leaderElectionRoleBindingName" -}}
{{- include "kubeflow.katib.leaderElectionRoleName" . }}
{{- end }}

{{- define "kubeflow.katib.adminClusterRoleName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) "katib-admin" }}
{{- end }}

{{- define "kubeflow.katib.editClusterRoleName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) "katib-edit" }}
{{- end }}

{{- define "kubeflow.katib.viewClusterRoleName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) "katib-view" }}
{{- end }}

{{/*
Role Aggregation Rule Labels
*/}}
{{- define "kubeflow.katib.adminClusterRoleLabel" -}}
{{- include "kubeflow.aggregationRule.labelBase" (include "kubeflow.katib.adminClusterRoleName" .) -}}
{{- end }}

{{/*
Kubeflow Katib Controller Service.
*/}}
{{- define "kubeflow.katib.svc.name" -}}
{{ include "kubeflow.component.svc.name" (
    include "kubeflow.katib.name" .
)}}
{{- end }}

{{- define "kubeflow.katib.svc.addressWithNs" -}}
{{ include "kubeflow.component.svc.addressWithNs"  (
    list
    .
    (include "kubeflow.katib.name" .)
)}}
{{- end }}

{{- define "kubeflow.katib.svc.addressWithSvc" -}}
{{ include "kubeflow.component.svc.addressWithSvc"  (
    list
    .
    (include "kubeflow.katib.name" .)
)}}
{{- end }}

{{- define "kubeflow.katib.svc.fqdn" -}}
{{ include "kubeflow.component.svc.fqdn"  (
    list
    .
    (include "kubeflow.katib.name" .)
)}}
{{- end }}

{{/*
Kubeflow Katib Controller object labels.
*/}}
{{- define "kubeflow.katib.labels" -}}
{{ include "kubeflow.common.labels" . }}
{{ include "kubeflow.component.labels" (include "kubeflow.katib.name" .) }}
{{ include "kubeflow.component.subcomponent.labels" (include "kubeflow.katib.name" .) }}
{{- end }}

{{- define "kubeflow.katib.selectorLabels" -}}
{{ include "kubeflow.common.selectorLabels" . }}
{{ include "kubeflow.component.selectorLabels" (include "kubeflow.katib.name" .) }}
{{ include "kubeflow.component.subcomponent.labels" (include "kubeflow.katib.name" .) }}
{{- end }}

{{/*
Kubeflow Katib Controller container image settings.
*/}}
{{- define "kubeflow.katib.image" -}}
{{ include "kubeflow.component.image" (
    list
    .Values.defaults.image
    .Values.katib.image
)}}
{{- end }}

{{- define "kubeflow.katib.imagePullPolicy" -}}
{{ include "kubeflow.component.imagePullPolicy" (
    list
    .Values.defaults.image
    .Values.katib.image
)}}
{{- end }}

{{/*
Kubeflow Katib Controller Autoscaling and Availability.
*/}}
{{- define "kubeflow.katib.autoscaling.minReplicas" -}}
{{ include "kubeflow.component.autoscaling.minReplicas" (
    list
    .Values.defaults.autoscaling
    .Values.katib.autoscaling
)}}
{{- end }}

{{- define "kubeflow.katib.autoscaling.maxReplicas" -}}
{{ include "kubeflow.component.autoscaling.maxReplicas" (
    list
    .Values.defaults.autoscaling
    .Values.katib.autoscaling
)}}
{{- end }}

{{- define "kubeflow.katib.autoscaling.targetCPUUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetCPUUtilizationPercentage" (
    list
    .Values.defaults.autoscaling
    .Values.katib.autoscaling
)}}
{{- end }}

{{- define "kubeflow.katib.autoscaling.targetMemoryUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetMemoryUtilizationPercentage" (
    list
    .Values.defaults.autoscaling
    .Values.katib.autoscaling
)}}
{{- end }}

{{- define "kubeflow.katib.pdb.values" -}}
{{- include "kubeflow.component.pdb.values" (
    list
    .Values.defaults.podDisruptionBudget
    .Values.katib.podDisruptionBudget
)}}
{{- end }}

{{/*
Kubeflow Katib Controller Security Context.
*/}}
{{- define "kubeflow.katib.containerSecurityContext" -}}
{{ include "kubeflow.component.containerSecurityContext" (
    list
    .Values.defaults.containerSecurityContext
    .Values.katib.containerSecurityContext
)}}
{{- end }}

{{/*
Kubeflow Katib Controller Scheduling.
*/}}
{{- define "kubeflow.katib.topologySpreadConstraints" -}}
{{ include "kubeflow.component.topologySpreadConstraints" (
    list
    .Values.defaults.topologySpreadConstraints
    .Values.katib.topologySpreadConstraints
)}}
{{- end }}

{{- define "kubeflow.katib.nodeSelector" -}}
{{ include "kubeflow.component.nodeSelector" (
    list
    .Values.defaults.nodeSelector
    .Values.katib.nodeSelector
)}}
{{- end }}

{{- define "kubeflow.katib.tolerations" -}}
{{ include "kubeflow.component.tolerations" (
    list
    .Values.defaults.tolerations
    .Values.katib.tolerations
)}}
{{- end }}

{{- define "kubeflow.katib.affinity" -}}
{{ include "kubeflow.component.affinity" (
    list
    .Values.defaults.affinity
    .Values.katib.affinity
)}}
{{- end }}

{{/*
Kubeflow Katib enable and create toggles.
*/}}
{{- define "kubeflow.katib.enabled" -}}
{{- ternary true "" .Values.katib.enabled }}
{{- end }}

{{- define "kubeflow.katib.autoscaling.enabled" -}}
{{ include "kubeflow.component.autoscaling.enabled" (
    list
    .Values.defaults.autoscaling
    .Values.katib.autoscaling
)}}
{{- end }}

{{- define "kubeflow.katib.rbac.createRoles" -}}
{{- ternary true "" (
    and
    (include "kubeflow.katib.enabled" . | eq "true")
    .Values.katib.rbac.create
)}}
{{- end }}

{{- define "kubeflow.katib.createServiceAccount" -}}
{{- ternary true "" (
and
    (include "kubeflow.katib.enabled" . | eq "true")
    .Values.katib.serviceAccount.create
)}}
{{- end }}

{{- define "kubeflow.katib.pdb.create" -}}
{{- include "kubeflow.component.pdb.create" (
    list
    (include "kubeflow.katib.enabled" .)
    .Values.defaults.podDisruptionBudget
    .Values.katib.podDisruptionBudget
)}}
{{- end }}
