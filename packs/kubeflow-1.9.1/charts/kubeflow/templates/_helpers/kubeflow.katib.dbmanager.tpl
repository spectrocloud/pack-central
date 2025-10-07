{{/*
Kubeflow Katib dbmanager object names.
*/}}
{{- define "kubeflow.katib.dbmanager.baseName" -}}
{{- printf "katib-db-manager" }}
{{- end }}

{{- define "kubeflow.katib.dbmanager.name" -}}
{{- include "kubeflow.component.name" (
    list
    (include "kubeflow.katib.dbmanager.baseName" .)
    .
)}}
{{- end }}

{{- define "kubeflow.katib.dbmanager.serviceAccountName" -}}
{{- include "kubeflow.component.serviceAccountName"  (
    list
    (include "kubeflow.katib.dbmanager.name" .)
    .Values.katib.dbmanager.serviceAccount
)}}
{{- end }}

{{- define "kubeflow.katib.dbmanager.serviceAccountPrincipal" -}}
{{- include "kubeflow.component.serviceAccountPrincipal" (
    list
    .
    (include "kubeflow.katib.dbmanager.serviceAccountName" .)
)}}
{{- end }}

{{- define "kubeflow.katib.dbmanager.mainClusterRoleName" -}}
{{- include "kubeflow.katib.dbmanager.name" . }}
{{- end }}

{{- define "kubeflow.katib.dbmanager.mainClusterRoleBindingName" -}}
{{- include "kubeflow.katib.dbmanager.mainClusterRoleName" . }}
{{- end }}

{{- define "kubeflow.katib.dbmanager.leaderElectionRoleName" -}}
{{- printf "%s-%s-%s"
    (include "kubeflow.fullname" .)
    (include "kubeflow.katib.dbmanager.name" .)
    "leader-election"
}}
{{- end }}

{{- define "kubeflow.katib.dbmanager.leaderElectionRoleBindingName" -}}
{{- include "kubeflow.katib.dbmanager.leaderElectionRoleName" . }}
{{- end }}

{{- define "kubeflow.katib.dbmanager.kfNbAdminClusterRoleName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) "katib-admin" }}
{{- end }}

{{- define "kubeflow.katib.dbmanager.kfNbEditClusterRoleName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) "katib-edit" }}
{{- end }}

{{- define "kubeflow.katib.dbmanager.kfNbViewClusterRoleName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) "katib-view" }}
{{- end }}

{{/*
Role Aggregation Rule Labels
*/}}
{{- define "kubeflow.katib.dbmanager.kfNbAdminClusterRoleLabel" -}}
{{- include "kubeflow.aggregationRule.labelBase" (include "kubeflow.katib.dbmanager.kfNbAdminClusterRoleName" .) -}}
{{- end }}

{{/*
Kubeflow Katib dbmanager Service.
*/}}
{{- define "kubeflow.katib.dbmanager.svc.name" -}}
{{ include "kubeflow.component.svc.name" (
    include "kubeflow.katib.dbmanager.name" .
)}}
{{- end }}

{{- define "kubeflow.katib.dbmanager.svc.addressWithNs" -}}
{{ include "kubeflow.component.svc.addressWithNs"  (
    list
    .
    (include "kubeflow.katib.dbmanager.name" .)
)}}
{{- end }}

{{- define "kubeflow.katib.dbmanager.svc.addressWithSvc" -}}
{{ include "kubeflow.component.svc.addressWithSvc"  (
    list
    .
    (include "kubeflow.katib.dbmanager.name" .)
)}}
{{- end }}

{{- define "kubeflow.katib.dbmanager.svc.fqdn" -}}
{{ include "kubeflow.component.svc.fqdn"  (
    list
    .
    (include "kubeflow.katib.dbmanager.name" .)
)}}
{{- end }}

{{/*
Kubeflow Katib dbmanager object labels.
*/}}
{{- define "kubeflow.katib.dbmanager.labels" -}}
{{ include "kubeflow.common.labels" . }}
{{ include "kubeflow.component.labels" (include "kubeflow.katib.name" .) }}
{{ include "kubeflow.component.subcomponent.labels" (include "kubeflow.katib.dbmanager.name" .) }}
{{- end }}

{{- define "kubeflow.katib.dbmanager.selectorLabels" -}}
{{ include "kubeflow.common.selectorLabels" . }}
{{ include "kubeflow.component.selectorLabels" (include "kubeflow.katib.name" .) }}
{{ include "kubeflow.component.subcomponent.labels" (include "kubeflow.katib.dbmanager.name" .) }}
{{- end }}

{{/*
Kubeflow Katib dbmanager container image settings.
*/}}
{{- define "kubeflow.katib.dbmanager.image" -}}
{{ include "kubeflow.component.image" (
    list
    .Values.defaults.image
    .Values.katib.dbmanager.image
)}}
{{- end }}

{{- define "kubeflow.katib.dbmanager.imagePullPolicy" -}}
{{ include "kubeflow.component.imagePullPolicy" (
    list
    .Values.defaults.image
    .Values.katib.dbmanager.image
)}}
{{- end }}

{{/*
Kubeflow Katib dbmanager Autoscaling and Availability.
*/}}
{{- define "kubeflow.katib.dbmanager.autoscaling.minReplicas" -}}
{{ include "kubeflow.component.autoscaling.minReplicas" (
    list
    .Values.defaults.autoscaling
    .Values.katib.dbmanager.autoscaling
)}}
{{- end }}

{{- define "kubeflow.katib.dbmanager.autoscaling.maxReplicas" -}}
{{ include "kubeflow.component.autoscaling.maxReplicas" (
    list
    .Values.defaults.autoscaling
    .Values.katib.dbmanager.autoscaling
)}}
{{- end }}

{{- define "kubeflow.katib.dbmanager.autoscaling.targetCPUUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetCPUUtilizationPercentage" (
    list
    .Values.defaults.autoscaling
    .Values.katib.dbmanager.autoscaling
)}}
{{- end }}

{{- define "kubeflow.katib.dbmanager.autoscaling.targetMemoryUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetMemoryUtilizationPercentage" (
    list
    .Values.defaults.autoscaling
    .Values.katib.dbmanager.autoscaling
)}}
{{- end }}

{{- define "kubeflow.katib.dbmanager.pdb.values" -}}
{{- include "kubeflow.component.pdb.values" (
    list
    .Values.defaults.podDisruptionBudget
    .Values.katib.dbmanager.podDisruptionBudget
)}}
{{- end }}

{{/*
Kubeflow Katib dbmanager Security Context.
*/}}
{{- define "kubeflow.katib.dbmanager.containerSecurityContext" -}}
{{ include "kubeflow.component.containerSecurityContext" (
    list
    .Values.defaults.containerSecurityContext
    .Values.katib.dbmanager.containerSecurityContext
)}}
{{- end }}

{{/*
Kubeflow Katib dbmanager Scheduling.
*/}}
{{- define "kubeflow.katib.dbmanager.topologySpreadConstraints" -}}
{{ include "kubeflow.component.topologySpreadConstraints" (
    list
    .Values.defaults.topologySpreadConstraints
    .Values.katib.dbmanager.topologySpreadConstraints
)}}
{{- end }}

{{- define "kubeflow.katib.dbmanager.nodeSelector" -}}
{{ include "kubeflow.component.nodeSelector" (
    list
    .Values.defaults.nodeSelector
    .Values.katib.dbmanager.nodeSelector
)}}
{{- end }}

{{- define "kubeflow.katib.dbmanager.tolerations" -}}
{{ include "kubeflow.component.tolerations" (
    list
    .Values.defaults.tolerations
    .Values.katib.dbmanager.tolerations
)}}
{{- end }}

{{- define "kubeflow.katib.dbmanager.affinity" -}}
{{ include "kubeflow.component.affinity" (
    list
    .Values.defaults.affinity
    .Values.katib.dbmanager.affinity
)}}
{{- end }}

{{/*
Kubeflow Katib dbmanager enable and create toggles.
*/}}
{{- define "kubeflow.katib.dbmanager.enabled" -}}
{{- ternary true "" (
    and
    (include "kubeflow.katib.enabled" . | eq "true")
    .Values.katib.dbmanager.enabled
)}}
{{- end }}

{{- define "kubeflow.katib.dbmanager.autoscaling.enabled" -}}
{{ include "kubeflow.component.autoscaling.enabled" (
    list
    .Values.defaults.autoscaling
    .Values.katib.dbmanager.autoscaling
)}}
{{- end }}

{{- define "kubeflow.katib.dbmanager.rbac.createRoles" -}}
{{- ternary true "" (
    and
    (include "kubeflow.katib.dbmanager.enabled" . | eq "true")
    .Values.katib.dbmanager.rbac.create
)}}
{{- end }}

{{- define "kubeflow.katib.dbmanager.createServiceAccount" -}}
{{- ternary true "" (
and
    (include "kubeflow.katib.dbmanager.enabled" . | eq "true")
    .Values.katib.dbmanager.serviceAccount.create
)}}
{{- end }}

{{- define "kubeflow.katib.dbmanager.pdb.create" -}}
{{- include "kubeflow.component.pdb.create" (
    list
    (include "kubeflow.katib.dbmanager.enabled" .)
    .Values.defaults.podDisruptionBudget
    .Values.katib.dbmanager.podDisruptionBudget
)}}
{{- end }}

{{/*
Environment names for database config.
*/}}
{{/*
FYI, This env var is actually the driver
*/}}
{{- define "kubeflow.katib.dbmanager.config.db.driver.env.name" -}}
{{- "DB_NAME" }}
{{- end }}

{{- define "kubeflow.katib.dbmanager.config.db.host.env.name" -}}
{{- "KATIB_MYSQL_DB_HOST" }}
{{- end }}

{{- define "kubeflow.katib.dbmanager.config.db.port.env.name" -}}
{{- "KATIB_MYSQL_DB_PORT" }}
{{- end }}

{{- define "kubeflow.katib.dbmanager.config.db.databaseName.env.name" -}}
{{- "KATIB_MYSQL_DB_DATABASE" }}
{{- end }}

{{- define "kubeflow.katib.dbmanager.config.db.user.env.name" -}}
{{- "DB_USER" }}
{{- end }}

{{- define "kubeflow.katib.dbmanager.config.db.password.env.name" -}}
{{- "DB_PASSWORD" }}
{{- end }}

{{/*
Environment Entries parametrization for database configuration with plaintext
value or through Secrets.
*/}}

{{- define "kubeflow.katib.dbmanager.config.db.driver.env.spec" -}}
{{- include "kubeflow.component.env.spec" (
    list
    (include "kubeflow.katib.dbmanager.config.db.driver.env.name" . )
    .Values.katib.dbmanager.config.db.existingSecretName
    .Values.katib.dbmanager.config.db.driver
) }}
{{- end }}

{{- define "kubeflow.katib.dbmanager.config.db.host.env.spec" -}}
{{- include "kubeflow.component.env.spec" (
    list
    (include "kubeflow.katib.dbmanager.config.db.host.env.name" . )
    .Values.katib.dbmanager.config.db.existingSecretName
    .Values.katib.dbmanager.config.db.host
) }}
{{- end }}

{{- define "kubeflow.katib.dbmanager.config.db.port.env.spec" -}}
{{- include "kubeflow.component.env.spec" (
    list
    (include "kubeflow.katib.dbmanager.config.db.port.env.name" . )
    .Values.katib.dbmanager.config.db.existingSecretName
    .Values.katib.dbmanager.config.db.port
) }}
{{- end }}

{{- define "kubeflow.katib.dbmanager.config.db.databaseName.env.spec" -}}
{{- include "kubeflow.component.env.spec" (
    list
    (include "kubeflow.katib.dbmanager.config.db.databaseName.env.name" . )
    .Values.katib.dbmanager.config.db.existingSecretName
    .Values.katib.dbmanager.config.db.databaseName
) }}
{{- end }}

{{- define "kubeflow.katib.dbmanager.config.db.user.env.spec" -}}
{{- include "kubeflow.component.env.spec" (
    list
    (include "kubeflow.katib.dbmanager.config.db.user.env.name" . )
    .Values.katib.dbmanager.config.db.existingSecretName
    .Values.katib.dbmanager.config.db.user
) }}
{{- end }}

{{- define "kubeflow.katib.dbmanager.config.db.password.env.spec" -}}
{{- include "kubeflow.component.env.spec" (
    list
    (include "kubeflow.katib.dbmanager.config.db.password.env.name" . )
    .Values.katib.dbmanager.config.db.existingSecretName
    .Values.katib.dbmanager.config.db.password
) }}
{{- end }}