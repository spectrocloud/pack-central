{{/*
Kubeflow Pipelines Metadata Envoy object names.
*/}}
{{- define "kubeflow.pipelines.metadataEnvoy.baseName" -}}
{{- printf "ml-pipeline-metadata-envoy" }}
{{- end }}

{{- define "kubeflow.pipelines.metadataEnvoy.name" -}}
{{- include "kubeflow.component.name" (
    list
    (include "kubeflow.pipelines.metadataEnvoy.baseName" .)
    .
)}}
{{- end }}

{{- define "kubeflow.pipelines.metadataEnvoy.serviceAccountName" -}}
{{- include "kubeflow.component.serviceAccountName"  (
    list
    (include "kubeflow.pipelines.metadataEnvoy.name" .)
    .Values.pipelines.metadataEnvoy.serviceAccount)
}}
{{- end }}

{{- define "kubeflow.pipelines.metadataEnvoy.roleName" -}}
{{- include "kubeflow.pipelines.metadataEnvoy.name" . }}
{{- end }}

{{- define "kubeflow.pipelines.metadataEnvoy.roleBindingName" -}}
{{- include "kubeflow.pipelines.metadataEnvoy.roleName" . }}
{{- end }}

{{/*
Kubeflow Pipelines Metadata Envoy Service.
*/}}
{{- define "kubeflow.pipelines.metadataEnvoy.svc.name" -}}
{{ include "kubeflow.component.svc.name" (
    include "kubeflow.pipelines.metadataEnvoy.name" .
)}}
{{- end }}

{{- define "kubeflow.pipelines.metadataEnvoy.svc.fqdn" -}}
{{ include "kubeflow.component.svc.fqdn"  (
    list
    .
    (include "kubeflow.pipelines.metadataEnvoy.name" .)
)}}
{{- end }}

{{/*
Kubeflow Pipelines Metadata Envoy object labels.
*/}}
{{- define "kubeflow.pipelines.metadataEnvoy.labels" -}}
{{ include "kubeflow.common.labels" . }}
{{ include "kubeflow.component.labels" (include "kubeflow.pipelines.name" .) }}
{{ include "kubeflow.component.subcomponent.labels" (include "kubeflow.pipelines.metadataEnvoy.name" .) }}
{{- end }}

{{- define "kubeflow.pipelines.metadataEnvoy.selectorLabels" -}}
{{ include "kubeflow.common.selectorLabels" . }}
{{ include "kubeflow.component.selectorLabels" (include "kubeflow.pipelines.name" .) }}
{{ include "kubeflow.component.subcomponent.labels" (include "kubeflow.pipelines.metadataEnvoy.name" .) }}
{{- end }}


{{/*
Kubeflow Pipelines Metadata Envoy container image settings.
*/}}
{{- define "kubeflow.pipelines.metadataEnvoy.image" -}}
{{- include "kubeflow.pipelines.image" (
    list
    .Values.defaults.image
    .Values.pipelines.defaults.image
    .Values.pipelines.metadataEnvoy.image
)}}
{{- end }}

{{- define "kubeflow.pipelines.metadataEnvoy.imagePullPolicy" -}}
{{- include "kubeflow.pipelines.imagePullPolicy" (
    list
    .Values.defaults.image
    .Values.pipelines.defaults.image
    .Values.pipelines.metadataEnvoy.image
)}}
{{- end }}


{{/*
Kubeflow Pipelines Metadata Envoy Autoscaling and Availability.
*/}}
{{- define "kubeflow.pipelines.metadataEnvoy.autoscaling.enabled" -}}
{{ include "kubeflow.component.autoscaling.enabled" (list .Values.defaults.autoscaling .Values.pipelines.metadataEnvoy.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.metadataEnvoy.autoscaling.minReplicas" -}}
{{ include "kubeflow.component.autoscaling.minReplicas" (list .Values.defaults.autoscaling .Values.pipelines.metadataEnvoy.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.metadataEnvoy.autoscaling.maxReplicas" -}}
{{ include "kubeflow.component.autoscaling.maxReplicas" (list .Values.defaults.autoscaling .Values.pipelines.metadataEnvoy.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.metadataEnvoy.autoscaling.targetCPUUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetCPUUtilizationPercentage" (list .Values.defaults.autoscaling .Values.pipelines.metadataEnvoy.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.metadataEnvoy.autoscaling.targetMemoryUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetMemoryUtilizationPercentage" (list .Values.defaults.autoscaling .Values.pipelines.metadataEnvoy.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.metadataEnvoy.pdb.values" -}}
{{- include "kubeflow.component.pdb.values" (
    list
    .Values.defaults.podDisruptionBudget
    .Values.pipelines.metadataEnvoy.podDisruptionBudget
)}}
{{- end }}

{{/*
Kubeflow Pipelines Metadata Envoy Security Context.
*/}}
{{- define "kubeflow.pipelines.metadataEnvoy.containerSecurityContext" -}}
{{- include "kubeflow.component.containerSecurityContext" (
    list
    .Values.defaults.containerSecurityContext
    .Values.pipelines.metadataEnvoy.containerSecurityContext
)}}
{{- end }}

{{/*
Kubeflow Pipelines Metadata Envoy Scheduling.
*/}}
{{- define "kubeflow.pipelines.metadataEnvoy.topologySpreadConstraints" -}}
{{ include "kubeflow.component.topologySpreadConstraints" (
    list
    .Values.defaults.topologySpreadConstraints
    .Values.pipelines.metadataEnvoy.topologySpreadConstraints
)}}
{{- end }}

{{- define "kubeflow.pipelines.metadataEnvoy.nodeSelector" -}}
{{ include "kubeflow.component.nodeSelector" (
    list
    .Values.defaults.nodeSelector
    .Values.pipelines.metadataEnvoy.nodeSelector
)}}
{{- end }}

{{- define "kubeflow.pipelines.metadataEnvoy.tolerations" -}}
{{ include "kubeflow.component.tolerations" (
    list
    .Values.defaults.tolerations
    .Values.pipelines.metadataEnvoy.tolerations
)}}
{{- end }}

{{- define "kubeflow.pipelines.metadataEnvoy.affinity" -}}
{{ include "kubeflow.component.affinity" (
    list
    .Values.defaults.affinity
    .Values.pipelines.metadataEnvoy.affinity
)}}
{{- end }}

{{/*
Kubeflow Pipelines Metadata Envoy enable and create toggles.
*/}}
{{- define "kubeflow.pipelines.metadataEnvoy.enabled" -}}
{{- and
    (include "kubeflow.pipelines.enabled" . | eq "true")
    .Values.pipelines.metadataEnvoy.enabled
}}
{{- end }}

{{/*
NOTE: Currently metadata-envoy doesn't define any rbac.
Let's be consistent and define functions around Service Account and RBAC.
*/}}
{{- define "kubeflow.pipelines.metadataEnvoy.rbac.createRoles" -}}
{{- and
    (include "kubeflow.pipelines.metadataEnvoy.enabled" . | eq "true")
    (((default (dict "create" false) .Values.pipelines.metadataEnvoy.rbac).create))
    .Values.pipelines.metadataEnvoy.rbac.create }}
{{- end }}

{{/*
NOTE: metadata-envoy doesn't define ServiceAccount.
Let's be consistent and define functions around Service Account and RBAC.

TODO: creation of service account shouldn't depend on if rbac is created.
People might want to define their own RBAC.
*/}}
{{- define "kubeflow.pipelines.metadataEnvoy.createServiceAccount" -}}
{{- and
    (include "kubeflow.pipelines.metadataEnvoy.enabled" . | eq "true")
    .Values.pipelines.metadataEnvoy.serviceAccount.create
}}
{{- end }}
