#!/usr/bin/env bash
# Generate Vol I chapter-divider plates via gpt-image-1.
# Rate limit: 5/min on gpt-image-1. We pace at 15s/call and retry on 429.
set -u
OUTDIR="/tmp/az-book-work/az-book/img/v1"
mkdir -p "$OUTDIR"

NEG='NOT photorealistic. NOT 3D-rendered. NOT fantasy. NOT cyberpunk neon. NOT steampunk dust. NOT children'"'"'s book. NOT corporate illustration. No legible text. No logos. No watermarks. No human faces. Maintain palette discipline — only atomic cream #F1E8D4, bone white #FBF7EE, deep teal #0E2F3D, tangerine #E88A3C, vermillion #D94E2E, champagne gold #C8A961, warm ink #2B2822. Mid-century-modernist illustrated plate, graphic-novel register, Saul Bass × Jonathan Hickman × Pentagram × Fantastic Four 2025 visual language.'

STYLE_HEAD='Mid-century-modernist illustrated graphic-novel chapter-divider plate, 16:9 aspect ratio. Visual register: Jonathan Hickman & R.B. Silva House of X / Powers of X (2019) data plates crossed with Saul Bass film posters (Vertigo, Anatomy of a Murder), Pentagram book design, Charley Harper geometric wildlife, Tomi Ungerer mid-century editorial illustration, Eric Lobbecke editorial work, and Fantastic Four: First Steps (2025) production design. The Jetsons by way of NASA 1962 mission control and Eero Saarinen TWA Flight Center. Strict palette only: atomic cream #F1E8D4 ground, bone white #FBF7EE highlights, deep teal #0E2F3D as primary structural color, tangerine #E88A3C primary accent, vermillion #D94E2E used sparingly as signal, champagne gold #C8A961 hairline accents, warm ink #2B2822 line weight. Generous negative space. Subtle 35mm film-grain texture, alive but not noisy. Hairline gold or teal lines used like an engineering schematic — disciplined, technical-illustration vocabulary. No photorealism, no 3D render, no text, no labels.'

call_api() {
  local prompt="$1"
  local body
  body=$(jq -nc --arg p "$prompt" '{model:"gpt-image-1",prompt:$p,size:"1536x1024",n:1,quality:"high"}')
  curl -sS https://api.openai.com/v1/images/generations \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$body"
}

gen() {
  local slug="$1"; shift
  local prompt="$1"; shift
  local outfile="$OUTDIR/$slug.png"
  if [[ -s "$outfile" ]]; then
    echo "==> SKIP $slug (already exists, $(wc -c < "$outfile") bytes)"
    return 0
  fi
  echo "==> Generating $slug ..."
  local full="$STYLE_HEAD

$prompt

$NEG"
  local resp b64 attempt=0
  while (( attempt < 6 )); do
    resp=$(call_api "$full")
    b64=$(echo "$resp" | jq -r '.data[0].b64_json // empty')
    if [[ -n "$b64" ]]; then
      echo "$b64" | base64 -d > "$outfile"
      local sz; sz=$(wc -c < "$outfile")
      echo "    saved $outfile ($sz bytes)"
      return 0
    fi
    local err; err=$(echo "$resp" | jq -r '.error.message // "unknown error"')
    echo "    attempt $((attempt+1)) failed: $err"
    if echo "$err" | grep -q "rate_limit\|Rate limit"; then
      echo "    sleeping 25s for rate-limit recovery..."
      sleep 25
    else
      echo "    non-rate-limit error, retrying in 8s..."
      sleep 8
    fi
    attempt=$((attempt+1))
  done
  echo "    GIVE UP on $slug"
  return 1
}

# Pace at 15s between successful calls to stay under 5/min rate limit.
PACE=15

# 1. Prologue
gen "prologue" 'A single tangerine #E88A3C spark — a small, perfectly circular ember about 8% of the frame width — suspended in the lower-third left of a vast atomic-cream #F1E8D4 field. From the spark, three concentric thin teal hairlines radiate outward, each terminating before reaching the edges, suggesting potential energy not yet released. In the upper right, a single faint champagne-gold #C8A961 atomic-symbol glyph (three-orbit, electron-style) floats small and unobtrusive — the seed of a thesis. Mid-century technical-illustration linework. Composition: heavy negative space, asymmetric balance, the spark feels like it is being looked at from inside a quiet room at dawn. Iconic, symbolic, not narrative. The plate should read as the moment before everything begins.' && sleep $PACE

# 2. Part I — The Thesis (9 Steps)
gen "part-i-thesis" 'Nine numbered nodes arranged in a precise geometric formation across a bone-white #FBF7EE field — a 3x3 lattice with hairline champagne-gold #C8A961 connector lines drawn between adjacent nodes like an engineering schematic. Each node is a small disc: nodes 1-3 in deep teal #0E2F3D, nodes 4-6 in tangerine #E88A3C, nodes 7-9 in vermillion #D94E2E (sparingly). The lattice is centered but not symmetric — it tilts slightly, suggesting motion through a process. Around the lattice, faint atomic-cream negative space, with one small starburst motif (8-point, mid-century) in champagne gold in a corner. Pentagram-grade typographic restraint — no text, but the composition feels like the title page of a technical manual from 1962. Charley Harper-level geometric discipline.' && sleep $PACE

# 3. Part II — Finding the Wave
gen "part-ii-wave" 'A single mid-century-stylized ocean wave breaking from left to right across the lower two-thirds of the frame. The wave is rendered in deep teal #0E2F3D with a tangerine #E88A3C crest line, drawn as flat geometric shapes (Saul Bass / Charley Harper vocabulary) — no realistic water, just stacked curves and a crisp foam-line in bone white #FBF7EE. At the very crest, a tiny operator silhouette — a single figure on a board, 2% of the frame width, rendered as a clean teal cutout with no facial features. Above the wave, atomic-cream #F1E8D4 sky with one small champagne-gold #C8A961 starburst motif (right side, upper third). The wave has the iconic graphic punch of a 1960s travel poster, the timing and tension of a Hickman data plate. Hairline ink #2B2822 outlines.' && sleep $PACE

# 4. Part III — Six Archetypes
gen "part-iii-archetypes" 'Six geometric icons arranged radially around a central point on an atomic-cream #F1E8D4 ground, each icon Saul-Bass-style flat and symbolic, separated by generous negative space: (1) a small concave dish, (2) a probe-arrow pointing diagonally, (3) a rectangular frame, (4) a stylized beach/horizon line, (5) a lighthouse silhouette with a single beam, (6) a network of three connected nodes. Icons rendered in deep teal #0E2F3D with tangerine #E88A3C accent fills on alternating shapes. Hairline champagne-gold #C8A961 circle inscribes all six, like an astrolabe. At center, a tiny vermillion #D94E2E dot — the operator at the decision point. Charley Harper geometric wildlife discipline applied to abstract symbols. The plate reads as a typology chart from a 1962 technical manual, cool and inevitable.' && sleep $PACE

# 5. Part IV — Generating and Killing Ideas (the funnel/sieve)
gen "part-iv-funnel" 'A downward-tapering geometric sieve — a stylized inverted trapezoid drawn in deep teal #0E2F3D hairlines on a bone-white #FBF7EE field. Many small dots (about 30) of mixed atomic-cream, tangerine #E88A3C, and champagne-gold #C8A961 enter the wide mouth at the top, drifting down. Inside the funnel, the dots collide with horizontal teal kill-bars (three of them) where most are absorbed — only three small tangerine dots emerge from the narrow bottom. The sieve casts a thin geometric shadow to one side. One vermillion #D94E2E mark above the funnel signals the cull. Mid-century technical illustration, the kind of plate a Bell Labs annual report would have used in 1961 to explain selection. Iconic, almost diagrammatic, but graphically composed. Hairline ink #2B2822 outlines.' && sleep $PACE

# 6. Part V — De-Risking (Hooks/Legs/Flywheel — green light)
gen "part-v-greenlight" 'Three circular gauges arranged in a horizontal row across an atomic-cream #F1E8D4 field, each with a teal #0E2F3D bezel, bone-white #FBF7EE dial face, and a tangerine #E88A3C needle. The leftmost gauge needle points low; the middle gauge needle points mid; the rightmost gauge needle is pinned high — suggesting a sequence reaching a green light. Above the three gauges, a single horizontal champagne-gold #C8A961 hairline runs across the frame like a guide rail. To the upper right, a small vermillion #D94E2E circle — the signal lamp — glows on. The composition is a mission-control instrument cluster from 1962 NASA, rendered with Saul Bass restraint. No text on the gauge faces, only abstract tick marks. The plate radiates cool, controlled go/no-go authority.' && sleep $PACE

# 7. Part VI — Shipping and Learning (Clock Speed / Bold Beats)
gen "part-vi-clockspeed" 'A stylized atomic clock at the center of a bone-white #FBF7EE field — a deep teal #0E2F3D circular face with bold tangerine #E88A3C tick marks at 12 evenly-spaced positions. The hour and minute hands are drawn as crisp tangerine geometric shapes, frozen at a confident angle (around 10:10). Three concentric atomic-orbit hairlines in champagne gold #C8A961 surround the clock, each carrying a small electron dot — one teal, one vermillion #D94E2E, one tangerine — caught mid-revolution. The orbits suggest the clock is also a particle in motion. Below the clock, a single thin horizontal ink #2B2822 baseline. Mid-century kinetic energy, the precision of a chronograph illustration plate. The plate reads as the heartbeat of execution.' && sleep $PACE

# 8. Part VII — Building the Moat (7 Powers)
gen "part-vii-moat" 'Seven concentric layered shapes building upward like a fortified ziggurat, centered on an atomic-cream #F1E8D4 field. Each layer is a wider trapezoid stacked atop a narrower one above, alternating deep teal #0E2F3D and tangerine #E88A3C, with hairline champagne-gold #C8A961 separators between every layer. The top of the structure terminates in a small vermillion #D94E2E peak point. The whole structure casts a long flat geometric shadow to one side, anchoring it. Around the base, a thin warm ink #2B2822 ground line. Iconic, monumental, the visual logic of a 1960s annual-report frontispiece illustrating defensibility. Charley Harper geometric architecture discipline — every shape flat, every edge intentional. The plate reads as an iconic emblem of accumulated structural advantage.' && sleep $PACE

# 9. Part IX — Culture (founders, not functions)
gen "part-ix-culture" 'A single mid-century chair, drawn in flat geometric shapes (Eero Saarinen Womb Chair silhouette / Charley Harper vocabulary), facing away toward a horizon line — rendered in deep teal #0E2F3D with tangerine #E88A3C accent on the seat cushion. The chair sits in the lower third of an atomic-cream #F1E8D4 field. The horizon line is a single hairline champagne-gold #C8A961 stroke crossing the upper third. Above the horizon, a small bone-white #FBF7EE sun-disc with a thin vermillion #D94E2E rim — small, distant. Generous negative space dominates. The plate is quiet, contemplative, iconic — a single founder facing the work, no facial features, no figure, only the chair and the horizon. The graphic punch of a Saul Bass title card paired with Charley Harper restraint.' && sleep $PACE

# 10. Part X — Finance (the ledger / circuit breaker)
gen "part-x-finance" 'A stylized circuit-breaker dashboard panel rendered as a flat mid-century instrument plate, centered on a bone-white #FBF7EE field. The panel is deep teal #0E2F3D with three vertical lever-switches arranged in a row — each lever is a tangerine #E88A3C handle on a champagne-gold #C8A961 hairline track. The leftmost lever points up (engaged), the middle lever is mid-position, the rightmost lever points down (tripped). To the right of the levers, three small circular indicator lamps — one teal, one tangerine, one vermillion #D94E2E — stacked vertically. Above the panel, a thin atomic-cream #F1E8D4 nameplate area (blank, no text). The whole panel is bordered by hairline ink #2B2822. The composition reads as a 1962 NASA mission-control sub-panel — disciplined, technical, with the iconic clarity of a Pentagram exhibition plate.'

echo "==> Done."
ls -la "$OUTDIR"/*.png 2>/dev/null
