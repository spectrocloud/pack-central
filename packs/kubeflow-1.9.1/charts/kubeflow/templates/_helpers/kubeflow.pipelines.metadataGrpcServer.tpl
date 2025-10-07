{{/*
Kubeflow Pipelines Metadata GRPC Server object names.
*/}}
{{- define "kubeflow.pipelines.metadataGrpcServer.baseName" -}}
{{- printf "ml-pipeline-metadata-grpc-server" }}
{{- end }}

{{- define "kubeflow.pipelines.metadataGrpcServer.name" -}}
{{- include "kubeflow.component.name" (
    list
    (include "kubeflow.pipelines.metadataGrpcServer.baseName" .)
    .
)}}
{{- end }}

{{- define "kubeflow.pipelines.metadataGrpcServer.serviceAccountName" -}}
{{- include "kubeflow.component.serviceAccountName"  (
    list
    (include "kubeflow.pipelines.metadataGrpcServer.name" .)
    .Values.pipelines.metadataGrpcServer.serviceAccount)
}}
{{- end }}

{{- define "kubeflow.pipelines.metadataGrpcServer.roleName" -}}
{{- include "kubeflow.pipelines.metadataGrpcServer.name" . }}
{{- end }}

{{- define "kubeflow.pipelines.metadataGrpcServer.roleBindingName" -}}
{{- include "kubeflow.pipelines.metadataGrpcServer.roleName" . }}
{{- end }}

{{/*
Kubeflow Pipelines Metadata GRPC Server Service.
*/}}
{{- define "kubeflow.pipelines.metadataGrpcServer.svc.name" -}}
{{ include "kubeflow.component.svc.name" (
    include "kubeflow.pipelines.metadataGrpcServer.name" .
)}}
{{- end }}

{{- define "kubeflow.pipelines.metadataGrpcServer.svc.addressWithNs" -}}
{{ include "kubeflow.component.svc.addressWithNs"  (
    list
    .
    (include "kubeflow.pipelines.metadataGrpcServer.name" .)
)}}
{{- end }}

{{- define "kubeflow.pipelines.metadataGrpcServer.svc.addressWithSvc" -}}
{{ include "kubeflow.component.svc.addressWithSvc"  (
    list
    .
    (include "kubeflow.pipelines.metadataGrpcServer.name" .)
)}}
{{- end }}

{{- define "kubeflow.pipelines.metadataGrpcServer.svc.fqdn" -}}
{{ include "kubeflow.component.svc.fqdn"  (
    list
    .
    (include "kubeflow.pipelines.metadataGrpcServer.name" .)
)}}
{{- end }}

{{/*
Kubeflow Pipelines Metadata GRPC Server object labels.
*/}}
{{- define "kubeflow.pipelines.metadataGrpcServer.labels" -}}
{{ include "kubeflow.common.labels" . }}
{{ include "kubeflow.component.labels" (include "kubeflow.pipelines.name" .) }}
{{ include "kubeflow.component.subcomponent.labels" (include "kubeflow.pipelines.metadataGrpcServer.name" .) }}
{{- end }}

{{- define "kubeflow.pipelines.metadataGrpcServer.selectorLabels" -}}
{{ include "kubeflow.common.selectorLabels" . }}
{{ include "kubeflow.component.selectorLabels" (include "kubeflow.pipelines.name" .) }}
{{ include "kubeflow.component.subcomponent.labels" (include "kubeflow.pipelines.metadataGrpcServer.name" .) }}
{{- end }}

{{/*
Kubeflow Pipelines Metadata GRPC Server container image settings.
*/}}
{{- define "kubeflow.pipelines.metadataGrpcServer.image" -}}
{{- include "kubeflow.pipelines.image" (
    list
    .Values.defaults.image
    .Values.pipelines.defaults.image
    .Values.pipelines.metadataGrpcServer.image
)}}
{{- end }}

{{- define "kubeflow.pipelines.metadataGrpcServer.imagePullPolicy" -}}
{{- include "kubeflow.pipelines.imagePullPolicy" (
    list
    .Values.defaults.image
    .Values.pipelines.defaults.image
    .Values.pipelines.metadataGrpcServer.image
)}}
{{- end }}


{{/*
Kubeflow Pipelines Metadata GRPC Server Autoscaling and Availability.
*/}}
{{- define "kubeflow.pipelines.metadataGrpcServer.autoscaling.enabled" -}}
{{ include "kubeflow.component.autoscaling.enabled" (list .Values.defaults.autoscaling .Values.pipelines.metadataGrpcServer.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.metadataGrpcServer.autoscaling.minReplicas" -}}
{{ include "kubeflow.component.autoscaling.minReplicas" (list .Values.defaults.autoscaling .Values.pipelines.metadataGrpcServer.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.metadataGrpcServer.autoscaling.maxReplicas" -}}
{{ include "kubeflow.component.autoscaling.maxReplicas" (list .Values.defaults.autoscaling .Values.pipelines.metadataGrpcServer.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.metadataGrpcServer.autoscaling.targetCPUUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetCPUUtilizationPercentage" (list .Values.defaults.autoscaling .Values.pipelines.metadataGrpcServer.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.metadataGrpcServer.autoscaling.targetMemoryUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetMemoryUtilizationPercentage" (list .Values.defaults.autoscaling .Values.pipelines.metadataGrpcServer.autoscaling) }}
{{- end }}

{{- define "kubeflow.pipelines.metadataGrpcServer.pdb.values" -}}
{{- include "kubeflow.component.pdb.values" (
    list
    .Values.defaults.podDisruptionBudget
    .Values.pipelines.metadataGrpcServer.podDisruptionBudget
)}}
{{- end }}

{{/*
Kubeflow Pipelines Metadata GRPC Server Security Context.
*/}}
{{- define "kubeflow.pipelines.metadataGrpcServer.containerSecurityContext" -}}
{{- include "kubeflow.component.containerSecurityContext" (
    list
    .Values.defaults.containerSecurityContext
    .Values.pipelines.metadataGrpcServer.containerSecurityContext
)}}
{{- end }}

{{/*
Kubeflow Pipelines Metadata GRPC Server Scheduling.
*/}}
{{- define "kubeflow.pipelines.metadataGrpcServer.topologySpreadConstraints" -}}
{{ include "kubeflow.component.topologySpreadConstraints" (
    list
    .Values.defaults.topologySpreadConstraints
    .Values.pipelines.metadataGrpcServer.topologySpreadConstraints
)}}
{{- end }}

{{- define "kubeflow.pipelines.metadataGrpcServer.nodeSelector" -}}
{{ include "kubeflow.component.nodeSelector" (
    list
    .Values.defaults.nodeSelector
    .Values.pipelines.metadataGrpcServer.nodeSelector
)}}
{{- end }}

{{- define "kubeflow.pipelines.metadataGrpcServer.tolerations" -}}
{{ include "kubeflow.component.tolerations" (
    list
    .Values.defaults.tolerations
    .Values.pipelines.metadataGrpcServer.tolerations
)}}
{{- end }}

{{- define "kubeflow.pipelines.metadataGrpcServer.affinity" -}}
{{ include "kubeflow.component.affinity" (
    list
    .Values.defaults.affinity
    .Values.pipelines.metadataGrpcServer.affinity
)}}
{{- end }}

{{/*
Kubeflow Pipelines Metadata GRPC Server enable and create toggles.
*/}}
{{- define "kubeflow.pipelines.metadataGrpcServer.enabled" -}}
{{- ternary true "" (
    and
        (include "kubeflow.pipelines.enabled" . | eq "true")
        .Values.pipelines.metadataGrpcServer.enabled
)}}
{{- end }}

{{- define "kubeflow.pipelines.metadataGrpcServer.rbac.createRoles" -}}
{{- and
    (include "kubeflow.pipelines.metadataGrpcServer.enabled" . | eq "true")
    .Values.pipelines.metadataGrpcServer.rbac.create }}
{{- end }}

{{- define "kubeflow.pipelines.metadataGrpcServer.createServiceAccount" -}}
{{- and
    (include "kubeflow.pipelines.metadataGrpcServer.enabled" . | eq "true")
    .Values.pipelines.metadataGrpcServer.serviceAccount.create
}}
{{- end }}

{{- define "kubeflow.pipelines.metadataGrpcServer.createIstioIntegrationObjects" -}}
{{- ternary true "" (
    and
        (include "kubeflow.pipelines.metadataGrpcServer.enabled" . | eq "true" )
        .Values.istioIntegration.enabled
)}}
{{- end }}
