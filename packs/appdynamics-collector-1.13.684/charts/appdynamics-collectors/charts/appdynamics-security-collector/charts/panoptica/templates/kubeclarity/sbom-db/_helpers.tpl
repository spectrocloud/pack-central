{{- define "sbom-db.name" -}}
{{- "kubeclarity-sbom-db" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "sbom-db.fullname" -}}
{{- "kubeclarity-sbom-db" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "sbom-db.labels" -}}
helm.sh/chart: {{ include "panoptica.chart" . }}
{{ include "sbom-db.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.global.extraLabels }}
{{ toYaml $.Values.global.extraLabels }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "sbom-db.selectorLabels" -}}
app.kubernetes.io/name: {{ include "sbom-db.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "sbom-db.serviceAccountName" -}}
{{- if .Values.sbomDb.serviceAccount.create }}
{{- default (include "sbom-db.fullname" .) .Values.sbomDb.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.sbomDb.serviceAccount.name }}
{{- end }}
{{- end }}