{{- define "appdynamics-csaas-k8s-cluster-agent.sensitiveData" -}}
{{- if (get . "data") | required (get . "message") -}}
{{ (get . "data") | trim | b64enc }}
{{- end -}}
{{- end -}}
