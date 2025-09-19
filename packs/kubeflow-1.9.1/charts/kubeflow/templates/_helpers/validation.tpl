{{/*
Dex validations.
*/}}

{{- if (ne .Values.dexIntegration.integrationType "internal" ) -}}
{{- fail "Currently only 'dexIntegration.integrationType: internal' is supported." -}}
{{- end }}

{{- if (ne .Values.dexIntegration.integrationMode "istio" ) -}}
{{- fail "Currently only 'dexIntegration.integrationMode: istio' is supported." -}}
{{- end }}

{{- if (ne .Values.pipelines.config.db.driver.value "mysql" ) -}}
{{- fail "Currently only 'pipelines.config.db.driver: mysql' is supported." -}}
{{- end }}

{{/*
Kubeflow Pipelines validations.
*/}}

# vars
{{- $hardcodedSecretName := "mlpipeline-minio-artifact" -}}
{{- $objectStoreCredentialsSecretKeyRefMessage := (.Files.Get "files/validation-messages/objectstore-accesskey-secretaccesskey-secret-ref.txt") -}}
{{- $secretConstraintsGeneralMessage := (.Files.Get "files/validation-messages/mlpipeline-minio-artifact.txt") -}}

# Check if the secret name for object store is either nil or $hardcodedSecretName.
{{- range $key, $val := (dict
    ".Values.pipelines.config.objectStore.existingSecretName" .Values.pipelines.config.objectStore.existingSecretName
    ".Values.pipelines.config.objectStore.accessKey.secretKeyRef.name" .Values.pipelines.config.objectStore.accessKey.secretKeyRef.name
    ".Values.pipelines.config.objectStore.secretAccessKey.secretKeyRef.name" .Values.pipelines.config.objectStore.secretAccessKey.secretKeyRef.name
) }}
    {{- if not (has $val (list nil $hardcodedSecretName)) -}}
    {{- fail (printf "%s must be one of [nil, '%s'], current value: %s\n\n%s"
        $key $hardcodedSecretName $val $secretConstraintsGeneralMessage
    ) }}
    {{- end }}
{{- end }}

# Check if objectStore accessKey and secretAccessKey references are the same.
{{- if (ne
    .Values.pipelines.config.objectStore.accessKey.secretKeyRef.name
    .Values.pipelines.config.objectStore.secretAccessKey.secretKeyRef.name
)}}
{{- fail (printf "%s\n%s"
    $objectStoreCredentialsSecretKeyRefMessage
    $secretConstraintsGeneralMessage
) -}}
{{- end }}

{{/*
*/}}
