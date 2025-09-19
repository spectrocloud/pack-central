{{/*
Kubeflow Pipelines Cache config.
*/}}

{{/*
Environment names for the env spec parametrization.
*/}}
{{- define "kubeflow.pipelines.cache.config.db.user.env.name" -}}
{{- "DBCONFIG_USER" }}
{{- end }}

{{- define "kubeflow.pipelines.cache.config.db.password.env.name" -}}
{{- "DBCONFIG_PASSWORD" }}
{{- end }}

{{- define "kubeflow.pipelines.cache.config.db.host.env.name" -}}
{{- "DBCONFIG_HOST" }}
{{- end }}

{{- define "kubeflow.pipelines.cache.config.db.port.env.name" -}}
{{- "DBCONFIG_PORT" }}
{{- end }}

{{- define "kubeflow.pipelines.cache.config.db.cacheDatabaseName.env.name" -}}
{{- "DBCONFIG_CACHE_DB_NAME" }}
{{- end }}

{{- define "kubeflow.pipelines.cache.config.db.driver.env.name" -}}
{{- "DBCONFIG_DRIVER" }}
{{- end }}


{{/*
Environment Entries parametrization with plaintext value
or through Secrets.
*/}}
{{- define "kubeflow.pipelines.cache.config.db.user.env.spec" -}}
{{- include "kubeflow.component.env.spec" (
    list
    (include "kubeflow.pipelines.cache.config.db.user.env.name" . )
    .Values.pipelines.config.db.existingSecretName
    .Values.pipelines.config.db.user
) }}
{{- end }}

{{- define "kubeflow.pipelines.cache.config.db.password.env.spec" -}}
{{- include "kubeflow.component.env.spec" (
    list
    (include "kubeflow.pipelines.cache.config.db.password.env.name" . )
    .Values.pipelines.config.db.existingSecretName
    .Values.pipelines.config.db.password
) }}
{{- end }}

{{- define "kubeflow.pipelines.cache.config.db.host.env.spec" -}}
{{- include "kubeflow.component.env.spec" (
    list
    (include "kubeflow.pipelines.cache.config.db.host.env.name" . )
    .Values.pipelines.config.db.existingSecretName
    .Values.pipelines.config.db.host
) }}
{{- end }}

{{- define "kubeflow.pipelines.cache.config.db.port.env.spec" -}}
{{- include "kubeflow.component.env.spec" (
    list
    (include "kubeflow.pipelines.cache.config.db.port.env.name" . )
    .Values.pipelines.config.db.existingSecretName
    .Values.pipelines.config.db.port
) }}
{{- end }}

{{- define "kubeflow.pipelines.cache.config.db.cacheDatabaseName.env.spec" -}}
{{- include "kubeflow.component.env.spec" (
    list
    (include "kubeflow.pipelines.cache.config.db.cacheDatabaseName.env.name" . )
    .Values.pipelines.config.db.existingSecretName
    .Values.pipelines.config.db.cacheDatabaseName
) }}
{{- end }}

{{- define "kubeflow.pipelines.cache.config.db.pipelineDatabaseName.env.spec" -}}
{{- include "kubeflow.component.env.spec" (
    list
    (include "kubeflow.pipelines.cache.config.db.pipelineDatabaseName.env.name" . )
    .Values.pipelines.config.db.existingSecretName
    .Values.pipelines.config.db.pipelineDatabaseName
) }}
{{- end }}

{{- define "kubeflow.pipelines.cache.config.db.conMaxLifetime.env.spec" -}}
{{- include "kubeflow.component.env.spec" (
    list
    (include "kubeflow.pipelines.cache.config.db.conMaxLifetime.env.name" . )
    .Values.pipelines.config.db.existingSecretName
    .Values.pipelines.config.db.conMaxLifetime
) }}
{{- end }}

{{- define "kubeflow.pipelines.cache.config.db.driver.env.spec" -}}
{{- include "kubeflow.component.env.spec" (
    list
    (include "kubeflow.pipelines.cache.config.db.driver.env.name" . )
    .Values.pipelines.config.db.existingSecretName
    .Values.pipelines.config.db.driver
) }}
{{- end }}

