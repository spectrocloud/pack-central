{{- define "sensitiveData" -}}
{{ (get . "data") | trim | b64enc | required (get . "message") }}
{{- end -}}

{{- define "podConfigs" }}
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
{{- end }}

{{- define "osNodeSelector" }}
nodeSelector:
  kubernetes.io/os: {{ . }}
{{- end }}

{{- define "getClusterID" }}
{{- if (lookup "v1" "Namespace" "" "kube-system").metadata }}
clusterID: {{ required "Could not fetch kube-system uid to populate clusterID! " (lookup "v1" "Namespace" "" "kube-system").metadata.uid }}
{{- else -}}
clusterID: {{ .Values.global.clusterId | required "clusterId needs to be specified when kube-system metadata is not accessible!" }}
{{- end }}
{{- end }}


{{- define "conditionalAppD"}}
conditionalConfigs:
  - condition:
      or:
        - contains:
            kubernetes.container.name: logcollector-agent
        - contains:
            kubernetes.container.name: inframon
        - contains:
            kubernetes.container.name: clustermon
        - contains:
            kubernetes.container.name: otc-container
        - contains:
            kubernetes.pod.name: cloud-operator
        - contains:
            kubernetes.pod.name: opentelemetry-operator
        - contains:
            kubernetes.container.name: fso-agent-mgmt-client
    config:
      messageParser:
        timestamp:
          enabled: true
          format: ABSOLUTE
{{- end }}


{{- define "filebeatYml" }}
{{- $clusterName := .Values.global.clusterName }}
{{- $clusterId := "" }}
{{- if (lookup "v1" "Namespace" "" "kube-system").metadata }}
{{- $clusterId = (lookup "v1" "Namespace" "" "kube-system").metadata.uid | required "Could not fetch kube-system uid to populate clusterID! " }}
{{- else }}
{{- $clusterId = .Values.global.clusterId | required "clusterId needs to be specified when kube-system metadata is not accessible!" }}
{{- end }}
{{- $lcaImageParts := split ":" .Values.logCollectorPod.image}}
{{- $lcaVersion := $lcaImageParts._1}}
{{- $osVal := .osVal }}
{{- $linux := "linux" }}
{{- $windows := "windows" }}
{{- $container:= deepCopy .Values.logCollectorConfig.container}}
{{- $osContainer:= index .Values.logCollectorConfig.env $osVal "container"}}
{{- $containerConfig:= mustMergeOverwrite  $container $osContainer}}
{{- if and ($osContainer) (index $container "defaultConfig")  }}
{{- $osMessageParser:= index $osContainer "defaultConfig" "messageParser"}}
{{- $_:= set $containerConfig.defaultConfig "messageParser" (coalesce $osMessageParser $containerConfig.defaultConfig.messageParser) }}
{{- end }}
{{- if ( $containerConfig.monitorCollectors)}}
{{- $_:=set $containerConfig "conditionalConfigs" (concat $containerConfig.conditionalConfigs (include "conditionalAppD" .| fromYaml).conditionalConfigs) }}
{{- end }}
filebeat.autodiscover:
  providers:
    - type: kubernetes
      node: ${NODE_NAME}
      labels.dedot: false
      annotations.dedot: false
      hints.enabled: true
      {{- if (and $containerConfig.defaultConfig $containerConfig.defaultConfig.enabled )}}
      {{- with $containerConfig.defaultConfig}}
      hints.default_config:
        enabled: true
        type: filestream
        id: fsid-${data.kubernetes.pod.name}-${data.kubernetes.container.id}
        close_removed: false
        clean_removed: false
        paths:
          {{- if eq $osVal $linux }}
          - /var/log/containers/${data.kubernetes.pod.name}*${data.kubernetes.container.id}.log
          {{- end }}
          {{- if eq $osVal $windows }}
          - C:/var/log/containers/${data.kubernetes.pod.name}*${data.kubernetes.container.id}.log
          {{- end }}
        parsers:
          - container:
              stream: all
              format: auto
          {{- if .multiLinePattern}}
          - multiline:
              type: pattern
              pattern: {{.multiLinePattern | quote}}
              {{- if .multiLineNegate}}
              negate: {{.multiLineNegate}}
              {{- end}}
              match: {{ required "\"multiLineMatch\" field is mandatory, if \"multiLinePattern\" is set." .multiLineMatch }}
          {{- end}}
        prospector.scanner.symlinks: true
        prospector.scanner.exclude_files : [".*(((log)-(collector))|(inframon)|(clustermon)|((otel)-(collect))|((cloud)-(operator))|((opentelemetry)-(operator))|((kube)-)|((fso)-(agent)-(mgmt)))+.*log"]
        processors:
          {{- if .logFormat}}
          - add_fields:
              target: appd
              fields:
                log.format: {{ .logFormat }}
          {{- end}}
          {{- with .messageParser }}
          {{- if .log4J}}
          {{- if .log4J.enabled}}
          - add_fields:
              target: _message_parser
              fields:
                type: log4j
                pattern: {{.log4J.pattern | quote}}
          {{- end}}
          {{- end}}
          {{- if .logback}}
          {{- if .logback.enabled}}
          - add_fields:
              target: _message_parser
              fields:
                type: logback
                pattern: {{.logback.pattern | quote}}
          {{- end}}
          {{- end}}
          {{- if .json}}
          {{- if .json.enabled}}
          {{- with .json}}
          - add_fields:
              target: _message_parser
              fields:
                type: json
                timestamp_field: {{if .timestampField}}{{.timestampField | quote}}{{end}}
                timestamp_pattern: {{if .timestampPattern}}{{.timestampPattern | quote}}{{else}}"yyyy-MM-dd HH:mm:ss,SSS"{{end}}
                {{if .flattenSep}}flatten_sep: {{.flattenSep | quote}}{{end}}
                {{if .fieldsToIgnore}}fields_to_ignore: {{$first := true}}"{{range .fieldsToIgnore}}{{if $first}}{{$first = false}}{{else}},{{end}}{{.}}{{end}}"{{end}}
                {{if .fieldsToIgnore}}fields_to_ignore_sep: ","{{end}}
                {{if .fieldsToIgnoreRegex}}fields_to_ignore_regex: {{.fieldsToIgnoreRegex | quote}}{{end}}
                {{if .maxNumOfFields}}max_num_of_fields: {{.maxNumOfFields}}{{end}}
                {{if .maxDepth}}max_depth: {{.maxDepth}}{{end}}
          {{- end}}
          {{- end}}
          {{- end}}
          {{- if not (or (and .logback .logback.enabled) (and .json .json.enabled) (and .log4J .log4J.enabled) (and .grok .grok.enabled) (and .infra .infra.enabled)) }}
          {{- if .timestamp}}
          {{- if .timestamp.enabled}}
          - add_fields:
              target: _message_parser
              fields:
                type: timestamp
                format: {{.timestamp.format | quote}}
                scan: "true"
          {{- end}}
          {{- end}}
          {{- end}}
          {{- if .grok}}
          {{- if .grok.enabled}}
          - add_fields:
              target: _message_parser
              fields:
                type: grok
                pattern:
                {{- range .grok.patterns}}
                  - {{. | quote}}
                {{- end}}
                timestamp_field: {{if .grok.timestampField}}{{.grok.timestampField}}{{end}}
                timestamp_format: {{if .grok.timestampPattern}}{{.grok.timestampPattern | quote}}{{else}}"yyyy-MM-dd HH:mm:ss,SSS"{{end}}
          {{- end}}
          {{- end}}
          {{- if .infra}}
          {{- if .infra.enabled}}
          - add_fields:
              target: _message_parser
              fields:
                type: infra
          {{- end}}
          {{- end}}
          {{- if .multi}}
          {{- if .multi.enabled}}
          - add_fields:
              target: _message_parser
              fields:
                type: multi
                parsers: {{.multi.parsers | quote}}
          {{- end}}
          {{- end}}
          {{- if .grok}}
          {{- if and (.grok.enabled) (.subparsers)}}
          - add_fields:
              target: _message_parser
              fields:
                subparsers: {{.subparsers | quote}}
          {{- end}}
          {{- end}}
          {{- end}}
      {{- end}}
      {{- else}}
      hints.default_config.enabled: false
      {{- end}}
      templates:
        {{- range $containerConfig.conditionalConfigs}}
        - condition:
          {{- if .condition}}
          {{- if .condition.operator}}
            {{.condition.operator}}:
              {{.condition.key}}: {{.condition.value}}
          {{- else}}
            {{ .condition | toYaml | indent 14 | trim }}
          {{- end}}
          {{- end}}
          config:
            {{- if .config}}
            {{- with .config}}
            - type: filestream
              id: fsid-${data.kubernetes.pod.name}-${data.kubernetes.container.id}
              close_removed: false
              clean_removed: false
              paths:
                {{- if eq $osVal $linux }}
                - /var/log/containers/${data.kubernetes.pod.name}*${data.kubernetes.container.id}.log
                {{- end }}
                {{- if eq $osVal $windows }}
                - C:/var/log/containers/${data.kubernetes.pod.name}*${data.kubernetes.container.id}.log
                {{- end}}
              parsers:
                - container:
                    stream: all
                    format: auto
                {{- if .multiLinePattern}}
                - multiline:
                    type: pattern
                    pattern: {{.multiLinePattern | quote}}
                    {{- if .multiLineNegate}}
                    negate: {{.multiLineNegate}}
                    {{- end}}
                    match: {{ required "\"multiLineMatch\" field is mandatory, if \"multiLinePattern\" is set." .multiLineMatch }}
                {{- end}}
              prospector.scanner.symlinks: true
              processors:
            {{- if .logFormat}}
                - add_fields:
                    target: appd
                    fields:
                        log.format: {{ .logFormat }}
            {{- end}}
                {{- with .messageParser }}
                {{- if .log4J}}
                {{- if .log4J.enabled}}
                - add_fields:
                    target: _message_parser
                    fields:
                      type: log4j
                      pattern: {{.log4J.pattern | quote}}
                {{- end}}
                {{- end}}
                {{- if .logback}}
                {{- if .logback.enabled}}
                - add_fields:
                    target: _message_parser
                    fields:
                      type: logback
                      pattern: {{.logback.pattern | quote}}
                {{- end}}
                {{- end}}
                {{- if .json}}
                {{- if .json.enabled}}
                {{- with .json}}
                - add_fields:
                    target: _message_parser
                    fields:
                      type: json
                      timestamp_field: {{if .timestampField}}{{.timestampField | quote}}{{end}}
                      timestamp_pattern: {{if .timestampPattern}}{{.timestampPattern | quote}}{{else}}"yyyy-MM-dd HH:mm:ss,SSS"{{end}}
                      {{if .flattenSep}}flatten_sep: {{.flattenSep | quote}}{{end}}
                      {{if .fieldsToIgnore}}fields_to_ignore: {{$first := true}}"{{range .fieldsToIgnore}}{{if $first}}{{$first = false}}{{else}},{{end}}{{.}}{{end}}"{{end}}
                      {{if .fieldsToIgnore}}fields_to_ignore_sep: ","{{end}}
                      {{if .fieldsToIgnoreRegex}}fields_to_ignore_regex: {{.fieldsToIgnoreRegex | quote}}{{end}}
                      {{if .maxNumOfFields}}max_num_of_fields: {{.maxNumOfFields}}{{end}}
                      {{if .maxDepth}}max_depth: {{.maxDepth}}{{end}}
                {{- end}}
                {{- end}}
                {{- end}}
                {{- if .timestamp}}
                {{- if .timestamp.enabled}}
                - add_fields:
                    target: _message_parser
                    fields:
                      type: timestamp
                      format: {{.timestamp.format | quote}}
                      scan: "true"
                {{- end}}
                {{- end}}
                {{- if .grok}}
                {{- if .grok.enabled}}
                - add_fields:
                    target: _message_parser
                    fields:
                      type: grok
                      pattern:
                       {{- range .grok.patterns}}
                        - {{. | quote}}
                       {{- end}}
                      timestamp_field: {{if .grok.timestampField}}{{.grok.timestampField}}{{end}}
                      timestamp_format: {{if .grok.timestampPattern}}{{.grok.timestampPattern | quote}}{{else}}"yyyy-MM-dd HH:mm:ss,SSS"{{end}}
                {{- end}}
                {{- end}}
                {{- if .infra}}
                {{- if .infra.enabled}}
                - add_fields:
                    target: _message_parser
                    fields:
                      type: infra
                {{- end}}
                {{- end}}
                {{- if .multi}}
                {{- if .multi.enabled}}
                - add_fields:
                    target: _message_parser
                    fields:
                      type: multi
                      parsers: {{.multi.parsers | quote}}
                {{- end}}
                {{- end}}
                {{- if .grok}}
                {{- if and (.grok.enabled) (.subparsers) }}
                - add_fields:
                    target: _message_parser
                    fields:
                      subparsers: {{.subparsers | quote}}
                {{- end}}
                {{- end}}
                {{- end}}
            {{- end}}
            {{- end}}
        {{- end}}
{{- with $containerConfig }}
processors:
  - add_cloud_metadata: ~
  - add_kubernetes_metadata:
      in_cluster: true
      host: ${NODE_NAME}
      matchers:
        - logs_path:
            {{- if eq $osVal $linux }}
            logs_path: "/var/log/containers/"
            {{- end }}
            {{- if eq $osVal $windows }}
            logs_path: "C:/ProgramData/docker/containers/"
            {{- end }}
  - copy_fields:
      fields:
        - from: "kubernetes.deployment.name"
          to: "kubernetes.workload.name"
        - from: "kubernetes.daemonset.name"
          to: "kubernetes.workload.name"
        - from: "kubernetes.statefulset.name"
          to: "kubernetes.workload.name"
        - from: "kubernetes.replicaset.name"
          to: "kubernetes.workload.name"
        - from: "kubernetes.cronjob.name"
          to: "kubernetes.workload.name"
        - from: "kubernetes.job.name"
          to: "kubernetes.workload.name"
      fail_on_error: false
      ignore_missing: true
  {{- if .excludeCondition}}
  - drop_event:
      when:
        {{ .excludeCondition | toYaml | indent 10 | trim }}
  {{- end}}
  - rename:
      fields:
        - from: "kubernetes.namespace"
          to: "kubernetes.namespace.name"
        - from: "kubernetes"
          to: "k8s"
        - from: k8s.annotations.appdynamics.lca/filebeat.parser
          to: "_message_parser"
        - from: "cloud.instance.id"
          to: "host.id"
      ignore_missing: true
      fail_on_error: false
  - add_fields:
      target: k8s
      fields:
        cluster.name: {{ $clusterName }}
  - add_fields:
      target: k8s
      fields:
        cluster.id: {{ $clusterId }}
  - add_fields:
      target: source
      fields:
        name: log-agent
  - add_fields:
      target: telemetry
      fields:
        sdk.name: log-agent
  - add_fields:
      target: os
      fields:
        type: {{ $osVal }}
  - script:
      lang: javascript
      source: >
        function process(event) {
          var podUID = event.Get("k8s.pod.uid");
          if (podUID) {
            event.Put("internal.container.encapsulating_object_id", "{{ $clusterId }}:" + podUID);
          }
          return event;
        }
  - drop_fields:
      {{- if .dropFields}}
      fields: [{{range .dropFields}}{{. | quote}}, {{end}}]
      {{- else}}
      fields: ["agent", "stream", "ecs", "input", "orchestrator", "k8s.annotations.appdynamics", "k8s.labels", "k8s.node.labels", "cloud"]
      {{- end}}
      ignore_missing: true
output.otlploggrpc:
  include_resources:
    - k8s
    - source
    - host
    - container
    - log
    - telemetry
    - internal
    - os
  # using the separate LCA logs pipeline's OTLP GRPC receiver port (14317)
  hosts: ["${APPD_OTELCOL_GRPC_RECEIVER_HOST}:14317"]
  worker: {{.worker}}
  max_bytes: {{.maxBytes}}
  #hosts: ["otel-collector-local-service.appdynamics.svc.cluster.local:8080"]
  {{- with $.Values.global.tls.appdCollectors }}
  ssl.enabled: {{.enabled}}
  {{- if .enabled}}
  {{- if eq $osVal $linux }}
  ssl.certificate_authorities: ["/opt/appdynamics/certs/ca/ca.pem"]
  ssl.certificate: "/opt/appdynamics/certs/client/client.pem"
  ssl.key: "/opt/appdynamics/certs/client/client-key.pem"
  {{- end }}
  {{- if eq $osVal $windows }}
  ssl.certificate_authorities: ["C:/filebeat/certs/ca/ca.pem"]
  ssl.certificate: "C:/filebeat/certs/client/client.pem"
  ssl.key: "C:/filebeat/certs/client/client-key.pem"
  {{- end }}
  {{- end}}
  {{- end}}
  wait_for_ready: true
  batch_size: {{.batchSize}}
  summary_debug_logs_interval: {{.summaryDebugLogsInterval}}
filebeat.registry.path: registry1
filebeat.registry.file_permissions: 0640
{{- if eq $osVal $linux }}
path.data: /opt/appdynamics/logcollector-agent/data
{{- end }}
{{- if eq $osVal $windows }}
path.data: C:/ProgramData/filebeat/data
{{- end}}
{{- with .logging}}
logging:
  level: {{.level}}
  {{- with .files}}
  to_files: {{.enabled}}
  files:
    {{- if eq $osVal $linux }}
    path: /opt/appdynamics/logcollector-agent/log
    {{- end }}
    {{- if eq $osVal $windows }}
    path: C:/ProgramData/filebeat/log
    {{- end }}
    name: lca-log
    keepfiles: {{.keepFiles}}
    permissions: 0640
  {{- end}}
  selectors: [{{if .metrics.enabled}}monitoring,{{end}}{{range .selectors}}{{.}},{{end}}]
  {{- with .metrics}}
  metrics:
    enabled: {{.enabled}}
    period: {{.period}}
  {{- end}}
{{- end}}
{{- with .monitoring}}
monitoring:
  enabled: {{.otlpmetric.enabled}}
  {{- if .otlpmetric.enabled}}
  {{- with .otlpmetric}}
  otlpmetric:
    endpoint: {{.endpoint}}
    protocol: {{.protocol}}
    collect_period: {{.collectPeriod}}
    report_period: {{.reportPeriod}}
    resource_attrs:
      k8s.cluster.name: "{{ $clusterName }}"
      k8s.cluster.id: "{{ $clusterId }}"
      k8s.pod.name: "${POD_NAME}"
      k8s.pod.uid: "${POD_UID}"
      service.instance.id: "${POD_UID}"
      service.version: "{{ $lcaVersion}}"
      {{- range .resourceAttrs}}
      {{.key}}: {{.value | quote}}
      {{- end}}
    {{- if (gt (len .metrics) 0)}}
    metrics:
      {{- range .metrics}}
      - {{.}}
      {{- end}}
    {{- end}}
    {{- if .retry.enabled}}
    {{- with .retry}}
    retry:
      enabled: {{.enabled}}
      initial_interval: {{.initialInterval}}
      max_interval: {{.maxInterval}}
      max_elapsed_time: {{.maxElapsedTime}}
    {{- end}}
    {{- end}}
    {{- with $.Values.global.tls.appdCollectors }}
    ssl.enabled: {{.enabled}}
    {{- if .enabled}}
    {{- if eq $osVal $linux }}
    ssl.certificate_authorities: ["/opt/appdynamics/certs/ca/ca.pem"]
    ssl.certificate: "/opt/appdynamics/certs/client/client.pem"
    ssl.key: "/opt/appdynamics/certs/client/client-key.pem"
    {{- end }}
    {{- if eq $osVal $windows }}
    ssl.certificate_authorities: ["C:/filebeat/certs/ca/ca.pem"]
    ssl.certificate: "C:/filebeat/certs/client/client.pem"
    ssl.key: "C:/filebeat/certs/client/client-key.pem"
    {{- end }}
    {{- end}}
    {{- end}}
  {{- end}}
  {{- end}}
{{- end}}
{{- end}}
{{- end}}
