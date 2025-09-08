{{/*
Kubeflow Pipelines Visualization object names.
*/}}
{{- define "kubeflow.pipelines.visualization.baseName" -}}
{{- printf "ml-pipeline-visualizationserver" }}
{{- end }}

{{- define "kubeflow.pipelines.visualization.name" -}}
{{- include "kubeflow.component.name" (
    list
    (include "kubeflow.pipelines.visualization.baseName" .)
    .
)}}
{{- end }}

{{- define "kubeflow.pipelines.visualization.serviceAccountName" -}}
{{- include "kubeflow.component.serviceAccountName"  (
    list
    (include "kubeflow.pipelines.visualization.name" .)
    .Values.pipelines.visualization.serviceAccount)
}}
{{- end }}

{{- define "kubeflow.pipelines.visualization.roleName" -}}
{{- include "kubeflow.pipelines.visualization.name" . }}
{{- end }}

{{- define "kubeflow.pipelines.visualization.roleBindingName" -}}
{{- include "kubeflow.pipelines.visualization.roleName" . }}
{{- end }}

{{/*
Kubeflow Pipelines Visualization Service.
*/}}
{{- define "kubeflow.pipelines.visualization.svc.name" -}}
{{ include "kubeflow.component.svc.name" (
    include "kubeflow.pipelines.visualization.name" .
)}}
{{- end }}

{{- define "kubeflow.pipelines.visualization.svc.addressWithNs" -}}
{{ include "kubeflow.component.svc.addressWithNs"  (
    list
    .
    (include "kubeflow.pipelines.visualization.name" .)
)}}
{{- end }}

{{- define "kubeflow.pipelines.visualization.svc.addressWithSvc" -}}
{{ include "kubeflow.component.svc.addressWithSvc"  (
    list
    .
    (include "kubeflow.pipelines.visualization.name" .)
)}}
{{- end }}

{{- define "kubeflow.pipelines.visualization.svc.fqdn" -}}
{{ include "kubeflow.component.svc.fqdn"  (
    list
    .
    (include "kubeflow.pipelines.visualization.name" .)
)}}
{{- end }}

{{/*
Kubeflow Pipelines Visualization object labels.
*/}}
{{- define "kubeflow.pipelines.visualization.labels" -}}
{{ include "kubeflow.common.labels" . }}
{{ include "kubeflow.component.labels" (include "kubeflow.pipelines.name" .) }}
{{ include "kubeflow.component.subcomponent.labels" (include "kubeflow.pipelines.visualization.name" .) }}
{{- end }}

{{- define "kubeflow.pipelines.visualization.selectorLabels" -}}
{{ include "kubeflow.common.selectorLabels" . }}
{{ include "kubeflow.component.selectorLabels" (include "kubeflow.pipelines.name" .) }}
{{ include "kubeflow.component.subcomponent.labels" (include "kubeflow.pipelines.visualization.name" .) }}
{{- end }}

{{/*
Kubeflow Pipelines Visualization container image settings.
*/}}
{{- define "kubeflow.pipelines.visualization.image" -}}
{{- include "kubeflow.pipelines.image" (
    list
    .Values.defaults.image
    .Values.pipelines.defaults.image
    .Values.pipelines.visualization.image
)}}

{{- end }}

{{- define "kubeflow.pipelines.visualization.imagePullPolicy" -}}
{{- include "kubeflow.pipelines.imagePullPolicy" (
    list
    .Values.defaults.image
    .Values.pipelines.defaults.image
    .Values.pipelines.visualization.image
)}}
{{- end }}


{{/*
Kubeflow Pipelines Visualization Autoscaling and Availability.
*/}}
{{- define "kubeflow.pipelines.visualization.autoscaling.enabled" -}}
{{ include "kubeflow.component.autoscaling.enabled" (list .Values.defaults.autoscaling .Values.pipelines.visualization.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.visualization.autoscaling.minReplicas" -}}
{{ include "kubeflow.component.autoscaling.minReplicas" (list .Values.defaults.autoscaling .Values.pipelines.visualization.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.visualization.autoscaling.maxReplicas" -}}
{{ include "kubeflow.component.autoscaling.maxReplicas" (list .Values.defaults.autoscaling .Values.pipelines.visualization.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.visualization.autoscaling.targetCPUUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetCPUUtilizationPercentage" (list .Values.defaults.autoscaling .Values.pipelines.visualization.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.visualization.autoscaling.targetMemoryUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetMemoryUtilizationPercentage" (list .Values.defaults.autoscaling .Values.pipelines.visualization.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.visualization.pdb.values" -}}
{{- include "kubeflow.component.pdb.values" (
    list
    .Values.defaults.podDisruptionBudget
    .Values.pipelines.visualization.podDisruptionBudget
)}}
{{- end }}

{{/*
Kubeflow Pipelines Visualization Security Context.
*/}}
{{- define "kubeflow.pipelines.visualization.containerSecurityContext" -}}
{{- include "kubeflow.component.containerSecurityContext" (
    list
    .Values.defaults.containerSecurityContext
    .Values.pipelines.visualization.containerSecurityContext
)}}
{{- end }}

{{/*
Kubeflow Pipelines Visualization Scheduling.
*/}}
{{- define "kubeflow.pipelines.visualization.topologySpreadConstraints" -}}
{{ include "kubeflow.component.topologySpreadConstraints" (
    list
    .Values.defaults.topologySpreadConstraints
    .Values.pipelines.visualization.topologySpreadConstraints
)}}
{{- end }}

{{- define "kubeflow.pipelines.visualization.nodeSelector" -}}
{{ include "kubeflow.component.nodeSelector" (
    list
    .Values.defaults.nodeSelector
    .Values.pipelines.visualization.nodeSelector
)}}
{{- end }}

{{- define "kubeflow.pipelines.visualization.tolerations" -}}
{{ include "kubeflow.component.tolerations" (
    list
    .Values.defaults.tolerations
    .Values.pipelines.visualization.tolerations
)}}
{{- end }}

{{- define "kubeflow.pipelines.visualization.affinity" -}}
{{ include "kubeflow.component.affinity" (
    list
    .Values.defaults.affinity
    .Values.pipelines.visualization.affinity
)}}
{{- end }}

{{/*
Kubeflow Pipelines Visualization enable and create toggles.
*/}}
{{- define "kubeflow.pipelines.visualization.enabled" -}}
{{- ternary true "" (
    and
    (include "kubeflow.pipelines.enabled" . | eq "true")
    .Values.pipelines.visualization.enabled
)}}
{{- end }}

{{- define "kubeflow.pipelines.visualization.rbac.createRoles" -}}
{{- ternary true "" (
    and
    (include "kubeflow.pipelines.visualization.enabled" . | eq "true")
    .Values.pipelines.visualization.rbac.create
)}}
{{- end }}

{{- define "kubeflow.pipelines.visualization.createServiceAccount" -}}
{{- ternary true "" (
    and
    (include "kubeflow.pipelines.visualization.enabled" . | eq "true")
    .Values.pipelines.visualization.serviceAccount.create
)}}
{{- end }}

{{- define "kubeflow.pipelines.visualization.createIstioIntegrationObjects" -}}
{{- ternary true "" (
    and
        (include "kubeflow.pipelines.visualization.enabled" . | eq "true" )
        .Values.istioIntegration.enabled
)}}
{{- end }}
