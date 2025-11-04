{{/*
Kubeflow Tensorboard object names.
*/}}
{{- define "kubeflow.tensorboard.baseName" -}}
{{- printf "tensorboard" }}
{{- end }}

{{- define "kubeflow.tensorboard.baseRbacName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) (include "kubeflow.tensorboard.name" .) }}
{{- end }}

{{- define "kubeflow.tensorboard.name" -}}
{{- include "kubeflow.component.name" (
    list
    (include "kubeflow.tensorboard.baseName" .)
    .
)}}
{{- end }}

{{/*
Kubeflow Tensorboard object labels.
*/}}
{{- define "kubeflow.tensorboard.labels" -}}
{{ include "kubeflow.common.labels" . }}
{{ include "kubeflow.component.labels" (include "kubeflow.tensorboard.name" .) }}
{{- end }}

{{- define "kubeflow.tensorboard.selectorLabels" -}}
{{ include "kubeflow.common.selectorLabels" . }}
{{ include "kubeflow.component.selectorLabels" (include "kubeflow.tensorboard.name" .) }}
{{- end }}

{{/*
Kubeflow Tensorboard container image settings.
*/}}
{{- define "kubeflow.tensorboard.image" -}}
{{ include "kubeflow.component.image" (list .Values.defaults.image .Values.tensorboard.image) }}
{{- end }}

{{- define "kubeflow.tensorboard.imagePullPolicy" -}}
{{ include "kubeflow.component.imagePullPolicy" (list .Values.defaults.image .Values.tensorboard.image) }}
{{- end }}

{{/*
Kubeflow Tensorboard Autoscaling and Availability.
*/}}
{{- define "kubeflow.tensorboard.autoscaling.enabled" -}}
{{ include "kubeflow.component.autoscaling.enabled" (list .Values.defaults.autoscaling .Values.tensorboard.autoscaling) }}
{{- end }}

{{- define "kubeflow.tensorboard.autoscaling.minReplicas" -}}
{{ include "kubeflow.component.autoscaling.minReplicas" (list .Values.defaults.autoscaling .Values.tensorboard.autoscaling) }}
{{- end }}

{{- define "kubeflow.tensorboard.autoscaling.maxReplicas" -}}
{{ include "kubeflow.component.autoscaling.maxReplicas" (list .Values.defaults.autoscaling .Values.tensorboard.autoscaling) }}
{{- end }}

{{- define "kubeflow.tensorboard.autoscaling.targetCPUUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetCPUUtilizationPercentage" (list .Values.defaults.autoscaling .Values.tensorboard.autoscaling) }}
{{- end }}

{{- define "kubeflow.tensorboard.autoscaling.targetMemoryUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetMemoryUtilizationPercentage" (list .Values.defaults.autoscaling .Values.tensorboard.autoscaling) }}
{{- end }}

{{- define "kubeflow.tensorboard.pdb.values" -}}
{{- include "kubeflow.component.pdb.values" (
    list
    .Values.defaults.podDisruptionBudget
    .Values.tensorboard.podDisruptionBudget
)}}
{{- end }}

{{/*
Kubeflow Tensorboard Security Context.
*/}}
{{- define "kubeflow.tensorboard.containerSecurityContext" -}}
{{ include "kubeflow.component.containerSecurityContext" (
    list
    .Values.defaults.containerSecurityContext
    .Values.tensorboard.containerSecurityContext
)}}
{{- end }}

{{/*
Kubeflow Tensorboard Scheduling.
*/}}
{{- define "kubeflow.tensorboard.topologySpreadConstraints" -}}
{{ include "kubeflow.component.topologySpreadConstraints" (
    list
    .Values.defaults.topologySpreadConstraints
    .Values.tensorboard.topologySpreadConstraints
)}}
{{- end }}

{{- define "kubeflow.tensorboard.nodeSelector" -}}
{{ include "kubeflow.component.nodeSelector" (
    list
    .Values.defaults.nodeSelector
    .Values.tensorboard.nodeSelector
)}}
{{- end }}

{{- define "kubeflow.tensorboard.tolerations" -}}
{{ include "kubeflow.component.tolerations" (
    list
    .Values.defaults.tolerations
    .Values.tensorboard.tolerations
)}}
{{- end }}

{{- define "kubeflow.tensorboard.affinity" -}}
{{ include "kubeflow.component.affinity" (
    list
    .Values.defaults.affinity
    .Values.tensorboard.affinity
)}}
{{- end }}

{{/*
Kubeflow Tensorboard enable and create toggles.
*/}}
{{- define "kubeflow.tensorboard.enabled" -}}
{{- ternary true "" .Values.tensorboard.enabled }}
{{- end }}
