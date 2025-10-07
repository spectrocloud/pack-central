{{/*
Kubeflow Pipelines UI config.
*/}}

{{/*
Environment names for object store config.
*/}}

{{- define "kubeflow.pipelines.ui.config.objectStore.host.env.name" -}}
{{- "MINIO_HOST" }}
{{- end }}

{{- define "kubeflow.pipelines.ui.config.objectStore.accessKey.env.name" -}}
{{- "MINIO_ACCESS_KEY" }}
{{- end }}

{{- define "kubeflow.pipelines.ui.config.objectStore.secretAccessKey.env.name" -}}
{{- "MINIO_SECRET_KEY" }}
{{- end }}

{{/*
Environment Entries parametrization for object store configuration with plaintext
value or through Secrets.
*/}}

{{- define "kubeflow.pipelines.ui.config.objectStore.host.env.spec" -}}
{{- include "kubeflow.component.env.spec" (
    list
    (include "kubeflow.pipelines.ui.config.objectStore.host.env.name" . )
    .Values.pipelines.config.objectStore.existingSecretName
    .Values.pipelines.config.objectStore.host
) }}
{{- end }}

{{- define "kubeflow.pipelines.ui.config.objectStore.accessKey.env.spec" -}}
{{- include "kubeflow.component.env.spec" (
    list
    (include "kubeflow.pipelines.ui.config.objectStore.accessKey.env.name" . )
    .Values.pipelines.config.objectStore.existingSecretName
    .Values.pipelines.config.objectStore.accessKey
) }}
{{- end }}

{{- define "kubeflow.pipelines.ui.config.objectStore.secretAccessKey.env.spec" -}}
{{- include "kubeflow.component.env.spec" (
    list
    (include "kubeflow.pipelines.ui.config.objectStore.secretAccessKey.env.name" . )
    .Values.pipelines.config.objectStore.existingSecretName
    .Values.pipelines.config.objectStore.secretAccessKey
) }}
{{- end }}
