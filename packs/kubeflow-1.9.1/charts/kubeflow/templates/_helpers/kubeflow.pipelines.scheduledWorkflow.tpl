{{/*
Kubeflow Pipelines Scheduled Workflow object names.
*/}}
{{- define "kubeflow.pipelines.scheduledWorkflow.baseName" -}}
{{- printf "ml-pipeline-scheduledworkflow" }}
{{- end }}

{{- define "kubeflow.pipelines.scheduledWorkflow.name" -}}
{{- include "kubeflow.component.name" (
    list
    (include "kubeflow.pipelines.scheduledWorkflow.baseName" .)
    .
)}}
{{- end }}

{{- define "kubeflow.pipelines.scheduledWorkflow.serviceAccountName" -}}
{{- include "kubeflow.component.serviceAccountName"  (
    list
    (include "kubeflow.pipelines.scheduledWorkflow.name" .)
    .Values.pipelines.scheduledWorkflow.serviceAccount)
}}
{{- end }}

{{- define "kubeflow.pipelines.scheduledWorkflow.serviceAccountPrincipal" -}}
{{- include "kubeflow.component.serviceAccountPrincipal" (
    list
    .
    (include "kubeflow.pipelines.scheduledWorkflow.serviceAccountName" .)
)}}
{{- end }}

{{- define "kubeflow.pipelines.scheduledWorkflow.roleName" -}}
{{- include "kubeflow.pipelines.scheduledWorkflow.name" . }}
{{- end }}

{{- define "kubeflow.pipelines.scheduledWorkflow.roleBindingName" -}}
{{- include "kubeflow.pipelines.scheduledWorkflow.roleName" . }}
{{- end }}

{{/*
Kubeflow Pipelines Scheduled Workflow Service.
*/}}
{{- define "kubeflow.pipelines.scheduledWorkflow.svc.name" -}}
{{ include "kubeflow.component.svc.name" (
    include "kubeflow.pipelines.scheduledWorkflow.name" .
)}}
{{- end }}

{{- define "kubeflow.pipelines.scheduledWorkflow.svc.addressWithNs" -}}
{{ include "kubeflow.component.svc.addressWithNs"  (
    list
    .
    (include "kubeflow.pipelines.scheduledWorkflow.name" .)
)}}
{{- end }}

{{- define "kubeflow.pipelines.scheduledWorkflow.svc.addressWithSvc" -}}
{{ include "kubeflow.component.svc.addressWithSvc"  (
    list
    .
    (include "kubeflow.pipelines.scheduledWorkflow.name" .)
)}}
{{- end }}

{{- define "kubeflow.pipelines.scheduledWorkflow.svc.fqdn" -}}
{{ include "kubeflow.component.svc.fqdn"  (
    list
    .
    (include "kubeflow.pipelines.scheduledWorkflow.name" .)
)}}
{{- end }}

{{/*
Kubeflow Pipelines Scheduled Workflow object labels.
*/}}
{{- define "kubeflow.pipelines.scheduledWorkflow.labels" -}}
{{ include "kubeflow.common.labels" . }}
{{ include "kubeflow.component.labels" (include "kubeflow.pipelines.name" .) }}
{{ include "kubeflow.component.subcomponent.labels" (include "kubeflow.pipelines.scheduledWorkflow.name" .) }}
{{- end }}

{{- define "kubeflow.pipelines.scheduledWorkflow.selectorLabels" -}}
{{ include "kubeflow.common.selectorLabels" . }}
{{ include "kubeflow.component.selectorLabels" (include "kubeflow.pipelines.name" .) }}
{{ include "kubeflow.component.subcomponent.labels" (include "kubeflow.pipelines.scheduledWorkflow.name" .) }}
{{- end }}

{{/*
Kubeflow Pipelines Scheduled Workflow container image settings.
*/}}
{{- define "kubeflow.pipelines.scheduledWorkflow.image" -}}
{{- include "kubeflow.pipelines.image" (
    list
    .Values.defaults.image
    .Values.pipelines.defaults.image
    .Values.pipelines.scheduledWorkflow.image
)}}

{{- end }}

{{- define "kubeflow.pipelines.scheduledWorkflow.imagePullPolicy" -}}
{{- include "kubeflow.pipelines.imagePullPolicy" (
    list
    .Values.defaults.image
    .Values.pipelines.defaults.image
    .Values.pipelines.scheduledWorkflow.image
)}}
{{- end }}


{{/*
Kubeflow Pipelines Scheduled Workflow Autoscaling and Availability.
*/}}
{{- define "kubeflow.pipelines.scheduledWorkflow.autoscaling.enabled" -}}
{{ include "kubeflow.component.autoscaling.enabled" (list .Values.defaults.autoscaling .Values.pipelines.scheduledWorkflow.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.scheduledWorkflow.autoscaling.minReplicas" -}}
{{ include "kubeflow.component.autoscaling.minReplicas" (list .Values.defaults.autoscaling .Values.pipelines.scheduledWorkflow.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.scheduledWorkflow.autoscaling.maxReplicas" -}}
{{ include "kubeflow.component.autoscaling.maxReplicas" (list .Values.defaults.autoscaling .Values.pipelines.scheduledWorkflow.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.scheduledWorkflow.autoscaling.targetCPUUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetCPUUtilizationPercentage" (list .Values.defaults.autoscaling .Values.pipelines.scheduledWorkflow.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.scheduledWorkflow.autoscaling.targetMemoryUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetMemoryUtilizationPercentage" (list .Values.defaults.autoscaling .Values.pipelines.scheduledWorkflow.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.scheduledWorkflow.pdb.values" -}}
{{- include "kubeflow.component.pdb.values" (
    list
    .Values.defaults.podDisruptionBudget
    .Values.pipelines.scheduledWorkflow.podDisruptionBudget
)}}
{{- end }}

{{/*
Kubeflow Pipelines Scheduled Workflow Security Context.
*/}}
{{- define "kubeflow.pipelines.scheduledWorkflow.containerSecurityContext" -}}
{{- include "kubeflow.component.containerSecurityContext" (
    list
    .Values.defaults.containerSecurityContext
    .Values.pipelines.scheduledWorkflow.containerSecurityContext
)}}
{{- end }}

{{/*
Kubeflow Pipelines Scheduled Workflow Scheduling.
*/}}
{{- define "kubeflow.pipelines.scheduledWorkflow.topologySpreadConstraints" -}}
{{ include "kubeflow.component.topologySpreadConstraints" (
    list
    .Values.defaults.topologySpreadConstraints
    .Values.pipelines.scheduledWorkflow.topologySpreadConstraints
)}}
{{- end }}

{{- define "kubeflow.pipelines.scheduledWorkflow.nodeSelector" -}}
{{ include "kubeflow.component.nodeSelector" (
    list
    .Values.defaults.nodeSelector
    .Values.pipelines.scheduledWorkflow.nodeSelector
)}}
{{- end }}

{{- define "kubeflow.pipelines.scheduledWorkflow.tolerations" -}}
{{ include "kubeflow.component.tolerations" (
    list
    .Values.defaults.tolerations
    .Values.pipelines.scheduledWorkflow.tolerations
)}}
{{- end }}

{{- define "kubeflow.pipelines.scheduledWorkflow.affinity" -}}
{{ include "kubeflow.component.affinity" (
    list
    .Values.defaults.affinity
    .Values.pipelines.scheduledWorkflow.affinity
)}}
{{- end }}

{{/*
Kubeflow Pipelines Scheduled Workflow enable and create toggles.
*/}}
{{- define "kubeflow.pipelines.scheduledWorkflow.enabled" -}}
{{- and
    (include "kubeflow.pipelines.enabled" . | eq "true")
    .Values.pipelines.scheduledWorkflow.enabled
}}
{{- end }}

{{- define "kubeflow.pipelines.scheduledWorkflow.rbac.createRoles" -}}
{{- and
    (include "kubeflow.pipelines.scheduledWorkflow.enabled" . | eq "true")
    .Values.pipelines.scheduledWorkflow.rbac.create }}
{{- end }}

{{- define "kubeflow.pipelines.scheduledWorkflow.createServiceAccount" -}}
{{- and
    (include "kubeflow.pipelines.scheduledWorkflow.enabled" . | eq "true")
    .Values.pipelines.scheduledWorkflow.serviceAccount.create
}}
{{- end }}
