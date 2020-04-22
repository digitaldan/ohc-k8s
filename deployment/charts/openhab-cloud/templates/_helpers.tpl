{{- define "ingress.host.effective" -}}
    {{- if .Values.ingress.ip -}}
        {{- .Chart.Name -}}.{{- .Values.ingress.ip -}}.nip.io
    {{- else -}}
         {{- if .Values.ingress.host -}}
            {{- .Values.ingress.host -}}
         {{- end -}}
    {{- end -}}
{{- end -}}