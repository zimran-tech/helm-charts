{{- define "app.fileVolumes" -}}
{{- range $volume := .Values.volumes }}
- name: {{ required "volumes[].name is required" $volume.name }}
  configMap:
    name: {{ $.Release.Name }}-{{ $volume.name }}
{{- end }}
{{- end -}}

{{- define "app.fileVolumeMounts" -}}
{{- range $volume := .Values.volumes }}
- name: {{ $volume.name }}
  mountPath: {{ required (printf "volumes[%s].mountPath is required" $volume.name) $volume.mountPath | quote }}
  readOnly: true
{{- end }}
{{- end -}}
