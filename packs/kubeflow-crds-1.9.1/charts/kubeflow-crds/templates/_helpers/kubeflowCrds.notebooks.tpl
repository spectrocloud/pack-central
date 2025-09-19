{{/*
Kubeflow Notebooks object names.
*/}}
{{- define "kubeflowCrds.notebooks.baseName" -}}
{{- printf "notebooks" }}
{{- end }}

{{- define "kubeflowCrds.notebooks.name" -}}
{{- include "kubeflowCrds.component.name" (
    list
    (include "kubeflowCrds.notebooks.baseName" .)
    .
)}}
{{- end }}

{{/*
Kubeflow Notebooks object labels.
*/}}
{{- define "kubeflowCrds.notebooks.labels" -}}
{{ include "kubeflowCrds.common.labels" . }}
{{ include "kubeflowCrds.component.labels" (include "kubeflowCrds.notebooks.name" .) }}
{{- end }}

{{- define "kubeflowCrds.notebooks.selectorLabels" -}}
{{ include "kubeflowCrds.common.selectorLabels" . }}
{{ include "kubeflowCrds.component.selectorLabels" (include "kubeflowCrds.notebooks.name" .) }}
{{- end }}

{{/*
Kubeflow Notebooks enable and create toggles.
*/}}
{{- define "kubeflowCrds.notebooks.enabled" -}}
{{- ternary true "" .Values.notebooks.enabled }}
{{- end }}
