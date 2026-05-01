#!/usr/bin/env bash
# bootstrap-project.sh — Scaffold new project from template.
#
# Usage:
#   bootstrap-project.sh <name> [--template python-fastapi|nextjs-shadcn]

set -uo pipefail

NAME="${1:-}"
TEMPLATE="python-fastapi"  # default

shift || true
while [[ $# -gt 0 ]]; do
  case $1 in
    --template) TEMPLATE=$2; shift 2 ;;
    *) shift ;;
  esac
done

if [ -z "$NAME" ]; then
  echo "Usage: $0 <name> [--template python-fastapi|nextjs-shadcn]" >&2
  exit 64
fi

# Validate name (kebab-case, no caps, no underscores)
if ! [[ "$NAME" =~ ^[a-z][a-z0-9-]*$ ]]; then
  echo "ERROR: name must be lowercase kebab-case (e.g., my-project)" >&2
  exit 1
fi

# Check template exists
TEMPLATE_DIR="$HOME/workbench/templates/$TEMPLATE"
if [ ! -d "$TEMPLATE_DIR" ]; then
  echo "ERROR: template not found: $TEMPLATE_DIR" >&2
  echo "Available templates:" >&2
  ls "$HOME/workbench/templates/" >&2
  exit 1
fi

# Check destination doesn't exist
DEST="$HOME/projects/$NAME"
if [ -e "$DEST" ]; then
  echo "ERROR: $DEST already exists. Pick a different name or remove the existing dir." >&2
  exit 1
fi

mkdir -p "$HOME/projects"

echo "=== Bootstrapping $NAME from $TEMPLATE ==="
echo

# 1. Copy template
cp -r "$TEMPLATE_DIR" "$DEST"
cd "$DEST"

# 2. Replace placeholders
NAME_SNAKE=$(echo "$NAME" | tr '-' '_')
NAME_PASCAL=$(echo "$NAME" | sed -E 's/(^|-)([a-z])/\U\2/g')

find . -type f \( -name "*.toml" -o -name "*.json" -o -name "*.md" -o -name "*.py" -o -name "*.ts" -o -name "*.tsx" -o -name "*.envrc" \) -exec \
  sed -i "s|{{PROJECT_NAME}}|$NAME|g; s|{{PROJECT_NAME_SNAKE}}|$NAME_SNAKE|g; s|{{PROJECT_NAME_PASCAL}}|$NAME_PASCAL|g" {} +

# 3. Rename source dir if Python template
if [ -d "src/PLACEHOLDER" ]; then
  mv src/PLACEHOLDER "src/$NAME_SNAKE"
fi

# 4. Init Git
git init -q
git add -A
git commit -q -m "chore: initial scaffold from $TEMPLATE template"

# 5. GitHub repo (if gh available)
if command -v gh &>/dev/null; then
  echo "Creating private GitHub repo..."
  gh repo create "$NAME" --private --source . --push 2>&1 || echo "WARN: gh repo create failed (continue without GH)"
else
  echo "gh CLI not found. Skip GitHub setup (run manually later)."
fi

# 6. direnv setup
if [ -f ".envrc" ]; then
  direnv allow . 2>/dev/null || echo "WARN: run 'direnv allow' manually"
fi

# 7. Install deps + smoke test
case $TEMPLATE in
  python-fastapi)
    echo "Installing Python deps..."
    uv pip install -e . 2>&1 | tail -5
    echo "Running smoke test..."
    uv run pytest tests/ -v 2>&1 | tail -10
    ;;
  nextjs-shadcn)
    echo "Installing Node deps..."
    pnpm install 2>&1 | tail -5
    echo "Running smoke test..."
    pnpm run --if-present test 2>&1 | tail -10
    ;;
esac

# 8. Print next steps
cat <<EOF

=== Bootstrap complete ===

Project: $NAME
Template: $TEMPLATE
Location: $DEST
Branch: main (initial commit)

Next steps:
  cd ~/projects/$NAME
  $([ -f ".envrc" ] && echo "direnv allow")
  
For Larder integration:
  larder list --cat api    # see what's available
  larder use api/<name>    # add as dep

For PB-1 review of the scaffold itself:
  bash ~/workbench/scripts/three-ai-consensus.sh --branch HEAD~1...HEAD

EOF
