{{- define "auto-instrumentation.http.endpoint" -}}
{{- if not .Values.instrumentation.insecure -}}
"https://appdynamics-otel-collector-service.appdynamics.svc.cluster.local:4318"
{{- else -}}
"http://appdynamics-otel-collector-service.appdynamics.svc.cluster.local:4318"
{{- end -}}
{{- end }}

{{- define "auto-instrumentation.grpc.endpoint" -}}
{{- if not .Values.instrumentation.insecure -}}
"https://appdynamics-otel-collector-service.appdynamics.svc.cluster.local:4317"
{{- else -}}
"http://appdynamics-otel-collector-service.appdynamics.svc.cluster.local:4317"
{{- end -}}
{{- end }}

{{- define "auto-instrumentation.exporter" -}}
{{- if not (.Values.instrumentation.spec.exporter).endpoint }}
exporter:
    endpoint: {{ include "auto-instrumentation.grpc.endpoint" . }}
{{- end }}
{{- end }}

{{/* 
  Append auto generated env to spec
*/}}
{{- define "auto-instrumentation.appendEnv" -}}
{{- $spec := get .Values.instrumentation "spec" }}
{{- $specEnv := get $spec "env" | deepCopy }}
{{- if not $specEnv }}
{{- $specEnv = list }}
{{- end }}
{{- $specEnv = append $specEnv (dict "name" "OTEL_EXPORTER_OTLP_INSECURE" "value" (.Values.instrumentation.insecure | quote)) }}
env:
{{- $specEnv | toYaml | nindent 2}}
{{- end }}

{{/* 
  Append auto generated env to python, the only one need http instead of grpc
*/}}
{{- define "auto-instrumentation.python.appendEnv" -}}
{{- $python := get .Values.instrumentation.spec "python" }}
{{- $pythonEnv := get $python "env" | deepCopy }}
{{- if not $pythonEnv }}
{{- $pythonEnv = list }}
{{- end }}
{{- $pythonEnv = append $pythonEnv (dict "name" "OTEL_EXPORTER_OTLP_TRACES_ENDPOINT" "value" (include "auto-instrumentation.http.endpoint" .)) }}
{{- $pythonEnv = append $pythonEnv (dict "name" "OTEL_TRACES_EXPORTER" "value" "otlp_proto_http") }}
python:
  env:
{{- $pythonEnv | toYaml | nindent 4}}
{{- end }}

{{- define "auto-instrumentation.spec" -}}
{{- $spec := .Values.instrumentation.spec | deepCopy }}
{{- $spec := include "auto-instrumentation.exporter" . | fromYaml | deepCopy | mustMergeOverwrite $spec }}
{{- $spec := include "auto-instrumentation.appendEnv" . | fromYaml | deepCopy | mustMergeOverwrite $spec }}
{{- $spec := include "auto-instrumentation.python.appendEnv" . | fromYaml | deepCopy | mustMergeOverwrite $spec }}
{{- toYaml $spec }}
{{- end }}

{{- define "auto-instrumentation.inst" -}}
metadata:
  name: {{ .var1.Values.instrumentation.metadata.name }}
  namespace: {{ .var2 }}
  labels:
{{- (include "appdynamics-otel-collector.labels" .var1) | nindent 4}}
spec:
{{- (include "auto-instrumentation.spec" .var1) | nindent 2 }}
{{- end }}

{{- define "auto-instrumentation.namespaces.inst" -}}
{{- $result := dict }}
{{- $global := . }}
{{- range $key, $value := .Values.instrumentation.namespaces }}
{{- $value = (include "auto-instrumentation.inst" (dict "var1" $global "var2" $key)) | fromYaml | deepCopy | merge ($value | toYaml | fromYaml) }}
{{- $_ := set $result $key $value }}
{{- end }}
{{- toYaml $result }}
{{- end }}
