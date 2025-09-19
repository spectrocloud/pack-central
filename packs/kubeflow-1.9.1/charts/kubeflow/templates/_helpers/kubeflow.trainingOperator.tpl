{{/*
Kubeflow Training Operator object names.
*/}}
{{- define "kubeflow.trainingOperator.baseName" -}}
{{- printf "training-operator" }}
{{- end }}

{{- define "kubeflow.trainingOperator.name" -}}
{{- include "kubeflow.component.name" (
    list
    (include "kubeflow.trainingOperator.baseName" .)
    .
)}}
{{- end }}

{{- define "kubeflow.trainingOperator.serviceAccountName" -}}
{{- include "kubeflow.component.serviceAccountName"  (
    list
    (include "kubeflow.trainingOperator.name" .)
    .Values.trainingOperator.serviceAccount
)}}
{{- end }}

{{- define "kubeflow.trainingOperator.mainClusterRoleName" -}}
{{- printf "%s-%s"
    (include "kubeflow.fullname" .)
    (include "kubeflow.trainingOperator.name" .)
}}
{{- end }}

{{- define "kubeflow.trainingOperator.mainClusterRoleBindingName" -}}
{{- include "kubeflow.trainingOperator.mainClusterRoleName" . }}
{{- end }}

{{- define "kubeflow.trainingOperator.kfTrAdminClusterRoleName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) "training-admin" }}
{{- end }}

{{- define "kubeflow.trainingOperator.kfTrEditClusterRoleName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) "training-edit" }}
{{- end }}

{{- define "kubeflow.trainingOperator.kfTrViewClusterRoleName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) "training-view" }}
{{- end }}

{{/*
Role Aggregation Rule Labels
*/}}
{{- define "kubeflow.trainingOperator.kfTrAdminClusterRoleLabel" -}}
{{- include "kubeflow.aggregationRule.labelBase" (include "kubeflow.trainingOperator.kfTrAdminClusterRoleName" .) -}}
{{- end }}

{{/*
Kubeflow Training Operator Service.
*/}}
{{- define "kubeflow.trainingOperator.svc.name" -}}
{{ include "kubeflow.component.svc.name" (
    include "kubeflow.trainingOperator.name" .
)}}
{{- end }}

{{/*
Kubeflow Training Operator object labels.
*/}}
{{- define "kubeflow.trainingOperator.labels" -}}
{{ include "kubeflow.common.labels" . }}
{{ include "kubeflow.component.labels" (include "kubeflow.trainingOperator.name" .) }}
{{- end }}

{{- define "kubeflow.trainingOperator.selectorLabels" -}}
{{ include "kubeflow.common.selectorLabels" . }}
{{ include "kubeflow.component.selectorLabels" (include "kubeflow.trainingOperator.name" .) }}
{{- end }}

{{/*
Kubeflow Training Operator container image settings.
*/}}
{{- define "kubeflow.trainingOperator.image" -}}
{{ include "kubeflow.component.image" (
    list
    .Values.defaults.image
    .Values.trainingOperator.image
)}}
{{- end }}

{{- define "kubeflow.trainingOperator.imagePullPolicy" -}}
{{ include "kubeflow.component.imagePullPolicy" (
    list
    .Values.defaults.image
    .Values.trainingOperator.image
)}}
{{- end }}

{{/*
Kubeflow Training Operator Autoscaling and Availability.
*/}}
{{- define "kubeflow.trainingOperator.autoscaling.minReplicas" -}}
{{ include "kubeflow.component.autoscaling.minReplicas" (
    list
    .Values.defaults.autoscaling
    .Values.trainingOperator.autoscaling
)}}
{{- end }}

{{- define "kubeflow.trainingOperator.autoscaling.maxReplicas" -}}
{{ include "kubeflow.component.autoscaling.maxReplicas" (
    list
    .Values.defaults.autoscaling
    .Values.trainingOperator.autoscaling
)}}
{{- end }}

{{- define "kubeflow.trainingOperator.autoscaling.targetCPUUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetCPUUtilizationPercentage" (
    list
    .Values.defaults.autoscaling
    .Values.trainingOperator.autoscaling
)}}
{{- end }}

{{- define "kubeflow.trainingOperator.autoscaling.targetMemoryUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetMemoryUtilizationPercentage" (
    list
    .Values.defaults.autoscaling
    .Values.trainingOperator.autoscaling
)}}
{{- end }}

{{- define "kubeflow.trainingOperator.pdb.values" -}}
{{- include "kubeflow.component.pdb.values" (
    list
    .Values.defaults.podDisruptionBudget
    .Values.trainingOperator.podDisruptionBudget
)}}
{{- end }}

{{/*
Kubeflow Training Operator Security Context.
*/}}
{{- define "kubeflow.trainingOperator.containerSecurityContext" -}}
{{ include "kubeflow.component.containerSecurityContext" (
    list
    .Values.defaults.containerSecurityContext
    .Values.trainingOperator.containerSecurityContext
)}}
{{- end }}

{{/*
Kubeflow Training Operator Scheduling.
*/}}
{{- define "kubeflow.trainingOperator.topologySpreadConstraints" -}}
{{ include "kubeflow.component.topologySpreadConstraints" (
    list
    .Values.defaults.topologySpreadConstraints
    .Values.trainingOperator.topologySpreadConstraints
)}}
{{- end }}

{{- define "kubeflow.trainingOperator.nodeSelector" -}}
{{ include "kubeflow.component.nodeSelector" (
    list
    .Values.defaults.nodeSelector
    .Values.trainingOperator.nodeSelector
)}}
{{- end }}

{{- define "kubeflow.trainingOperator.tolerations" -}}
{{ include "kubeflow.component.tolerations" (
    list
    .Values.defaults.tolerations
    .Values.trainingOperator.tolerations
)}}
{{- end }}

{{- define "kubeflow.trainingOperator.affinity" -}}
{{ include "kubeflow.component.affinity" (
    list
    .Values.defaults.affinity
    .Values.trainingOperator.affinity
)}}
{{- end }}

{{- define "kubeflow.trainingOperator.terminationGracePeriodSeconds" -}}
{{ include "kubeflow.component.terminationGracePeriodSeconds" (
    list
    .Values.defaults.terminationGracePeriodSeconds
    .Values.trainingOperator.terminationGracePeriodSeconds
)}}
{{- end }}

{{/*
Kubeflow Training Operator enable and create toggles.
*/}}
{{- define "kubeflow.trainingOperator.enabled" -}}
{{- .Values.trainingOperator.enabled }}
{{- end }}

{{- define "kubeflow.trainingOperator.autoscaling.enabled" -}}
{{ include "kubeflow.component.autoscaling.enabled" (
    list
    .Values.defaults.autoscaling
    .Values.trainingOperator.autoscaling
)}}
{{- end }}

{{- define "kubeflow.trainingOperator.rbac.createRoles" -}}
{{- ternary true "" (
    and
    (include "kubeflow.trainingOperator.enabled" . | eq "true")
    .Values.trainingOperator.rbac.create
)}}
{{- end }}

{{- define "kubeflow.trainingOperator.createServiceAccount" -}}
{{- ternary true "" (
and
    (include "kubeflow.trainingOperator.enabled" . | eq "true")
    .Values.trainingOperator.serviceAccount.create
)}}
{{- end }}

{{- define "kubeflow.trainingOperator.pdb.create" -}}
{{- include "kubeflow.component.pdb.create" (
    list
    (include "kubeflow.trainingOperator.enabled" .)
    .Values.defaults.podDisruptionBudget
    .Values.trainingOperator.podDisruptionBudget
)}}
{{- end }}

{{- define "kubeflow.trainingOperator.tlsCertSecretName" -}}
{{- printf "training-operator-webhook-cert" }}
{{- end }}
