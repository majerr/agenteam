# agenteam

A shared library of reusable Claude Code workflow agents, prompts, and invocation scripts.

## Architecture

| Layer | Location | Purpose |
|-------|----------|---------|
| Agent definitions | `agents/` | Generic agent roles for `.claude/agents/` |
| Orchestration prompts | `prompts/` | Workflow logic with `{{PLACEHOLDERS}}` |
| Invocation scripts | `bin/` | Interpolate + invoke `claude` non-interactively |

Agents and prompts are generic — no hardcoded paths or project-specific references. Invocation scripts supply project context at runtime.

## Installation

```bash
# Install agents globally (available in all projects)
./install.sh

# Or install into a specific project
./install.sh --project /path/to/your/project
```

## Usage

Run an invocation script from your project root:

```bash
brief-review path/to/brief.md
```

Override the output directory if your project uses a different convention:

```bash
OUTPUT_DIR=output/reviews brief-review path/to/brief.md
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Security guidance is in [SECURITY.md](SECURITY.md).

## License

[MIT](LICENSE)
