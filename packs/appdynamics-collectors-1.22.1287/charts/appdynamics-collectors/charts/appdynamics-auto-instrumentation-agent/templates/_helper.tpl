{{- define "appdynamics-auto-instrumentation-agent.sensitiveDataController" -}}
{{ (get . "data") | trim | b64enc | required (get . "message") }}
{{- end -}}
