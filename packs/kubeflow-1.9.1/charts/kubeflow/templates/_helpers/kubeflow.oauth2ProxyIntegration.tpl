{{- define "kubeflow.oauth2ProxyIntegration.istio.enabled" -}}
{{- and
  (include "kubeflow.istioIntegration.enabled" . | eq "true" )
  .Values.oauth2ProxyIntegration.enabled
}}
{{- end }}
