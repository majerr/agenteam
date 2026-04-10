# agenteam

A shared library of reusable Claude Code workflow agents.

## Architecture

Three layers — keep them separate:

- **`agents/`** — Agent definitions (`.md` files for `.claude/agents/`). Generic behaviour only. No hardcoded paths, no project names, no internal URLs.
- **`prompts/`** — Orchestration prompts with `{{PLACEHOLDER}}` syntax for all variable content.
- **`bin/`** — Shell scripts that interpolate placeholders and invoke `claude` non-interactively. These are installed to PATH.

## Placeholder convention

Variable content in prompts uses `{{UPPER_SNAKE_CASE}}`:

```
Write your output to {{OUTPUT_DIR}} following the naming convention ...
```

Invocation scripts in `bin/` substitute these before passing the prompt to `claude --print`.

## Agent authoring rules

- Agents must be generic — no project-specific assumptions
- Where an output path is needed, accept it via the invoking prompt (`{{OUTPUT_DIR}}`) or instruct the agent to check project conventions at runtime
- Group agents and prompts under a workflow type subdirectory (e.g. `agents/review/`, `prompts/review/`)

## Security

- Never commit secrets, API keys, internal URLs, or personal data
- Agent memory (`.claude/agent-memory/`) is gitignored — do not force-add it
- See SECURITY.md for full guidance
