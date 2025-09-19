{{/*
Kubeflow Pipelines Metadata GRPC Server config.
*/}}

{{/*
Environment names.
*/}}
{{- define "kubeflow.pipelines.metadataGrpcServer.config.db.user.env.name" -}}
{{- "DBCONFIG_USER" }}
{{- end }}

{{- define "kubeflow.pipelines.metadataGrpcServer.config.db.password.env.name" -}}
{{- "DBCONFIG_PASSWORD" }}
{{- end }}

{{- define "kubeflow.pipelines.metadataGrpcServer.config.db.host.env.name" -}}
{{- "DBCONFIG_HOST" }}
{{- end }}

{{- define "kubeflow.pipelines.metadataGrpcServer.config.db.port.env.name" -}}
{{- "DBCONFIG_PORT" }}
{{- end }}

{{- define "kubeflow.pipelines.metadataGrpcServer.config.db.mlmdDatabaseName.env.name" -}}
{{- "DBCONFIG_MLMD_DB_NAME" }}
{{- end }}


{{/*
Environment Entries parametrization with plaintext value
or through Secrets.
*/}}
{{- define "kubeflow.pipelines.metadataGrpcServer.config.db.user.env.spec" -}}
{{- include "kubeflow.component.env.spec" (
    list
    (include "kubeflow.pipelines.metadataGrpcServer.config.db.user.env.name" . )
    .Values.pipelines.config.db.existingSecretName
    .Values.pipelines.config.db.user
) }}
{{- end }}

{{- define "kubeflow.pipelines.metadataGrpcServer.config.db.password.env.spec" -}}
{{- include "kubeflow.component.env.spec" (
    list
    (include "kubeflow.pipelines.metadataGrpcServer.config.db.password.env.name" . )
    .Values.pipelines.config.db.existingSecretName
    .Values.pipelines.config.db.password
) }}
{{- end }}

{{- define "kubeflow.pipelines.metadataGrpcServer.config.db.host.env.spec" -}}
{{- include "kubeflow.component.env.spec" (
    list
    (include "kubeflow.pipelines.metadataGrpcServer.config.db.host.env.name" . )
    .Values.pipelines.config.db.existingSecretName
    .Values.pipelines.config.db.host
) }}
{{- end }}

{{- define "kubeflow.pipelines.metadataGrpcServer.config.db.port.env.spec" -}}
{{- include "kubeflow.component.env.spec" (
    list
    (include "kubeflow.pipelines.metadataGrpcServer.config.db.port.env.name" . )
    .Values.pipelines.config.db.existingSecretName
    .Values.pipelines.config.db.port
) }}
{{- end }}

{{- define "kubeflow.pipelines.metadataGrpcServer.config.db.mlmdDatabaseName.env.spec" -}}
{{- include "kubeflow.component.env.spec" (
    list
    (include "kubeflow.pipelines.metadataGrpcServer.config.db.mlmdDatabaseName.env.name" . )
    .Values.pipelines.config.db.existingSecretName
    .Values.pipelines.config.db.mlmdDatabaseName
) }}
{{- end }}
