{{/*
Kubeflow Notebooks Controller object names.
*/}}
{{- define "kubeflowCrds.notebooks.controller.baseName" -}}
{{- printf "notebooks-controller" }}
{{- end }}

{{- define "kubeflowCrds.notebooks.controller.name" -}}
{{- include "kubeflowCrds.component.name" (
    list
    (include "kubeflowCrds.notebooks.controller.baseName" .)
    .
)}}
{{- end }}

{{- define "kubeflowCrds.notebooks.controller.group" -}}
{{- include "kubeflowCrds.common.group" . }}
{{- end }}

{{- define "kubeflowCrds.notebooks.controller.singularName" -}}
{{- printf "notebook" }}
{{- end }}

{{- define "kubeflowCrds.notebooks.controller.pluralName" -}}
{{ printf "%s%s" (include "kubeflowCrds.notebooks.controller.singularName" .) "s" }}
{{- end }}

{{- define "kubeflowCrds.notebooks.controller.fullName" -}}
{{ printf "%s.%s" (include "kubeflowCrds.notebooks.controller.pluralName" .) (include "kubeflowCrds.notebooks.controller.group" .) }}
{{- end }}

{{/*
Kubeflow Notebooks Controller object labels.
*/}}
{{- define "kubeflowCrds.notebooks.controller.labels" -}}
{{ include "kubeflowCrds.common.labels" . }}
{{ include "kubeflowCrds.component.labels" (include "kubeflowCrds.notebooks.name" .) }}
{{ include "kubeflowCrds.component.subcomponent.labels" (include "kubeflowCrds.notebooks.controller.name" .) }}
{{- end }}

{{- define "kubeflowCrds.notebooks.controller.selectorLabels" -}}
{{ include "kubeflowCrds.common.selectorLabels" . }}
{{ include "kubeflowCrds.component.selectorLabels" (include "kubeflowCrds.notebooks.name" .) }}
{{ include "kubeflowCrds.component.subcomponent.labels" (include "kubeflowCrds.notebooks.controller.name" .) }}
{{- end }}

{{/*
Kubeflow Notebooks Controller enable and create toggles.
*/}}
{{- define "kubeflowCrds.notebooks.controller.enabled" -}}
{{- ternary true "" (
    and
    (include "kubeflowCrds.notebooks.enabled" . | eq "true")
    .Values.notebooks.controller.enabled
)}}
{{- end }}

{{- define "kubeflowCrds.notebooks.controller.certName" -}}
{{ printf "%s-%s" (include "kubeflowCrds.notebooks.controller.name" .) "cert" }}
{{- end }}
