{{/*
Kubeflow Training Operator object names.
*/}}
{{- define "kubeflowCrds.trainingOperator.baseName" -}}
{{- printf "training-operator" }}
{{- end }}

{{- define "kubeflowCrds.trainingOperator.name" -}}
{{- include "kubeflowCrds.component.name" (
    list
    (include "kubeflowCrds.trainingOperator.baseName" .)
    .
)}}
{{- end }}

{{- define "kubeflowCrds.trainingOperator.group" -}}
{{- include "kubeflowCrds.common.group" . }}
{{- end }}

{{- define "kubeflowCrds.trainingOperator.mpiSingularName" -}}
{{- printf "mpijob" }}
{{- end }}

{{- define "kubeflowCrds.trainingOperator.mpiPluralName" -}}
{{ printf "%s%s" (include "kubeflowCrds.trainingOperator.mpiSingularName" .) "s" }}
{{- end }}

{{- define "kubeflowCrds.trainingOperator.mpiFullName" -}}
{{ printf "%s.%s" (include "kubeflowCrds.trainingOperator.mpiPluralName" .) (include "kubeflowCrds.trainingOperator.group" .) }}
{{- end }}

{{- define "kubeflowCrds.trainingOperator.mxSingularName" -}}
{{- printf "mxjob" }}
{{- end }}

{{- define "kubeflowCrds.trainingOperator.mxPluralName" -}}
{{ printf "%s%s" (include "kubeflowCrds.trainingOperator.mxSingularName" .) "s" }}
{{- end }}

{{- define "kubeflowCrds.trainingOperator.mxFullName" -}}
{{ printf "%s.%s" (include "kubeflowCrds.trainingOperator.mxPluralName" .) (include "kubeflowCrds.trainingOperator.group" .) }}
{{- end }}

{{- define "kubeflowCrds.trainingOperator.paddleSingularName" -}}
{{- printf "paddlejob" }}
{{- end }}

{{- define "kubeflowCrds.trainingOperator.paddlePluralName" -}}
{{ printf "%s%s" (include "kubeflowCrds.trainingOperator.paddleSingularName" .) "s" }}
{{- end }}

{{- define "kubeflowCrds.trainingOperator.paddleFullName" -}}
{{ printf "%s.%s" (include "kubeflowCrds.trainingOperator.paddlePluralName" .) (include "kubeflowCrds.trainingOperator.group" .) }}
{{- end }}

{{- define "kubeflowCrds.trainingOperator.pytorchSingularName" -}}
{{- printf "pytorchjob" }}
{{- end }}

{{- define "kubeflowCrds.trainingOperator.pytorchPluralName" -}}
{{ printf "%s%s" (include "kubeflowCrds.trainingOperator.pytorchSingularName" .) "s" }}
{{- end }}

{{- define "kubeflowCrds.trainingOperator.pytorchFullName" -}}
{{ printf "%s.%s" (include "kubeflowCrds.trainingOperator.pytorchPluralName" .) (include "kubeflowCrds.trainingOperator.group" .) }}
{{- end }}

{{- define "kubeflowCrds.trainingOperator.tfSingularName" -}}
{{- printf "tfjob" }}
{{- end }}

{{- define "kubeflowCrds.trainingOperator.tfPluralName" -}}
{{ printf "%s%s" (include "kubeflowCrds.trainingOperator.tfSingularName" .) "s" }}
{{- end }}

{{- define "kubeflowCrds.trainingOperator.tfFullName" -}}
{{ printf "%s.%s" (include "kubeflowCrds.trainingOperator.tfPluralName" .) (include "kubeflowCrds.trainingOperator.group" .) }}
{{- end }}

{{- define "kubeflowCrds.trainingOperator.xgboostSingularName" -}}
{{- printf "xgboostjob" }}
{{- end }}

{{- define "kubeflowCrds.trainingOperator.xgboostPluralName" -}}
{{ printf "%s%s" (include "kubeflowCrds.trainingOperator.xgboostSingularName" .) "s" }}
{{- end }}

{{- define "kubeflowCrds.trainingOperator.xgboostFullName" -}}
{{ printf "%s.%s" (include "kubeflowCrds.trainingOperator.xgboostPluralName" .) (include "kubeflowCrds.trainingOperator.group" .) }}
{{- end }}

{{/*
Kubeflow Training Operator object labels.
*/}}
{{- define "kubeflowCrds.trainingOperator.labels" -}}
{{ include "kubeflowCrds.common.labels" . }}
{{ include "kubeflowCrds.component.labels" (include "kubeflowCrds.trainingOperator.name" .) }}
{{- end }}

{{- define "kubeflowCrds.trainingOperator.selectorLabels" -}}
{{ include "kubeflowCrds.common.selectorLabels" . }}
{{ include "kubeflowCrds.component.selectorLabels" (include "kubeflowCrds.trainingOperator.name" .) }}
{{- end }}

{{/*
Kubeflow Training Operator enable and create toggles.
*/}}
{{- define "kubeflowCrds.trainingOperator.enabled" -}}
{{- .Values.trainingOperator.enabled }}
{{- end }}
