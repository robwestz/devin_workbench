# devin_workbench Testing and Development Skill

Use this skill when changing or testing `robwestz/devin_workbench`.

## Repo Orientation

- Source of truth: `~/workbench` symlinked to `~/repos/devin_workbench`.
- Start by reading `README.md`, `SPEC.md`, `LESSONS.md`, `ANTI_PATTERNS.md`, and the relevant `playbooks/` file.
- The repo is mostly Markdown and Bash, not a TypeScript app. Do not assume `npm test` or frontend UI routes exist.
- Runtime/generated workbench artifacts should stay ignored and out of commits.

## Devin Secrets Needed

- Local workbench CLI/playbook tests: no secrets required.
- PB-1 or real cross-AI reviewer runs may need `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, or authenticated Claude/Codex/Ollama CLIs depending on the snapshot.
- PB-7 packet generation itself does not need secrets. If testing a real logged-in target app, request app-specific credentials through Devin Secrets instead of storing them in the repo.

## Current-Session Setup Checks

After pulling new scripts into an already-running session, refresh script symlinks because environment maintenance may have run before the new file existed:

```bash
mkdir -p "$HOME/.local/bin"
for script in "$HOME/repos/devin_workbench"/scripts/*.sh; do
  ln -sfn "$script" "$HOME/.local/bin/$(basename "$script" .sh)"
done
```

Verify a new script is reachable:

```bash
command -v visual-ai-jury
```

Future sessions should get these links automatically from the org maintenance config, but the refresh is useful immediately after merging a new script.

## Standard Validation Commands

Run these after Bash/playbook changes:

```bash
bash -n scripts/<changed-script>.sh
.git/hooks/pre-commit
git diff --check
```

Run script self-tests when available:

```bash
visual-ai-jury --self-test
scripts/self-improvement-experiment.sh --self-test
```

If PB-1 is used, first verify reviewer tools exist so missing CLI output is not mistaken for review findings:

```bash
command -v claude || true
command -v codex || true
command -v ollama || true
```

## Testing PB-7 Visual AI Jury

For shell-only validation, do not record the desktop. Collect command output and generated files instead.

Minimal E2E flow:

```bash
TEST_ROOT="$HOME/visual-ai-jury-e2e"
rm -rf "$TEST_ROOT"
mkdir -p "$TEST_ROOT/input"
printf 'fake screenshot evidence for e2e\n' > "$TEST_ROOT/input/homepage.png"
export DEVIN_VISUAL_AI_JURY_DIR="$TEST_ROOT/jury"

visual-ai-jury init --id e2e --url https://example.com --goal "Verify homepage visual QA packet"
visual-ai-jury note --id e2e --step "Opened homepage" --observation "Hero heading visible and primary CTA present"
visual-ai-jury console --id e2e --summary "No console errors observed during homepage load"
visual-ai-jury screenshot --id e2e --path "$TEST_ROOT/input/homepage.png" --label "Homepage loaded"
visual-ai-jury packet --id e2e
visual-ai-jury status --id e2e
```

Assertions to check:

- `PACKET.md`, `meta.json`, `notes.md`, `console.md`, `screenshots.md`, and copied screenshot file exist.
- `PACKET.md` preserves the exact target URL and goal.
- Observation and console/network notes appear in `PACKET.md`.
- `screenshots.md` indexes the screenshot label and copied path.
- Reviewer JSON contract includes `critical`, `ux`, `suggested`, and `discard`.

Negative check:

```bash
visual-ai-jury screenshot --id e2e --path /no/such/file.png --label Missing
```

Expected failure:

```text
ERROR: screenshot not found: /no/such/file.png
```

## Reporting

- For shell-only tests, attach a markdown report and relevant text artifacts (`PACKET.md`, command log) rather than a screen recording.
- If testing an open or recently merged PR, post one concise PR comment with pass/fail assertions and a link to the Devin session.
- If a test setup issue is caused by current-session drift, state it as a caveat and document the workaround.