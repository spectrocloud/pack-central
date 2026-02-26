{{- define "seccomp-installer.name" -}}
{{- "seccomp-installer" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "seccomp-installer.fullname" -}}
{{- "seccomp-installer" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "seccomp-installer.labels" -}}
helm.sh/chart: {{ include "panoptica.chart" . }}
{{ include "seccomp-installer.selectorLabels" . }}
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
{{- define "seccomp-installer.selectorLabels" -}}
app: {{ include "seccomp-installer.name" . }}
app.kubernetes.io/name: {{ include "seccomp-installer.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "seccomp-installer.serviceAccountName" -}}
{{- if .Values.seccompInstaller.serviceAccount.create }}
{{- default (include "seccomp-installer.fullname" .) .Values.seccompInstaller.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.seccompInstaller.serviceAccount.name }}
{{- end }}
{{- end }}
