#!/bin/bash
OUTFILE="/tmp/az-book-work/az-book/candidates/r2-nautical/img/chart.png"

PROMPT='Close macro photograph of a single vellum leaf on a navigator'"'"'s bench, shot at three-quarter angle with golden tungsten key. Hand-drawn in minium red ink: a compass rose with eight radial points plus three concentric brass-pressed rings — the outermost ring subtly labeled "EBU", middle "BBP", innermost "SER" in small hand-lettered monospace. Cyan telemetry ghosted beneath vellum like a watermark — faint coordinates, no glow. Corner of a logbook visible, edge of a brass divider. Portra 400 grain, shallow depth, editorial restraint. Absolutely no screen UI. NOT steampunk, NOT fantasy.'

RESPONSE=$(curl -sS https://api.openai.com/v1/images/generations \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg prompt "$PROMPT" '{"model":"gpt-image-1","prompt":$prompt,"size":"1024x1024","n":1,"quality":"high"}')")

echo "$RESPONSE" | jq -r '.data[0].b64_json' | base64 -d > "$OUTFILE"

if [ -s "$OUTFILE" ]; then
  echo "OK chart: $(ls -la "$OUTFILE" | awk '{print $5}') bytes"
else
  echo "FAIL chart"
  echo "$RESPONSE" | head -50
fi
