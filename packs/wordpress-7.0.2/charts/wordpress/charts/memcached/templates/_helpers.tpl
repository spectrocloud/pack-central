{{/*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}

{{/*
Return the proper Memcached image name
*/}}
{{- define "memcached.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the metrics image)
*/}}
{{- define "memcached.metrics.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.metrics.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "memcached.volumePermissions.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.volumePermissions.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "memcached.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.image .Values.metrics.image .Values.volumePermissions.image) "context" .) -}}
{{- end -}}

{{/*
 Create the name of the service account to use
 */}}
{{- define "memcached.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Check if admin credentials secret is based on user-provided credentials via chart values
*/}}
{{- define "memcached.valuesBasedSecret" -}}
{{- if and .Values.auth.enabled (not .Values.auth.existingPasswordSecret) (not (empty .Values.auth.password)) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Check if there are rolling tags in the images
*/}}
{{- define "memcached.checkRollingTags" -}}
{{- include "common.warnings.rollingTag" .Values.image }}
{{- include "common.warnings.rollingTag" .Values.metrics.image }}
{{- include "common.warnings.rollingTag" .Values.volumePermissions.image }}
{{- end -}}

{{/*
Compile all warnings into a single message, and call fail.
*/}}
{{- define "memcached.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "memcached.validateValues.architecture" .) -}}
{{- $messages := append $messages (include "memcached.validateValues.replicaCount" .) -}}
{{- $messages := append $messages (include "memcached.validateValues.auth" .) -}}
{{- $messages := append $messages (include "memcached.validateValues.readOnlyRootFilesystem" .) -}}
{{- $messages := append $messages (include "memcached.validateValues.tls" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message | fail -}}
{{- end -}}
{{- end -}}

{{/* Validate values of Memcached - must provide a valid architecture */}}
{{- define "memcached.validateValues.architecture" -}}
{{- if and (ne .Values.architecture "standalone") (ne .Values.architecture "high-availability") -}}
memcached: architecture
    Invalid architecture selected. Valid values are "standalone" and
    "high-availability". Please set a valid architecture (--set architecture="xxxx")
{{- end -}}
{{- end -}}

{{/* Validate values of Memcached - number of replicas */}}
{{- define "memcached.validateValues.replicaCount" -}}
{{- $replicaCount := int .Values.replicaCount }}
{{- if and (eq .Values.architecture "standalone") (gt $replicaCount 1) -}}
memcached: replicaCount
    The standalone architecture doesn't allow to run more than 1 replica.
    Please set a valid number of replicas (--set memcached.replicaCount=1) or
    use the "high-availability" architecture (--set architecture="high-availability")
{{- end -}}
{{- end -}}

{{/* Validate values of Memcached - authentication */}}
{{- define "memcached.validateValues.auth" -}}
{{- if and .Values.auth.enabled (empty .Values.auth.username) -}}
memcached: auth.username
    Enabling authentication requires setting a valid admin username.
    Please set a valid username (--set auth.username="xxxx")
{{- end -}}
{{- end -}}

{{/* Validate values of Memcached - containerSecurityContext.readOnlyRootFilesystem */}}
{{- define "memcached.validateValues.readOnlyRootFilesystem" -}}
{{- if and .Values.containerSecurityContext.enabled .Values.containerSecurityContext.readOnlyRootFilesystem .Values.auth.enabled -}}
memcached: containerSecurityContext.readOnlyRootFilesystem
    Enabling authentication is not compatible with using a read-only filesystem.
    Please disable it (--set containerSecurityContext.readOnlyRootFilesystem=false)
{{- end -}}
{{- end -}}

{{/*
Get the password secret.
*/}}
{{- define "memcached.secretPasswordName" -}}
    {{- if .Values.auth.existingPasswordSecret -}}
        {{- printf "%s" (tpl .Values.auth.existingPasswordSecret $) -}}
    {{- else -}}
        {{- printf "%s" (include "common.names.fullname" .) -}}
    {{- end -}}
{{- end -}}

{{/*
Return the TLS secret name.
*/}}
{{- define "memcached.tls.secretName" -}}
{{- if .Values.tls.existingSecret -}}
    {{- tpl .Values.tls.existingSecret . -}}
{{- else -}}
    {{- printf "%s-tls" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a TLS Secret should be created by this chart.
The secret is created when TLS is enabled, no existingSecret is given, and either
  (a) autoGenerated.enabled=true + engine=helm  (Helm self-signed)
  (b) autoGenerated.enabled=false + tls.cert + tls.key provided (user PEM values)
*/}}
{{- define "memcached.createTlsSecret" -}}
{{- if and .Values.tls.enabled (not .Values.tls.existingSecret) -}}
  {{- if and .Values.tls.autoGenerated.enabled (eq (lower (default "helm" .Values.tls.autoGenerated.engine)) "helm") -}}
    {{- true -}}
  {{- else if and (not .Values.tls.autoGenerated.enabled) .Values.tls.cert .Values.tls.key -}}
    {{- true -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/* Validate TLS configuration */}}
{{- define "memcached.validateValues.tls" -}}
{{- if .Values.tls.enabled -}}
{{- if not .Values.tls.autoGenerated.enabled -}}
{{- if and (not .Values.tls.existingSecret) (or (not .Values.tls.cert) (not .Values.tls.key)) -}}
memcached: tls
    When tls.enabled=true and tls.autoGenerated.enabled=false you must provide
    either tls.existingSecret or both tls.cert and tls.key.
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
