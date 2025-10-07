{{ define "istio.authorizationPolicy" }}
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: "{{ .name }}"
  namespace: "{{ .namespace }}"
spec:
  action: "{{ default "ALLOW" .action }}"
  rules:
    - {}
  selector:
    matchLabels:
      {{- toYaml .labels | nindent 6 -}}
{{- end}}
