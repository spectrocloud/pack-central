{{/*
Kubeflow Pipelines ML Pipeline object names.
*/}}
{{- define "kubeflow.pipelines.viewerCrd.baseName" -}}
{{- printf "ml-pipeline-viewer-crd" }}
{{- end }}

{{- define "kubeflow.pipelines.viewerCrd.name" -}}
{{- include "kubeflow.component.name" (
    list
    (include "kubeflow.pipelines.viewerCrd.baseName" .)
    .
)}}
{{- end }}

{{- define "kubeflow.pipelines.viewerCrd.serviceAccountName" -}}
{{- include "kubeflow.component.serviceAccountName"  (
    list
    (include "kubeflow.pipelines.viewerCrd.name" .)
    .Values.pipelines.viewerCrd.serviceAccount)
}}
{{- end }}

{{- define "kubeflow.pipelines.viewerCrd.serviceAccountPrincipal" -}}
{{- include "kubeflow.component.serviceAccountPrincipal" (
    list
    .
    (include "kubeflow.pipelines.viewerCrd.serviceAccountName" .)
)}}
{{- end }}

{{- define "kubeflow.pipelines.viewerCrd.roleName" -}}
{{- include "kubeflow.pipelines.viewerCrd.name" . }}
{{- end }}

{{- define "kubeflow.pipelines.viewerCrd.roleBindingName" -}}
{{- include "kubeflow.pipelines.viewerCrd.roleName" . }}
{{- end }}

{{/*
Kubeflow Pipelines ML Pipeline Service.
*/}}
{{- define "kubeflow.pipelines.viewerCrd.svc.name" -}}
{{ include "kubeflow.component.svc.name" (
    include "kubeflow.pipelines.viewerCrd.name" .
)}}
{{- end }}

{{- define "kubeflow.pipelines.viewerCrd.svc.addressWithNs" -}}
{{ include "kubeflow.component.svc.addressWithNs"  (
    list
    .
    (include "kubeflow.pipelines.viewerCrd.name" .)
)}}
{{- end }}

{{- define "kubeflow.pipelines.viewerCrd.svc.addressWithSvc" -}}
{{ include "kubeflow.component.svc.addressWithSvc"  (
    list
    .
    (include "kubeflow.pipelines.viewerCrd.name" .)
)}}
{{- end }}

{{- define "kubeflow.pipelines.viewerCrd.svc.fqdn" -}}
{{ include "kubeflow.component.svc.fqdn"  (
    list
    .
    (include "kubeflow.pipelines.viewerCrd.name" .)
)}}
{{- end }}

{{/*
Kubeflow Pipelines ML Pipeline object labels.
*/}}
{{- define "kubeflow.pipelines.viewerCrd.labels" -}}
{{ include "kubeflow.common.labels" . }}
{{ include "kubeflow.component.labels" (include "kubeflow.pipelines.name" .) }}
{{ include "kubeflow.component.subcomponent.labels" (include "kubeflow.pipelines.viewerCrd.name" .) }}
{{- end }}

{{- define "kubeflow.pipelines.viewerCrd.selectorLabels" -}}
{{ include "kubeflow.common.selectorLabels" . }}
{{ include "kubeflow.component.selectorLabels" (include "kubeflow.pipelines.name" .) }}
{{ include "kubeflow.component.subcomponent.labels" (include "kubeflow.pipelines.viewerCrd.name" .) }}
{{- end }}

{{/*
Kubeflow Pipelines ML Pipeline container image settings.
*/}}
{{- define "kubeflow.pipelines.viewerCrd.image" -}}
{{- include "kubeflow.pipelines.image" (
    list
    .Values.defaults.image
    .Values.pipelines.defaults.image
    .Values.pipelines.viewerCrd.image
)}}

{{- end }}

{{- define "kubeflow.pipelines.viewerCrd.imagePullPolicy" -}}
{{- include "kubeflow.pipelines.imagePullPolicy" (
    list
    .Values.defaults.image
    .Values.pipelines.defaults.image
    .Values.pipelines.viewerCrd.image
)}}
{{- end }}


{{/*
Kubeflow Pipelines ML Pipeline Autoscaling and Availability.
*/}}
{{- define "kubeflow.pipelines.viewerCrd.autoscaling.enabled" -}}
{{ include "kubeflow.component.autoscaling.enabled" (list .Values.defaults.autoscaling .Values.pipelines.viewerCrd.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.viewerCrd.autoscaling.minReplicas" -}}
{{ include "kubeflow.component.autoscaling.minReplicas" (list .Values.defaults.autoscaling .Values.pipelines.viewerCrd.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.viewerCrd.autoscaling.maxReplicas" -}}
{{ include "kubeflow.component.autoscaling.maxReplicas" (list .Values.defaults.autoscaling .Values.pipelines.viewerCrd.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.viewerCrd.autoscaling.targetCPUUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetCPUUtilizationPercentage" (list .Values.defaults.autoscaling .Values.pipelines.viewerCrd.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.viewerCrd.autoscaling.targetMemoryUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetMemoryUtilizationPercentage" (list .Values.defaults.autoscaling .Values.pipelines.viewerCrd.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.viewerCrd.pdb.values" -}}
{{- include "kubeflow.component.pdb.values" (
    list
    .Values.defaults.podDisruptionBudget
    .Values.pipelines.viewerCrd.podDisruptionBudget
)}}
{{- end }}

{{/*
Kubeflow Pipelines ML Pipeline Security Context.
*/}}
{{- define "kubeflow.pipelines.viewerCrd.containerSecurityContext" -}}
{{- include "kubeflow.component.containerSecurityContext" (
    list
    .Values.defaults.containerSecurityContext
    .Values.pipelines.viewerCrd.containerSecurityContext
)}}
{{- end }}

{{/*
Kubeflow Pipelines ML Pipeline Scheduling.
*/}}
{{- define "kubeflow.pipelines.viewerCrd.topologySpreadConstraints" -}}
{{ include "kubeflow.component.topologySpreadConstraints" (
    list
    .Values.defaults.topologySpreadConstraints
    .Values.pipelines.viewerCrd.topologySpreadConstraints
)}}
{{- end }}

{{- define "kubeflow.pipelines.viewerCrd.nodeSelector" -}}
{{ include "kubeflow.component.nodeSelector" (
    list
    .Values.defaults.nodeSelector
    .Values.pipelines.viewerCrd.nodeSelector
)}}
{{- end }}

{{- define "kubeflow.pipelines.viewerCrd.tolerations" -}}
{{ include "kubeflow.component.tolerations" (
    list
    .Values.defaults.tolerations
    .Values.pipelines.viewerCrd.tolerations
)}}
{{- end }}

{{- define "kubeflow.pipelines.viewerCrd.affinity" -}}
{{ include "kubeflow.component.affinity" (
    list
    .Values.defaults.affinity
    .Values.pipelines.viewerCrd.affinity
)}}
{{- end }}

{{/*
Kubeflow Pipelines ML Pipeline enable and create toggles.
*/}}
{{- define "kubeflow.pipelines.viewerCrd.enabled" -}}
{{- and
    (include "kubeflow.pipelines.enabled" . | eq "true")
    .Values.pipelines.viewerCrd.enabled
}}
{{- end }}

{{- define "kubeflow.pipelines.viewerCrd.rbac.createRoles" -}}
{{- and
    (include "kubeflow.pipelines.viewerCrd.enabled" . | eq "true")
    .Values.pipelines.viewerCrd.rbac.create }}
{{- end }}

{{- define "kubeflow.pipelines.viewerCrd.createServiceAccount" -}}
{{- and
    (include "kubeflow.pipelines.viewerCrd.enabled" . | eq "true")
    .Values.pipelines.viewerCrd.serviceAccount.create
}}
{{- end }}
