{{/* Pod spec shared by the quotas hook Job and the reconciling CronJob. */}}
{{- define "redpanda-cluster.quotasPodSpec" -}}
restartPolicy: OnFailure
{{- with .Values.scheduling }}
{{- toYaml . | nindent 0 }}
{{- end }}
containers:
  - name: rpk
    image: {{ .Values.image }}
    command: ["/bin/bash", "-ec"]
    args:
      - |
        until rpk cluster info >/dev/null 2>&1; do echo "waiting for brokers"; sleep 10; done
        {{- range .Values.quotas }}
        rpk cluster quotas alter --name user={{ .user }}
        {{- if .producer_byte_rate }} --add producer_byte_rate={{ int64 .producer_byte_rate }}{{ else }} --delete producer_byte_rate{{ end }}
        {{- if .consumer_byte_rate }} --add consumer_byte_rate={{ int64 .consumer_byte_rate }}{{ else }} --delete consumer_byte_rate{{ end }}
        {{- end }}
        rpk cluster quotas describe
    env:
      - name: RPK_BROKERS
        value: {{ .Values.brokersAddress | quote }}
      - name: RPK_SASL_MECHANISM
        value: SCRAM-SHA-512
      - name: RPK_USER
        valueFrom: { secretKeyRef: { name: {{ .Values.adminSecret }}, key: username } }
      - name: RPK_PASS
        valueFrom: { secretKeyRef: { name: {{ .Values.adminSecret }}, key: password } }
{{- end -}}
