{{/*
Kubeflow Notebooks PVC Viewer Controller object names.
*/}}
{{- define "kubeflow.notebooks.pvcviewerController.baseName" -}}
{{- printf "pvcviewer-controller" }}
{{- end }}

{{- define "kubeflow.notebooks.pvcviewerController.name" -}}
{{- include "kubeflow.component.name" (
    list
    (include "kubeflow.notebooks.pvcviewerController.baseName" .)
    .
)}}
{{- end }}

{{- define "kubeflow.notebooks.pvcviewerController.manager.name" -}}
{{- printf "%s-%s"
    (include "kubeflow.notebooks.pvcviewerController.name" .)
    "manager"
}}
{{- end }}

{{- define "kubeflow.notebooks.pvcviewerController.kubeRbacProxy.name" -}}
{{- printf "%s-%s"
    (include "kubeflow.notebooks.pvcviewerController.name" .)
    "kube-rbac-proxy"
}}
{{- end }}

{{- define "kubeflow.notebooks.pvcviewerController.serviceAccountName" -}}
{{- include "kubeflow.component.serviceAccountName"  (
    list
    (include "kubeflow.notebooks.pvcviewerController.name" .)
    .Values.notebooks.pvcviewerController.serviceAccount
)}}
{{- end }}

{{- define "kubeflow.notebooks.pvcviewerController.mainClusterRoleName" -}}
{{- printf "%s-%s"
    (include "kubeflow.fullname" .)
    (include "kubeflow.notebooks.pvcviewerController.name" .)
}}
{{- end }}

{{- define "kubeflow.notebooks.pvcviewerController.mainClusterRoleBindingName" -}}
{{- include "kubeflow.notebooks.pvcviewerController.mainClusterRoleName" . }}
{{- end }}

{{- define "kubeflow.notebooks.pvcviewerController.leaderElectionRoleName" -}}
{{- printf "%s-%s-%s"
    (include "kubeflow.fullname" .)
    (include "kubeflow.notebooks.pvcviewerController.name" .)
    "leader-election"
}}
{{- end }}

{{- define "kubeflow.notebooks.pvcviewerController.leaderElectionRoleBindingName" -}}
{{- include "kubeflow.notebooks.pvcviewerController.leaderElectionRoleName" . }}
{{- end }}

{{- define "kubeflow.notebooks.pvcviewerController.metricsReaderClusterRoleName" -}}
{{- printf "%s-%s-%s"
    (include "kubeflow.fullname" .)
    (include "kubeflow.notebooks.pvcviewerController.name" .)
    "metrics-reader"
}}
{{- end }}

{{- define "kubeflow.notebooks.pvcviewerController.metricsReaderClusterRoleBindingName" -}}
{{- include "kubeflow.notebooks.pvcviewerController.metricsReaderClusterRoleName" . }}
{{- end }}

{{- define "kubeflow.notebooks.pvcviewerController.proxyClusterRoleName" -}}
{{- printf "%s-%s-%s"
    (include "kubeflow.fullname" .)
    (include "kubeflow.notebooks.pvcviewerController.name" .)
    "proxy"
}}
{{- end }}

{{- define "kubeflow.notebooks.pvcviewerController.proxyClusterRoleBindingName" -}}
{{- include "kubeflow.notebooks.pvcviewerController.proxyClusterRoleName" . }}
{{- end }}


{{- define "kubeflow.notebooks.pvcviewerController.tlsCertSecretName" -}}
{{ printf "%s-%s" (include "kubeflow.notebooks.pvcviewerController.name" .) "tls-certs" }}
{{- end }}

{{- define "kubeflow.notebooks.pvcviewerController.certIssuerName" -}}
{{ printf "%s-%s" (include "kubeflow.notebooks.pvcviewerController.name" .) "selfsigned-issuer" }}
{{- end }}

{{- define "kubeflow.notebooks.pvcviewerController.certName" -}}
{{ printf "%s-%s" (include "kubeflow.notebooks.pvcviewerController.name" .) "cert" }}
{{- end }}

{{- define "kubeflow.notebooks.pvcviewerController.mutatingWebhookName" -}}
{{ printf "%s-%s" (include "kubeflow.notebooks.pvcviewerController.name" .) "mutating" }}
{{- end }}

{{- define "kubeflow.notebooks.pvcviewerController.validatingWebhookName" -}}
{{ printf "%s-%s" (include "kubeflow.notebooks.pvcviewerController.name" .) "validating" }}
{{- end }}

{{/*
Kubeflow Notebooks PVC Viewer Controller Service.
*/}}
{{- define "kubeflow.notebooks.pvcviewerController.manager.svc.name" -}}
{{ include "kubeflow.component.svc.name" (
    include "kubeflow.notebooks.pvcviewerController.manager.name" .
)}}
{{- end }}

{{- define "kubeflow.notebooks.pvcviewerController.manager.svc.addressWithNs" -}}
{{ include "kubeflow.component.svc.addressWithNs"  (
    list
    .
    (include "kubeflow.notebooks.pvcviewerController.manager.name" .)
)}}
{{- end }}

{{- define "kubeflow.notebooks.pvcviewerController.manager.svc.addressWithSvc" -}}
{{ include "kubeflow.component.svc.addressWithSvc"  (
    list
    .
    (include "kubeflow.notebooks.pvcviewerController.manager.name" .)
)}}
{{- end }}

{{- define "kubeflow.notebooks.pvcviewerController.manager.svc.fqdn" -}}
{{ include "kubeflow.component.svc.fqdn"  (
    list
    .
    (include "kubeflow.notebooks.pvcviewerController.manager.name" .)
)}}
{{- end }}

{{- define "kubeflow.notebooks.pvcviewerController.kubeRbacProxy.svc.name" -}}
{{ include "kubeflow.component.svc.name" (
    include "kubeflow.notebooks.pvcviewerController.kubeRbacProxy.name" .
)}}
{{- end }}

{{- define "kubeflow.notebooks.pvcviewerController.webhook.port" -}}
{{- .Values.notebooks.pvcviewerController.manager.webhook.port }}
{{- end }}

{{/*
Kubeflow Notebooks PVC Viewer Controller object labels.
*/}}
{{- define "kubeflow.notebooks.pvcviewerController.labels" -}}
{{ include "kubeflow.common.labels" . }}
{{ include "kubeflow.component.labels" (include "kubeflow.notebooks.name" .) }}
{{ include "kubeflow.component.subcomponent.labels" (include "kubeflow.notebooks.pvcviewerController.name" .) }}
{{- end }}

{{- define "kubeflow.notebooks.pvcviewerController.selectorLabels" -}}
{{ include "kubeflow.common.selectorLabels" . }}
{{ include "kubeflow.component.selectorLabels" (include "kubeflow.notebooks.name" .) }}
{{ include "kubeflow.component.subcomponent.labels" (include "kubeflow.notebooks.pvcviewerController.name" .) }}
{{- end }}

{{/*
Kubeflow Notebooks PVC Viewer Controller Manager container image settings.
*/}}
{{- define "kubeflow.notebooks.pvcviewerController.manager.image" -}}
{{ include "kubeflow.component.image" (
    list
    .Values.defaults.image
    .Values.notebooks.pvcviewerController.manager.image
)}}
{{- end }}

{{- define "kubeflow.notebooks.pvcviewerController.manager.imagePullPolicy" -}}
{{ include "kubeflow.component.imagePullPolicy" (
    list
    .Values.defaults.image
    .Values.notebooks.pvcviewerController.manager.image
)}}
{{- end }}

{{/*
Kubeflow Notebooks PVC Viewer Controller Kube RBAC Proxy container image settings.
*/}}
{{- define "kubeflow.notebooks.pvcviewerController.kubeRbacProxy.image" -}}
{{ include "kubeflow.component.image" (
    list
    .Values.defaults.image
    .Values.notebooks.pvcviewerController.kubeRbacProxy.image
)}}
{{- end }}

{{- define "kubeflow.notebooks.pvcviewerController.kubeRbacProxy.imagePullPolicy" -}}
{{ include "kubeflow.component.imagePullPolicy" (
    list
    .Values.defaults.image
    .Values.notebooks.pvcviewerController.kubeRbacProxy.image
)}}
{{- end }}

{{/*
Kubeflow Notebooks PVC Viewer Controller Autoscaling and Availability.
*/}}
{{- define "kubeflow.notebooks.pvcviewerController.autoscaling.minReplicas" -}}
{{ include "kubeflow.component.autoscaling.minReplicas" (
    list
    .Values.defaults.autoscaling
    .Values.notebooks.pvcviewerController.autoscaling
)}}
{{- end }}

{{- define "kubeflow.notebooks.pvcviewerController.autoscaling.maxReplicas" -}}
{{ include "kubeflow.component.autoscaling.maxReplicas" (
    list
    .Values.defaults.autoscaling
    .Values.notebooks.pvcviewerController.autoscaling
)}}
{{- end }}

{{- define "kubeflow.notebooks.pvcviewerController.autoscaling.targetCPUUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetCPUUtilizationPercentage" (
    list
    .Values.defaults.autoscaling
    .Values.notebooks.pvcviewerController.autoscaling
)}}
{{- end }}

{{- define "kubeflow.notebooks.pvcviewerController.autoscaling.targetMemoryUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetMemoryUtilizationPercentage" (
    list
    .Values.defaults.autoscaling
    .Values.notebooks.pvcviewerController.autoscaling
)}}
{{- end }}

{{- define "kubeflow.notebooks.pvcviewerController.pdb.values" -}}
{{- include "kubeflow.component.pdb.values" (
    list
    .Values.defaults.podDisruptionBudget
    .Values.notebooks.pvcviewerController.podDisruptionBudget
)}}
{{- end }}

{{/*
Kubeflow Notebooks PVC Viewer Controller Security Context.
*/}}
{{- define "kubeflow.notebooks.pvcviewerController.manager.containerSecurityContext" -}}
{{ include "kubeflow.component.containerSecurityContext" (
    list
    .Values.defaults.containerSecurityContext
    .Values.notebooks.pvcviewerController.manager.containerSecurityContext
)}}
{{- end }}

{{- define "kubeflow.notebooks.pvcviewerController.kubeRbacProxy.containerSecurityContext" -}}
{{ include "kubeflow.component.containerSecurityContext" (
    list
    .Values.defaults.containerSecurityContext
    .Values.notebooks.pvcviewerController.kubeRbacProxy.containerSecurityContext
)}}
{{- end }}

{{- define "kubeflow.notebooks.pvcviewerController.securityContext" -}}
{{ include "kubeflow.component.containerSecurityContext" (
    list
    .Values.defaults.containerSecurityContext
    .Values.notebooks.pvcviewerController.securityContext
)}}
{{- end }}

{{/*
Kubeflow Notebooks PVC Viewer Controller Scheduling.
*/}}
{{- define "kubeflow.notebooks.pvcviewerController.topologySpreadConstraints" -}}
{{ include "kubeflow.component.topologySpreadConstraints" (
    list
    .Values.defaults.topologySpreadConstraints
    .Values.notebooks.pvcviewerController.topologySpreadConstraints
)}}
{{- end }}

{{- define "kubeflow.notebooks.pvcviewerController.nodeSelector" -}}
{{ include "kubeflow.component.tolerations" (
    list
    .Values.defaults.nodeSelector
    .Values.notebooks.pvcviewerController.nodeSelector
)}}
{{- end }}

{{- define "kubeflow.notebooks.pvcviewerController.tolerations" -}}
{{ include "kubeflow.component.tolerations" (
    list
    .Values.defaults.tolerations
    .Values.notebooks.pvcviewerController.tolerations
)}}
{{- end }}

{{- define "kubeflow.notebooks.pvcviewerController.affinity" -}}
{{ include "kubeflow.component.affinity" (
    list
    .Values.defaults.affinity
    .Values.notebooks.pvcviewerController.affinity
)}}
{{- end }}

{{- define "kubeflow.notebooks.pvcviewerController.terminationGracePeriodSeconds" -}}
{{ include "kubeflow.component.terminationGracePeriodSeconds" (
    list
    .Values.defaults.terminationGracePeriodSeconds
    .Values.notebooks.pvcviewerController.terminationGracePeriodSeconds
)}}
{{- end }}

{{/*
Kubeflow Notebooks PVC Viewer Controller enable and create toggles.
*/}}
{{- define "kubeflow.notebooks.pvcviewerController.enabled" -}}
{{- ternary true "" (
    and
    (include "kubeflow.notebooks.enabled" . | eq "true")
    .Values.notebooks.pvcviewerController.enabled
)}}
{{- end }}

{{- define "kubeflow.notebooks.pvcviewerController.autoscaling.enabled" -}}
{{ include "kubeflow.component.autoscaling.enabled" (
    list
    .Values.defaults.autoscaling
    .Values.notebooks.pvcviewerController.autoscaling
)}}
{{- end }}

{{- define "kubeflow.notebooks.pvcviewerController.rbac.createRoles" -}}
{{- ternary true "" (
    and
    (include "kubeflow.notebooks.pvcviewerController.enabled" . | eq "true")
    .Values.notebooks.pvcviewerController.rbac.create
)}}
{{- end }}

{{- define "kubeflow.notebooks.pvcviewerController.createServiceAccount" -}}
{{- ternary true "" (
and
    (include "kubeflow.notebooks.pvcviewerController.enabled" . | eq "true")
    .Values.notebooks.pvcviewerController.serviceAccount.create
)}}
{{- end }}

{{- define "kubeflow.notebooks.pvcviewerController.pdb.create" -}}
{{- include "kubeflow.component.pdb.create" (
    list
    (include "kubeflow.notebooks.pvcviewerController.enabled" .)
    .Values.defaults.podDisruptionBudget
    .Values.notebooks.pvcviewerController.podDisruptionBudget
)}}
{{- end }}

{{/*
Kubeflow Notebooks PVC Viewer Controller certificate manager.
*/}}
{{- define "kubeflow.notebooks.pvcviewerController.enabledWithCertManager" -}}
{{- ternary true "" (
    and
        (include "kubeflow.notebooks.pvcviewerController.enabled" . | eq "true" )
        (include "kubeflow.certManagerIntegration.enabled" . | eq "true" )
)}}
{{- end }}
