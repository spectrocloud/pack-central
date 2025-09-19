{{/*
Kubeflow Model Registry object names.
*/}}
{{- define "kubeflow.modelRegistry.baseName" -}}
{{- printf "model-registry" }}
{{- end }}

{{- define "kubeflow.modelRegistry.name" -}}
{{- include "kubeflow.component.name" (
    list
    (include "kubeflow.modelRegistry.baseName" .)
    .
)}}
{{- end }}

{{- define "kubeflow.modelRegistry.serviceAccountName" -}}
{{- include "kubeflow.component.serviceAccountName"  (
    list
    (include "kubeflow.modelRegistry.name" .)
    .Values.modelRegistry.serviceAccount
)}}
{{- end }}

{{/*
Kubeflow Model Registry Service.
*/}}
{{- define "kubeflow.modelRegistry.svc.name" -}}
{{ printf "%s-%s"
    (include "kubeflow.component.svc.name" (
        include "kubeflow.modelRegistry.name" .
    ))
    "service"
}}
{{- end }}

{{- define "kubeflow.modelRegistry.svc.fqdn" -}}
{{ include "kubeflow.component.svc.fqdn"  (
    list
    .
    (include "kubeflow.modelRegistry.svc.name" .)
)}}
{{- end }}

{{/*
Kubeflow Model Registry object labels.
*/}}
{{- define "kubeflow.modelRegistry.labels" -}}
{{ include "kubeflow.common.labels" . }}
{{ include "kubeflow.component.labels" (include "kubeflow.modelRegistry.name" .) }}
{{- end }}

{{- define "kubeflow.modelRegistry.selectorLabels" -}}
{{ include "kubeflow.common.selectorLabels" . }}
{{ include "kubeflow.component.selectorLabels" (include "kubeflow.modelRegistry.name" .) }}
{{- end }}

{{/*
Kubeflow Model Registry Scheduling.
*/}}
{{- define "kubeflow.modelRegistry.topologySpreadConstraints" -}}
{{ include "kubeflow.component.topologySpreadConstraints" (
    list
    .Values.defaults.topologySpreadConstraints
    .Values.modelRegistry.topologySpreadConstraints
)}}
{{- end }}

{{- define "kubeflow.modelRegistry.nodeSelector" -}}
{{ include "kubeflow.component.nodeSelector" (
    list
    .Values.defaults.nodeSelector
    .Values.modelRegistry.nodeSelector
)}}
{{- end }}

{{- define "kubeflow.modelRegistry.tolerations" -}}
{{ include "kubeflow.component.tolerations" (
    list
    .Values.defaults.tolerations
    .Values.modelRegistry.tolerations
)}}
{{- end }}

{{- define "kubeflow.modelRegistry.affinity" -}}
{{ include "kubeflow.component.affinity" (
    list
    .Values.defaults.affinity
    .Values.modelRegistry.affinity
)}}
{{- end }}

{{/*
Kubeflow Model registrry enable and create toggles.
*/}}
{{- define "kubeflow.modelRegistry.enabled" -}}
{{- ternary true "" .Values.modelRegistry.enabled }}
{{- end }}

{{- define "kubeflow.modelRegistry.createServiceAccount" -}}
{{- ternary true "" (
and
    (include "kubeflow.modelRegistry.enabled" . | eq "true")
    .Values.modelRegistry.serviceAccount.create
)}}
{{- end }}

{{- define "kubeflow.modelRegistry.configMapName" -}}
{{- printf "%s" (include "kubeflow.modelRegistry.name" .) }}
{{- end }}

{{- define "kubeflow.modelRegistry.createIstioIntegrationObjects" -}}
{{- ternary true "" (
    and
    (include "kubeflow.modelRegistry.enabled" . | eq "true")
    .Values.istioIntegration.enabled
)}}
{{- end }}

{{- define "kubeflow.modelRegistry.pdb.create" -}}
{{- include "kubeflow.component.pdb.create" (
    list
    (include "kubeflow.modelRegistry.enabled" .)
    .Values.defaults.podDisruptionBudget
    .Values.modelRegistry.podDisruptionBudget
)}}
{{- end }}

{{/*
Image configuration.
*/}}

{{- define "kubeflow.modelRegistry.rest.image" -}}
{{ include "kubeflow.component.image" (list .Values.defaults.image .Values.modelRegistry.rest.image) }}
{{- end }}

{{- define "kubeflow.modelRegistry.rest.imagePullPolicy" -}}
{{ include "kubeflow.component.imagePullPolicy" (list .Values.modelRegistry.rest.image .Values.modelRegistry.rest.image) }}
{{- end }}

{{- define "kubeflow.modelRegistry.grpc.image" -}}
{{ include "kubeflow.component.image" (list .Values.modelRegistry.grpc.image .Values.modelRegistry.grpc.image) }}
{{- end }}

{{- define "kubeflow.modelRegistry.grpc.imagePullPolicy" -}}
{{ include "kubeflow.component.imagePullPolicy" (list .Values.modelRegistry.grpc.image .Values.modelRegistry.grpc.image) }}
{{- end }}

{{/*
Kubeflow model-registry Autoscaling and Availability.
*/}}
{{- define "kubeflow.modelRegistry.autoscaling.enabled" -}}
{{ include "kubeflow.component.autoscaling.enabled" (list .Values.defaults.autoscaling .Values.modelRegistry.autoscaling) }}
{{- end }}

{{- define "kubeflow.modelRegistry.autoscaling.minReplicas" -}}
{{ include "kubeflow.component.autoscaling.minReplicas" (list .Values.defaults.autoscaling .Values.modelRegistry.autoscaling) }}
{{- end }}

{{- define "kubeflow.modelRegistry.autoscaling.maxReplicas" -}}
{{ include "kubeflow.component.autoscaling.maxReplicas" (list .Values.defaults.autoscaling .Values.modelRegistry.autoscaling) }}
{{- end }}

{{- define "kubeflow.modelRegistry.autoscaling.targetCPUUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetCPUUtilizationPercentage" (list .Values.defaults.autoscaling .Values.modelRegistry.autoscaling) }}
{{- end }}

{{- define "kubeflow.modelRegistry.autoscaling.targetMemoryUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetMemoryUtilizationPercentage" (list .Values.defaults.autoscaling .Values.modelRegistry.autoscaling) }}
{{- end }}

{{- define "kubeflow.modelRegistry.pdb.values" -}}
{{- include "kubeflow.component.pdb.values" (
    list
    .Values.defaults.podDisruptionBudget
    .Values.modelRegistry.podDisruptionBudget
)}}
{{- end }}

{{/*
Kubeflow model-registry Security Context.
*/}}
{{- define "kubeflow.modelRegistry.rest.containerSecurityContext" -}}
{{ include "kubeflow.component.containerSecurityContext" (
    list
    .Values.defaults.containerSecurityContext
    .Values.modelRegistry.rest.containerSecurityContext
)}}
{{- end }}

{{- define "kubeflow.modelRegistry.grpc.containerSecurityContext" -}}
{{ include "kubeflow.component.containerSecurityContext" (
    list
    .Values.defaults.containerSecurityContext
    .Values.modelRegistry.grpc.containerSecurityContext
)}}
{{- end }}

{{/*
Environment names for database config.
*/}}
{{- define "kubeflow.modelRegistry.config.db.user.env.name" -}}
{{- "MYSQL_USER_NAME" }}
{{- end }}

{{- define "kubeflow.modelRegistry.config.db.password.env.name" -}}
{{- "MYSQL_PASSWORD" }}
{{- end }}

{{- define "kubeflow.modelRegistry.config.db.host.env.name" -}}
{{- "MYSQL_HOST" }}
{{- end }}

{{- define "kubeflow.modelRegistry.config.db.port.env.name" -}}
{{- "MYSQL_PORT" }}
{{- end }}

{{- define "kubeflow.modelRegistry.config.db.dbName.env.name" -}}
{{- "MYSQL_DBNAME" }}
{{- end }}

{{/*
Environment Entries parametrization for database configuration with plaintext
value or through Secrets.
*/}}

{{- define "kubeflow.modelRegistry.config.db.user.env.spec" -}}
{{- include "kubeflow.component.env.spec" (
    list
    (include "kubeflow.modelRegistry.config.db.user.env.name" . )
    .Values.modelRegistry.config.db.existingSecretName
    .Values.modelRegistry.config.db.user
) }}
{{- end }}

{{- define "kubeflow.modelRegistry.config.db.password.env.spec" -}}
{{- include "kubeflow.component.env.spec" (
    list
    (include "kubeflow.modelRegistry.config.db.password.env.name" . )
    .Values.modelRegistry.config.db.existingSecretName
    .Values.modelRegistry.config.db.password
) }}
{{- end }}

{{- define "kubeflow.modelRegistry.config.db.host.env.spec" -}}
{{- include "kubeflow.component.env.spec" (
    list
    (include "kubeflow.modelRegistry.config.db.host.env.name" . )
    .Values.modelRegistry.config.db.existingSecretName
    .Values.modelRegistry.config.db.host
) }}
{{- end }}

{{- define "kubeflow.modelRegistry.config.db.port.env.spec" -}}
{{- include "kubeflow.component.env.spec" (
    list
    (include "kubeflow.modelRegistry.config.db.port.env.name" . )
    .Values.modelRegistry.config.db.existingSecretName
    .Values.modelRegistry.config.db.port
) }}
{{- end }}

{{- define "kubeflow.modelRegistry.config.db.dbName.env.spec" -}}
{{- include "kubeflow.component.env.spec" (
    list
    (include "kubeflow.modelRegistry.config.db.dbName.env.name" . )
    .Values.modelRegistry.config.db.existingSecretName
    .Values.modelRegistry.config.db.dbName
) }}
{{- end }}
