#!/bin/bash
OUTFILE="/tmp/az-book-work/az-book/candidates/r2-nautical/img/sextant.png"

PROMPT='Extreme macro of the brass sextant'"'"'s vernier scale, shot at eye-level with the instrument from eight inches away. Brass warm, slightly tarnished, thumbprint-worn. Along the arc, a thin ribbon of phosphor-cyan (#2FD8C9) light glows from within the engraved markings — not a screen, treated as ink. A single floating mono-type readout hovers a few millimeters above the scale: "RETENTION D7 41% ▲". Below the readout, a second fainter line: "COHORT 04 n=812". A navigator'"'"'s hand enters frame lower-right, wearing one thin wire-cotton glove, holding a fine brass stylus about to touch a calibration screw. Out of focus in background: edge of a logbook, ceramic coffee cup, ghost of vellum. Lighting: warm tungsten key, cool cyan rim from instrument itself. 100mm macro f/2.8 very shallow DOF. Portra 400 grain. Mood: the instant before a reading is taken.'

RESPONSE=$(curl -sS https://api.openai.com/v1/images/generations \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg prompt "$PROMPT" '{"model":"gpt-image-1","prompt":$prompt,"size":"1024x1024","n":1,"quality":"high"}')")

echo "$RESPONSE" | jq -r '.data[0].b64_json' | base64 -d > "$OUTFILE"

if [ -s "$OUTFILE" ]; then
  echo "OK sextant: $(ls -la "$OUTFILE" | awk '{print $5}') bytes"
else
  echo "FAIL sextant"
  echo "$RESPONSE" | head -50
fi
