{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "panoptica.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create the product name.
*/}}
{{- define "product.name" -}}
{{- default .Chart.Name .Values.global.productNameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the target Kubernetes version.
Ref https://github.com/bitnami/charts/blob/main/bitnami/common/templates/_capabilities.tpl
*/}}
{{- define "panoptica.capabilities.kubeVersion" -}}
{{- default .Capabilities.KubeVersion.Version .Values.global.kubeVersionOverride -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for Horizontal Pod Autoscaler.
*/}}
{{- define "panoptica.capabilities.hpa.apiVersion" -}}
{{- if semverCompare "<1.23-0" (include "panoptica.capabilities.kubeVersion" .) -}}
{{- print "autoscaling/v2beta2" -}}
{{- else -}}
{{- print "autoscaling/v2" -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for poddisruptionbudget.
*/}}
{{- define "panoptica.capabilities.pdb.apiVersion" -}}
{{- if semverCompare "<1.21-0" (include "panoptica.capabilities.kubeVersion" .) -}}
{{- print "policy/v1beta1" -}}
{{- else -}}
{{- print "policy/v1" -}}
{{- end -}}
{{- end -}}
