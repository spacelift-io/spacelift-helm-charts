{{/*
Expand the name of the server.
*/}}
{{- define "spacelift.serverName" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Expand the name of the chart.
*/}}
{{- define "spacelift.drainName" -}}
{{- printf "%s-drain" (default .Values.nameOverride .Chart.Name) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Expand the name of the chart.
*/}}
{{- define "spacelift.schedulerName" -}}
{{- printf "%s-scheduler" (default .Values.nameOverride .Chart.Name) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "spacelift.fullname" -}}
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
{{- define "spacelift.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Server labels
*/}}
{{- define "spacelift.serverLabels" -}}
helm.sh/chart: {{ include "spacelift.chart" . }}
{{ include "spacelift.serverSelectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Common drain labels
*/}}
{{- define "spacelift.drainLabels" -}}
helm.sh/chart: {{ include "spacelift.chart" . }}
{{ include "spacelift.drainSelectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Common scheduler labels
*/}}
{{- define "spacelift.schedulerLabels" -}}
helm.sh/chart: {{ include "spacelift.chart" . }}
{{ include "spacelift.schedulerSelectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Server Selector labels
*/}}
{{- define "spacelift.serverSelectorLabels" -}}
app.kubernetes.io/name: {{ include "spacelift.serverName" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Selector drain labels
*/}}
{{- define "spacelift.drainSelectorLabels" -}}
app.kubernetes.io/name: {{ include "spacelift.drainName" . }}
app.kubernetes.io/instance: {{ printf "%s-drain" .Release.Name }}
{{- end }}

{{/*
Selector scheduler labels
*/}}
{{- define "spacelift.schedulerSelectorLabels" -}}
app.kubernetes.io/name: {{ include "spacelift.schedulerName" . }}
app.kubernetes.io/instance: {{ printf "%s-scheduler" .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "spacelift.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "spacelift.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use for the server.
*/}}
{{- define "spacelift.serverServiceAccountName" -}}
{{- if .Values.server.serviceAccount.create }}
{{- .Values.server.serviceAccount.name }}
{{- else }}
{{- include "spacelift.serviceAccountName" . }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use for the drain.
*/}}
{{- define "spacelift.drainServiceAccountName" -}}
{{- if .Values.drain.serviceAccount.create }}
{{- .Values.drain.serviceAccount.name }}
{{- else }}
{{- include "spacelift.serviceAccountName" . }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use for the scheduler.
*/}}
{{- define "spacelift.schedulerServiceAccountName" -}}
{{- if .Values.scheduler.serviceAccount.create }}
{{- .Values.scheduler.serviceAccount.name }}
{{- else }}
{{- include "spacelift.serviceAccountName" . }}
{{- end }}
{{- end }}

{{/*
Expand the name of the VCS Gateway.
*/}}
{{- define "spacelift.vcsGatewayName" -}}
{{- printf "%s-vcs-gateway" (default .Values.nameOverride .Chart.Name) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
VCS Gateway labels
*/}}
{{- define "spacelift.vcsGatewayLabels" -}}
helm.sh/chart: {{ include "spacelift.chart" . }}
{{ include "spacelift.vcsGatewaySelectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
VCS Gateway Selector labels
*/}}
{{- define "spacelift.vcsGatewaySelectorLabels" -}}
app.kubernetes.io/name: {{ include "spacelift.vcsGatewayName" . }}
app.kubernetes.io/instance: {{ printf "%s-vcs-gateway" .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use for the VCS Gateway.
*/}}
{{- define "spacelift.vcsGatewayServiceAccountName" -}}
{{- if .Values.vcsGateway.serviceAccount.create }}
{{- .Values.vcsGateway.serviceAccount.name }}
{{- else }}
{{- include "spacelift.serviceAccountName" . }}
{{- end }}
{{- end }}
