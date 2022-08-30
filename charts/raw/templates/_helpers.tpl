{{/*
Expand the name of the chart.
*/}}
{{- define "raw.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "raw.fullname" -}}
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
{{- define "raw.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common chart labels
*/}}
{{- define "raw.labels" -}}
helm.sh/chart: {{ include "raw.chart" . }}
{{ include "raw.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "raw.selectorLabels" -}}
app.kubernetes.io/name: {{ include "raw.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Chart labels
*/}}
{{- define "raw.chartLabels" -}}
metadata:
  labels:
    {{- include "raw.labels" . | nindent 4 }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "raw.commonLabels" -}}
{{- with .Values.commonLabels }}
metadata:
  labels:
    {{ toYaml . | nindent 4 }}
{{- end }}
{{- end }}

{{/*
Append Chart labels if "appendChartLabels" is set
*/}}
{{- define "raw.appendChartLabels" }}
{{- $chartLabels := dict "metadata" (dict "labels" dict) }}
{{- if .Values.appendChartLabels }}
{{- $chartLabels = fromYaml (include "raw.chartLabels" .) }}
{{- end }}
{{- toYaml $chartLabels }}
{{- end }}

{{/*
Create manifests and append labels (support both resources and templates)
*/}}
{{- define "raw.manifests" -}}
{{- $dot := index . 0 }}
{{- $resources := index . 1 }}
{{- $type := index . 2 }}
{{- $chartLabels := fromYaml (include "raw.appendChartLabels" $dot) }}
{{- $commonLabels := fromYaml (include "raw.commonLabels" $dot) }}
{{- range $resource := $resources }}
---
{{- if eq $type "templates" }}
{{- toYaml (merge (tpl $resource $dot | fromYaml) $chartLabels $commonLabels) -}}
{{- else }}
{{- toYaml (merge $resource $chartLabels $commonLabels) }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create manifests (supports slice and map)
*/}}
{{- define "raw.resources" -}}
{{- $dot := index . 0 }}
{{- $resources := index . 1 }}
{{- $type := index . 2 }}
{{- if (kindIs "slice" $resources) }}
{{- include "raw.manifests" (list $dot $resources $type) }}
{{- else if (kindIs "map" $resources) }}
{{- range $group, $resources := $resources }}
{{- include "raw.manifests" (list $dot $resources $type) }}
{{- end }}
{{- end }}
{{- end }}