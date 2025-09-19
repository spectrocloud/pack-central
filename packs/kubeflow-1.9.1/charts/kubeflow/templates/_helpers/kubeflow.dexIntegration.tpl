{{/*
Dex Integration object names.
*/}}
{{- define "kubeflow.dexIntegration.baseName" -}}
{{- printf "dex" }}
{{- end }}

{{- define "kubeflow.dexIntegration.name" -}}
{{- include "kubeflow.component.name" (
    list
    (include "kubeflow.dexIntegration.baseName" .)
    .
)}}
{{- end }}

{{/*
Dex Service.
*/}}
{{- define "kubeflow.dexIntegration.svc.fqdn" -}}
{{ printf "%s.%s.svc.%s"
  .Values.dexIntegration.svc.name
  .Values.dexIntegration.svc.namespace
  .Values.clusterDomain
}}
{{- end }}

{{/*
Dex Integration object labels.
*/}}
{{- define "kubeflow.dexIntegration.labels" -}}
{{ include "kubeflow.common.labels" . }}
{{ include "kubeflow.component.labels" (include "kubeflow.dexIntegration.name" .) }}
{{- end }}

{{/*
Dex Integration enable and create toggles.
*/}}
{{- define "kubeflow.dexIntegration.enabled" -}}
{{- or
    (
        and
        (eq .Values.dexIntegration.integrationMode "istio")
        .Values.istioIntegration.enabled
        .Values.dexIntegration.enabled
    )
    (
        and
        (eq .Values.dexIntegration.integrationMode "ingress")
        .Values.dexIntegration.enabled
    )
}}
{{- end }}


{{- define "kubeflow.dexIntegration.istio.enabled" -}}
{{- ternary true "" (
    and
    (include "kubeflow.dexIntegration.enabled" . | eq "true")
    .Values.istioIntegration.enabled
)}}
{{- end }}
