{{/*
Kubeflow Tensorboard Controller object names.
*/}}
{{- define "kubeflowCrds.tensorboard.controller.baseName" -}}
{{- printf "tensorboard-controller" }}
{{- end }}

{{- define "kubeflowCrds.tensorboard.controller.name" -}}
{{- include "kubeflowCrds.component.name" (
    list
    (include "kubeflowCrds.tensorboard.controller.baseName" .)
    .
)}}
{{- end }}

{{- define "kubeflowCrds.tensorboard.controller.group" -}}
{{ printf "%s.%s" (include "kubeflowCrds.tensorboard.controller.singularName" .) (include "kubeflowCrds.common.group" .) }}
{{- end }}

{{- define "kubeflowCrds.tensorboard.controller.singularName" -}}
{{- printf "tensorboard" }}
{{- end }}

{{- define "kubeflowCrds.tensorboard.controller.pluralName" -}}
{{ printf "%s%s" (include "kubeflowCrds.tensorboard.controller.singularName" .) "s" }}
{{- end }}

{{- define "kubeflowCrds.tensorboard.controller.fullName" -}}
{{ printf "%s.%s" (include "kubeflowCrds.tensorboard.controller.pluralName" .) (include "kubeflowCrds.tensorboard.controller.group" .) }}
{{- end }}

{{/*
Kubeflow Tensorboard Controller object labels.
*/}}
{{- define "kubeflowCrds.tensorboard.controller.labels" -}}
{{ include "kubeflowCrds.common.labels" . }}
{{ include "kubeflowCrds.component.labels" (include "kubeflowCrds.tensorboard.name" .) }}
{{ include "kubeflowCrds.component.subcomponent.labels" (include "kubeflowCrds.tensorboard.controller.name" .) }}
{{- end }}

{{- define "kubeflowCrds.tensorboard.controller.selectorLabels" -}}
{{ include "kubeflowCrds.common.selectorLabels" . }}
{{ include "kubeflowCrds.component.selectorLabels" (include "kubeflowCrds.tensorboard.name" .) }}
{{ include "kubeflowCrds.component.subcomponent.labels" (include "kubeflowCrds.tensorboard.controller.name" .) }}
{{- end }}

{{/*
Kubeflow Tensorboard Controller enable and create toggles.
*/}}
{{- define "kubeflowCrds.tensorboard.controller.enabled" -}}
{{- ternary true "" (
    and
    (include "kubeflowCrds.tensorboard.enabled" . | eq "true")
    .Values.tensorboard.controller.enabled
)}}
{{- end }}
