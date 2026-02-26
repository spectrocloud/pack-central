{{/*
Kubeflow Admission Webhook object names.
*/}}
{{- define "kubeflow.admissionWebhook.baseName" -}}
{{- printf "admission-webhook" }}
{{- end }}

{{- define "kubeflow.admissionWebhook.name" -}}
{{- include "kubeflow.component.name" (
    list
    (include "kubeflow.admissionWebhook.baseName" .)
    .
)}}
{{- end }}

{{- define "kubeflow.admissionWebhook.serviceAccountName" -}}
{{- include "kubeflow.component.serviceAccountName"  (
    list
    (include "kubeflow.admissionWebhook.name" .)
    .Values.admissionWebhook.serviceAccount
)}}
{{- end }}

{{- define "kubeflow.admissionWebhook.tlsCertSecretName" -}}
{{ printf "%s-%s" (include "kubeflow.admissionWebhook.name" .) "tls-certs" }}
{{- end }}

{{- define "kubeflow.admissionWebhook.certIssuerName" -}}
{{ printf "%s-%s" (include "kubeflow.admissionWebhook.name" .) "selfsigned-issuer" }}
{{- end }}

{{- define "kubeflow.admissionWebhook.certName" -}}
{{ printf "%s-%s" (include "kubeflow.admissionWebhook.name" .) "cert" }}
{{- end }}

{{- define "kubeflow.admissionWebhook.webhookName" -}}
{{ print (include "kubeflow.admissionWebhook.name" .) }}
{{- end }}

{{- define "kubeflow.admissionWebhook.mainClusterRoleName" -}}
{{- printf "%s-%s"
    (include "kubeflow.fullname" .)
    (include "kubeflow.admissionWebhook.name" .)
}}
{{- end }}

{{- define "kubeflow.admissionWebhook.mainClusterRoleBindingName" -}}
{{- include "kubeflow.admissionWebhook.mainClusterRoleName" . }}
{{- end }}

{{- define "kubeflow.admissionWebhook.kfPdAdminName" -}}
{{- printf "poddefaults-admin" }}
{{- end }}

{{- define "kubeflow.admissionWebhook.kfPdEditName" -}}
{{- printf "poddefaults-edit" }}
{{- end }}

{{- define "kubeflow.admissionWebhook.kfPdViewName" -}}
{{- printf "poddefaults-view" }}
{{- end }}

{{- define "kubeflow.admissionWebhook.kfPdAdminClusterRoleName" -}}
{{- printf "%s-%s-%s" (include "kubeflow.fullname" .) (include "kubeflow.admissionWebhook.name" .) (include "kubeflow.admissionWebhook.kfPdAdminName" .) }}
{{- end }}

{{- define "kubeflow.admissionWebhook.kfPdEditClusterRoleName" -}}
{{- printf "%s-%s-%s" (include "kubeflow.fullname" .) (include "kubeflow.admissionWebhook.name" .) (include "kubeflow.admissionWebhook.kfPdEditName" .) }}
{{- end }}

{{- define "kubeflow.admissionWebhook.kfPdViewClusterRoleName" -}}
{{- printf "%s-%s-%s" (include "kubeflow.fullname" .) (include "kubeflow.admissionWebhook.name" .) (include "kubeflow.admissionWebhook.kfPdViewName" .) }}
{{- end }}

{{- define "kubeflow.admissionWebhook.kfPdAdminClusterRoleLabelName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) (include "kubeflow.admissionWebhook.kfPdAdminName" .) }}
{{- end }}

{{- define "kubeflow.admissionWebhook.kfPdEditClusterRoleLabelName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) (include "kubeflow.admissionWebhook.kfPdEditName" .) }}
{{- end }}

{{/*
Role Aggregation Rule Labels
*/}}
{{- define "kubeflow.admissionWebhook.kfPdAdminClusterRoleLabel" -}}
{{- include "kubeflow.aggregationRule.labelBase" (include "kubeflow.admissionWebhook.kfPdAdminClusterRoleLabelName" .) -}}
{{- end }}

{{- define "kubeflow.admissionWebhook.kfPdEditClusterRoleLabel" -}}
{{- include "kubeflow.aggregationRule.labelBase" (include "kubeflow.admissionWebhook.kfPdEditClusterRoleLabelName" .) -}}
{{- end }}

{{/*
Kubeflow Admission Webhook Service.
*/}}
{{- define "kubeflow.admissionWebhook.svc.name" -}}
{{ include "kubeflow.component.svc.name" (
    include "kubeflow.admissionWebhook.name" .
)}}
{{- end }}

{{- define "kubeflow.admissionWebhook.svc.addressWithNs" -}}
{{ include "kubeflow.component.svc.addressWithNs"  (
    list
    .
    (include "kubeflow.admissionWebhook.name" .)
)}}
{{- end }}

{{- define "kubeflow.admissionWebhook.svc.addressWithSvc" -}}
{{ include "kubeflow.component.svc.addressWithSvc"  (
    list
    .
    (include "kubeflow.admissionWebhook.name" .)
)}}
{{- end }}

{{- define "kubeflow.admissionWebhook.svc.fqdn" -}}
{{ include "kubeflow.component.svc.fqdn"  (
    list
    .
    (include "kubeflow.admissionWebhook.name" .)
)}}
{{- end }}

{{/*
Kubeflow Admission Webhook object labels.
*/}}
{{- define "kubeflow.admissionWebhook.labels" -}}
{{ include "kubeflow.common.labels" . }}
{{ include "kubeflow.component.labels" (include "kubeflow.admissionWebhook.name" .) }}
{{- end }}

{{- define "kubeflow.admissionWebhook.selectorLabels" -}}
{{ include "kubeflow.common.selectorLabels" . }}
{{ include "kubeflow.component.selectorLabels" (include "kubeflow.admissionWebhook.name" .) }}
{{- end }}

{{- define "kubeflow.admissionWebhook.partOfLabel" -}}
app.kubernetes.io/part-of: kubeflow-profile
{{- end }}

{{/*
Kubeflow Admission Webhook container image settings.
*/}}
{{- define "kubeflow.admissionWebhook.image" -}}
{{ include "kubeflow.component.image" (
    list
    .Values.defaults.image
    .Values.admissionWebhook.image
)}}
{{- end }}

{{- define "kubeflow.admissionWebhook.imagePullPolicy" -}}
{{ include "kubeflow.component.imagePullPolicy" (
    list
    .Values.defaults.image
    .Values.admissionWebhook.image
)}}
{{- end }}

{{/*
Kubeflow Admission Webhook Autoscaling and Availability.
*/}}
{{- define "kubeflow.admissionWebhook.autoscaling.minReplicas" -}}
{{ include "kubeflow.component.autoscaling.minReplicas" (
    list
    .Values.defaults.autoscaling
    .Values.admissionWebhook.autoscaling
)}}
{{- end }}

{{- define "kubeflow.admissionWebhook.autoscaling.maxReplicas" -}}
{{ include "kubeflow.component.autoscaling.maxReplicas" (
    list
    .Values.defaults.autoscaling
    .Values.admissionWebhook.autoscaling
)}}
{{- end }}

{{- define "kubeflow.admissionWebhook.autoscaling.targetCPUUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetCPUUtilizationPercentage" (
    list
    .Values.defaults.autoscaling
    .Values.admissionWebhook.autoscaling
)}}
{{- end }}

{{- define "kubeflow.admissionWebhook.autoscaling.targetMemoryUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetMemoryUtilizationPercentage" (
    list
    .Values.defaults.autoscaling
    .Values.admissionWebhook.autoscaling
)}}
{{- end }}

{{- define "kubeflow.admissionWebhook.pdb.values" -}}
{{- include "kubeflow.component.pdb.values" (
    list
    .Values.defaults.podDisruptionBudget
    .Values.admissionWebhook.podDisruptionBudget
)}}
{{- end }}

{{/*
Kubeflow Admission Webhook Security Context.
*/}}
{{- define "kubeflow.admissionWebhook.containerSecurityContext" -}}
{{ include "kubeflow.component.containerSecurityContext" (
    list
    .Values.defaults.containerSecurityContext
    .Values.admissionWebhook.containerSecurityContext
)}}
{{- end }}

{{/*
Kubeflow Admission Webhook Scheduling.
*/}}
{{- define "kubeflow.admissionWebhook.topologySpreadConstraints" -}}
{{ include "kubeflow.component.topologySpreadConstraints" (
    list
    .Values.defaults.topologySpreadConstraints
    .Values.admissionWebhook.topologySpreadConstraints
)}}
{{- end }}

{{- define "kubeflow.admissionWebhook.nodeSelector" -}}
{{ include "kubeflow.component.nodeSelector" (
    list
    .Values.defaults.nodeSelector
    .Values.admissionWebhook.nodeSelector
)}}
{{- end }}

{{- define "kubeflow.admissionWebhook.tolerations" -}}
{{ include "kubeflow.component.tolerations" (
    list
    .Values.defaults.tolerations
    .Values.admissionWebhook.tolerations
)}}
{{- end }}

{{- define "kubeflow.admissionWebhook.affinity" -}}
{{ include "kubeflow.component.affinity" (
    list
    .Values.defaults.affinity
    .Values.admissionWebhook.affinity
)}}
{{- end }}

{{/*
Kubeflow Admission Webhook enable and create toggles.
*/}}
{{- define "kubeflow.admissionWebhook.enabled" -}}
{{- .Values.admissionWebhook.enabled }}
{{- end }}

{{- define "kubeflow.admissionWebhook.autoscaling.enabled" -}}
{{ include "kubeflow.component.autoscaling.enabled" (
    list
    .Values.defaults.autoscaling
    .Values.admissionWebhook.autoscaling
)}}
{{- end }}

{{- define "kubeflow.admissionWebhook.rbac.createRoles" -}}
{{- ternary true "" (
    and
    (include "kubeflow.admissionWebhook.enabled" . | eq "true")
    .Values.admissionWebhook.rbac.create
)}}
{{- end }}

{{- define "kubeflow.admissionWebhook.createServiceAccount" -}}
{{- ternary true "" (
and
    (include "kubeflow.admissionWebhook.enabled" . | eq "true")
    .Values.admissionWebhook.serviceAccount.create
)}}
{{- end }}

{{- define "kubeflow.admissionWebhook.pdb.create" -}}
{{- include "kubeflow.component.pdb.create" (
    list
    (include "kubeflow.admissionWebhook.enabled" .)
    .Values.defaults.podDisruptionBudget
    .Values.admissionWebhook.podDisruptionBudget
)}}
{{- end }}

{{/*
Kubeflow Admission Webhook certificate manager.
*/}}
{{- define "kubeflow.admissionWebhook.enabledWithCertManager" -}}
{{- ternary true "" (
    and
        (include "kubeflow.admissionWebhook.enabled" . | eq "true" )
        (include "kubeflow.certManagerIntegration.enabled" . | eq "true" )
)}}
{{- end }}
