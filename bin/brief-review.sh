#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: brief-review <path-to-brief> <review-name> [review-id]"
  echo ""
  echo "Options:"
  echo "  --on-rate-limit <behaviour>   What to do if an agent hits a 429 (default: skip)"
  echo ""
  echo "    exit          Stop immediately and report the error"
  echo "    skip          Skip the failed agent and continue (default)"
  echo "    retry:N:Xs    Wait X seconds and retry up to N times, then skip"
  echo "                  Note: each retry re-runs the full agent and burns tokens"
  echo ""
  echo "Environment variables:"
  echo "  OUTPUT_DIR   Directory to write reviews (default: docs/reviews)"
  echo ""
  echo "Examples:"
  echo "  brief-review briefs/auth-service.md auth-service-review"
  echo "  brief-review briefs/auth-service.md auth-service-review 002 --on-rate-limit exit"
  echo "  brief-review briefs/auth-service.md auth-service-review 002 --on-rate-limit retry:2:60s"
  echo "  OUTPUT_DIR=output/reviews brief-review briefs/auth-service.md auth-service-review"
  exit 1
}

BRIEF="${1:-}"
REVIEW_NAME="${2:-}"
REVIEW_ID="${3:-$(date +%Y%m%d)-001}"
ON_RATE_LIMIT="skip"

# Shift past the positional args (only as many as were provided)
shift $(( $# < 3 ? $# : 3 ))
while [[ $# -gt 0 ]]; do
  case "$1" in
    --on-rate-limit)
      ON_RATE_LIMIT="${2:?--on-rate-limit requires a value}"
      shift 2
      ;;
    --help|-h)
      usage
      ;;
    *)
      echo "Error: unknown option '$1'" >&2
      usage
      ;;
  esac
done

if [[ -z "$BRIEF" || -z "$REVIEW_NAME" ]]; then
  usage
fi

if [[ ! -f "$BRIEF" ]]; then
  echo "Error: brief not found at '$BRIEF'" >&2
  exit 1
fi

OUTPUT_DIR="${OUTPUT_DIR:-docs/reviews}"

# Build the rate limit behaviour instruction to inject into the prompt
case "$ON_RATE_LIMIT" in
  exit)
    RATE_LIMIT_BEHAVIOUR="If an agent returns a rate limit error (429), **DO NOT RETRY**. Stop immediately and report: \"RATE_LIMIT_ERROR: {subagent_name}\""
    ;;
  skip)
    RATE_LIMIT_BEHAVIOUR="If an agent returns a rate limit error (429), skip it without retrying, record the skip, and continue with the remaining agents. Note any skipped agents in the synthesis."
    ;;
  retry:*:*)
    COUNT=$(echo "$ON_RATE_LIMIT" | cut -d: -f2)
    DELAY=$(echo "$ON_RATE_LIMIT" | cut -d: -f3)
    if ! [[ "$COUNT" =~ ^[0-9]+$ ]]; then
      echo "Error: retry count must be a number (got '$COUNT')" >&2
      exit 1
    fi
    RATE_LIMIT_BEHAVIOUR="If an agent returns a rate limit error (429), wait ${DELAY} then retry, up to ${COUNT} time(s). If still failing after ${COUNT} attempt(s), skip it, record the skip, and continue with the remaining agents. Note any skipped agents in the synthesis."
    ;;
  *)
    echo "Error: unknown --on-rate-limit value '$ON_RATE_LIMIT'. Use: exit, skip, or retry:N:Xs" >&2
    exit 1
    ;;
esac

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
  -e "s|{{RATE_LIMIT_BEHAVIOUR}}|$RATE_LIMIT_BEHAVIOUR|g" \
  "$PROMPT_TEMPLATE")

mkdir -p "$OUTPUT_DIR"

# --permission-mode acceptEdits is required for subagents to write review files
# without prompting. Path-restricted Write patterns (e.g. Write(./docs/**)) are not
# reliably respected by subagents (anthropics/claude-code#33901), and wildcard
# pattern matching itself has known bugs (#28023, #37496). Revisit when fixed.
echo "$PROMPT" | claude --print --permission-mode acceptEdits --allowedTools "Read,Write,WebSearch,WebFetch"
