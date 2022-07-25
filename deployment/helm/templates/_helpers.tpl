{{/*
Expand the name of the chart.
*/}}
{{- define "powerdns-pdns.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "powerdns-pdns.fullname" -}}
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
{{- define "powerdns-pdns.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "powerdns-pdns.labels" -}}
helm.sh/chart: {{ include "powerdns-pdns.chart" . }}
{{ include "powerdns-pdns.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "powerdns-pdns.selectorLabels" -}}
app.kubernetes.io/name: {{ include "powerdns-pdns.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "powerdns-pdns.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "powerdns-pdns.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
labels for backup cron-job
*/}}
{{- define "dbbackupjob.labels" -}}
{{- with .Values.pdns.database.backup.cronJobLabels }}
{{- toYaml . }}
{{- end }}
{{- end }}
 
{{/*
Common labels for backup
*/}}
{{- define "dbbackup.labels" -}}
helm.sh/chart: {{ include "powerdns-pdns.chart" . }}
{{ include "dbbackup.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
 
{{/*
Selector labels for backup
*/}}
{{- define "dbbackup.selectorLabels" -}}
app.kubernetes.io/name: {{ printf "%s-backup" (include "powerdns-pdns.name" .) }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
 
 
{{/*
Return the secret with S3 credentials
*/}}
{{- define "dbbackup.secretName" -}}
    {{- if .Values.pdns.database.backup.s3.existingSecret -}}
        {{- printf "%s" .Values.pdns.database.backup.s3.existingSecret -}}
    {{- else -}}
        {{ printf "%s-backup" (include "powerdns-pdns.fullname" .) }} 
    {{- end -}}
{{- end -}}

{{/*
Return true if a secret object should be created for S3 backups
*/}}
{{- define "dbbackup.createSecret" -}}
{{- if and (not .Values.pdns.database.backup.s3.existingSecret) (.Values.pdns.database.backup.enabled) }}
    {{- true -}}
{{- else -}}
{{- end -}}
{{- end -}}
 