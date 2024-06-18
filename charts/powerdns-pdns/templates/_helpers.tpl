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

{{/*
Fail in case database configuration is not complete
*/}}
{{- define "database.isConfigured" -}}
{{- $failMessageRaw := `
To configure the database, you have to set:

    - pdns.database.host
    - pdns.database.port (defaults to 3306)
    - pdns.database.user
    - pdns.database.db

  To configure the  password you have to either

  - option 1, set :
    - pdns.database.password

  - option 2, provide a secret with the keys (if key is not defined value will be taken from value-specification)
    - pdns.database.existingSecret
    - pdns.database.secretKey (defaults to password)

` -}}
    {{- $failMessage := printf "\n%s" $failMessageRaw | trimSuffix "\n" -}}

    {{- $_ := required $failMessage .Values.pdns.database.host -}}
    {{- $_ := required $failMessage .Values.pdns.database.port -}}
    {{- $_ := required $failMessage .Values.pdns.database.user -}}
    {{- $_ := required $failMessage .Values.pdns.database.db -}}

    {{- if (not .Values.pdns.database.existingSecret) -}}
        {{- $_ := required $failMessage .Values.pdns.database.password -}}
    {{- end -}}

    {{- if ( .Values.pdns.database.existingSecret) -}}
        {{- $_ := required $failMessage .Values.pdns.database.secretKey -}}
    {{- end -}}

{{- end -}} 


{{/*
Fail in case database-backup configuration is not complete
*/}}
{{- define "dbbackup.isConfigured" -}}
{{- if ( .Values.pdns.database.backup.enabled ) -}}
{{- $failMessageRaw := `
To configure the database-backup, you have to set:

    - pdns.database.backup.s3.endpoint
    - pdns.database.backup.s3.bucket

  To configure the access-seccrets you have to either

  - option 1, set :
    - pdns.database.backup.s3.accessKeyId
    - pdns.database.backup.s3.secretAccessKey

  - option 2, provide a secret 
    - pdns.database.backup.s3.existingSecret
    - pdns.database.backup.s3.accessKeyIdSecretKey (defaults to S3_ACCESS_KEY_ID)
    - pdns.database.backup.s3.secretAccessKeySecretKey (defaults to S3_SECRET_ACCESS_KEY)

` -}}
    {{- $failMessage := printf "\n%s" $failMessageRaw | trimSuffix "\n" -}}

    {{- $_ := required $failMessage .Values.pdns.database.backup.s3.endpoint -}}
    {{- $_ := required $failMessage .Values.pdns.database.backup.s3.bucket -}}

    {{- if (not .Values.pdns.database.backup.s3.existingSecret) -}}
        {{- $_ := required $failMessage .Values.pdns.database.backup.s3.accessKeyId -}}
        {{- $_ := required $failMessage .Values.pdns.database.backup.s3.secretAccessKey -}}
    {{- end -}}

    {{- if ( .Values.pdns.database.backup.s3.existingSecret) -}}
        {{- $_ := required $failMessage .Values.pdns.database.backup.s3.accessKeyIdSecretKey -}}
        {{- $_ := required $failMessage .Values.pdns.database.backup.s3.secretAccessKeySecretKey -}}
    {{- end -}}

{{- end -}} 
{{- end -}} 