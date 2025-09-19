{{/*
Kubeflow Admission Webhook object names.
*/}}
{{- define "kubeflowCrds.admissionWebhook.baseName" -}}
{{- printf "admission-webhook" }}
{{- end }}

{{- define "kubeflowCrds.admissionWebhook.name" -}}
{{- include "kubeflowCrds.component.name" (
    list
    (include "kubeflowCrds.admissionWebhook.baseName" .)
    .
)}}
{{- end }}

{{- define "kubeflowCrds.admissionWebhook.group" -}}
{{- include "kubeflowCrds.common.group" . }}
{{- end }}

{{- define "kubeflowCrds.admissionWebhook.singularName" -}}
{{- printf "poddefault" }}
{{- end }}

{{- define "kubeflowCrds.admissionWebhook.pluralName" -}}
{{ printf "%s%s" (include "kubeflowCrds.admissionWebhook.singularName" .) "s" }}
{{- end }}

{{- define "kubeflowCrds.admissionWebhook.fullName" -}}
{{ printf "%s.%s" (include "kubeflowCrds.admissionWebhook.pluralName" .) (include "kubeflowCrds.admissionWebhook.group" .) }}
{{- end }}

{{/*
Kubeflow Admission Webhook object labels.
*/}}
{{- define "kubeflowCrds.admissionWebhook.labels" -}}
{{ include "kubeflowCrds.common.labels" . }}
{{ include "kubeflowCrds.component.labels" (include "kubeflowCrds.admissionWebhook.name" .) }}
{{- end }}

{{- define "kubeflowCrds.admissionWebhook.selectorLabels" -}}
{{ include "kubeflowCrds.common.selectorLabels" . }}
{{ include "kubeflowCrds.component.selectorLabels" (include "kubeflowCrds.admissionWebhook.name" .) }}
{{- end }}

{{/*
Kubeflow Admission Webhook enable and create toggles.
*/}}
{{- define "kubeflowCrds.admissionWebhook.enabled" -}}
{{- .Values.admissionWebhook.enabled }}
{{- end }}
