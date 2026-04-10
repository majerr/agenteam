# Contributing

## Architecture

This repo has three layers. Keep them separate:

| Layer | Location | Rule |
|-------|----------|------|
| Agent definitions | `agents/` | Generic behaviour only — no paths, no project context |
| Orchestration prompts | `prompts/` | Generic logic with `{{PLACEHOLDERS}}` for variable content |
| Invocation scripts | `bin/` | Interpolate placeholders, invoke `claude` non-interactively |

## Adding an agent

1. Create `agents/<workflow-type>/<agent-name>.md`
2. Define role, capabilities, and output behaviour — but **not** output paths
3. Where the agent needs a path, instruct it to accept the path from the invoking prompt or check project conventions at runtime
4. Update `prompts/` and `bin/` if the agent needs an orchestration prompt or invocation script

## Placeholder convention

Prompts use `{{UPPER_SNAKE_CASE}}` for variable content:

```
Output your review to {{OUTPUT_DIR}} using the naming convention ...
```

Invocation scripts substitute these before passing the prompt to `claude`.

## Checklist before opening a PR

- [ ] No hardcoded file paths or project-specific references in agents or prompts
- [ ] No secrets, API keys, credentials, or internal URLs
- [ ] All variable content uses `{{PLACEHOLDER}}` syntax
- [ ] Agent behaviour is generic (adapts to project conventions at runtime where needed)
- [ ] New agents/prompts are grouped under the appropriate workflow type
- [ ] CONTRIBUTING.md or README updated if you've introduced a new pattern

## Commit style

Use the imperative mood: `Add software-architect agent`, `Fix output path placeholder in brief-review prompt`.
