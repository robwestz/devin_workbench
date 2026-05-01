# ~/workbench/.bashrc.d/00-workbench.sh
# Aliases and functions for the Compounding Workbench.

# Quick jumps
alias wb='cd ~/workbench'
alias projects='cd ~/projects'
alias lessons='${EDITOR:-nano} ~/workbench/LESSONS.md'

# Project navigation function
pj() {
  if [ -z "$1" ]; then
    ls ~/projects/
    return
  fi
  if [ -d "$HOME/projects/$1" ]; then
    cd "$HOME/projects/$1"
  else
    echo "Project '$1' not found. Use 'pj' alone to list, or PB-6 to bootstrap."
    return 1
  fi
}

# Cross-AI quick aliases
alias review-panel='~/workbench/scripts/three-ai-consensus.sh'
alias claude-review='~/workbench/scripts/claude-review.sh'
alias codex-review='~/workbench/scripts/codex-review.sh'

# Visual diff
alias visual-diff='~/workbench/scripts/visual-diff.sh'

# Cost tracking
alias acu-track='~/workbench/scripts/acu-track.sh'
alias acu-summary='~/workbench/scripts/acu-track.sh --summary'

# Observer
alias observer='~/workbench/scripts/observer.sh'

# Quick lessons-add
add-lesson() {
  if [ -z "$1" ]; then
    echo "Usage: add-lesson '<tag>' '<observation>' '<mitigation>'"
    return 64
  fi
  echo "$(date +%Y-%m-%d) | $1 | $2 | $3" >> ~/workbench/LESSONS.md
  echo "Lesson added."
}

# Display motd on session start (if interactive)
if [[ $- == *i* ]] && [ -f ~/workbench/LESSONS.md ]; then
  recent_lessons=$(grep -v "^#" ~/workbench/LESSONS.md | grep -E "^20[0-9]{2}-" | tail -5)
  if [ -n "$recent_lessons" ]; then
    echo "=== Recent lessons (read more: lessons) ==="
    echo "$recent_lessons" | sed 's/^/  /'
    echo
  fi
fi
