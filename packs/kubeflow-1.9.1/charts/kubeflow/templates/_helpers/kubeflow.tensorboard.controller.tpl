{{/*
Kubeflow Tensorboard Controller object names.
*/}}
{{- define "kubeflow.tensorboard.controller.baseName" -}}
{{- printf "tensorboard-controller" }}
{{- end }}

{{- define "kubeflow.tensorboard.controller.name" -}}
{{- include "kubeflow.component.name" (
    list
    (include "kubeflow.tensorboard.controller.baseName" .)
    .
)}}
{{- end }}

{{- define "kubeflow.tensorboard.controller.manager.name" -}}
{{- printf "%s-%s"
    (include "kubeflow.tensorboard.controller.name" .)
    "manager"
}}
{{- end }}

{{- define "kubeflow.tensorboard.controller.kubeRbacProxy.name" -}}
{{- printf "%s-%s"
    (include "kubeflow.tensorboard.controller.name" .)
    "kube-rbac-proxy"
}}
{{- end }}

{{- define "kubeflow.tensorboard.controller.serviceAccountName" -}}
{{- include "kubeflow.component.serviceAccountName"  (
    list
    (include "kubeflow.tensorboard.controller.name" .)
    .Values.tensorboard.controller.serviceAccount
)}}
{{- end }}

{{- define "kubeflow.tensorboard.controller.mainClusterRoleName" -}}
{{- printf "%s-%s"
    (include "kubeflow.fullname" .)
    (include "kubeflow.tensorboard.controller.name" .)
}}
{{- end }}

{{- define "kubeflow.tensorboard.controller.mainClusterRoleBindingName" -}}
{{- include "kubeflow.tensorboard.controller.mainClusterRoleName" . }}
{{- end }}

{{- define "kubeflow.tensorboard.controller.leaderElectionRoleName" -}}
{{- printf "%s-%s-%s"
    (include "kubeflow.fullname" .)
    (include "kubeflow.tensorboard.controller.name" .)
    "leader-election"
}}
{{- end }}

{{- define "kubeflow.tensorboard.controller.leaderElectionRoleBindingName" -}}
{{- include "kubeflow.tensorboard.controller.leaderElectionRoleName" . }}
{{- end }}

{{- define "kubeflow.tensorboard.controller.metricsReaderClusterRoleName" -}}
{{- printf "%s-%s-%s"
    (include "kubeflow.fullname" .)
    (include "kubeflow.tensorboard.controller.name" .)
    "metrics-reader"
}}
{{- end }}

{{- define "kubeflow.tensorboard.controller.metricsReaderClusterRoleBindingName" -}}
{{- include "kubeflow.tensorboard.controller.metricsReaderClusterRoleName" . }}
{{- end }}

{{- define "kubeflow.tensorboard.controller.proxyClusterRoleName" -}}
{{- printf "%s-%s-%s"
    (include "kubeflow.fullname" .)
    (include "kubeflow.tensorboard.controller.name" .)
    "proxy"
}}
{{- end }}

{{- define "kubeflow.tensorboard.controller.proxyClusterRoleBindingName" -}}
{{- include "kubeflow.tensorboard.controller.proxyClusterRoleName" . }}
{{- end }}

{{/*
Kubeflow Tensorboard Controller Manager Metrics Service.
*/}}

{{- define "kubeflow.tensorboard.controller.metricsService.svc.name" -}}
{{- printf "%s-%s"
    ( include "kubeflow.component.svc.name" (
        include "kubeflow.tensorboard.controller.name" .
    ))
    "controller-manager-metrics-service"
}}
{{- end }}

{{/*
Kubeflow Tensorboard Controller object labels.
*/}}
{{- define "kubeflow.tensorboard.controller.labels" -}}
{{ include "kubeflow.common.labels" . }}
{{ include "kubeflow.component.labels" (include "kubeflow.tensorboard.name" .) }}
{{ include "kubeflow.component.subcomponent.labels" (include "kubeflow.tensorboard.controller.name" .) }}
{{- end }}

{{- define "kubeflow.tensorboard.controller.selectorLabels" -}}
{{ include "kubeflow.common.selectorLabels" . }}
{{ include "kubeflow.component.selectorLabels" (include "kubeflow.tensorboard.name" .) }}
{{ include "kubeflow.component.subcomponent.labels" (include "kubeflow.tensorboard.controller.name" .) }}
{{- end }}

{{/*
Kubeflow Tensorboard Controller Manager container image settings.
*/}}
{{- define "kubeflow.tensorboard.controller.manager.image" -}}
{{ include "kubeflow.component.image" (
    list
    .Values.defaults.image
    .Values.tensorboard.controller.manager.image
)}}
{{- end }}

{{- define "kubeflow.tensorboard.controller.manager.tensorboardImage" -}}
{{ include "kubeflow.component.image" (
    list
    .Values.defaults.image
    .Values.tensorboard.controller.manager.config.tensorboard.image
)}}
{{- end }}

{{- define "kubeflow.tensorboard.controller.manager.imagePullPolicy" -}}
{{ include "kubeflow.component.imagePullPolicy" (
    list
    .Values.defaults.image
    .Values.tensorboard.controller.manager.image
)}}
{{- end }}

{{/*
Kubeflow Tensorboard Controller Kube RBAC Proxy container image settings.
*/}}
{{- define "kubeflow.tensorboard.controller.kubeRbacProxy.image" -}}
{{ include "kubeflow.component.image" (
    list
    .Values.defaults.image
    .Values.tensorboard.controller.kubeRbacProxy.image
)}}
{{- end }}

{{- define "kubeflow.tensorboard.controller.kubeRbacProxy.imagePullPolicy" -}}
{{ include "kubeflow.component.imagePullPolicy" (
    list
    .Values.defaults.image
    .Values.tensorboard.controller.kubeRbacProxy.image
)}}
{{- end }}

{{/*
Kubeflow Tensorboard Controller Autoscaling and Availability.
*/}}
{{- define "kubeflow.tensorboard.controller.autoscaling.minReplicas" -}}
{{ include "kubeflow.component.autoscaling.minReplicas" (
    list
    .Values.defaults.autoscaling
    .Values.tensorboard.controller.autoscaling
)}}
{{- end }}

{{- define "kubeflow.tensorboard.controller.autoscaling.maxReplicas" -}}
{{ include "kubeflow.component.autoscaling.maxReplicas" (
    list
    .Values.defaults.autoscaling
    .Values.tensorboard.controller.autoscaling
)}}
{{- end }}

{{- define "kubeflow.tensorboard.controller.autoscaling.targetCPUUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetCPUUtilizationPercentage" (
    list
    .Values.defaults.autoscaling
    .Values.tensorboard.controller.autoscaling
)}}
{{- end }}

{{- define "kubeflow.tensorboard.controller.autoscaling.targetMemoryUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetMemoryUtilizationPercentage" (
    list
    .Values.defaults.autoscaling
    .Values.tensorboard.controller.autoscaling
)}}
{{- end }}

{{- define "kubeflow.tensorboard.controller.pdb.values" -}}
{{- include "kubeflow.component.pdb.values" (
    list
    .Values.defaults.podDisruptionBudget
    .Values.tensorboard.controller.podDisruptionBudget
)}}
{{- end }}

{{/*
Kubeflow Tensorboard Controller Security Context.
*/}}
{{- define "kubeflow.tensorboard.controller.manager.containerSecurityContext" -}}
{{ include "kubeflow.component.containerSecurityContext" (
    list
    .Values.defaults.containerSecurityContext
    .Values.tensorboard.controller.manager.containerSecurityContext
)}}
{{- end }}

{{- define "kubeflow.tensorboard.controller.kubeRbacProxy.containerSecurityContext" -}}
{{ include "kubeflow.component.containerSecurityContext" (
    list
    .Values.defaults.containerSecurityContext
    .Values.tensorboard.controller.kubeRbacProxy.containerSecurityContext
)}}
{{- end }}

{{- define "kubeflow.tensorboard.controller.securityContext" -}}
{{ include "kubeflow.component.containerSecurityContext" (
    list
    .Values.defaults.containerSecurityContext
    .Values.tensorboard.controller.securityContext
)}}
{{- end }}

{{/*
Kubeflow Tensorboard Controller Scheduling.
*/}}
{{- define "kubeflow.tensorboard.controller.topologySpreadConstraints" -}}
{{ include "kubeflow.component.topologySpreadConstraints" (
    list
    .Values.defaults.topologySpreadConstraints
    .Values.tensorboard.controller.topologySpreadConstraints
)}}
{{- end }}

{{- define "kubeflow.tensorboard.controller.nodeSelector" -}}
{{ include "kubeflow.component.tolerations" (
    list
    .Values.defaults.nodeSelector
    .Values.tensorboard.controller.nodeSelector
)}}
{{- end }}

{{- define "kubeflow.tensorboard.controller.tolerations" -}}
{{ include "kubeflow.component.tolerations" (
    list
    .Values.defaults.tolerations
    .Values.tensorboard.controller.tolerations
)}}
{{- end }}

{{- define "kubeflow.tensorboard.controller.affinity" -}}
{{ include "kubeflow.component.affinity" (
    list
    .Values.defaults.affinity
    .Values.tensorboard.controller.affinity
)}}
{{- end }}

{{- define "kubeflow.tensorboard.controller.terminationGracePeriodSeconds" -}}
{{ include "kubeflow.component.terminationGracePeriodSeconds" (
    list
    .Values.defaults.terminationGracePeriodSeconds
    .Values.tensorboard.controller.terminationGracePeriodSeconds
)}}
{{- end }}

{{/*
Kubeflow Tensorboard Controller enable and create toggles.
*/}}
{{- define "kubeflow.tensorboard.controller.enabled" -}}
{{- ternary true "" (
    and
    (include "kubeflow.tensorboard.enabled" . | eq "true")
    .Values.tensorboard.controller.enabled
)}}
{{- end }}

{{- define "kubeflow.tensorboard.controller.autoscaling.enabled" -}}
{{ include "kubeflow.component.autoscaling.enabled" (
    list
    .Values.defaults.autoscaling
    .Values.tensorboard.controller.autoscaling
)}}
{{- end }}

{{- define "kubeflow.tensorboard.controller.rbac.createRoles" -}}
{{- ternary true "" (
    and
    (include "kubeflow.tensorboard.controller.enabled" . | eq "true")
    .Values.tensorboard.controller.rbac.create
)}}
{{- end }}

{{- define "kubeflow.tensorboard.controller.createServiceAccount" -}}
{{- ternary true "" (
and
    (include "kubeflow.tensorboard.controller.enabled" . | eq "true")
    .Values.tensorboard.controller.serviceAccount.create
)}}
{{- end }}

{{- define "kubeflow.tensorboard.controller.pdb.create" -}}
{{- include "kubeflow.component.pdb.create" (
    list
    (include "kubeflow.tensorboard.controller.enabled" .)
    .Values.defaults.podDisruptionBudget
    .Values.tensorboard.controller.podDisruptionBudget
)}}
{{- end }}
