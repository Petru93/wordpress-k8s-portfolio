{{/*
Expand the name of the chart
*/}}
{{- define "wordpress.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a fully qualified app name
*/}}
{{- define "wordpress.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels applied to all resources
*/}}
{{- define "wordpress.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
WordPress specific selector labels
*/}}
{{- define "wordpress.selectorLabels" -}}
app.kubernetes.io/name: wordpress
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
MySQL specific selector labels
*/}}
{{- define "mysql.selectorLabels" -}}
app.kubernetes.io/name: mysql
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}