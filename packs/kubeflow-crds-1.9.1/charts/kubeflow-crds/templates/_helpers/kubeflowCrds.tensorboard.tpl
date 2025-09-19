{{/*
Kubeflow Tensorboard object names.
*/}}
{{- define "kubeflowCrds.tensorboard.baseName" -}}
{{- printf "tensorboard" }}
{{- end }}

{{- define "kubeflowCrds.tensorboard.name" -}}
{{- include "kubeflowCrds.component.name" (
    list
    (include "kubeflowCrds.tensorboard.baseName" .)
    .
)}}
{{- end }}

{{/*
Kubeflow Tensorboard object labels.
*/}}
{{- define "kubeflowCrds.tensorboard.labels" -}}
{{ include "kubeflowCrds.common.labels" . }}
{{ include "kubeflowCrds.component.labels" (include "kubeflowCrds.tensorboard.name" .) }}
{{- end }}

{{- define "kubeflowCrds.tensorboard.selectorLabels" -}}
{{ include "kubeflowCrds.common.selectorLabels" . }}
{{ include "kubeflowCrds.component.selectorLabels" (include "kubeflowCrds.tensorboard.name" .) }}
{{- end }}

{{/*
Kubeflow Tensorboard enable and create toggles.
*/}}
{{- define "kubeflowCrds.tensorboard.enabled" -}}
{{- ternary true "" .Values.tensorboard.enabled }}
{{- end }}
