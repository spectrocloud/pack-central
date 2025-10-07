{{/*
Kubeflow Katib Controller object names.
*/}}
{{- define "kubeflowCrds.katib.controller.baseName" -}}
{{- printf "katib-controller" }}
{{- end }}

{{- define "kubeflowCrds.katib.controller.name" -}}
{{- include "kubeflowCrds.component.name" (
    list
    (include "kubeflowCrds.katib.controller.baseName" .)
    .
)}}
{{- end }}

{{- define "kubeflowCrds.katib.controller.group" -}}
{{- include "kubeflowCrds.common.group" . }}
{{- end }}

{{- define "kubeflowCrds.katib.controller.experimentSingularName" -}}
{{- printf "experiment" }}
{{- end }}

{{- define "kubeflowCrds.katib.controller.experimentPluralName" -}}
{{ printf "%s%s" (include "kubeflowCrds.katib.controller.experimentSingularName" .) "s" }}
{{- end }}

{{- define "kubeflowCrds.katib.controller.experimentFullName" -}}
{{ printf "%s.%s" (include "kubeflowCrds.katib.controller.experimentPluralName" .) (include "kubeflowCrds.katib.controller.group" .) }}
{{- end }}

{{- define "kubeflowCrds.katib.controller.suggestionSingularName" -}}
{{- printf "suggestion" }}
{{- end }}

{{- define "kubeflowCrds.katib.controller.suggestionPluralName" -}}
{{ printf "%s%s" (include "kubeflowCrds.katib.controller.suggestionSingularName" .) "s" }}
{{- end }}

{{- define "kubeflowCrds.katib.controller.suggestionFullName" -}}
{{ printf "%s.%s" (include "kubeflowCrds.katib.controller.suggestionPluralName" .) (include "kubeflowCrds.katib.controller.group" .) }}
{{- end }}

{{- define "kubeflowCrds.katib.controller.trialSingularName" -}}
{{- printf "trial" }}
{{- end }}

{{- define "kubeflowCrds.katib.controller.trialPluralName" -}}
{{ printf "%s%s" (include "kubeflowCrds.katib.controller.trialSingularName" .) "s" }}
{{- end }}

{{- define "kubeflowCrds.katib.controller.trialFullName" -}}
{{ printf "%s.%s" (include "kubeflowCrds.katib.controller.trialPluralName" .) (include "kubeflowCrds.katib.controller.group" .) }}
{{- end }}

{{/*
Kubeflow Katib Controller object labels.
*/}}
{{- define "kubeflowCrds.katib.controller.labels" -}}
{{ include "kubeflowCrds.common.labels" . }}
{{ include "kubeflowCrds.component.labels" (include "kubeflowCrds.katib.name" .) }}
{{ include "kubeflowCrds.component.subcomponent.labels" (include "kubeflowCrds.katib.controller.name" .) }}
{{- end }}

{{- define "kubeflowCrds.katib.controller.selectorLabels" -}}
{{ include "kubeflowCrds.common.selectorLabels" . }}
{{ include "kubeflowCrds.component.selectorLabels" (include "kubeflowCrds.katib.name" .) }}
{{ include "kubeflowCrds.component.subcomponent.labels" (include "kubeflowCrds.katib.controller.name" .) }}
{{- end }}

{{/*
Kubeflow Katib Controller enable and create toggles.
*/}}
{{- define "kubeflowCrds.katib.controller.enabled" -}}
{{- ternary true "" (
    and
    (include "kubeflowCrds.katib.enabled" . | eq "true")
    .Values.katib.controller.enabled
)}}
{{- end }}
