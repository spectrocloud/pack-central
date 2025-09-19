{{/*
Kubeflow Pipelines ML Pipeline (api-server) config.
*/}}

{{/*
NOTE/TODO: KFP 2.0.2 supports postresql. This needs to be handled.
https://github.com/kubeflow/pipelines/blob/2.0.2/backend/src/apiserver/client_manager/client_manager.go#L47

relic variables
https://github.com/kubeflow/pipelines/blob/2.0.2/manifests/kustomize/base/pipeline/ml-pipeline-apiserver-deployment.yaml#L36

mysql config
https://github.com/kubeflow/pipelines/blob/2.0.2/manifests/kustomize/base/pipeline/ml-pipeline-apiserver-deployment.yaml#L73

DBConfig.MySQLConfig.Host == DBCONFIG_MYSQLCONFIG_HOST
DBConfig.PostgreSQLConfig.Host == DBCONFIG_POSTGRESQLCONFIG_HOST
*/}}

{{/*
Environment names for database config.
*/}}

# This env name is currently hardcoded:
# https://github.com/kubeflow/pipelines/blob/63ca91850a9f42a357f3417110a3011ddbf43290/backend/src/apiserver/client_manager.go#L46
{{- define "kubeflow.pipelines.mlPipeline.config.db.user.env.name" -}}
{{- "DBCONFIG_MYSQLCONFIG_USER" }}
{{- end }}

# This env name is currently hardcoded:
# https://github.com/kubeflow/pipelines/blob/63ca91850a9f42a357f3417110a3011ddbf43290/backend/src/apiserver/client_manager.go#L47
{{- define "kubeflow.pipelines.mlPipeline.config.db.password.env.name" -}}
{{- "DBCONFIG_MYSQLCONFIG_PASSWORD" }}
{{- end }}

# This env name is currently hardcoded:
# https://github.com/kubeflow/pipelines/blob/63ca91850a9f42a357f3417110a3011ddbf43290/backend/src/apiserver/client_manager.go#L44
{{- define "kubeflow.pipelines.mlPipeline.config.db.host.env.name" -}}
{{- "DBCONFIG_MYSQLCONFIG_HOST" }}
{{- end }}

# This env name is currently hardcoded:
# https://github.com/kubeflow/pipelines/blob/63ca91850a9f42a357f3417110a3011ddbf43290/backend/src/apiserver/client_manager.go#L45
{{- define "kubeflow.pipelines.mlPipeline.config.db.port.env.name" -}}
{{- "DBCONFIG_MYSQLCONFIG_PORT" }}
{{- end }}

# This env name is currently hardcoded:
# https://github.com/kubeflow/pipelines/blob/63ca91850a9f42a357f3417110a3011ddbf43290/backend/src/apiserver/client_manager.go#L48
{{- define "kubeflow.pipelines.mlPipeline.config.db.pipelineDatabaseName.env.name" -}}
{{- "DBCONFIG_MYSQLCONFIG_DBNAME" }}
{{- end }}

# This env name is currently hardcoded:
# https://github.com/kubeflow/pipelines/blob/63ca91850a9f42a357f3417110a3011ddbf43290/backend/src/apiserver/client_manager.go#L53
{{- define "kubeflow.pipelines.mlPipeline.config.db.conMaxLifetime.env.name" -}}
{{- "DBCONFIG_CONMAXLIFETIME" }}
{{- end }}

{{- define "kubeflow.pipelines.mlPipeline.config.db.driver.env.name" -}}
{{- "DB_DRIVER_NAME" }}
{{- end }}

{{/*
Environment names for object store config.
*/}}

# This env name is currently hardcoded:
# https://github.com/kubeflow/pipelines/blob/63ca91850a9f42a357f3417110a3011ddbf43290/backend/src/apiserver/client_manager.go#L408
{{- define "kubeflow.pipelines.mlPipeline.config.objectStore.secure.env.name" -}}
{{- "OBJECTSTORECONFIG_SECURE" }}
{{- end }}

# This env name is currently hardcoded:
# https://github.com/kubeflow/pipelines/blob/63ca91850a9f42a357f3417110a3011ddbf43290/backend/src/apiserver/client_manager.go#L411
{{- define "kubeflow.pipelines.mlPipeline.config.objectStore.bucketName.env.name" -}}
{{- "OBJECTSTORECONFIG_BUCKETNAME" }}
{{- end }}

# This env name is currently hardcoded:
# https://github.com/kubeflow/pipelines/blob/63ca91850a9f42a357f3417110a3011ddbf43290/backend/src/apiserver/client_manager.go#L402
{{- define "kubeflow.pipelines.mlPipeline.config.objectStore.host.env.name" -}}
{{- "OBJECTSTORECONFIG_HOST" }}
{{- end }}

# This env name is currently hardcoded:
# https://github.com/kubeflow/pipelines/blob/63ca91850a9f42a357f3417110a3011ddbf43290/backend/src/apiserver/client_manager.go#L409
{{- define "kubeflow.pipelines.mlPipeline.config.objectStore.accessKey.env.name" -}}
{{- "OBJECTSTORECONFIG_ACCESSKEY" }}
{{- end }}

# This env name is currently hardcoded:
# https://github.com/kubeflow/pipelines/blob/63ca91850a9f42a357f3417110a3011ddbf43290/backend/src/apiserver/client_manager.go#L410
{{- define "kubeflow.pipelines.mlPipeline.config.objectStore.secretAccessKey.env.name" -}}
{{- "OBJECTSTORECONFIG_SECRETACCESSKEY" }}
{{- end }}

# This env name is currently hardcoded:
# https://github.com/kubeflow/pipelines/blob/63ca91850a9f42a357f3417110a3011ddbf43290/backend/src/apiserver/client_manager.go#L403
{{- define "kubeflow.pipelines.mlPipeline.config.objectStore.port.env.name" -}}
{{- "OBJECTSTORECONFIG_PORT" }}
{{- end }}

# This env name is currently hardcoded:
# https://github.com/kubeflow/pipelines/blob/63ca91850a9f42a357f3417110a3011ddbf43290/backend/src/apiserver/client_manager.go#L405
{{- define "kubeflow.pipelines.mlPipeline.config.objectStore.region.env.name" -}}
{{- "OBJECTSTORECONFIG_REGION" }}
{{- end }}

{{/*
Environment Entries parametrization for database configuration with plaintext
value or through Secrets.
*/}}

{{- define "kubeflow.pipelines.mlPipeline.config.db.user.env.spec" -}}
{{- include "kubeflow.component.env.spec" (
    list
    (include "kubeflow.pipelines.mlPipeline.config.db.user.env.name" . )
    .Values.pipelines.config.db.existingSecretName
    .Values.pipelines.config.db.user
) }}
{{- end }}

{{- define "kubeflow.pipelines.mlPipeline.config.db.password.env.spec" -}}
{{- include "kubeflow.component.env.spec" (
    list
    (include "kubeflow.pipelines.mlPipeline.config.db.password.env.name" . )
    .Values.pipelines.config.db.existingSecretName
    .Values.pipelines.config.db.password
) }}
{{- end }}

{{- define "kubeflow.pipelines.mlPipeline.config.db.host.env.spec" -}}
{{- include "kubeflow.component.env.spec" (
    list
    (include "kubeflow.pipelines.mlPipeline.config.db.host.env.name" . )
    .Values.pipelines.config.db.existingSecretName
    .Values.pipelines.config.db.host
) }}
{{- end }}

{{- define "kubeflow.pipelines.mlPipeline.config.db.port.env.spec" -}}
{{- include "kubeflow.component.env.spec" (
    list
    (include "kubeflow.pipelines.mlPipeline.config.db.port.env.name" . )
    .Values.pipelines.config.db.existingSecretName
    .Values.pipelines.config.db.port
) }}
{{- end }}

{{- define "kubeflow.pipelines.mlPipeline.config.db.pipelineDatabaseName.env.spec" -}}
{{- include "kubeflow.component.env.spec" (
    list
    (include "kubeflow.pipelines.mlPipeline.config.db.pipelineDatabaseName.env.name" . )
    .Values.pipelines.config.db.existingSecretName
    .Values.pipelines.config.db.pipelineDatabaseName
) }}
{{- end }}

{{- define "kubeflow.pipelines.mlPipeline.config.db.conMaxLifetime.env.spec" -}}
{{- include "kubeflow.component.env.spec" (
    list
    (include "kubeflow.pipelines.mlPipeline.config.db.conMaxLifetime.env.name" . )
    .Values.pipelines.config.db.existingSecretName
    .Values.pipelines.config.db.conMaxLifetime
) }}
{{- end }}

{{- define "kubeflow.pipelines.mlPipeline.config.db.driver.env.spec" -}}
{{- include "kubeflow.component.env.spec" (
    list
    (include "kubeflow.pipelines.mlPipeline.config.db.driver.env.name" . )
    .Values.pipelines.config.db.existingSecretName
    .Values.pipelines.config.db.driver
) }}
{{- end }}

{{/*
Environment Entries parametrization for object store config with plaintext value
or through Secrets.
*/}}

{{- define "kubeflow.pipelines.mlPipeline.config.objectStore.secure.env.spec" -}}
{{- include "kubeflow.component.env.spec" (
    list
    (include "kubeflow.pipelines.mlPipeline.config.objectStore.secure.env.name" . )
    .Values.pipelines.config.objectStore.existingSecretName
    .Values.pipelines.config.objectStore.secure
) }}
{{- end }}

{{- define "kubeflow.pipelines.mlPipeline.config.objectStore.bucketName.env.spec" -}}
{{- include "kubeflow.component.env.spec" (
    list
    (include "kubeflow.pipelines.mlPipeline.config.objectStore.bucketName.env.name" . )
    .Values.pipelines.config.objectStore.existingSecretName
    .Values.pipelines.config.objectStore.bucketName
) }}
{{- end }}

{{- define "kubeflow.pipelines.mlPipeline.config.objectStore.host.env.spec" -}}
{{- include "kubeflow.component.env.spec" (
    list
    (include "kubeflow.pipelines.mlPipeline.config.objectStore.host.env.name" . )
    .Values.pipelines.config.objectStore.existingSecretName
    .Values.pipelines.config.objectStore.host
) }}
{{- end }}

{{- define "kubeflow.pipelines.mlPipeline.config.objectStore.accessKey.env.spec" -}}
{{- include "kubeflow.component.env.spec" (
    list
    (include "kubeflow.pipelines.mlPipeline.config.objectStore.accessKey.env.name" . )
    .Values.pipelines.config.objectStore.existingSecretName
    .Values.pipelines.config.objectStore.accessKey
) }}
{{- end }}

{{- define "kubeflow.pipelines.mlPipeline.config.objectStore.secretAccessKey.env.spec" -}}
{{- include "kubeflow.component.env.spec" (
    list
    (include "kubeflow.pipelines.mlPipeline.config.objectStore.secretAccessKey.env.name" . )
    .Values.pipelines.config.objectStore.existingSecretName
    .Values.pipelines.config.objectStore.secretAccessKey
) }}
{{- end }}

{{- define "kubeflow.pipelines.mlPipeline.config.objectStore.port.env.spec" -}}
{{- include "kubeflow.component.env.spec" (
    list
    (include "kubeflow.pipelines.mlPipeline.config.objectStore.port.env.name" . )
    .Values.pipelines.config.objectStore.existingSecretName
    .Values.pipelines.config.objectStore.port
) }}
{{- end }}

{{- define "kubeflow.pipelines.mlPipeline.config.objectStore.region.env.spec" -}}
{{- include "kubeflow.component.env.spec" (
    list
    (include "kubeflow.pipelines.mlPipeline.config.objectStore.region.env.name" . )
    .Values.pipelines.config.objectStore.existingSecretName
    .Values.pipelines.config.objectStore.region
) }}
{{- end }}
