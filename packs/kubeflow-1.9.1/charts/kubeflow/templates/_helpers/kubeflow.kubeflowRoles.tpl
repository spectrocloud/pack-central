{{- define "kubeflow.roles.baseName" -}}
{{- print "kubeflow-roles" }}
{{- end }}

{{- define "kubeflow.roles.name" -}}
{{- include "kubeflow.component.name" (
    list
    (include "kubeflow.roles.baseName" .)
    .
)}}
{{- end }}

{{- define "kubeflow.kubeflowRoles.labels" -}}
{{ include "kubeflow.common.labels" . }}
{{ include "kubeflow.component.labels" (include "kubeflow.roles.name" .) }}
{{- end }}

{{/*
Kubeflow Main Role Names.
*/}}
{{- define "kubeflow.kubeflowRoles.kubeflowAdminRoleName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) "admin" }}
{{- end }}

{{- define "kubeflow.kubeflowRoles.kubeflowEditRoleName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) "edit" }}
{{- end }}

{{- define "kubeflow.kubeflowRoles.kubeflowViewRoleName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) "view" }}
{{- end }}


{{/*
Kubeflow Kubernetes Role Names.
*/}}
{{- define "kubeflow.kubeflowRoles.kubernetesAdminRoleName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) "kubernetes-admin" }}
{{- end }}

{{- define "kubeflow.kubeflowRoles.kubernetesEditRoleName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) "kubernetes-edit" }}
{{- end }}

{{- define "kubeflow.kubeflowRoles.kubernetesViewRoleName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) "kubernetes-view" }}
{{- end }}

{{/*
Kubeflow Pipelines Role Names.
*/}}
{{- define "kubeflow.kubeflowRoles.kubeflowPipelinesAdminRoleName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) "pipelines-admin" }}
{{- end }}

{{- define "kubeflow.kubeflowRoles.kubeflowPipelinesEditRoleName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) "pipelines-edit" }}
{{- end }}

{{- define "kubeflow.kubeflowRoles.kubeflowPipelinesViewRoleName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) "pipelines-view" }}
{{- end }}

{{- define "kubeflow.kubeflowRoles.aggregateToKubeflowPipelinesEditRoleName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) "aggregate-pipelines-edit" }}
{{- end }}

{{- define "kubeflow.kubeflowRoles.aggregateToKubeflowPipelinesViewRoleName" -}}
{{- printf "%s-%s" (include "kubeflow.fullname" .) "aggregate-pipelines-view" }}
{{- end }}

{{/*
    ###################################
    ### Role Aggreation Rule Labels ###
    ###################################
*/}}

{{/*
Kubeflow Main Role Labels.
*/}}
{{- define "kubeflow.kubeflowRoles.kubeflowAdminRoleLabel" -}}
{{- include "kubeflow.aggregationRule.labelBase" (include "kubeflow.kubeflowRoles.kubeflowAdminRoleName" .) -}}
{{- end }}

{{- define "kubeflow.kubeflowRoles.kubeflowEditRoleLabel" -}}
{{- include "kubeflow.aggregationRule.labelBase" (include "kubeflow.kubeflowRoles.kubeflowEditRoleName" .) -}}
{{- end }}

{{- define "kubeflow.kubeflowRoles.kubeflowViewRoleLabel" -}}
{{- include "kubeflow.aggregationRule.labelBase" (include "kubeflow.kubeflowRoles.kubeflowViewRoleName" .) -}}
{{- end }}

{{/*
Kubeflow Kubernetes Role Labels.
*/}}
{{- define "kubeflow.kubeflowRoles.kubernetesAdminRoleLabel" -}}
{{- include "kubeflow.aggregationRule.labelBase" (include "kubeflow.kubeflowRoles.kubernetesAdminRoleName" .) -}}
{{- end }}

{{- define "kubeflow.kubeflowRoles.kubernetesEditRoleLabel" -}}
{{- include "kubeflow.aggregationRule.labelBase" (include "kubeflow.kubeflowRoles.kubernetesEditRoleName" .) -}}
{{- end }}

{{- define "kubeflow.kubeflowRoles.kubernetesViewRoleLabel" -}}
{{- include "kubeflow.aggregationRule.labelBase" (include "kubeflow.kubeflowRoles.kubernetesViewRoleName" .) -}}
{{- end }}

{{/*
Kubeflow Pipelines Role Labels.
*/}}
{{- define "kubeflow.kubeflowRoles.kubeflowPipelinesAdminRoleLabel" -}}
{{- include "kubeflow.aggregationRule.labelBase" (include "kubeflow.kubeflowRoles.kubeflowPipelinesAdminRoleName" .) -}}
{{- end }}

{{- define "kubeflow.kubeflowRoles.kubeflowPipelinesEditRoleLabel" -}}
{{- include "kubeflow.aggregationRule.labelBase" (include "kubeflow.kubeflowRoles.kubeflowPipelinesEditRoleName" .) -}}
{{- end }}

{{- define "kubeflow.kubeflowRoles.kubeflowPipelinesViewRoleLabel" -}}
{{- include "kubeflow.aggregationRule.labelBase" (include "kubeflow.kubeflowRoles.kubeflowPipelinesViewRoleName" .) -}}
{{- end }}