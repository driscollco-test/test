{{- define "universal.name" -}}
{{- default .Chart.Name .Values.name -}}
{{- end -}}

{{- define "universal.fullname" -}}
{{- $n := include "universal.name" . -}}
{{- trunc 63 $n | trimSuffix "-" -}}
{{- end -}}

{{- define "universal.namespace" -}}
{{- default .Release.Namespace .Values.namespace -}}
{{- end -}}

{{- define "universal.selectorLabels" -}}
app.kubernetes.io/name: {{ include "universal.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "universal.labels" -}}
{{ include "universal.selectorLabels" . }}
app.kubernetes.io/managed-by: Helm
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | quote }}
{{- end -}}

{{- define "universal.filesMap" -}}
{{- /* always returns a map */ -}}
{{- default (dict) .Values.files -}}
{{- end -}}

{{- define "universal.hasFiles" -}}
{{- $files := (include "universal.filesMap" . | fromYaml) -}}
{{- gt (len (keys $files)) 0 -}}
{{- end -}}

{{- define "universal.hasIngressRules" -}}
{{- $rules := default (dict) .Values.ingress.rules -}}
{{- gt (len (keys $rules)) 0 -}}
{{- end -}}