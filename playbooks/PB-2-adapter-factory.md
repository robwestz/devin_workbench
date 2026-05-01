# PB-2 — Adapter Factory Run

> Generate a new API adapter and add it to Larder.

## Trigger

User says: "Generate adapter for <api-doc-url>" / "Add <X> to my Larder" / "Run PB-2 with <url>"

## What it does

This playbook is the **integration point between Workbench and Larder**. It uses the spawn-claude.sh script from Larder to generate a single adapter on demand.

Pre-requisite: Larder is built (Phase 0 + 1 complete). If Larder doesn't exist yet, this playbook errors out.

## Steps

1. **Verify Larder is set up:**
   ```bash
   if [ ! -d ~/larder ] || [ ! -f ~/larder/.larder/BASE_ADAPTER_v0.md ]; then
     echo "ERROR: Larder not initialized. Build Larder first."
     exit 1
   fi
   ```

2. **Confirm API is keyless** (Phase 1 of Larder is keyless-only — keyed APIs come in future phases):
   ```bash
   # Devin asks user to confirm: is <api> keyless? Or do we need to extend Larder for keyed APIs?
   ```

3. **Add to ad-hoc build plan:**
   ```bash
   # Devin generates a one-target build plan
   cat > /tmp/adhoc-target.yaml <<EOF
   targets:
     - name: <name>
       docs: <url>
       capabilities: <list>
       notes: <user provided>
   EOF
   ```

4. **Run construction crew on single target:**
   ```bash
   bash <larder-build-repo>/scripts/spawn-claude.sh <name>
   ```

5. **Validate:**
   ```bash
   bash <larder-build-repo>/scripts/validator-chain.sh <name>
   ```

6. **On pass, commit to vault and run PB-1 (cross-AI review) on the result:**
   ```bash
   # Move to ~/larder/api/<name>/, run larder add, push
   # Then PB-1 reviews the new adapter code
   ```

7. **On consensus-pass from PB-1: done.** On divergence: present to user for decision.

## When NOT to run PB-2

- **API requires auth** — Larder Phase 1 is keyless. Wait for keyed-API phase.
- **API is undocumented** — without docs, Claude can only guess. High failure rate.
- **API doc is in non-English** — works but lossy. Best results with English docs.
- **For internal/private APIs** — different category; these belong in `larder/tools/`, not `larder/api/`.

## Cost

Single adapter via PB-2: ~3 ACU + LLM tokens (Sonnet for generation, second Sonnet for review, ollama for sanity = ~$0.30 in API costs at most).

Compare to manually writing an adapter: ~30 minutes of focused work. PB-2 is cheaper if you'll use the API more than twice.

## Difference from Larder Phase 1 batch run

- Phase 1: 30 adapters in parallel, batch
- PB-2: 1 adapter on demand, integrated with PB-1 review

## Output

```
=== PB-2: Adapter Factory ===

Target: <name>
Docs: <url>
Capabilities: <list>

Generation: ✓ (Sonnet via Claude Code, 47s)
Validation chain: ✓ (6/6 steps passed, 22s)
Live API call: ✓ (p50: 142ms, p95: 380ms)
PB-1 review: ✓ (consensus: clean; 1 nitpick noted)

Committed to: ~/larder/api/<name>/
Manifest: ~/larder/api/<name>/manifest.json
Vault repo: pushed

Use it:
  $ larder use api/<name>
  
ACU: 3.2
LLM cost: ~$0.18
```
