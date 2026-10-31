#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT
helm lint "$ROOT/charts/redpanda-monitoring" -f "$ROOT/tests/rules/values.yaml"
helm template monitoring "$ROOT/charts/redpanda-monitoring" --namespace redpanda-test \
  -f "$ROOT/tests/rules/values.yaml" > "$TEMP_DIR/rendered.yaml"
# Helm emits the PrometheusRule spec as the standalone promtool rule document.
awk '/^kind: PrometheusRule$/ { rule=1; next } /^---$/ { rule=0 } rule && /^spec:$/ { spec=1; next } rule && spec { print substr($0, 3) }' \
  "$TEMP_DIR/rendered.yaml" > "$TEMP_DIR/rules.yaml"
python3 - "$TEMP_DIR/rendered.yaml" "$ROOT/charts/redpanda-monitoring/dashboards/redpanda.json" <<'PY'
import json
import pathlib
import sys
rendered = pathlib.Path(sys.argv[1]).read_text()
assert "{{ $value }}" in rendered, "Prometheus value template was lost"
assert "{{ $labels.pod }}" in rendered, "Prometheus label template was lost"
json.loads(pathlib.Path(sys.argv[2]).read_text())
PY
cp "$ROOT/tests/rules/rules_test.yaml" "$TEMP_DIR/rules_test.yaml"
# Match the host uid so Prometheus can read mktemp's private directory.
docker run --rm --user "$(id -u):$(id -g)" --entrypoint promtool -v "$TEMP_DIR:/work:ro" -w /work \
  prom/prometheus:v3.5.0 check rules rules.yaml
docker run --rm --user "$(id -u):$(id -g)" --entrypoint promtool -v "$TEMP_DIR:/work:ro" -w /work \
  prom/prometheus:v3.5.0 test rules rules_test.yaml
