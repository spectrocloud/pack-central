{{/*
Kubeflow Profiles Controller object names.
TODO: define profilesController.manager, standardize kubeflow.component.name template (and maybe others) to include ctx either as always first or always last.
*/}}
{{- define "kubeflow.profilesController.baseName" -}}
{{- printf "profiles-controller" }}
{{- end }}

{{- define "kubeflow.profilesController.name" -}}
{{- include "kubeflow.component.name" (
    list
    (include "kubeflow.profilesController.baseName" .)
    .
)}}
{{- end }}

{{- define "kubeflow.profilesController.kfam.name" -}}
{{- printf "%s-%s"
    (include "kubeflow.profilesController.name" .)
    "kfam"
}}
{{- end }}


{{- define "kubeflow.profilesController.serviceAccountName" -}}
{{- include "kubeflow.component.serviceAccountName"  (
    list
    (include "kubeflow.profilesController.name" .)
    .Values.profilesController.serviceAccount
)}}
{{- end }}

{{/*
'cluster-admin' role should not be used...
This is the default in kubeflow/manifests and kubeflow/kubeflow.
TODO: use proper cluster role dedicated to profiles-controller.
*/}}
{{- define "kubeflow.profilesController.mainClusterRoleName" -}}
{{- printf "cluster-admin" -}}
{{- end }}


{{- define "kubeflow.profilesController.mainClusterRoleBindingName" -}}
{{- printf "%s-%s"
    (include "kubeflow.fullname" .)
    (include "kubeflow.profilesController.name" .)
}}
{{- end }}

{{- define "kubeflow.profilesController.leaderElectionRoleName" -}}
{{- printf "%s-%s-%s"
    (include "kubeflow.fullname" .)
    (include "kubeflow.profilesController.name" .)
    "leader-election"
}}
{{- end }}

{{- define "kubeflow.profilesController.leaderElectionRoleBindingName" -}}
{{- include "kubeflow.profilesController.leaderElectionRoleName" . }}
{{- end }}

{{- define "kubeflow.profilesController.namespaceLabelsConfigMapName" -}}
{{- printf "%s-%s"
    (include "kubeflow.profilesController.name" .)
    "namespace-labels"
}}
{{- end }}

# ---
{{/*
Kubeflow Profiles Controller Service.
*/}}
{{- define "kubeflow.profilesController.kfam.svc.name" -}}
{{ include "kubeflow.component.svc.name" (
    include "kubeflow.profilesController.kfam.name" .
)}}
{{- end }}

{{- define "kubeflow.profilesController.kfam.svc.addressWithNs" -}}
{{ include "kubeflow.component.svc.addressWithNs"  (
    list
    .
    (include "kubeflow.profilesController.kfam.name" .)
)}}
{{- end }}

{{- define "kubeflow.profilesController.kfam.svc.addressWithSvc" -}}
{{ include "kubeflow.component.svc.addressWithSvc"  (
    list
    .
    (include "kubeflow.profilesController.kfam.name" .)
)}}
{{- end }}

{{- define "kubeflow.profilesController.kfam.svc.fqdn" -}}
{{ include "kubeflow.component.svc.fqdn"  (
    list
    .
    (include "kubeflow.profilesController.kfam.name" .)
)}}
{{- end }}

{{/*
Kubeflow Profiles Controller object labels.
*/}}
{{- define "kubeflow.profilesController.labels" -}}
{{ include "kubeflow.common.labels" . }}
{{ include "kubeflow.component.labels" (include "kubeflow.profilesController.name" .) }}
{{- end }}

{{- define "kubeflow.profilesController.selectorLabels" -}}
{{ include "kubeflow.common.selectorLabels" . }}
{{ include "kubeflow.component.selectorLabels" (include "kubeflow.profilesController.name" .) }}
{{- end }}

{{/*
Kubeflow Profiles Controller container image settings.
*/}}
{{- define "kubeflow.profilesController.manager.image" -}}
{{ include "kubeflow.component.image" (list .Values.defaults.image .Values.profilesController.manager.image) }}
{{- end }}

{{- define "kubeflow.profilesController.kfam.image" -}}
{{ include "kubeflow.component.image" (list .Values.defaults.image .Values.profilesController.kfam.image) }}
{{- end }}

{{- define "kubeflow.profilesController.manager.imagePullPolicy" -}}
{{ include "kubeflow.component.imagePullPolicy" (list .Values.defaults.image .Values.profilesController.manager.image) }}
{{- end }}

{{- define "kubeflow.profilesController.kfam.imagePullPolicy" -}}
{{ include "kubeflow.component.imagePullPolicy" (list .Values.defaults.image .Values.profilesController.kfam.image) }}
{{- end }}

{{/*
Kubeflow Profiles Controller Autoscaling and Availability.
*/}}
{{- define "kubeflow.profilesController.autoscaling.enabled" -}}
{{ include "kubeflow.component.autoscaling.enabled" (
    list
    .Values.defaults.autoscaling
    .Values.profilesController.autoscaling
)}}
{{- end }}

{{- define "kubeflow.profilesController.autoscaling.minReplicas" -}}
{{ include "kubeflow.component.autoscaling.minReplicas" (list .Values.defaults.autoscaling .Values.profilesController.autoscaling) }}
{{- end }}

{{- define "kubeflow.profilesController.autoscaling.maxReplicas" -}}
{{ include "kubeflow.component.autoscaling.maxReplicas" (list .Values.defaults.autoscaling .Values.profilesController.autoscaling) }}
{{- end }}

{{- define "kubeflow.profilesController.autoscaling.targetCPUUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetCPUUtilizationPercentage" (list .Values.defaults.autoscaling .Values.profilesController.autoscaling) }}
{{- end }}

{{- define "kubeflow.profilesController.autoscaling.targetMemoryUtilizationPercentage" -}}
{{ include "kubeflow.component.autoscaling.targetMemoryUtilizationPercentage" (list .Values.defaults.autoscaling .Values.profilesController.autoscaling) }}
{{- end }}

{{- define "kubeflow.profilesController.pdb.values" -}}
{{- include "kubeflow.component.pdb.values" (
    list
    .Values.defaults.podDisruptionBudget
    .Values.profilesController.podDisruptionBudget
)}}
{{- end }}

{{/*
Kubeflow Profiles Controller enable and create toggles.
*/}}
{{- define "kubeflow.profilesController.enabled" -}}
{{- .Values.profilesController.enabled }}
{{- end }}

{{- define "kubeflow.profilesController.createIstioIntegrationObjects" -}}
{{- ternary true "" (
    and
    (include "kubeflow.profilesController.enabled" . | eq "true" )
    .Values.istioIntegration.enabled
)}}
{{- end }}

{{- define "kubeflow.profilesController.rbac.createRoles" -}}
{{- and
    (include "kubeflow.profilesController.enabled" . | eq "true")
    .Values.profilesController.rbac.create }}
{{- end }}

{{- define "kubeflow.profilesController.createServiceAccount" -}}
{{- and
    (include "kubeflow.profilesController.enabled" . | eq "true")
    .Values.profilesController.serviceAccount.create
}}
{{- end }}

{{- define "kubeflow.profilesController.pdb.create" -}}
{{- include "kubeflow.component.pdb.create" (
    list
    (include "kubeflow.profilesController.enabled" .)
    .Values.defaults.podDisruptionBudget
    .Values.profilesController.podDisruptionBudget
)}}
{{- end }}
