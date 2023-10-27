{{/*
  Prometheus config
*/}}
{{- define "appdynamics-otel-collector-statefulset.prometheusConfig" -}}
{{- if .Values.enablePrometheus }}
receivers:
  prometheus:
    config:
      scrape_configs:
        - job_name: 'prometheus-exporter-endpoints'
          scrape_interval: 60s
          kubernetes_sd_configs:
            - role: endpoints

          relabel_configs:
            - source_labels: [__meta_kubernetes_service_annotation_appdynamics_com_exporter_type]
              action: keep
              regex: (redis|kafka|kafkajmx)
              replacement: $$1
            - source_labels: [__meta_kubernetes_endpoint_ready]
              action: keep
              regex: (.+)
              replacement: $$1
            - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_path]
              action: replace
              target_label: __metrics_path__
              regex: (.+)
              replacement: $$1
            - source_labels: [__address__, __meta_kubernetes_service_annotation_prometheus_io_port]
              action: replace
              target_label: __address__
              regex: ([^:]+)(?::\d+)?;(\d+)
              replacement: $$1:$$2
            - source_labels: [__meta_kubernetes_service_annotation_appdynamics_com_exporter_type]
              action: replace
              target_label: appdynamics_exporter_type
              replacement: $$1
            - source_labels: [__meta_kubernetes_service_annotation_appdynamics_com_kafka_cluster_name]
              action: replace
              target_label: kafka_cluster_name
              replacement: $$1

          metric_relabel_configs:
            - source_labels: [__name__]
              regex: "kafka_(.+)|java_(.+)|redis_blocked_clients|redis_commands_duration_seconds_total|redis_commands_processed_total|redis_commands_total|redis_config_maxclients|redis_connected_clients|redis_connected_slave(.+)|redis_connections_received_total|redis_cpu_sys_children_seconds_total|redis_cpu_sys_seconds_total|redis_cpu_user_children_seconds_total|redis_cpu_user_seconds_total|redis_db_(.+)|redis_(.+)_keys_total|redis_instance_info|redis_keyspace_(.+)|redis_master_last_io_seconds_ago|redis_master_link_up|redis_master_sync_in_progress|redis_mem_fragmentation_ratio|redis_memory_max_bytes|redis_memory_used_bytes|redis_memory_used_dataset_bytes|redis_memory_used_lua_bytes|redis_memory_used_overhead_bytes|redis_memory_used_scripts_bytes|redis_net_(.+)|redis_pubsub_(.+)|redis_rdb_changes_since_last_save|redis_rdb_last_save_timestamp_seconds|redis_rejected_connections_total|redis_slave_info|redis_slowlog_length|redis_up(.*)"
              action: keep
            - source_labels: [__name__]
              regex: "kafka_exporter_build_info|kafka_consumergroup_current_offset|kafka_consumergroup_lag|kafka_topic_partition_current_offset|kafka_topic_partition_in_sync_replica|kafka_topic_partition_leader|kafka_topic_partition_leader_is_preferred|kafka_topic_partition_oldest_offset"
              action: drop

processors:
  groupbyattrs/prometheus:
    keys:
      - appdynamics_exporter_type
  resource/prometheus:
    attributes:
      - key: telemetry.sdk.name
        value: "prometheus"
        action: upsert
      - key: prometheus.exporter_type
        from_attribute: appdynamics_exporter_type
        action: upsert
      - key: appdynamics_exporter_type
        action: delete
      - key: k8s.cluster.name
        value: {{ required "clusterName must be provided when enablePrometheus set to true." .Values.global.clusterName | quote }}
        action: upsert
{{- $clusterId := "" }}
{{- if (lookup "v1" "Namespace" "" "kube-system").metadata }}
{{- $clusterId = required "could not fetch kube-system uid to populate clusterID!" (lookup "v1" "Namespace" "" "kube-system").metadata.uid }}
{{- else }}
{{- $clusterId = required "clusterId needs to be specified when enablePrometheus set to true and kube-system namespace metadata is not accessible." .Values.global.clusterId }}
{{- end }}
      - key: k8s.cluster.id
        value: {{ $clusterId | quote }}
        action: upsert
  metricstransform/prometheus:
    transforms:
      - include: kafka_log_log_size
        match_type: strict
        action: update
        operations:
          - action: aggregate_labels
            label_set: [ kafka_cluster_name,topic ]
            aggregation_type: sum
      - include: kafka_topic_partition_replicas
        match_type: strict
        action: update
        operations:
          - action: aggregate_labels
            label_set: [ kafka_cluster_name,topic ]
            aggregation_type: sum
      - include: kafka_topic_partition_under_replicated_partition
        match_type: strict
        action: update
        operations:
          - action: aggregate_labels
            label_set: [ kafka_cluster_name,topic ]
            aggregation_type: sum

service:
  pipelines:
    metrics/prometheus:
      receivers: [ prometheus ]
      processors: [ memory_limiter, groupbyattrs/prometheus, resource/prometheus, metricstransform/prometheus, batch ]
      exporters: [ otlphttp ]
{{- end }}
{{- end }}

{{/*
  Spec changes for Prometheus config
*/}}
{{- define "appdynamics-otel-collector-statefulset.prometheusSpec" -}}
{{- if .Values.enablePrometheus -}}
targetAllocator:
  enabled: true
  serviceAccount: {{ include "appdynamics-otel-collector.valueTargetAllocatorServiceAccount" . }}
{{- end }}
{{- end }}

{{/*
  statefulset config
  var1 - global scope
  var2 - computed spec
*/}}
{{- define "appdynamics-otel-collector-statefulset.autoValueConfig" -}}
{{- $mergedConfig :=  (include "appdynamics-otel-collector.autoValueConfig" . | fromYaml ) }}
{{- $mergedConfig :=  mustMergeOverwrite $mergedConfig (include "appdynamics-otel-collector-statefulset.prometheusConfig" .var1 | fromYaml) }}
{{- if .var1.Values.mode.statefulset.configOverride }}
{{- $mergedConfig := mustMergeOverwrite $mergedConfig (deepCopy .var1.Values.mode.statefulset.configOverride) }}
{{- end }}
{{- toYaml $mergedConfig }}
{{- end }}

{{/*
  statefulset spec
*/}}
{{- define "appdynamics-otel-collector-statefulset.spec" -}}
{{- $spec := (include "appdynamics-otel-collector.spec" . | fromYaml) }}
{{- $spec := include "appdynamics-otel-collector-statefulset.prometheusSpec" . | fromYaml | deepCopy | mustMergeOverwrite $spec }}
{{- $config := include "appdynamics-otel-collector-statefulset.autoValueConfig" (dict "var1" . "var2" $spec) | deepCopy | fromYaml }}
{{- $spec := include "appdynamics-otel-collector.configToYamlString" $config | fromYaml | deepCopy | mustMergeOverwrite $spec }}
{{- $spec := .Values.mode.statefulset.spec | deepCopy | mustMergeOverwrite $spec }}
{{- toYaml $spec }}
{{- end }}