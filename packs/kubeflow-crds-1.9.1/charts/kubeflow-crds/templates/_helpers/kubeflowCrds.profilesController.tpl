{{/*
Kubeflow Profiles Controller object names.
*/}}
{{- define "kubeflowCrds.profilesController.baseName" -}}
{{- printf "profiles-controller" }}
{{- end }}

{{- define "kubeflowCrds.profilesController.name" -}}
{{- include "kubeflowCrds.component.name" (
    list
    (include "kubeflowCrds.profilesController.baseName" .)
    .
)}}
{{- end }}

{{- define "kubeflowCrds.profilesController.group" -}}
{{- include "kubeflowCrds.common.group" . }}
{{- end }}

{{- define "kubeflowCrds.profilesController.singularName" -}}
{{- printf "profile" }}
{{- end }}

{{- define "kubeflowCrds.profilesController.pluralName" -}}
{{ printf "%s%s" (include "kubeflowCrds.profilesController.singularName" .) "s" }}
{{- end }}

{{- define "kubeflowCrds.profilesController.fullName" -}}
{{ printf "%s.%s" (include "kubeflowCrds.profilesController.pluralName" .) (include "kubeflowCrds.profilesController.group" .) }}
{{- end }}

{{/*
Kubeflow Profiles Controller object labels.
*/}}
{{- define "kubeflowCrds.profilesController.labels" -}}
{{ include "kubeflowCrds.common.labels" . }}
{{ include "kubeflowCrds.component.labels" (include "kubeflowCrds.profilesController.name" .) }}
{{- end }}

{{- define "kubeflowCrds.profilesController.selectorLabels" -}}
{{ include "kubeflowCrds.common.selectorLabels" . }}
{{ include "kubeflowCrds.component.selectorLabels" (include "kubeflowCrds.profilesController.name" .) }}
{{- end }}

{{/*
Kubeflow Profiles Controller enable and create toggles.
*/}}
{{- define "kubeflowCrds.profilesController.enabled" -}}
{{- .Values.profilesController.enabled }}
{{- end }}
