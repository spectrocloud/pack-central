{{/*
Knative Integration helpers.
*/}}

{{- define "kubeflow.knativeIntegration.enabled" -}}
{{- .Values.knativeIntegration.enabled }}
{{- end }}

{{/*
Knative Serving helpers.
*/}}

{{- define "kubeflow.knativeIntegration.knativeServing.enabled" -}}
{{- ternary true "" (
    and
        (include "kubeflow.knativeIntegration.enabled" . | eq "true")
        .Values.knativeIntegration.knativeServing.enabled
)}}
{{- end }}

{{/*
Knative Eventing helpers.
*/}}

{{- define "kubeflow.knativeIntegration.knativeEventing.enabled" -}}
{{- ternary true "" (
    and
        (include "kubeflow.knativeIntegration.enabled" . | eq "true")
        .Values.knativeIntegration.knativeEventing.enabled
)}}
{{- end }}

{{/*
KNative Istio Ingregration helpers.
*/}}

{{- define "kubeflow.knativeIntegration.createIstioIntegrationObjects" -}}
{{- ternary true "" (
    and
    (include "kubeflow.knativeIntegration.enabled" . | eq "true")
    .Values.istioIntegration.enabled
)}}
{{- end }}
