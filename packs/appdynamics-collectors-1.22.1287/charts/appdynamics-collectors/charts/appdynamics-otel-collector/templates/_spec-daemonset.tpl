{{- define  "appdynamics-otel-collector-daemonset.filelog-receiver.basedefination" -}}
{{- if .var1.Values.enableFileLog }}
receivers:
  filelog:
    poll_interval: 10ms
    include: {{ .var1.Values.filelogReceiverConfig.includeLogsPath }}
    exclude: {{ .var1.Values.filelogReceiverConfig.excludeLogsPath }}
    start_at: beginning
    include_file_path: true
    include_file_name: false
    operators:
      - type: router
        id: get-format
        routes:
          - output: parser-docker
            expr: 'body matches "^\\{"'
      - type: json_parser
        id: parser-docker
        output: extract_metadata_from_filepath
        timestamp:
          parse_from: attributes.time
          layout: '%Y-%m-%dT%H:%M:%S.%LZ'
      - type: move
        from: attributes.log
        to: body
      - type: regex_parser
        id: extract_metadata_from_filepath
        regex: '^.*\/(?P<namespace>[^_]+)_(?P<pod_name>[^_]+)_(?P<uid>[a-f0-9\-]{36})\/(?P<container_name>[^\._]+)\/(?P<restart_count>\d+)\.log$'
        parse_from: attributes["log.file.path"]
      - type: move
        from: attributes.stream
        to: attributes["log.iostream"]
      - type: move
        from: attributes.container_name
        to: resource["k8s.container.name"]
      - type: move
        from: attributes.namespace
        to: resource["k8s.namespace.name"]
      - type: move
        from: attributes.pod_name
        to: resource["k8s.pod.name"]
      - type: move
        from: attributes.restart_count
        to: resource["k8s.container.restart_count"]
      - type: move
        from: attributes.uid
        to: resource["k8s.pod.uid"]
processors:
  resource/filelog:
    attributes:
      - key: telemetry.sdk.name
        action: upsert
        value: "log-agent"
      - key: k8s.cluster.id
        action: upsert
        value: {{ (include "appdynamics-otel-collector.clusterId" .var1) | quote}}
      - key: source.name
        action: upsert
        value: "log-agent"
      - key: k8s.cluster.name
        action: upsert
        value: {{ (include "appdynamics-otel-collector.cluster.name" .var1) | quote}}
      - key: _message_parser.pattern
        action: upsert
        value: {{ .var1.Values.filelogReceiverConfig.messageParserPattern | quote }}
      - key: _message_parser.type
        action: upsert
        value: {{ .var1.Values.filelogReceiverConfig.messageParserType | quote }}
      - key: log_sender
        action: upsert
        value: "AppD_filelog_recevier"
      - key: host.name
        action: delete
      - key: cloud.provider
        action: delete
      - key: cloud.platform
        action: delete
      - key: cloud.region
        action: delete
      - key: cloud.account.id
        action: delete
      - key: cloud.availability_zone
        action: delete
      - key: host.image.id
        action: delete
      - key: host.type
        action: delete
      - key: host.name
        action: delete
  resourcedetection:
    detectors: ["ec2", "system"]
    system:
      hostname_sources: ["os", "cname", "lookup", "dns"]
  transform/filelog:
    log_statements:
      - context: resource
        statements:
          - set(attributes["internal.container.encapsulating_object_id"],Concat([attributes["k8s.cluster.id"],attributes["k8s.pod.uid"]],":"))
  k8sattributes/filelog:
    auth_type: "serviceAccount"
    passthrough: false
    {{- if .Values.nodeLocalTrafficMode }}
    filter:
      node_from_env_var: NODE_NAME
    {{- end }}
    extract:
      metadata:
        - k8s.pod.name
        - k8s.pod.uid
        - k8s.deployment.name
        - k8s.namespace.name
        - k8s.node.name
        - k8s.pod.start_time
        - container.id
    pod_association:
      - sources:
          - from: resource_attribute
            name: k8s.pod.uid
service:
  pipelines:
    logs/filelog:
      receivers: [filelog]
      processors: ["memory_limiter","k8sattributes/filelog", "resourcedetection", "resource/filelog","transform/filelog"]
      exporters: [logging, otlphttp]
{{- end }}
{{- end }}

{{/*
  daemonset config
  var1 - global scope
  var2 - computed spec
*/}}
{{- define "appdynamics-otel-collector-daemonset.autoValueConfig" -}}
{{- $mergedConfig :=  (include "appdynamics-otel-collector.autoValueConfig" . | fromYaml ) }}
{{- $mergedConfig :=  mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector-daemonset.filelog-receiver.basedefination" . | fromYaml ) }}
{{- $mergedConfig :=  mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector.agentManagementModeConfig" (dict "mode" "daemonset" "var1" .var1) | fromYaml ) }}
{{- if .var1.Values.mode.daemonset.configOverride }}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (deepCopy .var1.Values.mode.daemonset.configOverride)}}
{{- end }}
{{- toYaml $mergedConfig }}
{{- end }}

{{- define "appdynamics-otel-collector-daemonset.valueVarLogVolumeMounts" -}}
name: {{.name}}
mountPath: {{.mountPath}}
{{- end }}
{{- define "appdynamics-otel-collector-daemonset.valueVarLogVolume" -}}
name: {{.name}}
hostPath:
  path: {{.path}}
{{- end }}

{{- define "appdynamics-otel-collector-daemonset.valueVarLogVolumeSpec" -}}
{{- if .Values.enableFileLog }}
podSecurityContext:
  runAsUser: 10001
  runAsGroup: 0
{{- $specVolumeMounts := get .spec "volumeMounts" | deepCopy }}
{{- if not $specVolumeMounts }}
{{- $specVolumeMounts = list }}
{{- end }}
{{- $specVolumeMounts = append $specVolumeMounts  (include "appdynamics-otel-collector-daemonset.valueVarLogVolumeMounts" (dict "name" "varlog" "mountPath" "/var/log") | fromYaml)}}
{{- $specVolumeMounts = append $specVolumeMounts  (include "appdynamics-otel-collector-daemonset.valueVarLogVolumeMounts" (dict "name" "varlibdockercontainers" "mountPath" " /var/lib/docker/containers") | fromYaml)}}
volumeMounts:
{{- $specVolumeMounts | toYaml | nindent 2}}

{{- $specVolume := get .spec "volumes" | deepCopy }}
{{- if not $specVolume }}
{{- $specVolume = list }}
{{- end }}
{{- $specVolume = append $specVolume  (include "appdynamics-otel-collector-daemonset.valueVarLogVolume" (dict "name" "varlog" "path" "/var/log") | fromYaml)}}
{{- $specVolume = append $specVolume  (include "appdynamics-otel-collector-daemonset.valueVarLogVolume" (dict "name" "varlibdockercontainers" "path" "/var/lib/docker/containers") | fromYaml)}}
volumes:
{{- $specVolume | toYaml | nindent 2}}
{{- end }}
{{- end }}

{{/*
  daemonset spec
*/}}
{{- define "appdynamics-otel-collector-daemonset.spec" -}}
{{- $spec := (include "appdynamics-otel-collector.spec" . | fromYaml) }}
{{- $spec := include "appdynamics-otel-collector-daemonset.valueVarLogVolumeSpec" (dict "Values" .Values "spec" $spec) | fromYaml | deepCopy | mustMergeOverwrite $spec }}
{{- $config := include "appdynamics-otel-collector-daemonset.autoValueConfig" (dict "var1" . "var2" $spec) | deepCopy | fromYaml }}
{{- $spec := include "appdynamics-otel-collector.configToYamlString" $config | fromYaml | deepCopy | mustMergeOverwrite $spec }}
{{- $spec := .Values.mode.daemonset.spec | deepCopy | mustMergeOverwrite $spec }}
{{- toYaml $spec }}
{{- end }}