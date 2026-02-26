{{/*
Kubeflow Pipelines ML Pipeline object names.
*/}}
{{- define "kubeflowCrds.pipelines.viewerCrd.baseName" -}}
{{- printf "ml-pipeline-viewer-crd" }}
{{- end }}

{{- define "kubeflowCrds.pipelines.viewerCrd.name" -}}
{{- include "kubeflowCrds.component.name" (
    list
    (include "kubeflowCrds.pipelines.viewerCrd.baseName" .)
    .
)}}
{{- end }}

{{- define "kubeflowCrds.pipelines.viewerCrd.group" -}}
{{- include "kubeflowCrds.common.group" . }}
{{- end }}

{{- define "kubeflowCrds.pipelines.viewerCrd.singularName" -}}
{{- printf "viewer" }}
{{- end }}

{{- define "kubeflowCrds.pipelines.viewerCrd.pluralName" -}}
{{ printf "%s%s" (include "kubeflowCrds.pipelines.viewerCrd.singularName" .) "s" }}
{{- end }}

{{- define "kubeflowCrds.pipelines.viewerCrd.fullName" -}}
{{ printf "%s.%s" (include "kubeflowCrds.pipelines.viewerCrd.pluralName" .) (include "kubeflowCrds.pipelines.viewerCrd.group" .) }}
{{- end }}

{{/*
Kubeflow Pipelines ML Pipeline object labels.
*/}}
{{- define "kubeflowCrds.pipelines.viewerCrd.labels" -}}
{{ include "kubeflowCrds.common.labels" . }}
{{ include "kubeflowCrds.component.labels" (include "kubeflowCrds.pipelines.name" .) }}
{{ include "kubeflowCrds.component.subcomponent.labels" (include "kubeflowCrds.pipelines.viewerCrd.name" .) }}
{{- end }}

{{- define "kubeflowCrds.pipelines.viewerCrd.selectorLabels" -}}
{{ include "kubeflowCrds.common.selectorLabels" . }}
{{ include "kubeflowCrds.component.selectorLabels" (include "kubeflowCrds.pipelines.name" .) }}
{{ include "kubeflowCrds.component.subcomponent.labels" (include "kubeflowCrds.pipelines.viewerCrd.name" .) }}
{{- end }}

{{/*
Kubeflow Pipelines ML Pipeline enable and create toggles.
*/}}
{{- define "kubeflowCrds.pipelines.viewerCrd.enabled" -}}
{{- and
    (include "kubeflowCrds.pipelines.enabled" . | eq "true")
    .Values.pipelines.viewerCrd.enabled
}}
{{- end }}
