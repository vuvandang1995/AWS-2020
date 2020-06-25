{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "devops.name" -}}
{{- default $.Release.Name $.Values.serviceName | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name. This should be serviceName, unless using Release.Name as service name
*/}}
{{- define "devops.fullname" -}}
{{- default $.Release.Name $.Values.serviceName | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "devops.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "devops.labels" -}}
app.kubernetes.io/name: {{ include "devops.name" . }}
helm.sh/chart: {{ include "devops.chart" . }}
{{- if $.Chart.AppVersion }}
app.kubernetes.io/version: {{ $.Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ $.Release.Service }}
{{- end -}}


{{- define "devops.env" -}}
{{- with . -}}
env:
{{- range $key, $val := . }} 
- name: {{ $key }}
  {{- if hasPrefix "\"secret:" ($val | quote) }}
  valueFrom:   
    secretKeyRef:
      name: {{ trimPrefix "secret:" $val | splitList "." | first }}
      key: {{ trimPrefix "secret:" $val | splitList "." | last }}
  {{- else if hasPrefix "\"configmap:" ($val | quote) }}
  valueFrom:   
    configMapKeyRef:
      name: {{ trimPrefix "configmap:" $val | splitList "." | first }}
      key: {{ trimPrefix "configmap:" $val | splitList "." | last }}
  {{- else }}
  value: {{ $val | quote }}
  {{- end }}
{{- end }}
{{- end }}
{{- end -}}


{{- define "devops.cmd" -}}
{{- with .command }}
command: {{ . | toYaml | nindent 2 }}
{{- end }}
{{- with .args }}
args: {{ . | toYaml | nindent 2 }}
{{- end }}
{{- end -}}


{{- define "devops.resources" -}}
{{- with . }}
resources: {{ . | toYaml | nindent 2 }}
{{- end }}
{{- end -}}
