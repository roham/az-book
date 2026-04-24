#!/usr/bin/env bash
# Generate Vol II chapter-divider plates via gpt-image-1
# Sanitized prompts — no negation of moderated categories
set -euo pipefail
cd /tmp/az-book-work/az-book
mkdir -p img/v2 logs

STYLE_GUIDE='A flat illustrated mid-century-modernist editorial plate in 16:9 horizontal aspect, in the spirit of Saul Bass posters, Pentagram book covers, Charley Harper geometric forms, Tomi Ungerer mid-century editorial illustration, and the design language of NASA mission control circa 1962 combined with Eero Saarinen TWA Flight Center curves. Strict palette discipline — use ONLY these seven colors: atomic cream #F1E8D4 as ground, bone white #FBF7EE for highlights, deep teal #0E2F3D as primary structural color, tangerine #E88A3C as primary accent, vermillion #D94E2E used sparingly as a signal, champagne gold #C8A961 as hairline accents, and warm ink #2B2822 for line weight. The plate is iconic and symbolic, never narrative. Generous negative space throughout. Always include one retro-future motif somewhere in the composition: an atomic three-orbit symbol, a boomerang shape, a starburst, or a piece of mid-century technical-illustration linework. A subtle 35mm grain texture sits over the whole plate. Hairline gold or teal line weights only. Flat illustrated graphic style — never a photograph, never a 3D render, never a realistic scene. No human faces, only architectural silhouettes or abstract geometric figures. No text, no letters, no labels, no logos, no watermarks. Maintain the strict palette discipline. The result should look like a Pentagram-designed plate from a Jonathan Hickman graphic novel.'

gen () {
  local slug="$1" prompt_body="$2"
  local full="${STYLE_GUIDE} ${prompt_body}"
  local out="img/v2/${slug}.png"
  echo "[$(date +%H:%M:%S)] START ${slug}" >&2
  local resp
  resp=$(curl -sS https://api.openai.com/v1/images/generations \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$(jq -nc --arg p "$full" '{model:"gpt-image-1",prompt:$p,size:"1536x1024",n:1,quality:"high"}')")
  local b64
  b64=$(printf '%s' "$resp" | jq -r '.data[0].b64_json // empty')
  if [ -z "$b64" ]; then
    echo "[$(date +%H:%M:%S)] FAIL ${slug}: $(printf '%s' "$resp" | jq -c '.error // .' 2>/dev/null | head -c 400)" >&2
    return 1
  fi
  printf '%s' "$b64" | base64 -d > "$out"
  local sz
  sz=$(stat -f%z "$out" 2>/dev/null || stat -c%s "$out")
  echo "[$(date +%H:%M:%S)] DONE  ${slug}  ${sz} bytes" >&2
}

# 10 prompts — sanitized, positive-only, palette names included inline
P1='Composition for a chapter plate titled "Farming Luck": a stylized open palm shape rendered as elegant deep-teal hairline geometric arcs (an abstract architectural cup, never a photoreal hand), anchored low-left on the atomic-cream ground. Resting in the center of the cup is a single small tangerine circle representing a seed or spark, surrounded by a faint champagne-gold halo. Vast empty atomic-cream sky above the palm. In the upper-right corner, a small atomic three-orbit symbol drawn faintly in champagne-gold hairlines. Asymmetric balance — palm low-left, atomic motif upper-right. Quiet, meditative, iconic.'

P2='Composition for a chapter plate titled "Place in the System": nested concentric forms. A large outer geometric framework drawn in deep-teal hairlines fills most of the plate — an architectural blueprint outline of the larger system. Inside it, perfectly centered, sits a smaller tangerine ring or gear representing the inner volume. Champagne-gold hairline arrows trace from the outer architecture inward to the tangerine inner ring. The ground is atomic cream. One small mid-century starburst motif in champagne gold marks where the two systems meet. Schematic, blueprint-like, geometric.'

P3='Composition for a chapter plate titled "The Intake Valve": a single stylized industrial funnel mechanism rendered in deep-teal hairline technical-illustration style on atomic-cream ground, centered. Above the funnel, a vertical column of small warm-ink dots descends into the funnel mouth. Below the narrow spout, a single tangerine drop releases into negative space below. The funnel has subtle Saarinen-curved sides — mid-century industrial elegance, not a crude cone. Hairline champagne-gold tick-marks along the funnel side suggest measurement. A small atomic three-orbit motif in champagne gold floats above the queue. Asymmetric weight bottom-center. Schematic.'

P4='Composition for a chapter plate titled "The Hand-Picked Cohort": a small constellation of approximately fifty tiny dots — alternating warm ink and deep teal — clustered inside a tangerine-bordered enclosure shaped like a stylized geometric arena (read as a circular amphitheater or hexagonal container). The tangerine border is a hairline, not heavy. On one side of the enclosure, a single open gateway rendered as a champagne-gold gap in the border, suggesting selective entry. Outside the enclosure, vast atomic-cream negative space with no other dots. A faint starburst motif in champagne gold above the enclosure. Static, jewel-like.'

P5='Composition for a chapter plate titled "The Doubling Ladder": a stepwise ascending staircase or histogram rising from left to right across the lower third of the plate. Each step is twice the height of the previous — a clear doubling pattern. The steps are tangerine, outlined in deep-teal hairlines, on atomic-cream ground. Above each step, a tiny champagne-gold horizontal tick suggests a gate threshold. The rightmost step fades subtly. A thin deep-teal horizontal baseline anchors the bars. A small atomic three-orbit motif in champagne gold floats in the upper-right corner. Flat data-plate style.'

P6='Composition for a chapter plate titled "The Dashboard": a Saarinen-curved control panel rendered in flat illustrated style. Inside the panel, a clean grid of abstract Saul-Bass-flat icon gauges: a circular dial with a tangerine pointer, a horizontal bar with a deep-teal fill, a small line graph with a champagne-gold spline, a numeric readout block, and a starburst-style indicator. The panel frame is deep teal with hairline champagne-gold trim. Atomic-cream ground around it. One tiny vermillion dot glows in the corner of one gauge as a sparing signal. Iconic, schematic, editorial.'

P7='Composition for a chapter plate titled "Reading the Scent": a Charley-Harper-style geometric hound silhouette in deep teal — body composed of stacked simple shapes (oval body, triangular ears, rectangular legs) — head down, nose tracking a faint tangerine trail of small dots curving across the atomic-cream ground from lower-left to upper-right. The trail dots fade in size as they recede. Champagne-gold hairlines suggest air currents. A subtle atomic three-orbit motif in the upper corner. The hound is iconic and flat. Asymmetric — hound anchored bottom-left, trail leading the eye up-right.'

P8='Composition for a chapter plate titled "The Cascade": a network of nodes spreading across a deep-teal background. One central node glows tangerine, and concentric rings of pulses radiate outward to neighboring nodes which themselves begin to glow tangerine — a propagation cascade across an irregular organic graph. Connector lines are champagne-gold hairlines. Outer nodes are warm-ink dots. A few far-edge nodes remain unlit (small atomic-cream circles). A thin starburst motif sits behind the source node. Flat schematic diagram, like a Saul Bass plate.'

P9='Composition for a chapter plate titled "The Loop": a stylized closed-loop control diagram — a circular feedback loop drawn as a tangerine arrow that travels around a circle and returns to its own tail. Inside the loop, three small abstract icon-stations: a champagne-gold gear, a deep-teal lens shape, and a tangerine spark. The arrow connecting them is unbroken. The diagram sits centered on atomic-cream ground with vast negative space. Champagne-gold tick-marks at each station. A small atomic three-orbit motif in the upper corner. Schematic mid-century technical-illustration style.'

P10='Composition for a chapter plate titled "The Bridge": an iconic mid-century bridge silhouette spanning two banks across the lower half of the plate. The left bank is rendered in atomic cream, the right bank in bone white — two subtly different shores. The bridge arch is deep teal with hairline champagne-gold cables suggesting a Saarinen-elegance suspension form. A single small tangerine traveler — a simple geometric figure (a circle atop a rectangle, no face) — stands mid-bridge, walking from left bank toward right. Vast atomic-cream sky above with one thin atomic three-orbit motif in champagne gold floating high. Silent, hopeful, iconic.'

# part-vi-metrics already generated successfully earlier — skip.
# Stagger to avoid the 5/min input-images rate limit (5 per wave, sleep 70s between)
gen part-i-frame           "$P1" &
gen part-ii-place          "$P2" &
gen part-iii-waitlist      "$P3" &
gen part-iv-alpha          "$P4" &
gen part-v-beta            "$P5" &
wait
echo "[$(date +%H:%M:%S)] WAVE 1 DONE — sleeping 70s to clear rate limit"
sleep 70
gen part-vii-houndog       "$P7" &
gen part-viii-wom          "$P8" &
gen part-ix-programmatic   "$P9" &
gen coda-bridge            "$P10" &
wait
echo "[$(date +%H:%M:%S)] ALL DONE"
ls -la img/v2/
