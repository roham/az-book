#!/bin/bash
# Generate a single hero variant
# Usage: ./gen-hero.sh <variant_number>

VARIANT=$1
OUTFILE="/tmp/az-book-work/az-book/candidates/r2-nautical/img/hero-v${VARIANT}.png"

PROMPT='Overhead still life photograph, shot straight down onto a dark walnut navigator'"'"'s workbench in a quiet cabin at golden hour. The bench is arranged as a patient operator'"'"'s workspace — not cluttered, not sparse, every object placed with intention. At center-right: a large antique brass sextant, maritime 18th century, with a visible vernier scale backlit with a thin matte phosphor-cyan glow (not a screen, treated as ink, no bloom, no halation). A single hair-thin line of cyan light traces from the sextant'"'"'s index arm outward onto the chart, resolving into a small floating data readout in monospace type that reads "ALT 47.2° t+00:12:04". At center-left: an open unrolled vellum chart (cream #F3EAD3, soft creases, visible fiber grain, edge-weighted by two brass weights). Hand-drawn in minium red ink (#D94A28): a compass rose with eight radial points, tiny hand-lettered minimal labels at cardinal and ordinal points — short plausible nautical words or initials, NOT specific innovation-archetype names, simple and terse. Bleeding faintly through the vellum from below, a pale cyan satellite weather grid — isobars and coordinate ticks ghosted at 15% opacity. In the upper-right quadrant: a brass marine chronometer in a gimbaled wooden box, its face showing analog hands AND a thin ring of phosphor-cyan tick marks indicating a separate elapsed-experiment timer. Beside it: a small leather-bound logbook, open, with a fountain pen resting in the gutter. The left page handwritten in iron-gall ink, right page the same handwriting but printed as if dictated by an instrument. Scattered with intention: a pair of brass dividers, a folded pair of wire-frame spectacles, a single ceramic cup of black coffee (steam catching cyan faintly), a brass stamp that reads "GREEN LIGHT" in reverse. One anachronism played deadpan: a small matte-black rectangular device the size of a deck of cards, unlabeled, with a single cyan pinhole LED — it could be a modem, a dongle, or nothing. Lighting: warm tungsten key from upper-left (window light, golden hour), cool cyan fill only from the instruments themselves. High dynamic range but restrained — brass gleams, vellum holds detail, shadows deep but readable. 80mm macro, f/4, very shallow falloff at bench edges. Mood: patient, expert, slightly eccentric. The operator just stepped away. Visual language: Stripe Press covers, Hodinkee macro, The Witness, Wes Anderson symmetry. NOT Blade Runner. NOT neon rain. NOT steampunk. Zero UI chrome, zero HUD brackets, zero lens flare. Film grain Portra 400 fine. 16:9, photoreal editorial.'

RESPONSE=$(curl -sS https://api.openai.com/v1/images/generations \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg prompt "$PROMPT" '{"model":"gpt-image-1","prompt":$prompt,"size":"1536x1024","n":1,"quality":"high"}')")

echo "$RESPONSE" | jq -r '.data[0].b64_json' | base64 -d > "$OUTFILE"

if [ -s "$OUTFILE" ]; then
  echo "OK variant $VARIANT: $(ls -la "$OUTFILE" | awk '{print $5}') bytes"
else
  echo "FAIL variant $VARIANT"
  echo "$RESPONSE" | head -50
fi
