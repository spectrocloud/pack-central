{{/*
Kubeflow Network Policies object names.
*/}}
{{- define "kubeflow.networkPolicies.baseName" -}}
{{- printf "network-policies" }}
{{- end }}

{{- define "kubeflow.networkPolicies.name" -}}
{{- include "kubeflow.component.name" (
    list
    (include "kubeflow.networkPolicies.baseName" .)
    .
)}}
{{- end }}

{{/*
Kubeflow Network Policies enable and create toggles.
*/}}
{{- define "kubeflow.networkPolicies.enabled" -}}
{{- ternary true "" (
    .Values.networkPolicies.enabled
)}}
{{- end }}

{{/*
Kubeflow Network Policies object labels.
*/}}
{{- define "kubeflow.networkPolicies.labels" -}}
{{ include "kubeflow.common.labels" . }}
{{ include "kubeflow.component.labels" (include "kubeflow.networkPolicies.name" .) }}
{{- end }}
