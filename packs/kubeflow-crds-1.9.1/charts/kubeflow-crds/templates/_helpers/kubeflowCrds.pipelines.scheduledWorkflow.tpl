{{/*
Kubeflow Pipelines Scheduled Workflow object names.
*/}}
{{- define "kubeflowCrds.pipelines.scheduledWorkflow.baseName" -}}
{{- printf "ml-pipeline-scheduledworkflow" }}
{{- end }}

{{- define "kubeflowCrds.pipelines.scheduledWorkflow.name" -}}
{{- include "kubeflowCrds.component.name" (
    list
    (include "kubeflowCrds.pipelines.scheduledWorkflow.baseName" .)
    .
)}}
{{- end }}

{{- define "kubeflowCrds.pipelines.scheduledWorkflow.group" -}}
{{- include "kubeflowCrds.common.group" . }}
{{- end }}

{{- define "kubeflowCrds.pipelines.scheduledWorkflow.singularName" -}}
{{- printf "scheduledworkflow" }}
{{- end }}

{{- define "kubeflowCrds.pipelines.scheduledWorkflow.pluralName" -}}
{{ printf "%s%s" (include "kubeflowCrds.pipelines.scheduledWorkflow.singularName" .) "s" }}
{{- end }}

{{- define "kubeflowCrds.pipelines.scheduledWorkflow.fullName" -}}
{{ printf "%s.%s" (include "kubeflowCrds.pipelines.scheduledWorkflow.pluralName" .) (include "kubeflowCrds.pipelines.scheduledWorkflow.group" .) }}
{{- end }}

{{/*
Kubeflow Pipelines Scheduled Workflow object labels.
*/}}
{{- define "kubeflowCrds.pipelines.scheduledWorkflow.labels" -}}
{{ include "kubeflowCrds.common.labels" . }}
{{ include "kubeflowCrds.component.labels" (include "kubeflowCrds.pipelines.name" .) }}
{{ include "kubeflowCrds.component.subcomponent.labels" (include "kubeflowCrds.pipelines.scheduledWorkflow.name" .) }}
{{- end }}

{{- define "kubeflowCrds.pipelines.scheduledWorkflow.selectorLabels" -}}
{{ include "kubeflowCrds.common.selectorLabels" . }}
{{ include "kubeflowCrds.component.selectorLabels" (include "kubeflowCrds.pipelines.name" .) }}
{{ include "kubeflowCrds.component.subcomponent.labels" (include "kubeflowCrds.pipelines.scheduledWorkflow.name" .) }}
{{- end }}

{{/*
Kubeflow Pipelines Scheduled Workflow enable and create toggles.
*/}}
{{- define "kubeflowCrds.pipelines.scheduledWorkflow.enabled" -}}
{{- and
    (include "kubeflowCrds.pipelines.enabled" . | eq "true")
    .Values.pipelines.scheduledWorkflow.enabled
}}
{{- end }}
