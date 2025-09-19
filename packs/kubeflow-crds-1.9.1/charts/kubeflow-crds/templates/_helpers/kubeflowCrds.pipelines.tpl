{{/*
Kubeflow Pipelines object names.
*/}}
{{- define "kubeflowCrds.pipelines.baseName" -}}
{{- printf "pipelines" }}
{{- end }}

{{- define "kubeflowCrds.pipelines.name" -}}
{{- include "kubeflowCrds.component.name" (
    list
    (include "kubeflowCrds.pipelines.baseName" .)
    .
)}}
{{- end }}

{{/*
Kubeflow Pipelines object labels.
*/}}
{{- define "kubeflowCrds.pipelines.labels" -}}
{{ include "kubeflowCrds.common.labels" . }}
{{ include "kubeflowCrds.component.labels" (include "kubeflowCrds.pipelines.name" .) }}
{{- end }}

{{- define "kubeflowCrds.pipelines.selectorLabels" -}}
{{ include "kubeflowCrds.common.selectorLabels" . }}
{{ include "kubeflowCrds.component.selectorLabels" (include "kubeflowCrds.pipelines.name" .) }}
{{- end }}

{{/*
Kubeflow Pipelines enable and create toggles.
*/}}
{{- define "kubeflowCrds.pipelines.enabled" -}}
{{- ternary true "" .Values.pipelines.enabled }}
{{- end }}
