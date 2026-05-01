# PB-3 — Visual Regression

> Compare a deployed site (or two snapshots) for visual diffs. Catches CSS-only changes that break layout.

## Trigger

User says: "Visual diff <url-A> vs <url-B>" / "Run PB-3 on staging vs prod" / "Check for visual regressions in this PR"

## What it does

1. Take screenshots of `<url-A>` at multiple viewports (desktop + mobile)
2. Take screenshots of `<url-B>` at same viewports
3. Run pixelmatch + reg-cli to generate diff
4. Output diff report with images

## Steps

```bash
bash ~/workbench/scripts/visual-diff.sh <url-A> <url-B>
```

The script:

1. Creates `/tmp/visual-diff-<timestamp>/` working dir
2. Launches Playwright headless chromium
3. Captures `<url-A>` at viewports: 1920x1080, 1440x900, 768x1024, 375x667
4. Captures `<url-B>` at same viewports
5. Runs pixelmatch per viewport pair
6. Generates HTML report at `/tmp/visual-diff-<timestamp>/report.html`
7. Outputs summary to terminal

## Output

```
=== PB-3: Visual Regression ===

URL A: https://staging.myproject.com
URL B: https://myproject.com
Viewports: 4 (desktop-2k, desktop-laptop, tablet, mobile)

Results:
- desktop-2k:    diff = 0.02%  (within tolerance, likely antialiasing)
- desktop-laptop: diff = 0.01%  (within tolerance)
- tablet:        diff = 4.2%   ⚠ ABOVE TOLERANCE
- mobile:        diff = 12.1%  ⚠ ABOVE TOLERANCE — significant change

Report: file:///tmp/visual-diff-20260430-1423/report.html
Open in browser to inspect.

Tolerance setting: 1.0% (configurable via --tolerance flag)
ACU: 0.4
```

## Tolerance defaults

| Viewport | Default tolerance | Reason |
|---|---|---|
| desktop-2k | 0.5% | High DPI, subtle diffs are real |
| desktop-laptop | 1.0% | Standard |
| tablet | 1.5% | Layout shifts more common |
| mobile | 2.0% | Most variation in mobile rendering |

User can override: `bash visual-diff.sh <a> <b> --tolerance 0.5`

## When to run

- Before merging a PR that touches CSS/layout
- Before/after a deploy to catch unintended visual changes
- After updating dependencies (e.g., new Tailwind version)
- Routine: weekly on production to catch visual drift from external CDN changes

## When NOT to run

- For pure backend changes (waste of ACU)
- For sites behind login walls without saved auth state (won't capture real pages)
- For sites with heavy random/dynamic content (false positives dominate)

## Caveats

- Screenshots happen sequentially per viewport (parallel breaks visual fidelity sometimes)
- Animation timing matters — wait 2s after page load before capture
- Cookie banners cause false positives — script auto-dismisses common ones
- Auth: pre-saved Playwright auth state can be loaded with `--auth-state <path>`

## Cost

| Site complexity | Approx ACU |
|---|---|
| Simple landing page | 0.3 |
| Standard webapp | 0.5 |
| Complex SPA, many viewports | 1.0 |
| Site requiring auth | 1.5 |

ollama path is not used here (visual, not LLM). Cost is pure Devin compute time.
