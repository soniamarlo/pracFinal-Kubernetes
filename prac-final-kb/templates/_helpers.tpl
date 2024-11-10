{{- define "flask-mysql-kb.name" -}}
{{ .Chart.Name }}
{{- end -}}

{{- define "flask-mysql-kb.fullname" -}}
{{ .Release.Name }}-{{ .Chart.Name }}
{{- end -}}

{{- define "flask-mysql-kb.selectorLabels" -}}
app.kubernetes.io/name: {{ include "flask-mysql-kb.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "flask-mysql-kb.labels" -}}
{{ include "flask-mysql-kb.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- end -}}
