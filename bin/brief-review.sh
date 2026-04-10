#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: brief-review <path-to-brief> <review-name> [review-id]"
  echo ""
  echo "Environment variables:"
  echo "  OUTPUT_DIR   Directory to write reviews (default: docs/reviews)"
  echo ""
  echo "Examples:"
  echo "  brief-review briefs/auth-service.md auth-service-review"
  echo "  OUTPUT_DIR=output/reviews brief-review briefs/auth-service.md auth-service-review 002"
  exit 1
}

BRIEF="${1:-}"
REVIEW_NAME="${2:-}"

if [[ -z "$BRIEF" || -z "$REVIEW_NAME" ]]; then
  usage
fi

if [[ ! -f "$BRIEF" ]]; then
  echo "Error: brief not found at '$BRIEF'" >&2
  exit 1
fi

REVIEW_ID="${3:-$(date +%Y%m%d)-001}"
OUTPUT_DIR="${OUTPUT_DIR:-docs/reviews}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPT_TEMPLATE="$SCRIPT_DIR/../prompts/review/brief-review.md"

# Fall back to the global install location if not running from the repo directly
if [[ ! -f "$PROMPT_TEMPLATE" ]]; then
  PROMPT_TEMPLATE="${XDG_DATA_HOME:-$HOME/.local/share}/agenteam/prompts/review/brief-review.md"
fi

if [[ ! -f "$PROMPT_TEMPLATE" ]]; then
  echo "Error: prompt template not found. Re-run install.sh to reinstall." >&2
  exit 1
fi

PROMPT=$(sed \
  -e "s|{{BRIEF_PATH}}|$BRIEF|g" \
  -e "s|{{REVIEW_ID}}|$REVIEW_ID|g" \
  -e "s|{{REVIEW_NAME}}|$REVIEW_NAME|g" \
  -e "s|{{OUTPUT_DIR}}|$OUTPUT_DIR|g" \
  "$PROMPT_TEMPLATE")

mkdir -p "$OUTPUT_DIR"

# --permission-mode acceptEdits is required for subagents to write review files
# without prompting. Path-restricted Write patterns (e.g. Write(./docs/**)) are not
# reliably respected by subagents (anthropics/claude-code#33901), and wildcard
# pattern matching itself has known bugs (#28023, #37496). Revisit when fixed.
echo "$PROMPT" | claude --print --permission-mode acceptEdits --allowedTools "Read,Write,WebSearch,WebFetch"
