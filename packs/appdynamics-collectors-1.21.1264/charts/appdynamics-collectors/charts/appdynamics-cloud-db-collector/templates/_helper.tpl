{{- define "appdynamics-cloud-db-collector.getClusterID" }}
{{ if .Values.global.smartAgentInstall -}}
# If installation is via the smartagent, use the special purpose value to set what is being used by the smartagent.
clusterID: {{ "AGENT_PLATFORM_ID_VALUE" }}
{{ else }}
{{- if (lookup "v1" "Namespace" "" "kube-system").metadata }}
clusterID: {{ required "Could not fetch kube-system uid to populate clusterID! " (lookup "v1" "Namespace" "" "kube-system").metadata.uid }}
{{- else -}}
clusterID: {{ .Values.global.clusterId | required "clusterId needs to be specified when kube-system metadata is not accessible!" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "appdynamics-cloud-db-collector.podConfigs" }}
  image: {{ .image }}
  imagePullPolicy: {{ .imagePullPolicy }}
  resources:
  {{- toYaml .resources | nindent 4 }}
  labels:
  {{- toYaml .labels | nindent 4 }}
  annotations:
  {{- toYaml .annotations | nindent 4 }}
  nodeSelector:
  {{- toYaml .nodeSelector | nindent 4 }}
  imagePullSecrets:
  {{- toYaml .imagePullSecrets | nindent 4 }}
  affinity:
  {{- toYaml .affinity | nindent 4 }}
  tolerations:
  {{- toYaml .tolerations | nindent 4 }}
  securityContext:
  {{- toYaml .securityContext | nindent 4 }}
  {{ if .priorityClassName -}}
  priorityClassName: {{ .priorityClassName }}
  {{- end }}
{{- end }}