{{/*
Kubeflow Centraldashboard object names.
*/}}
{{- define "kubeflow.centraldashboard.baseName" -}}
{{- printf "centraldashboard" }}
{{- end }}

{{- define "kubeflow.centraldashboard.name" -}}
{{- include "kubeflow.component.name" (
    list
    (include "kubeflow.centraldashboard.baseName" .)
    .
)}}
{{- end }}

{{- define "kubeflow.centraldashboard.serviceAccountName" -}}
{{- include "kubeflow.component.serviceAccountName"  (
    list
    (include "kubeflow.centraldashboard.name" .)
    .Values.centraldashboard.serviceAccount)
}}
{{- end }}

{{- define "kubeflow.centraldashboard.roleName" -}}
{{- include "kubeflow.centraldashboard.name" . }}
{{- end }}

{{- define "kubeflow.centraldashboard.roleBindingName" -}}
{{- include "kubeflow.centraldashboard.name" . }}
{{- end }}

{{- define "kubeflow.centraldashboard.clusterRoleName" -}}
{{- include "kubeflow.centraldashboard.name" . }}
{{- end }}

{{- define "kubeflow.centraldashboard.clusterRoleBindingName" -}}
{{- include "kubeflow.centraldashboard.name" . }}
{{- end }}

{{- define "kubeflow.centraldashboard.config.name" -}}
{{ printf "%s-config" (include "kubeflow.centraldashboard.name" .) }}
{{- end }}

{{- define "kubeflow.centraldashboard.authorizationPolicyExtAuthName" -}}
{{ include "kubeflow.component.authorizationPolicyExtAuthName" (
    list
    (include "kubeflow.centraldashboard.name" .)
    .Values.istioIntegration
)}}
{{- end }}

{{/*
Kubeflow Centraldashboard Service.
*/}}
{{- define "kubeflow.centraldashboard.svc.name" -}}
{{ include "kubeflow.component.svc.name" (
    include "kubeflow.centraldashboard.name" .
)}}
{{- end }}

{{- define "kubeflow.centraldashboard.svc.addressWithNs" -}}
{{ include "kubeflow.component.svc.addressWithNs"  (
    list
    .
    (include "kubeflow.centraldashboard.name" .)
)}}
{{- end }}

{{- define "kubeflow.centraldashboard.svc.addressWithSvc" -}}
{{ include "kubeflow.component.svc.addressWithSvc"  (
    list
    .
    (include "kubeflow.centraldashboard.name" .)
)}}
{{- end }}

{{- define "kubeflow.centraldashboard.svc.fqdn" -}}
{{ include "kubeflow.component.svc.fqdn"  (
    list
    .
    (include "kubeflow.centraldashboard.name" .)
)}}
{{- end }}

{{/*
Kubeflow Centraldashboard object labels.
*/}}
{{- define "kubeflow.centraldashboard.labels" -}}
{{ include "kubeflow.common.labels" . }}
{{ include "kubeflow.component.labels" (include "kubeflow.centraldashboard.name" .) }}
{{- end }}

{{- define "kubeflow.centraldashboard.selectorLabels" -}}
{{ include "kubeflow.common.selectorLabels" . }}
{{ include "kubeflow.component.selectorLabels" (include "kubeflow.centraldashboard.name" .) }}
{{- end }}

{{/*
Kubeflow Centraldashboard container image settings.
*/}}
{{- define "kubeflow.centraldashboard.image" -}}
{{ include "kubeflow.component.image" (list .Values.defaults.image .Values.centraldashboard.image) }}
{{- end }}

{{- define "kubeflow.centraldashboard.imagePullPolicy" -}}
{{ include "kubeflow.component.imagePullPolicy" (list .Values.defaults.image .Values.centraldashboard.image) }}
{{- end }}

{{/*
Kubeflow Centraldashboard Autoscaling and Availability.
*/}}
{{- define "kubeflow.centraldashboard.autoscaling.enabled" -}}
{{ include "kubeflow.component.autoscaling.enabled" (list .Values.defaults.autoscaling .Values.centraldashboard.autoscaling) }}
{{- end }}

{{- define "kubeflow.centraldashboard.autoscaling.minReplicas" -}}
{{ include "kubeflow.component.autoscaling.minReplicas" (list .Values.defaults.autoscaling .Values.centraldashboard.autoscaling) }}
{{- end }}

{{- define "kubeflow.centraldashboard.autoscaling.maxReplicas" -}}
{{ include "kubeflow.component.autoscaling.maxReplicas" (list .Values.defaults.autoscaling .Values.centraldashboard.autoscaling) }}
{{- end }}

{{- define "kubeflow.centraldashboard.autoscaling.targetCPUUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetCPUUtilizationPercentage" (list .Values.defaults.autoscaling .Values.centraldashboard.autoscaling) }}
{{- end }}

{{- define "kubeflow.centraldashboard.autoscaling.targetMemoryUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetMemoryUtilizationPercentage" (list .Values.defaults.autoscaling .Values.centraldashboard.autoscaling) }}
{{- end }}

{{- define "kubeflow.centraldashboard.pdb.values" -}}
{{- include "kubeflow.component.pdb.values" (
    list
    .Values.defaults.podDisruptionBudget
    .Values.centraldashboard.podDisruptionBudget
)}}
{{- end }}

{{/*
Kubeflow Centraldashboard Security Context.
*/}}
{{- define "kubeflow.centraldashboard.containerSecurityContext" -}}
{{ include "kubeflow.component.containerSecurityContext" (
    list
    .Values.defaults.containerSecurityContext
    .Values.centraldashboard.containerSecurityContext
)}}
{{- end }}

{{/*
Kubeflow Centraldashboard Scheduling.
*/}}
{{- define "kubeflow.centraldashboard.topologySpreadConstraints" -}}
{{ include "kubeflow.component.topologySpreadConstraints" (
    list
    .Values.defaults.topologySpreadConstraints
    .Values.centraldashboard.topologySpreadConstraints
)}}
{{- end }}

{{- define "kubeflow.centraldashboard.nodeSelector" -}}
{{ include "kubeflow.component.nodeSelector" (
    list
    .Values.defaults.nodeSelector
    .Values.centraldashboard.nodeSelector
)}}
{{- end }}

{{- define "kubeflow.centraldashboard.tolerations" -}}
{{ include "kubeflow.component.tolerations" (
    list
    .Values.defaults.tolerations
    .Values.centraldashboard.tolerations
)}}
{{- end }}

{{- define "kubeflow.centraldashboard.affinity" -}}
{{ include "kubeflow.component.affinity" (
    list
    .Values.defaults.affinity
    .Values.centraldashboard.affinity
)}}
{{- end }}

{{/*
Kubeflow Centraldashboard enable and create toggles.
*/}}
{{- define "kubeflow.centraldashboard.enabled" -}}
{{- .Values.centraldashboard.enabled }}
{{- end }}

{{- define "kubeflow.centraldashboard.createIstioIntegrationObjects" -}}
{{- ternary true "" (
    and
    (include "kubeflow.centraldashboard.enabled" . | eq "true")
    .Values.istioIntegration.enabled
)}}
{{- end }}

{{- define "kubeflow.centraldashboard.rbac.createRoles" -}}
{{- and
    (include "kubeflow.centraldashboard.enabled" . | eq "true")
    .Values.centraldashboard.rbac.create }}
{{- end }}

{{- define "kubeflow.centraldashboard.createServiceAccount" -}}
{{- and
    (include "kubeflow.centraldashboard.enabled" . | eq "true")
    .Values.centraldashboard.serviceAccount.create
}}
{{- end }}

{{- define "kubeflow.centraldashboard.pdb.create" -}}
{{- include "kubeflow.component.pdb.create" (
    list
    (include "kubeflow.centraldashboard.enabled" .)
    .Values.defaults.podDisruptionBudget
    .Values.centraldashboard.podDisruptionBudget
)}}
{{- end }}
