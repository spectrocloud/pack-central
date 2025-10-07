{{/*
Istio Integration object names.
*/}}

{{- define "kubeflow.istioIntegration.baseName" -}}
{{- print "istio-integration" }}
{{- end }}

{{- define "kubeflow.istioIntegration.name" -}}
{{- include "kubeflow.component.name" (
    list
    (include "kubeflow.istioIntegration.baseName" .)
    .
)}}
{{- end }}

{{- define "kubeflow.istioIntegration.istioAdminRoleName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) "istio-admin" }}
{{- end }}

{{- define "kubeflow.istioIntegration.istioEditRoleName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) "istio-edit" }}
{{- end }}

{{- define "kubeflow.istioIntegration.istioViewRoleName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) "istio-view" }}
{{- end }}

{{- define "kubeflow.istioIntegration.m2m.requestAuthenticationName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) "m2m" }}
{{- end }}

{{- define "kubeflow.istioIntegration.m2m.selfSigned.jobName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) "configure-self-signed-m2m" }}
{{- end }}

{{- define "kubeflow.istioIntegration.m2m.selfSigned.inClusterClusterRoleBindingName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) "unauthenticated-oidc-viewer" }}
{{- end }}

{{- define "kubeflow.istioIntegration.userAuth.requestAuthenticationName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) "user-auth" }}
{{- end }}

{{- define "kubeflow.istioIntegration.extAuth.authorizationPolicyName" -}}
{{- printf "%s-ext-auth-%s"
  (include "kubeflow.fullname" .)
  .Values.istioIntegration.envoyExtAuthzHttpExtensionProviderName
}}
{{- end }}

{{- define "kubeflow.istioIntegration.jwtRequire.authorizationPolicyName" -}}
{{- printf "%s-jwt-require"
  (include "kubeflow.fullname" .)
}}
{{- end }}

{{/*
Role Aggregation Rule Labels
*/}}
{{- define "kubeflow.istioIntegration.istioAdminRoleLabel" -}}
{{- include "kubeflow.aggregationRule.labelBase" (include "kubeflow.istioIntegration.istioAdminRoleName" .) -}}
{{- end }}

{{/*
Istio Integration object labels.
*/}}
{{- define "kubeflow.istioIntegration.labels" -}}
{{ include "kubeflow.common.labels" . }}
{{ include "kubeflow.component.labels" (include "kubeflow.istioIntegration.name" .) }}
{{- end }}

{{/*
Istio Integration enable and create toggles.
*/}}
{{- define "kubeflow.istioIntegration.enabled" -}}
{{- .Values.istioIntegration.enabled }}
{{- end }}

{{- define "kubeflow.istioIntegration.m2m.enabled" -}}
{{- and
  (include "kubeflow.istioIntegration.enabled" . | eq "true" )
  .Values.istioIntegration.m2m.enabled
}}
{{- end }}

{{- define "kubeflow.istioIntegration.m2m.selfSigned.autoJwksDiscovery" -}}
{{- and
  (include "kubeflow.istioIntegration.enabled" . | eq "true" )
  .Values.istioIntegration.m2m.selfSigned.autoJwksDiscovery
}}
{{- end }}

{{- define "kubeflow.istioIntegration.authorizationMode.granular" -}}
{{- ternary true "" (eq .Values.istioIntegration.authorizationMode "granular") -}}
{{- end }}

{{- define "kubeflow.istioIntegration.authorizationMode.ingressgateway" -}}
{{- ternary true "" (eq .Values.istioIntegration.authorizationMode "ingressgateway") -}}
{{- end }}

{{- define "kubeflow.istioIntegration.istioIngressGateway.serviceAccountPrincipal" -}}
{{- printf "%s/ns/%s/sa/%s"
    .Values.clusterDomain
    .Values.istioIntegration.ingressGatewayNamespace
    .Values.istioIntegration.ingressGatewayServiceAccountName
}}
{{- end }}

{{- define "kubeflow.istioIntegration.kubeflowJwksProxy.name" -}}
{{- printf "%s-jwks-proxy"
  (include "kubeflow.fullname" .)
}}
{{- end -}}

{{- define "kubeflow.istioIntegration.kubeflowJwksProxy.labels" -}}
app.kubernetes.io/name: {{ include "kubeflow.istioIntegration.kubeflowJwksProxy.name" . }}
{{- end -}}

{{- define "kubeflow.istioIntegration.kubeflowJwksProxy.namespace" -}}
{{ include "kubeflow.namespace" . }}
{{- end -}}

{{- define "kubeflow.istioIntegration.jwksUri" -}}
http://{{ include "kubeflow.istioIntegration.kubeflowJwksProxy.name" . }}.{{ include "kubeflow.istioIntegration.kubeflowJwksProxy.namespace" . }}.svc.cluster.local/openid/v1/jwks
{{- end -}}

{{- define "kubeflow.istioIntegration.kubeflowJwksProxy.enabled" -}}
{{- and
  (include "kubeflow.istioIntegration.enabled" . | eq "true" )
  .Values.istioIntegration.kubeflowJwksProxy.enabled
}}
{{- end }}
