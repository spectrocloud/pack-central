{{- define "lava-sensor.fullname" -}}
{{- if contains .Chart.Name .Release.Name -}}
{{- .Release.Name | trunc 50 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 50 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "lava-sensor.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" }}
{{- end -}}

{{- define "lava-sensor.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "lava-sensor.image" -}}
{{- if .digest -}}{{ .repository }}:{{ .tag }}@{{ .digest }}{{- else -}}{{ .repository }}:{{ .tag }}{{- end -}}
{{- end -}}

{{- define "lava-sensor.secretName" -}}
{{- if .Values.existingSecret -}}{{ .Values.existingSecret }}{{- else -}}{{ include "lava-sensor.fullname" . }}-enrollment-key{{- end -}}
{{- end -}}

{{- define "lava-sensor.secretKey" -}}
{{- if .Values.existingSecret -}}{{ required "existingSecretKey names the key inside existingSecret that holds the enrollment key" .Values.existingSecretKey }}{{- else -}}enrollment-key{{- end -}}
{{- end -}}

{{- /* The Lava address every node installs from, without a trailing slash.
       The same shape sensor-api itself accepts for it: https to any host, or
       http to a loopback one, with no character a shell would read. */ -}}
{{- define "lava-sensor.apiUrl" -}}
{{- $url := .Values.sensorApiUrl | toString | trimSuffix "/" -}}
{{- if not (regexMatch "^(https://[A-Za-z0-9.-]+(:[0-9]+)?(/[A-Za-z0-9._/-]*)?|http://(localhost|127\\.0\\.0\\.1|\\[::1\\])(:[0-9]+)?(/[A-Za-z0-9._/-]*)?)$" $url) -}}
{{- fail (printf "sensorApiUrl must be the Lava address the nodes install from, such as https://api.lavalabs.io/sensor (got %q). Install the chart from the URL the Lava console shows, which fills it in." $url) -}}
{{- end -}}
{{- $url -}}
{{- end -}}
