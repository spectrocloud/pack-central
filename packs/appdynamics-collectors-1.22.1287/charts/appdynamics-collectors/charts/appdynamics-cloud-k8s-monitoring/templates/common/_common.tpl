{{- define "appdynamics-cloud-k8s-monitoring.getClusterId" }}
{{- if .Values.global.smartAgentInstall -}}
{{ "AGENT_PLATFORM_ID_VALUE" }}
{{- else -}}
{{- if (lookup "v1" "Namespace" "" "kube-system").metadata }}
{{- required "Could not fetch kube-system uid to populate clusterID! " (lookup "v1" "Namespace" "" "kube-system").metadata.uid }}
{{- else -}}
{{- .Values.global.clusterId | required "clusterId needs to be specified when kube-system metadata is not accessible!" }}
{{- end }}
{{- end }}
{{- end }}

