# Meta Desktop Ideas

> What becomes possible because Devin has a real desktop, not just a chat box or CLI.

## Core model

Devin's desktop should be treated as a **control plane**, not the compute plane.

Heavy work can run elsewhere:

- hosted OpenClaw or other browser-based agents
- Claude/Codex/Gemini web UIs
- remote VS Code, Jupyter, notebooks, dashboards, deploy consoles
- cloud-hosted test runners and preview environments

Devin uses the desktop for what only a desktop can do:

- operate logged-in GUI tools without an API
- verify visual state in a real browser
- record proof for the user
- inspect console/network/devtools-style evidence
- coordinate multiple tools side by side
- compare what humans and AI reviewers would actually see

The goal is not "GUI everywhere." The goal is **CLI-first execution with visual proof where reality matters**.

## Ranked ideas

### 1. Visual AI Jury

Devin tests a running app like a human QA lead, captures evidence, then asks multiple AI reviewers to critique the same packet.

Why it matters:

- catches UX, copy, layout, auth, navigation, and console issues that code review misses
- produces user-visible proof via screenshots/recording
- turns multiple AIs into an attention filter instead of another chat thread
- fits solo development: one Devin session acts as QA, product reviewer, and engineer

This is now PB-7.

### 2. Hosted Tool Control Plane

If a tool is too heavy for the Devin VM, host it elsewhere and let Devin drive it through Chrome.

Examples:

- hosted OpenClaw
- hosted browser agents
- cloud notebooks
- dashboards with no API
- specialized SaaS tools

Rule: hosted compute, desktop orchestration.

### 3. Long-Running Observing Incubator

Devin watches a deploy preview, CI job, staging URL, or logs for hours, then captures the moment something fails.

This is covered by PB-5. The desktop extension is to capture browser screenshots/recordings when the trigger is visual.

### 4. Recursive Self-Improvement Lab

Devin records where workbench use is slow or fragile, proposes small improvements, and only applies reversible low-risk helpers.

This is in `experiments/self-improvement-loop/`. Keep it experimental until it proves useful across multiple sessions.

### 5. Digital Twin of the User's Workflow

Useful only in a narrow sense: encode preferences, shortcuts, QA rituals, and review habits.

Not useful as a literal copy of the user's IDE. The workbench already rejected "VS Code inside Devin" as too slow and brittle.

## Ideas to avoid for now

### Devin-in-Devin

Starting Devin sessions from Devin's browser is meta, but weak as a default workflow:

- auth and permissions are brittle
- supervision becomes confusing
- native child sessions/playbooks are cleaner when available
- risk of cost runaway is higher

Use explicit child-session tooling instead of GUI recursion.

### GUI IDE inside Devin

Running Cursor/VS Code inside Devin looks cool but duplicates what the user already has locally.

Prefer:

- CLI edits
- browser for real app verification
- external AI tools via API/CLI where possible
- GUI only when no API exists or visual state matters

### Full Wireshark-style "watch everything" robot

Too noisy for solo development. Use targeted observers, browser console/network notes, and app logs instead.

## Operating principles

1. **Desktop for evidence.** If the output needs visual trust, record it.
2. **Hosted compute when heavy.** Do not force heavyweight tools into the snapshot.
3. **AI reviewers get packets, not vague prompts.** Screenshots, console notes, task goal, URL, and diff context.
4. **Consensus before patching.** Fix only issues with clear evidence or multi-reviewer agreement.
5. **No secret scraping.** Browser auth is for operating tools, not extracting credentials.
6. **No hidden autonomy.** Anything that changes code, config, billing, deploys, or snapshot state needs a PR or explicit approval.

## What would be a genuine gamechanger

The best workflow is:

1. Devin opens the app in a real browser.
2. Devin performs the golden path and records proof.
3. Devin captures console/network errors and UX observations.
4. Devin creates a review packet.
5. Claude/Codex/Gemini/OpenClaw critique the same packet.
6. Devin merges reviewer output into consensus/divergence.
7. Devin fixes consensus issues.
8. Devin reruns the same visual flow and attaches proof to the PR.

That is the solo-developer version of a product team: engineer, QA, reviewer, and UX critic compressed into one controlled loop.
