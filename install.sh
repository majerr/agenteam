#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  echo "Usage: install.sh [--global] [--project <path>]"
  echo ""
  echo "  --global            Install agents to ~/.claude/agents/ and scripts to ~/.local/bin/"
  echo "  --project <path>    Install agents into <path>/.claude/agents/ only"
  echo ""
  echo "If no flag is given, --global is assumed."
  exit 1
}

install_global() {
  echo "Installing agents to ~/.claude/agents/ ..."
  mkdir -p ~/.claude/agents
  find "$SCRIPT_DIR/agents" -name "*.md" -exec cp {} ~/.claude/agents/ \;
  echo "  $(find "$SCRIPT_DIR/agents" -name "*.md" | wc -l | tr -d ' ') agent(s) installed."

  echo "Installing scripts to ~/.local/bin/ ..."
  mkdir -p ~/.local/bin
  for script in "$SCRIPT_DIR/bin/"*.sh; do
    name=$(basename "$script" .sh)
    cp "$script" ~/.local/bin/"$name"
    chmod +x ~/.local/bin/"$name"
    echo "  Installed: $name"
  done

  echo ""
  echo "Done. Make sure ~/.local/bin is on your PATH."
  echo "  bash/zsh: export PATH=\"\$HOME/.local/bin:\$PATH\""
}

install_project() {
  local project_dir="$1"
  if [[ ! -d "$project_dir" ]]; then
    echo "Error: directory not found: $project_dir" >&2
    exit 1
  fi

  echo "Installing agents to $project_dir/.claude/agents/ ..."
  mkdir -p "$project_dir/.claude/agents"
  find "$SCRIPT_DIR/agents" -name "*.md" -exec cp {} "$project_dir/.claude/agents/" \;
  echo "  $(find "$SCRIPT_DIR/agents" -name "*.md" | wc -l | tr -d ' ') agent(s) installed."
  echo "Done."
}

case "${1:---global}" in
  --global)
    install_global
    ;;
  --project)
    [[ -n "${2:-}" ]] || usage
    install_project "$2"
    ;;
  *)
    usage
    ;;
esac
