{{- define "app.projectedTokenVolumes" -}}
{{- range $token := .Values.serviceAccount.projectedTokens }}
{{- if and $token.expirationSeconds (lt (int $token.expirationSeconds) 600) }}
{{- fail (printf "serviceAccount.projectedTokens[%s].expirationSeconds must be at least 600" $token.name) }}
{{- end }}
- name: {{ $token.name }}-token
  projected:
    sources:
      - serviceAccountToken:
          path: token
          audience: {{ required (printf "serviceAccount.projectedTokens[%s].audience is required" $token.name) $token.audience | quote }}
          expirationSeconds: {{ $token.expirationSeconds | default 3600 }}
{{- end }}
{{- end -}}

{{- define "app.projectedTokenMounts" -}}
{{- range $token := .Values.serviceAccount.projectedTokens }}
- name: {{ $token.name }}-token
  mountPath: "/var/run/secrets/tokens/{{ $token.name }}"
  readOnly: true
{{- end }}
{{- end -}}
