{{/*
Expand the name of the chart.
*/}}
{{- define "spacelift-workerpool-controller.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "spacelift-workerpool-controller.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "spacelift-workerpool-controller.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "spacelift-workerpool-controller.labels" -}}
helm.sh/chart: {{ include "spacelift-workerpool-controller.chart" . }}
{{ include "spacelift-workerpool-controller.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: Helm
{{- end }}

{{/*
Selector labels
*/}}
{{- define "spacelift-workerpool-controller.selectorLabels" -}}
app.kubernetes.io/name: {{ include "spacelift-workerpool-controller.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Default controller manager service account name
*/}}
{{- define "spacelift-workerpool-controller.defaultServiceAccountName" -}}
{{- printf "%s-controller-manager" (include "spacelift-workerpool-controller.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "spacelift-workerpool-controller.serviceAccountName" -}}
{{- default (include "spacelift-workerpool-controller.defaultServiceAccountName" .) .Values.controllerManager.serviceAccount.name }}
{{- end }}
