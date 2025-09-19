{{/*
Kubeflow Notebooks object names.
*/}}
{{- define "kubeflow.notebooks.baseName" -}}
{{- printf "notebooks" }}
{{- end }}

{{- define "kubeflow.notebooks.baseRbacName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) (include "kubeflow.notebooks.name" .) }}
{{- end }}

{{- define "kubeflow.notebooks.name" -}}
{{- include "kubeflow.component.name" (
    list
    (include "kubeflow.notebooks.baseName" .)
    .
)}}
{{- end }}

{{/*
Kubeflow Notebooks object labels.
*/}}
{{- define "kubeflow.notebooks.labels" -}}
{{ include "kubeflow.common.labels" . }}
{{ include "kubeflow.component.labels" (include "kubeflow.notebooks.name" .) }}
{{- end }}

{{- define "kubeflow.notebooks.selectorLabels" -}}
{{ include "kubeflow.common.selectorLabels" . }}
{{ include "kubeflow.component.selectorLabels" (include "kubeflow.notebooks.name" .) }}
{{- end }}

{{/*
Kubeflow Notebooks container image settings.
*/}}
{{- define "kubeflow.notebooks.image" -}}
{{ include "kubeflow.component.image" (list .Values.defaults.image .Values.notebooks.image) }}
{{- end }}

{{- define "kubeflow.notebooks.imagePullPolicy" -}}
{{ include "kubeflow.component.imagePullPolicy" (list .Values.defaults.image .Values.notebooks.image) }}
{{- end }}

{{/*
Kubeflow Notebooks Autoscaling and Availability.
*/}}
{{- define "kubeflow.notebooks.autoscaling.enabled" -}}
{{ include "kubeflow.component.autoscaling.enabled" (list .Values.defaults.autoscaling .Values.notebooks.autoscaling) }}
{{- end }}

{{- define "kubeflow.notebooks.autoscaling.minReplicas" -}}
{{ include "kubeflow.component.autoscaling.minReplicas" (list .Values.defaults.autoscaling .Values.notebooks.autoscaling) }}
{{- end }}

{{- define "kubeflow.notebooks.autoscaling.maxReplicas" -}}
{{ include "kubeflow.component.autoscaling.maxReplicas" (list .Values.defaults.autoscaling .Values.notebooks.autoscaling) }}
{{- end }}

{{- define "kubeflow.notebooks.autoscaling.targetCPUUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetCPUUtilizationPercentage" (list .Values.defaults.autoscaling .Values.notebooks.autoscaling) }}
{{- end }}

{{- define "kubeflow.notebooks.autoscaling.targetMemoryUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetMemoryUtilizationPercentage" (list .Values.defaults.autoscaling .Values.notebooks.autoscaling) }}
{{- end }}

{{- define "kubeflow.notebooks.pdb.values" -}}
{{- include "kubeflow.component.pdb.values" (
    list
    .Values.defaults.podDisruptionBudget
    .Values.notebooks.podDisruptionBudget
)}}
{{- end }}

{{/*
Kubeflow Notebooks Security Context.
*/}}
{{- define "kubeflow.notebooks.containerSecurityContext" -}}
{{ include "kubeflow.component.containerSecurityContext" (
    list
    .Values.defaults.containerSecurityContext
    .Values.notebooks.containerSecurityContext
)}}
{{- end }}

{{/*
Kubeflow Notebooks Scheduling.
*/}}
{{- define "kubeflow.notebooks.topologySpreadConstraints" -}}
{{ include "kubeflow.component.topologySpreadConstraints" (
    list
    .Values.defaults.topologySpreadConstraints
    .Values.notebooks.topologySpreadConstraints
)}}
{{- end }}

{{- define "kubeflow.notebooks.nodeSelector" -}}
{{ include "kubeflow.component.nodeSelector" (
    list
    .Values.defaults.nodeSelector
    .Values.notebooks.nodeSelector
)}}
{{- end }}

{{- define "kubeflow.notebooks.tolerations" -}}
{{ include "kubeflow.component.tolerations" (
    list
    .Values.defaults.tolerations
    .Values.notebooks.tolerations
)}}
{{- end }}

{{- define "kubeflow.notebooks.affinity" -}}
{{ include "kubeflow.component.affinity" (
    list
    .Values.defaults.affinity
    .Values.notebooks.affinity
)}}
{{- end }}

{{/*
Kubeflow Notebooks enable and create toggles.
*/}}
{{- define "kubeflow.notebooks.enabled" -}}
{{- ternary true "" .Values.notebooks.enabled }}
{{- end }}
