{{- define "csm-operator.powermax" -}}
  {{- if eq .lookup "driver-config" }}v2.10.0{{ end }}
  {{- if eq .lookup "driver-image" }}v2.10.0{{ end }}
  {{- if eq .lookup "module-csirevprx-config" }}v2.9.0{{ end }}
  {{- if eq .lookup "module-csirevprx-image" }}v2.9.0{{ end }}
  {{- if eq .lookup "module-auth-config" }}v1.10.0{{ end }}
  {{- if eq .lookup "module-auth-image" }}v1.10.0{{ end }}
  {{- if eq .lookup "module-repl-image-replicator" }}v1.8.0{{ end }}
  {{- if eq .lookup "module-repl-image-controller" }}v1.8.0{{ end }}
  {{- if eq .lookup "module-obsv-config" }}v1.8.0{{ end }}
  {{- if eq .lookup "module-obsv-image" }}v1.8.0{{ end }}
  {{- if eq .lookup "module-metrics-image" }}v1.3.0{{ end }}
{{- end }}

{{- define "csm-operator.powerflex" -}}
  {{- if eq .lookup "driver-config" }}v2.10.0{{ end }}
  {{- if eq .lookup "driver-image" }}v2.10.0{{ end }}
  {{- if eq .lookup "module-auth-config" }}v1.10.0{{ end }}
  {{- if eq .lookup "module-auth-image" }}v1.10.0{{ end }}
  {{- if eq .lookup "module-obsv-config" }}v1.8.0{{ end }}
  {{- if eq .lookup "module-obsv-image" }}v1.8.0{{ end }}
  {{- if eq .lookup "module-metrics-image" }}v1.8.0{{ end }}
  {{- if eq .lookup "module-repl-config" }}v1.8.0{{ end }}
  {{- if eq .lookup "module-repl-image-replicator" }}v1.8.0{{ end }}
  {{- if eq .lookup "module-repl-image-controller" }}v1.8.0{{ end }}
  {{- if eq .lookup "module-resiliency-config" }}v1.9.0{{ end }}
  {{- if eq .lookup "module-resiliency-image-podmon" }}v1.9.0{{ end }}
{{- end }}

{{- define "csm-operator.powerstore" -}}
  {{- if eq .lookup "driver-config" }}v2.10.0{{ end }}
  {{- if eq .lookup "driver-image" }}v2.10.0{{ end }}
  {{- if eq .lookup "module-resiliency-config" }}v1.9.0{{ end }}
  {{- if eq .lookup "module-resiliency-image-podmon" }}v1.9.0{{ end }}
{{- end }}
