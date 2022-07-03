{{/*
Expand the name of the chart.
*/}}
{{- define "restic-rest-server.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "restic-rest-server.fullname" -}}
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
{{- define "restic-rest-server.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "restic-rest-server.labels" -}}
helm.sh/chart: {{ include "restic-rest-server.chart" . }}
{{ include "restic-rest-server.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "restic-rest-server.selectorLabels" -}}
app.kubernetes.io/name: {{ include "restic-rest-server.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "restic-rest-server.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "restic-rest-server.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create a default fully qualified component name from the full app name and a component name.
We truncate the full name at 63 - 1 (last dash) - len(component name) chars because some Kubernetes name fields are limited to this (by the DNS naming spec)
and we want to make sure that the component is included in the name.

Usage: {{ include "restic-rest-server.componentname" (list . "component") }}
*/}}
{{- define "restic-rest-server.componentname" -}}
{{- $global := index . 0 -}}
{{- $component := index . 1 | trimPrefix "-" -}}
{{- printf "%s-%s" (include "restic-rest-server.fullname" $global | trunc (sub 62 (len $component) | int) | trimSuffix "-" ) $component | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name for the users file
*/}}
{{- define "restic-rest-server.usersSecret" }}
{{- include "restic-rest-server.componentname" (list . "users") }}
{{- end }}

{{/*
Create the PersistentVolumeClaim name
*/}}
{{- define "restic-rest-server.claimName" -}}
{{- default (include "restic-rest-server.fullname" .) .Values.restic.restServer.repos.persistence.existingClaim }}
{{- end }}

{{/*
Create a default password
*/}}
{{- define "restic-rest-server.defaultPassword" -}}
{{- randAlphaNum 32 }}
{{- end }}
