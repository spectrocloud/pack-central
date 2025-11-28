{{/*
Kubeflow Katib Controller object names.
*/}}
{{- define "kubeflow.katib.controller.baseName" -}}
{{- printf "katib-controller" }}
{{- end }}

{{- define "kubeflow.katib.controller.name" -}}
{{- include "kubeflow.component.name" (
    list
    (include "kubeflow.katib.controller.baseName" .)
    .
)}}
{{- end }}

{{- define "kubeflow.katib.controller.serviceAccountName" -}}
{{- include "kubeflow.component.serviceAccountName"  (
    list
    (include "kubeflow.katib.controller.name" .)
    .Values.katib.controller.serviceAccount
)}}
{{- end }}

{{- define "kubeflow.katib.controller.serviceAccountPrincipal" -}}
{{- include "kubeflow.component.serviceAccountPrincipal" (
    list
    .
    (include "kubeflow.katib.controller.serviceAccountName" .)
)}}
{{- end }}

{{- define "kubeflow.katib.controller.mainClusterRoleName" -}}
{{- include "kubeflow.katib.controller.name" . }}
{{- end }}

{{- define "kubeflow.katib.controller.mainClusterRoleBindingName" -}}
{{- include "kubeflow.katib.controller.mainClusterRoleName" . }}
{{- end }}

{{- define "kubeflow.katib.controller.leaderElectionRoleName" -}}
{{- printf "%s-%s-%s"
    (include "kubeflow.fullname" .)
    (include "kubeflow.katib.controller.name" .)
    "leader-election"
}}
{{- end }}

{{- define "kubeflow.katib.controller.leaderElectionRoleBindingName" -}}
{{- include "kubeflow.katib.controller.leaderElectionRoleName" . }}
{{- end }}

{{- define "kubeflow.katib.controller.kfNbAdminClusterRoleName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) "katib-admin" }}
{{- end }}

{{- define "kubeflow.katib.controller.kfNbEditClusterRoleName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) "katib-edit" }}
{{- end }}

{{- define "kubeflow.katib.controller.kfNbViewClusterRoleName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) "katib-view" }}
{{- end }}

{{- define "kubeflow.katib.controller.configMapName" -}}
{{/*
katib-config ConfigMap name is hardcoded
https://github.com/kubeflow/katib/blob/0e2ba6efc1bc18b1d1d72b90046598a00f02a2c3/pkg/controller.v1beta1/consts/const.go#L109
https://github.com/kubeflow/katib/blob/0e2ba6efc1bc18b1d1d72b90046598a00f02a2c3/pkg/util/v1beta1/katibconfig/config.go#L164
{{- printf "%s-%s" (include "kubeflow.katib.controller.name" .) "config" }}
*/}}
{{- printf "katib-config" }}
{{- end }}

{{/*
Role Aggregation Rule Labels
*/}}
{{- define "kubeflow.katib.controller.kfNbAdminClusterRoleLabel" -}}
{{- include "kubeflow.aggregationRule.labelBase" (include "kubeflow.katib.controller.kfNbAdminClusterRoleName" .) -}}
{{- end }}

{{/*
Kubeflow Katib Controller Service.
*/}}
{{- define "kubeflow.katib.controller.svc.name" -}}
{{ include "kubeflow.component.svc.name" (
    include "kubeflow.katib.controller.name" .
)}}
{{- end }}

{{- define "kubeflow.katib.controller.svc.addressWithNs" -}}
{{ include "kubeflow.component.svc.addressWithNs"  (
    list
    .
    (include "kubeflow.katib.controller.name" .)
)}}
{{- end }}

{{- define "kubeflow.katib.controller.svc.addressWithSvc" -}}
{{ include "kubeflow.component.svc.addressWithSvc"  (
    list
    .
    (include "kubeflow.katib.controller.name" .)
)}}
{{- end }}

{{- define "kubeflow.katib.controller.svc.fqdn" -}}
{{ include "kubeflow.component.svc.fqdn"  (
    list
    .
    (include "kubeflow.katib.controller.name" .)
)}}
{{- end }}

{{/*
Kubeflow Katib Controller object labels.
*/}}
{{- define "kubeflow.katib.controller.labels" -}}
{{ include "kubeflow.common.labels" . }}
{{ include "kubeflow.component.labels" (include "kubeflow.katib.name" .) }}
{{ include "kubeflow.component.subcomponent.labels" (include "kubeflow.katib.controller.name" .) }}
{{- end }}

{{- define "kubeflow.katib.controller.selectorLabels" -}}
{{ include "kubeflow.common.selectorLabels" . }}
{{ include "kubeflow.component.selectorLabels" (include "kubeflow.katib.name" .) }}
{{ include "kubeflow.component.subcomponent.labels" (include "kubeflow.katib.controller.name" .) }}
{{- end }}

{{/*
Kubeflow Katib Controller container image settings.
*/}}
{{- define "kubeflow.katib.controller.image" -}}
{{ include "kubeflow.component.image" (
    list
    .Values.defaults.image
    .Values.katib.controller.image
)}}
{{- end }}

{{- define "kubeflow.katib.controller.imagePullPolicy" -}}
{{ include "kubeflow.component.imagePullPolicy" (
    list
    .Values.defaults.image
    .Values.katib.controller.image
)}}
{{- end }}

{{/*
Kubeflow Katib Controller Autoscaling and Availability.
*/}}
{{- define "kubeflow.katib.controller.autoscaling.minReplicas" -}}
{{ include "kubeflow.component.autoscaling.minReplicas" (
    list
    .Values.defaults.autoscaling
    .Values.katib.controller.autoscaling
)}}
{{- end }}

{{- define "kubeflow.katib.controller.autoscaling.maxReplicas" -}}
{{ include "kubeflow.component.autoscaling.maxReplicas" (
    list
    .Values.defaults.autoscaling
    .Values.katib.controller.autoscaling
)}}
{{- end }}

{{- define "kubeflow.katib.controller.autoscaling.targetCPUUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetCPUUtilizationPercentage" (
    list
    .Values.defaults.autoscaling
    .Values.katib.controller.autoscaling
)}}
{{- end }}

{{- define "kubeflow.katib.controller.autoscaling.targetMemoryUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetMemoryUtilizationPercentage" (
    list
    .Values.defaults.autoscaling
    .Values.katib.controller.autoscaling
)}}
{{- end }}

{{- define "kubeflow.katib.controller.pdb.values" -}}
{{- include "kubeflow.component.pdb.values" (
    list
    .Values.defaults.podDisruptionBudget
    .Values.katib.controller.podDisruptionBudget
)}}
{{- end }}

{{/*
Kubeflow Katib Controller Security Context.
*/}}
{{- define "kubeflow.katib.controller.containerSecurityContext" -}}
{{ include "kubeflow.component.containerSecurityContext" (
    list
    .Values.defaults.containerSecurityContext
    .Values.katib.controller.containerSecurityContext
)}}
{{- end }}

{{/*
Kubeflow Katib Controller Scheduling.
*/}}
{{- define "kubeflow.katib.controller.topologySpreadConstraints" -}}
{{ include "kubeflow.component.topologySpreadConstraints" (
    list
    .Values.defaults.topologySpreadConstraints
    .Values.katib.controller.topologySpreadConstraints
)}}
{{- end }}

{{- define "kubeflow.katib.controller.nodeSelector" -}}
{{ include "kubeflow.component.nodeSelector" (
    list
    .Values.defaults.nodeSelector
    .Values.katib.controller.nodeSelector
)}}
{{- end }}

{{- define "kubeflow.katib.controller.tolerations" -}}
{{ include "kubeflow.component.tolerations" (
    list
    .Values.defaults.tolerations
    .Values.katib.controller.tolerations
)}}
{{- end }}

{{- define "kubeflow.katib.controller.affinity" -}}
{{ include "kubeflow.component.affinity" (
    list
    .Values.defaults.affinity
    .Values.katib.controller.affinity
)}}
{{- end }}

{{/*
Kubeflow Katib Controller enable and create toggles.
*/}}
{{- define "kubeflow.katib.controller.enabled" -}}
{{- ternary true "" (
    and
    (include "kubeflow.katib.enabled" . | eq "true")
    .Values.katib.controller.enabled
)}}
{{- end }}

{{- define "kubeflow.katib.controller.autoscaling.enabled" -}}
{{ include "kubeflow.component.autoscaling.enabled" (
    list
    .Values.defaults.autoscaling
    .Values.katib.controller.autoscaling
)}}
{{- end }}

{{- define "kubeflow.katib.controller.rbac.createRoles" -}}
{{- ternary true "" (
    and
    (include "kubeflow.katib.controller.enabled" . | eq "true")
    .Values.katib.controller.rbac.create
)}}
{{- end }}

{{- define "kubeflow.katib.controller.createServiceAccount" -}}
{{- ternary true "" (
and
    (include "kubeflow.katib.controller.enabled" . | eq "true")
    .Values.katib.controller.serviceAccount.create
)}}
{{- end }}

{{- define "kubeflow.katib.controller.pdb.create" -}}
{{- include "kubeflow.component.pdb.create" (
    list
    (include "kubeflow.katib.controller.enabled" .)
    .Values.defaults.podDisruptionBudget
    .Values.katib.controller.podDisruptionBudget
)}}
{{- end }}

{{/*
Kubeflow Katib Controller certificate manager.
*/}}
{{- define "kubeflow.katib.controller.enabledWithCertManager" -}}
{{- ternary true "" (
    and
        (include "kubeflow.katib.controller.enabled" . | eq "true" )
        (include "kubeflow.certManagerIntegration.enabled" . | eq "true" )
)}}
{{- end }}

{{- define "kubeflow.katib.controller.certIssuerName" -}}
{{ printf "%s-%s" (include "kubeflow.katib.controller.name" .) "selfsigned-issuer" }}
{{- end }}

{{- define "kubeflow.katib.controller.tlsCertSecretName" -}}
{{ printf "%s-%s" (include "kubeflow.katib.controller.name" .) "tls-certs" }}
{{- end }}

{{- define "kubeflow.katib.controller.validatingWebhookName" -}}
{{ printf "%s-%s" (include "kubeflow.katib.controller.name" .) "validating" }}
{{- end }}

{{- define "kubeflow.katib.controller.mutatingWebhookName" -}}
{{ printf "%s-%s" (include "kubeflow.katib.controller.name" .) "mutating" }}
{{- end }}

{{- define "kubeflow.katib.controller.certName" -}}
{{ printf "%s-%s" (include "kubeflow.katib.controller.name" .) "cert" }}
{{- end }}

{{/*
Kubeflow Katib Controller Admission Webhooks.
*/}}
{{- define "kubeflow.katib.controller.webhook.baseName" -}}
{{ printf "katib.kubeflow.org" }}
{{- end }}

{{- define "kubeflow.katib.controller.mutatingWebhook.name" -}}
{{ printf "%s" (include "kubeflow.katib.controller.webhook.baseName" .) }}
{{- end }}

{{- define "kubeflow.katib.controller.validatingWebhook.name" -}}
{{ printf "%s" (include "kubeflow.katib.controller.webhook.baseName" .) }}
{{- end }}

{{/*
{{- define "kubeflow.katib.controller.mutatingWebhook.experimentDefaulter.name" -}}
{{ printf "%s.%s" "defaulter.experiment" (include "kubeflow.katib.controller.mutatingWebhook.name" .) }}
{{- end }}
*/}}

