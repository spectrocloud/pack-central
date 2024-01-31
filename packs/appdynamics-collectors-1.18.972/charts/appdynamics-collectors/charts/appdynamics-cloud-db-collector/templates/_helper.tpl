{{- define "getClusterID" }}
{{- if (lookup "v1" "Namespace" "" "kube-system").metadata }}
clusterID: {{ required "Could not fetch kube-system uid to populate clusterID! " (lookup "v1" "Namespace" "" "kube-system").metadata.uid }}
{{- else -}}
clusterID: {{ .Values.global.clusterId | required "clusterId needs to be specified when kube-system metadata is not accessible!" }}
{{- end }}
{{- end }}