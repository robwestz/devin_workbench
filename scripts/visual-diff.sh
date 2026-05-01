#!/usr/bin/env bash
# visual-diff.sh — Compare two URLs visually using Playwright + pixelmatch.
#
# Usage:
#   visual-diff.sh <url-A> <url-B> [--tolerance N] [--auth-state <path>]
#   visual-diff.sh --self-test

set -uo pipefail

# -------- Parse args --------
URL_A=""
URL_B=""
TOLERANCE=1.0
AUTH_STATE=""
SELFTEST=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --self-test) SELFTEST=true; shift ;;
    --tolerance) TOLERANCE=$2; shift 2 ;;
    --auth-state) AUTH_STATE=$2; shift 2 ;;
    *)
      if [ -z "$URL_A" ]; then URL_A=$1
      elif [ -z "$URL_B" ]; then URL_B=$1
      fi
      shift ;;
  esac
done

# -------- Self-test --------
if [ "$SELFTEST" = "true" ]; then
  URL_A="https://example.com"
  URL_B="https://www.iana.org/help/example-domains"
  echo "Self-test: comparing $URL_A vs $URL_B"
fi

if [ -z "$URL_A" ] || [ -z "$URL_B" ]; then
  echo "Usage: $0 <url-A> <url-B> [--tolerance N] [--auth-state <path>]" >&2
  exit 64
fi

# -------- Setup --------
WORK_DIR="/tmp/visual-diff-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$WORK_DIR"/{a,b,diff}

cat > "$WORK_DIR/capture.js" <<EOF
const { chromium } = require('playwright');

const VIEWPORTS = [
  { name: 'desktop-2k', width: 1920, height: 1080 },
  { name: 'desktop-laptop', width: 1440, height: 900 },
  { name: 'tablet', width: 768, height: 1024 },
  { name: 'mobile', width: 375, height: 667 },
];

async function capture(url, outDir, authStatePath) {
  const browser = await chromium.launch();
  const contextOpts = {};
  if (authStatePath) {
    contextOpts.storageState = authStatePath;
  }
  
  for (const vp of VIEWPORTS) {
    const context = await browser.newContext({
      ...contextOpts,
      viewport: { width: vp.width, height: vp.height }
    });
    const page = await context.newPage();
    await page.goto(url, { waitUntil: 'networkidle', timeout: 30000 });
    
    // Auto-dismiss common cookie banners
    const cookieSelectors = [
      'button:has-text("Accept")',
      'button:has-text("Accept all")',
      'button:has-text("OK")',
      'button:has-text("Close")',
      '[id*="cookie"] button',
    ];
    for (const sel of cookieSelectors) {
      try {
        await page.locator(sel).first().click({ timeout: 1000 });
        break;
      } catch {}
    }
    
    // Wait for animations
    await page.waitForTimeout(2000);
    
    await page.screenshot({
      path: \`\${outDir}/\${vp.name}.png\`,
      fullPage: true
    });
    
    await context.close();
  }
  
  await browser.close();
}

const url = process.argv[2];
const outDir = process.argv[3];
const authState = process.argv[4] || null;

capture(url, outDir, authState).catch(e => { console.error(e); process.exit(1); });
EOF

# -------- Capture --------
echo "Capturing $URL_A..."
node "$WORK_DIR/capture.js" "$URL_A" "$WORK_DIR/a" "$AUTH_STATE"

echo "Capturing $URL_B..."
node "$WORK_DIR/capture.js" "$URL_B" "$WORK_DIR/b" "$AUTH_STATE"

# -------- Diff --------
echo "Computing diffs..."

declare -A RESULTS

for vp in desktop-2k desktop-laptop tablet mobile; do
  if [ -f "$WORK_DIR/a/$vp.png" ] && [ -f "$WORK_DIR/b/$vp.png" ]; then
    DIFF_OUT=$(pixelmatch \
      "$WORK_DIR/a/$vp.png" \
      "$WORK_DIR/b/$vp.png" \
      "$WORK_DIR/diff/$vp.png" \
      0.1 2>&1 || true)
    
    # Extract pixel diff count (pixelmatch outputs to stderr)
    DIFF_PCT=$(echo "$DIFF_OUT" | grep -oP '\d+\.\d+%' | head -1 || echo "?")
    RESULTS[$vp]=$DIFF_PCT
  fi
done

# -------- Report --------
REPORT="$WORK_DIR/report.html"
cat > "$REPORT" <<EOF
<!DOCTYPE html>
<html><head><title>Visual Diff Report</title>
<style>
body { font-family: monospace; max-width: 1400px; margin: 2em auto; padding: 1em; }
.viewport { margin: 2em 0; padding: 1em; border: 1px solid #ccc; }
img { max-width: 100%; border: 1px solid #999; }
.row { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 1em; }
h2 { margin-top: 0; }
.warn { background: #fee; border-left: 4px solid #c00; padding: 0.5em; }
</style></head><body>
<h1>Visual Diff: $URL_A → $URL_B</h1>
<p>Tolerance: $TOLERANCE%</p>
EOF

for vp in desktop-2k desktop-laptop tablet mobile; do
  pct=${RESULTS[$vp]:-N/A}
  warn=""
  if [ "$pct" != "N/A" ] && [ "$pct" != "?" ]; then
    pct_num=$(echo "$pct" | tr -d '%')
    if (( $(echo "$pct_num > $TOLERANCE" | bc -l) )); then
      warn="<div class='warn'>⚠ Above tolerance threshold</div>"
    fi
  fi
  cat >> "$REPORT" <<EOF
<div class="viewport">
  <h2>$vp — diff: $pct</h2>
  $warn
  <div class="row">
    <div><h3>A</h3><img src="a/$vp.png"></div>
    <div><h3>B</h3><img src="b/$vp.png"></div>
    <div><h3>Diff</h3><img src="diff/$vp.png"></div>
  </div>
</div>
EOF
done

echo "</body></html>" >> "$REPORT"

# -------- Summary --------
echo
echo "=== PB-3: Visual Regression ==="
echo "URL A: $URL_A"
echo "URL B: $URL_B"
echo "Tolerance: $TOLERANCE%"
echo
for vp in desktop-2k desktop-laptop tablet mobile; do
  pct=${RESULTS[$vp]:-N/A}
  echo "  $vp: diff = $pct"
done
echo
echo "Report: file://$REPORT"
echo "Open in browser to inspect visual diffs."
