{{/*
Kubeflow Pipelines Metadata Writer object names.
*/}}
{{- define "kubeflow.pipelines.metadataWriter.baseName" -}}
{{- printf "ml-pipeline-metadata-writer" }}
{{- end }}

{{- define "kubeflow.pipelines.metadataWriter.name" -}}
{{- include "kubeflow.component.name" (
    list
    (include "kubeflow.pipelines.metadataWriter.baseName" .)
    .
)}}
{{- end }}

{{- define "kubeflow.pipelines.metadataWriter.serviceAccountName" -}}
{{- include "kubeflow.component.serviceAccountName"  (
    list
    (include "kubeflow.pipelines.metadataWriter.name" .)
    .Values.pipelines.metadataWriter.serviceAccount)
}}
{{- end }}

{{- define "kubeflow.pipelines.metadataWriter.roleName" -}}
{{- include "kubeflow.pipelines.metadataWriter.name" . }}
{{- end }}

{{- define "kubeflow.pipelines.metadataWriter.roleBindingName" -}}
{{- include "kubeflow.pipelines.metadataWriter.roleName" . }}
{{- end }}

{{/*
Kubeflow Pipelines Metadata Writer Service.
*/}}
{{- define "kubeflow.pipelines.metadataWriter.svc.name" -}}
{{ include "kubeflow.component.svc.name" (
    include "kubeflow.pipelines.metadataWriter.name" .
)}}
{{- end }}

{{- define "kubeflow.pipelines.metadataWriter.svc.addressWithNs" -}}
{{ include "kubeflow.component.svc.addressWithNs"  (
    list
    .
    (include "kubeflow.pipelines.metadataWriter.name" .)
)}}
{{- end }}

{{- define "kubeflow.pipelines.metadataWriter.svc.addressWithSvc" -}}
{{ include "kubeflow.component.svc.addressWithSvc"  (
    list
    .
    (include "kubeflow.pipelines.metadataWriter.name" .)
)}}
{{- end }}

{{- define "kubeflow.pipelines.metadataWriter.svc.fqdn" -}}
{{ include "kubeflow.component.svc.fqdn"  (
    list
    .
    (include "kubeflow.pipelines.metadataWriter.name" .)
)}}
{{- end }}

{{/*
Kubeflow Pipelines Metadata Writer object labels.
*/}}
{{- define "kubeflow.pipelines.metadataWriter.labels" -}}
{{ include "kubeflow.common.labels" . }}
{{ include "kubeflow.component.labels" (include "kubeflow.pipelines.name" .) }}
{{ include "kubeflow.component.subcomponent.labels" (include "kubeflow.pipelines.metadataWriter.name" .) }}
{{- end }}

{{- define "kubeflow.pipelines.metadataWriter.selectorLabels" -}}
{{ include "kubeflow.common.selectorLabels" . }}
{{ include "kubeflow.component.selectorLabels" (include "kubeflow.pipelines.name" .) }}
{{ include "kubeflow.component.subcomponent.labels" (include "kubeflow.pipelines.metadataWriter.name" .) }}
{{- end }}

{{/*
Kubeflow Pipelines Metadata Writer container image settings.
*/}}
{{- define "kubeflow.pipelines.metadataWriter.image" -}}
{{- include "kubeflow.pipelines.image" (
    list
    .Values.defaults.image
    .Values.pipelines.defaults.image
    .Values.pipelines.metadataWriter.image
)}}
{{- end }}

{{- define "kubeflow.pipelines.metadataWriter.imagePullPolicy" -}}
{{- include "kubeflow.pipelines.imagePullPolicy" (
    list
    .Values.defaults.image
    .Values.pipelines.defaults.image
    .Values.pipelines.metadataWriter.image
)}}
{{- end }}


{{/*
Kubeflow Pipelines Metadata Writer Autoscaling and Availability.
*/}}
{{- define "kubeflow.pipelines.metadataWriter.autoscaling.enabled" -}}
{{ include "kubeflow.component.autoscaling.enabled" (list .Values.defaults.autoscaling .Values.pipelines.metadataWriter.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.metadataWriter.autoscaling.minReplicas" -}}
{{ include "kubeflow.component.autoscaling.minReplicas" (list .Values.defaults.autoscaling .Values.pipelines.metadataWriter.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.metadataWriter.autoscaling.maxReplicas" -}}
{{ include "kubeflow.component.autoscaling.maxReplicas" (list .Values.defaults.autoscaling .Values.pipelines.metadataWriter.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.metadataWriter.autoscaling.targetCPUUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetCPUUtilizationPercentage" (list .Values.defaults.autoscaling .Values.pipelines.metadataWriter.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.metadataWriter.autoscaling.targetMemoryUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetMemoryUtilizationPercentage" (list .Values.defaults.autoscaling .Values.pipelines.metadataWriter.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.metadataWriter.pdb.values" -}}
{{- include "kubeflow.component.pdb.values" (
    list
    .Values.defaults.podDisruptionBudget
    .Values.pipelines.metadataWriter.podDisruptionBudget
)}}
{{- end }}

{{/*
Kubeflow Pipelines Metadata Writer Security Context.
*/}}
{{- define "kubeflow.pipelines.metadataWriter.containerSecurityContext" -}}
{{- include "kubeflow.component.containerSecurityContext" (
    list
    .Values.defaults.containerSecurityContext
    .Values.pipelines.metadataWriter.containerSecurityContext
)}}
{{- end }}

{{/*
Kubeflow Pipelines Metadata Writer Scheduling.
*/}}
{{- define "kubeflow.pipelines.metadataWriter.topologySpreadConstraints" -}}
{{ include "kubeflow.component.topologySpreadConstraints" (
    list
    .Values.defaults.topologySpreadConstraints
    .Values.pipelines.metadataWriter.topologySpreadConstraints
)}}
{{- end }}

{{- define "kubeflow.pipelines.metadataWriter.nodeSelector" -}}
{{ include "kubeflow.component.nodeSelector" (
    list
    .Values.defaults.nodeSelector
    .Values.pipelines.metadataWriter.nodeSelector
)}}
{{- end }}

{{- define "kubeflow.pipelines.metadataWriter.tolerations" -}}
{{ include "kubeflow.component.tolerations" (
    list
    .Values.defaults.tolerations
    .Values.pipelines.metadataWriter.tolerations
)}}
{{- end }}

{{- define "kubeflow.pipelines.metadataWriter.affinity" -}}
{{ include "kubeflow.component.affinity" (
    list
    .Values.defaults.affinity
    .Values.pipelines.metadataWriter.affinity
)}}
{{- end }}

{{/*
Kubeflow Pipelines Metadata Writer enable and create toggles.
*/}}
{{- define "kubeflow.pipelines.metadataWriter.enabled" -}}
{{- ternary true "" (
    and
    (include "kubeflow.pipelines.enabled" . | eq "true")
    .Values.pipelines.metadataWriter.enabled
)}}
{{- end }}

{{- define "kubeflow.pipelines.metadataWriter.rbac.createRoles" -}}
{{- ternary true "" (
    and
    (include "kubeflow.pipelines.metadataWriter.enabled" . | eq "true")
    .Values.pipelines.metadataWriter.rbac.create
)}}
{{- end }}

{{- define "kubeflow.pipelines.metadataWriter.createServiceAccount" -}}
{{- ternary true "" (
    and
    (include "kubeflow.pipelines.metadataWriter.enabled" . | eq "true")
    .Values.pipelines.metadataWriter.serviceAccount.create
)}}
{{- end }}
