{{/*
Kubeflow Kserve Models Web App object names.
*/}}
{{- define "kubeflow.kserveModelsWebApp.baseName" -}}
{{- printf "kserve-models-web-app" }}
{{- end }}

{{- define "kubeflow.kserveModelsWebApp.name" -}}
{{- include "kubeflow.component.name" (
    list
    (include "kubeflow.kserveModelsWebApp.baseName" .)
    .
)}}
{{- end }}

{{/*
Kubeflow Kserve Models Web App enable and create toggles.
*/}}
{{- define "kubeflow.kserveModelsWebApp.enabled" -}}
{{- ternary true "" 
    .Values.kserveModelsWebApp.enabled
}}
{{- end }}

{{- define "kubeflow.kserveModelsWebApp.createServiceAccount" -}}
{{- ternary true "" (
    and
    (include "kubeflow.kserveModelsWebApp.enabled" . | eq "true")
    .Values.kserveModelsWebApp.serviceAccount.create
)}}
{{- end }}

{{- define "kubeflow.kserveModelsWebApp.serviceAccountName" -}}
{{- include "kubeflow.component.serviceAccountName"  (list (include "kubeflow.kserveModelsWebApp.name" .) .Values.kserveModelsWebApp.serviceAccount) }}
{{- end }}

{{/*
Kubeflow Kserve Models Web App object labels.
*/}}
{{- define "kubeflow.kserveModelsWebApp.labels" -}}
{{ include "kubeflow.common.labels" . }}
{{ include "kubeflow.component.labels" (include "kubeflow.kserveModelsWebApp.name" .) }}
{{- end }}

{{- define "kubeflow.kserveModelsWebApp.configMapName" -}}
{{- printf "%s-%s" (include "kubeflow.kserveModelsWebApp.name" .) "viewer-spec" }}
{{- end }}

{{- define "kubeflow.kserveModelsWebApp.mainClusterRoleName" -}}
{{- printf "%s-%s"
    (include "kubeflow.fullname" .)
    (include "kubeflow.kserveModelsWebApp.name" .)
}}
{{- end }}

{{- define "kubeflow.kserveModelsWebApp.mainClusterRoleBindingName" -}}
{{- include "kubeflow.kserveModelsWebApp.mainClusterRoleName" . }}
{{- end }}

{{- define "kubeflow.kserveModelsWebApp.rbac.createRole" -}}
{{- ternary true "" (
    and
    (include "kubeflow.kserveModelsWebApp.enabled" . | eq "true")
    .Values.kserveModelsWebApp.rbac.create
)}}
{{- end }}

{{- define "kubeflow.kserveModelsWebApp.image" -}}
{{ include "kubeflow.component.image" (list .Values.defaults.image .Values.kserveModelsWebApp.image) }}
{{- end }}

{{- define "kubeflow.kserveModelsWebApp.imagePullPolicy" -}}
{{ include "kubeflow.component.imagePullPolicy" (list .Values.defaults.image .Values.kserveModelsWebApp.image) }}
{{- end }}

{{- define "kubeflow.kserveModelsWebApp.selectorLabels" -}}
{{ include "kubeflow.common.selectorLabels" . }}
{{ include "kubeflow.component.selectorLabels" (include "kubeflow.kserveModelsWebApp.name" .) }}
{{- end }}

{{- define "kubeflow.kserveModelsWebApp.svc.name" -}}
{{ include "kubeflow.component.svc.name" (
    include "kubeflow.kserveModelsWebApp.name" .
)}}
{{- end }}

{{- define "kubeflow.kserveModelsWebApp.nodeSelector" -}}
{{ include "kubeflow.component.nodeSelector" (
    list
    .Values.defaults.nodeSelector
    .Values.kserveModelsWebApp.nodeSelector
)}}
{{- end }}

{{- define "kubeflow.kserveModelsWebApp.tolerations" -}}
{{ include "kubeflow.component.tolerations" (
    list
    .Values.defaults.tolerations
    .Values.kserveModelsWebApp.tolerations
)}}
{{- end }}

{{- define "kubeflow.kserveModelsWebApp.affinity" -}}
{{ include "kubeflow.component.affinity" (
    list
    .Values.defaults.affinity
    .Values.kserveModelsWebApp.affinity
)}}
{{- end }}

{{- define "kubeflow.kserveModelsWebApp.topologySpreadConstraints" -}}
{{ include "kubeflow.component.topologySpreadConstraints" (
    list
    .Values.defaults.topologySpreadConstraints
    .Values.kserveModelsWebApp.topologySpreadConstraints
)}}
{{- end }}

{{- define "kubeflow.kserveModelsWebApp.autoscaling.enabled" -}}
{{ include "kubeflow.component.autoscaling.enabled" (list .Values.defaults.autoscaling .Values.kserveModelsWebApp.autoscaling) }}
{{- end }}

{{- define "kubeflow.kserveModelsWebApp.autoscaling.minReplicas" -}}
{{ include "kubeflow.component.autoscaling.minReplicas" (list .Values.defaults.autoscaling .Values.kserveModelsWebApp.autoscaling) }}
{{- end }}
