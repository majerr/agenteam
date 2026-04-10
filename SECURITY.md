# Security Policy

## What not to commit

Agents and prompts in this repo are **generic and reusable**. Before contributing, check that your files contain none of the following:

- API keys, tokens, or credentials of any kind
- Internal URLs, hostnames, or IP addresses
- Organisation or project names that could identify internal systems
- Personal data (names, emails, user IDs)
- Hardcoded file paths specific to a project or user
- Client or customer references

If an agent or prompt needs a value that varies by project, use a `{{PLACEHOLDER}}` instead. See [CONTRIBUTING.md](CONTRIBUTING.md) for the placeholder convention.

## Agent memory

Agent memory directories (`.claude/agent-memory/`) are excluded from version control via `.gitignore` because they accumulate project-specific context that may be sensitive. Do not commit agent memory files.

## Reporting a vulnerability

If you discover a security issue in this repo — for example, a committed secret or a prompt that could be exploited to exfiltrate data — please open a private [GitHub Security Advisory](../../security/advisories/new) rather than a public issue.
