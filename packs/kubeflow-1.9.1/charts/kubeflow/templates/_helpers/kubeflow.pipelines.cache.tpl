{{/*
Kubeflow Pipelines Cache object names.
*/}}
{{- define "kubeflow.pipelines.cache.baseName" -}}
{{- printf "ml-pipeline-cache" }}
{{- end }}

{{- define "kubeflow.pipelines.cache.name" -}}
{{- include "kubeflow.component.name" (
    list
    (include "kubeflow.pipelines.cache.baseName" .)
    .
)}}
{{- end }}

{{- define "kubeflow.pipelines.cache.serviceAccountName" -}}
{{- include "kubeflow.component.serviceAccountName"  (
    list
    (include "kubeflow.pipelines.cache.name" .)
    .Values.pipelines.cache.serviceAccount)
}}
{{- end }}

{{- define "kubeflow.pipelines.cache.serviceAccountPrincipal" -}}
{{- include "kubeflow.component.serviceAccountPrincipal" (
    list
    .
    (include "kubeflow.pipelines.cache.serviceAccountName" .)
)}}
{{- end }}

{{- define "kubeflow.pipelines.cache.roleName" -}}
{{- include "kubeflow.pipelines.cache.name" . }}
{{- end }}

{{- define "kubeflow.pipelines.cache.roleBindingName" -}}
{{- include "kubeflow.pipelines.cache.roleName" . }}
{{- end }}

{{- define "kubeflow.pipelines.cache.tlsCertSecretName" -}}
{{ printf "%s-%s" (include "kubeflow.pipelines.cache.name" .) "tls-certs" }}
{{- end }}

{{- define "kubeflow.pipelines.cache.certIssuerName" -}}
{{ printf "%s-%s" (include "kubeflow.pipelines.cache.name" .) "selfsigned-issuer" }}
{{- end }}

{{- define "kubeflow.pipelines.cache.certName" -}}
{{ printf "%s-%s" (include "kubeflow.pipelines.cache.name" .) "cert" }}
{{- end }}

{{- define "kubeflow.pipelines.cache.webhookName" -}}
{{ print (include "kubeflow.pipelines.cache.name" .) }}
{{- end }}

{{/*
Kubeflow Pipelines Cache Service.
*/}}
{{- define "kubeflow.pipelines.cache.svc.name" -}}
{{ include "kubeflow.component.svc.name" (
    include "kubeflow.pipelines.cache.name" .
)}}
{{- end }}

{{- define "kubeflow.pipelines.cache.svc.addressWithNs" -}}
{{ include "kubeflow.component.svc.addressWithNs"  (
    list
    .
    (include "kubeflow.pipelines.cache.name" .)
)}}
{{- end }}

{{- define "kubeflow.pipelines.cache.svc.addressWithSvc" -}}
{{ include "kubeflow.component.svc.addressWithSvc"  (
    list
    .
    (include "kubeflow.pipelines.cache.name" .)
)}}
{{- end }}

{{- define "kubeflow.pipelines.cache.svc.fqdn" -}}
{{ include "kubeflow.component.svc.fqdn"  (
    list
    .
    (include "kubeflow.pipelines.cache.name" .)
)}}
{{- end }}

{{/*
Kubeflow Pipelines Cache object labels.
*/}}
{{- define "kubeflow.pipelines.cache.labels" -}}
{{ include "kubeflow.common.labels" . }}
{{ include "kubeflow.component.labels" (include "kubeflow.pipelines.name" .) }}
{{ include "kubeflow.component.subcomponent.labels" (include "kubeflow.pipelines.cache.name" .) }}
{{- end }}

{{- define "kubeflow.pipelines.cache.selectorLabels" -}}
{{ include "kubeflow.common.selectorLabels" . }}
{{ include "kubeflow.component.selectorLabels" (include "kubeflow.pipelines.name" .) }}
{{ include "kubeflow.component.subcomponent.labels" (include "kubeflow.pipelines.cache.name" .) }}
{{- end }}

{{- define "kubeflow.pipelines.cache.cacheEnabledLabel" -}}
pipelines.kubeflow.org/cache_enabled: "true"
{{- end }}

{{- define "kubeflow.pipelines.cache.cacheDisabledLabel" -}}
pipelines.kubeflow.org/cache_enabled: "false"
{{- end }}

{{/*
Kubeflow Pipelines Cache container image settings.
*/}}
{{- define "kubeflow.pipelines.cache.image" -}}
{{- include "kubeflow.pipelines.image" (
    list
    .Values.defaults.image
    .Values.pipelines.defaults.image
    .Values.pipelines.cache.image
)}}
{{- end }}

{{- define "kubeflow.pipelines.cache.imagePullPolicy" -}}
{{- include "kubeflow.pipelines.imagePullPolicy" (
    list
    .Values.defaults.image
    .Values.pipelines.defaults.image
    .Values.pipelines.cache.image
)}}
{{- end }}


{{/*
Kubeflow Pipelines Cache Autoscaling and Availability.
*/}}
{{- define "kubeflow.pipelines.cache.autoscaling.enabled" -}}
{{ include "kubeflow.component.autoscaling.enabled" (list .Values.defaults.autoscaling .Values.pipelines.cache.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.cache.autoscaling.minReplicas" -}}
{{ include "kubeflow.component.autoscaling.minReplicas" (list .Values.defaults.autoscaling .Values.pipelines.cache.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.cache.autoscaling.maxReplicas" -}}
{{ include "kubeflow.component.autoscaling.maxReplicas" (list .Values.defaults.autoscaling .Values.pipelines.cache.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.cache.autoscaling.targetCPUUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetCPUUtilizationPercentage" (list .Values.defaults.autoscaling .Values.pipelines.cache.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.cache.autoscaling.targetMemoryUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetMemoryUtilizationPercentage" (list .Values.defaults.autoscaling .Values.pipelines.cache.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.cache.pdb.values" -}}
{{- include "kubeflow.component.pdb.values" (
    list
    .Values.defaults.podDisruptionBudget
    .Values.pipelines.cache.podDisruptionBudget
)}}
{{- end }}

{{/*
Kubeflow Pipelines Cache Security Context.
*/}}
{{- define "kubeflow.pipelines.cache.containerSecurityContext" -}}
{{- include "kubeflow.component.containerSecurityContext" (
    list
    .Values.defaults.containerSecurityContext
    .Values.pipelines.cache.containerSecurityContext
)}}
{{- end }}

{{/*
Kubeflow Pipelines Cache Scheduling.
*/}}
{{- define "kubeflow.pipelines.cache.topologySpreadConstraints" -}}
{{ include "kubeflow.component.topologySpreadConstraints" (
    list
    .Values.defaults.topologySpreadConstraints
    .Values.pipelines.cache.topologySpreadConstraints
)}}
{{- end }}

{{- define "kubeflow.pipelines.cache.nodeSelector" -}}
{{ include "kubeflow.component.nodeSelector" (
    list
    .Values.defaults.nodeSelector
    .Values.pipelines.cache.nodeSelector
)}}
{{- end }}

{{- define "kubeflow.pipelines.cache.tolerations" -}}
{{ include "kubeflow.component.tolerations" (
    list
    .Values.defaults.tolerations
    .Values.pipelines.cache.tolerations
)}}
{{- end }}

{{- define "kubeflow.pipelines.cache.affinity" -}}
{{ include "kubeflow.component.affinity" (
    list
    .Values.defaults.affinity
    .Values.pipelines.cache.affinity
)}}
{{- end }}

{{/*
Kubeflow Pipelines Cache enable and create toggles.
*/}}
{{- define "kubeflow.pipelines.cache.enabled" -}}
{{- ternary true "" (
    and
        (include "kubeflow.pipelines.enabled" . | eq "true")
        .Values.pipelines.cache.enabled
)}}
{{- end }}

{{- define "kubeflow.pipelines.cache.rbac.createRoles" -}}
{{- ternary true "" (
    and
        (include "kubeflow.pipelines.cache.enabled" . | eq "true")
        .Values.pipelines.cache.rbac.create
)}}
{{- end }}

{{- define "kubeflow.pipelines.cache.createServiceAccount" -}}
{{- ternary true "" (
    and
        (include "kubeflow.pipelines.cache.enabled" . | eq "true")
        .Values.pipelines.cache.serviceAccount.create
)}}
{{- end }}

{{- define "kubeflow.pipelines.cache.enabledWithCertManager" -}}
{{- ternary true "" (
    and
        (include "kubeflow.pipelines.cache.enabled" . | eq "true" )
        (include "kubeflow.certManagerIntegration.enabled" . | eq "true" )
)}}
{{- end }}

{{- define "kubeflow.pipelines.cache.createIstioIntegrationObjects" -}}
{{- ternary true "" (
    and
        (include "kubeflow.pipelines.cache.enabled" . | eq "true" )
        .Values.istioIntegration.enabled
)}}
{{- end }}
