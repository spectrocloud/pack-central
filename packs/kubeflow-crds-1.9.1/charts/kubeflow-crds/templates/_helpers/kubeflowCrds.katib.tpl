{{/*
Kubeflow Katib Controller object names.
*/}}
{{- define "kubeflowCrds.katib.baseName" -}}
{{- printf "katib" }}
{{- end }}

{{- define "kubeflowCrds.katib.name" -}}
{{- include "kubeflowCrds.component.name" (
    list
    (include "kubeflowCrds.katib.baseName" .)
    .
)}}
{{- end }}

{{/*
Kubeflow Katib Controller object labels.
*/}}
{{- define "kubeflowCrds.katib.labels" -}}
{{ include "kubeflowCrds.common.labels" . }}
{{ include "kubeflowCrds.component.labels" (include "kubeflowCrds.katib.name" .) }}
{{ include "kubeflowCrds.component.subcomponent.labels" (include "kubeflowCrds.katib.name" .) }}
{{- end }}

{{- define "kubeflowCrds.katib.selectorLabels" -}}
{{ include "kubeflowCrds.common.selectorLabels" . }}
{{ include "kubeflowCrds.component.selectorLabels" (include "kubeflowCrds.katib.name" .) }}
{{ include "kubeflowCrds.component.subcomponent.labels" (include "kubeflowCrds.katib.name" .) }}
{{- end }}

{{/*
Kubeflow Katib enable and create toggles.
*/}}
{{- define "kubeflowCrds.katib.enabled" -}}
{{- ternary true "" .Values.katib.enabled }}
{{- end }}
