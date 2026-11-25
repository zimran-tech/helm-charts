{{- define "app.plainEnv" -}}
{{- range $env := .Values.env }}
- name: {{ required "env[].name is required" $env.name }}
  value: {{ $env.value | toString | quote }}
{{- end }}
{{- end -}}
