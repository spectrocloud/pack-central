{{/*
Kubeflow Notebooks PVC Viewer Controller object names.
*/}}
{{- define "kubeflowCrds.notebooks.pvcviewerController.baseName" -}}
{{- printf "pvcviewer-controller" }}
{{- end }}

{{- define "kubeflowCrds.notebooks.pvcviewerController.name" -}}
{{- include "kubeflowCrds.component.name" (
    list
    (include "kubeflowCrds.notebooks.pvcviewerController.baseName" .)
    .
)}}
{{- end }}

{{- define "kubeflowCrds.notebooks.pvcviewerController.manager.name" -}}
{{- printf "%s-%s"
    (include "kubeflowCrds.notebooks.pvcviewerController.name" .)
    "manager"
}}
{{- end }}

{{- define "kubeflowCrds.notebooks.pvcviewerController.certName" -}}
{{ printf "%s-%s" (include "kubeflowCrds.notebooks.pvcviewerController.name" .) "cert" }}
{{- end }}

{{- define "kubeflowCrds.notebooks.pvcviewerController.group" -}}
{{- include "kubeflowCrds.common.group" . }}
{{- end }}

{{- define "kubeflowCrds.notebooks.pvcviewerController.singularName" -}}
{{- printf "pvcviewer" }}
{{- end }}

{{- define "kubeflowCrds.notebooks.pvcviewerController.pluralName" -}}
{{ printf "%s%s" (include "kubeflowCrds.notebooks.pvcviewerController.singularName" .) "s" }}
{{- end }}

{{- define "kubeflowCrds.notebooks.pvcviewerController.fullName" -}}
{{ printf "%s.%s" (include "kubeflowCrds.notebooks.pvcviewerController.pluralName" .) (include "kubeflowCrds.notebooks.pvcviewerController.group" .) }}
{{- end }}

{{/*
Kubeflow Notebooks PVC Viewer Controller object labels.
*/}}
{{- define "kubeflowCrds.notebooks.pvcviewerController.labels" -}}
{{ include "kubeflowCrds.common.labels" . }}
{{ include "kubeflowCrds.component.labels" (include "kubeflowCrds.notebooks.name" .) }}
{{ include "kubeflowCrds.component.subcomponent.labels" (include "kubeflowCrds.notebooks.pvcviewerController.name" .) }}
{{- end }}

{{- define "kubeflowCrds.notebooks.pvcviewerController.selectorLabels" -}}
{{ include "kubeflowCrds.common.selectorLabels" . }}
{{ include "kubeflowCrds.component.selectorLabels" (include "kubeflowCrds.notebooks.name" .) }}
{{ include "kubeflowCrds.component.subcomponent.labels" (include "kubeflowCrds.notebooks.pvcviewerController.name" .) }}
{{- end }}

{{/*
Kubeflow Notebooks PVC Viewer Controller enable and create toggles.
*/}}
{{- define "kubeflowCrds.notebooks.pvcviewerController.enabled" -}}
{{- ternary true "" (
    and
    (include "kubeflowCrds.notebooks.enabled" . | eq "true")
    .Values.notebooks.pvcviewerController.enabled
)}}
{{- end }}
