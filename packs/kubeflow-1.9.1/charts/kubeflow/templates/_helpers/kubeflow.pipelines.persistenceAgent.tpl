{{/*
Kubeflow Pipelines Persistence Agent object names.
*/}}
{{- define "kubeflow.pipelines.persistenceAgent.baseName" -}}
{{- printf "ml-pipeline-persistenceagent" }}
{{- end }}

{{- define "kubeflow.pipelines.persistenceAgent.name" -}}
{{- include "kubeflow.component.name" (
    list
    (include "kubeflow.pipelines.persistenceAgent.baseName" .)
    .
)}}
{{- end }}

{{- define "kubeflow.pipelines.persistenceAgent.serviceAccountName" -}}
{{- include "kubeflow.component.serviceAccountName"  (
    list
    (include "kubeflow.pipelines.persistenceAgent.name" .)
    .Values.pipelines.persistenceAgent.serviceAccount)
}}
{{- end }}

{{- define "kubeflow.pipelines.persistenceAgent.serviceAccountPrincipal" -}}
{{- include "kubeflow.component.serviceAccountPrincipal" (
    list
    .
    (include "kubeflow.pipelines.persistenceAgent.serviceAccountName" .)
)}}
{{- end }}

{{- define "kubeflow.pipelines.persistenceAgent.roleName" -}}
{{- include "kubeflow.pipelines.persistenceAgent.name" . }}
{{- end }}

{{- define "kubeflow.pipelines.persistenceAgent.roleBindingName" -}}
{{- include "kubeflow.pipelines.persistenceAgent.roleName" . }}
{{- end }}

{{/*
Kubeflow Pipelines Persistence Agent Service.
*/}}
{{- define "kubeflow.pipelines.persistenceAgent.svc.name" -}}
{{ include "kubeflow.component.svc.name" (
    include "kubeflow.pipelines.persistenceAgent.name" .
)}}
{{- end }}

{{- define "kubeflow.pipelines.persistenceAgent.svc.addressWithNs" -}}
{{ include "kubeflow.component.svc.addressWithNs"  (
    list
    .
    (include "kubeflow.pipelines.persistenceAgent.name" .)
)}}
{{- end }}

{{- define "kubeflow.pipelines.persistenceAgent.svc.addressWithSvc" -}}
{{ include "kubeflow.component.svc.addressWithSvc"  (
    list
    .
    (include "kubeflow.pipelines.persistenceAgent.name" .)
)}}
{{- end }}

{{- define "kubeflow.pipelines.persistenceAgent.svc.fqdn" -}}
{{ include "kubeflow.component.svc.fqdn"  (
    list
    .
    (include "kubeflow.pipelines.persistenceAgent.name" .)
)}}
{{- end }}

{{/*
Kubeflow Pipelines Persistence Agent object labels.
*/}}
{{- define "kubeflow.pipelines.persistenceAgent.labels" -}}
{{ include "kubeflow.common.labels" . }}
{{ include "kubeflow.component.labels" (include "kubeflow.pipelines.name" .) }}
{{ include "kubeflow.component.subcomponent.labels" (include "kubeflow.pipelines.persistenceAgent.name" .) }}
{{- end }}

{{- define "kubeflow.pipelines.persistenceAgent.selectorLabels" -}}
{{ include "kubeflow.common.selectorLabels" . }}
{{ include "kubeflow.component.selectorLabels" (include "kubeflow.pipelines.name" .) }}
{{ include "kubeflow.component.subcomponent.labels" (include "kubeflow.pipelines.persistenceAgent.name" .) }}
{{- end }}

{{/*
Kubeflow Pipelines Persistence Agent container image settings.
*/}}
{{- define "kubeflow.pipelines.persistenceAgent.image" -}}
{{- include "kubeflow.pipelines.image" (
    list
    .Values.defaults.image
    .Values.pipelines.defaults.image
    .Values.pipelines.persistenceAgent.image
)}}
{{- end }}

{{- define "kubeflow.pipelines.persistenceAgent.imagePullPolicy" -}}
{{- include "kubeflow.pipelines.imagePullPolicy" (
    list
    .Values.defaults.image
    .Values.pipelines.defaults.image
    .Values.pipelines.persistenceAgent.image
)}}
{{- end }}


{{/*
Kubeflow Pipelines Persistence Agent Autoscaling and Availability.
*/}}
{{- define "kubeflow.pipelines.persistenceAgent.autoscaling.enabled" -}}
{{ include "kubeflow.component.autoscaling.enabled" (list .Values.defaults.autoscaling .Values.pipelines.persistenceAgent.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.persistenceAgent.autoscaling.minReplicas" -}}
{{ include "kubeflow.component.autoscaling.minReplicas" (list .Values.defaults.autoscaling .Values.pipelines.persistenceAgent.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.persistenceAgent.autoscaling.maxReplicas" -}}
{{ include "kubeflow.component.autoscaling.maxReplicas" (list .Values.defaults.autoscaling .Values.pipelines.persistenceAgent.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.persistenceAgent.autoscaling.targetCPUUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetCPUUtilizationPercentage" (list .Values.defaults.autoscaling .Values.pipelines.persistenceAgent.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.persistenceAgent.autoscaling.targetMemoryUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetMemoryUtilizationPercentage" (list .Values.defaults.autoscaling .Values.pipelines.persistenceAgent.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.persistenceAgent.pdb.values" -}}
{{- include "kubeflow.component.pdb.values" (
    list
    .Values.defaults.podDisruptionBudget
    .Values.pipelines.persistenceAgent.podDisruptionBudget
)}}
{{- end }}

{{/*
Kubeflow Pipelines Persistence Agent Security Context.
*/}}
{{- define "kubeflow.pipelines.persistenceAgent.containerSecurityContext" -}}
{{- include "kubeflow.component.containerSecurityContext" (
    list
    .Values.defaults.containerSecurityContext
    .Values.pipelines.persistenceAgent.containerSecurityContext
)}}
{{- end }}

{{/*
Kubeflow Pipelines Persistence Agent Scheduling.
*/}}
{{- define "kubeflow.pipelines.persistenceAgent.topologySpreadConstraints" -}}
{{ include "kubeflow.component.topologySpreadConstraints" (
    list
    .Values.defaults.topologySpreadConstraints
    .Values.pipelines.persistenceAgent.topologySpreadConstraints
)}}
{{- end }}

{{- define "kubeflow.pipelines.persistenceAgent.nodeSelector" -}}
{{ include "kubeflow.component.nodeSelector" (
    list
    .Values.defaults.nodeSelector
    .Values.pipelines.persistenceAgent.nodeSelector
)}}
{{- end }}

{{- define "kubeflow.pipelines.persistenceAgent.tolerations" -}}
{{ include "kubeflow.component.tolerations" (
    list
    .Values.defaults.tolerations
    .Values.pipelines.persistenceAgent.tolerations
)}}
{{- end }}

{{- define "kubeflow.pipelines.persistenceAgent.affinity" -}}
{{ include "kubeflow.component.affinity" (
    list
    .Values.defaults.affinity
    .Values.pipelines.persistenceAgent.affinity
)}}
{{- end }}

{{/*
Kubeflow Pipelines Persistence Agent enable and create toggles.
*/}}
{{- define "kubeflow.pipelines.persistenceAgent.enabled" -}}
{{- and
    (include "kubeflow.pipelines.enabled" . | eq "true")
    .Values.pipelines.persistenceAgent.enabled
}}
{{- end }}

{{- define "kubeflow.pipelines.persistenceAgent.rbac.createRoles" -}}
{{- and
    (include "kubeflow.pipelines.persistenceAgent.enabled" . | eq "true")
    .Values.pipelines.persistenceAgent.rbac.create }}
{{- end }}

{{- define "kubeflow.pipelines.persistenceAgent.createServiceAccount" -}}
{{- and
    (include "kubeflow.pipelines.persistenceAgent.enabled" . | eq "true")
    .Values.pipelines.persistenceAgent.serviceAccount.create
}}
{{- end }}
