---
name: documentation
description: Create and maintain accurate technical documentation for software projects, including architecture, APIs, setup, workflows, decisions, testing, deployment, and changelogs. Use when documenting a new project, updating docs after code changes, generating an API guide, or synchronizing documentation with verified project state.
---

# Documentation

Create documentation from evidence in the repository, not from assumptions. Keep it concise, actionable, and synchronized with the implementation.

## Workflow

1. Inspect the repository structure, README, manifests, routes, configuration, tests, deployment files, and accepted decisions.
2. Identify the audience: developer, operator, product user, maintainer, or reviewer.
3. Establish the scope and list missing or contradictory information.
4. Verify claims against source files or commands. Mark unverified items as `TODO` or `proposed`.
5. Write or update the smallest set of documents that answers the request.
6. Cross-check commands, paths, environment variables, endpoints, and examples against the repository.
7. Run relevant validation when possible and record the command and result.
8. Report changed files, verified facts, open gaps, and recommended next steps.

## Documentation set

Choose only the documents needed:

- `README.md`: purpose, prerequisites, quick start, and basic usage.
- `docs/architecture.md`: components, boundaries, data flow, integrations, and trade-offs.
- `docs/api.md`: authentication, endpoints, parameters, responses, errors, and examples.
- `docs/development.md`: local setup, conventions, tests, lint, and troubleshooting.
- `docs/deployment.md`: environments, variables, build, migrations, health checks, rollback, and monitoring.
- `docs/decisions/ADR-NNN.md`: durable technical decisions and their impact.
- `CHANGELOG.md`: user-visible changes organized by version or date.

Do not invent endpoints, credentials, performance numbers, test coverage, or deployment steps. Never include secrets or real tokens.

## Project memory and gates

Read `.opencode/memory/project.md`, accepted decisions under `.opencode/memory/decisions/`, `.opencode/state/workflow.json`, and `.opencode/state/GATES.md` when they exist. Preserve accepted decisions and document conflicts instead of silently changing them.

Documentation may claim a gate passed only when its evidence exists in the workflow state or handoff. Distinguish these labels:

- **Verified**: confirmed by source code, command output, or user.
- **Inferred**: reasonable interpretation that still needs confirmation.
- **Proposed**: recommendation not yet approved.
- **Missing**: expected information not found.

## Quality checklist

- Match the actual stack and directory structure.
- Use exact commands and paths.
- Explain required environment variables without exposing values.
- Include failure modes and troubleshooting where useful.
- Keep examples minimal and executable.
- Link related documents and decisions.
- Update documentation when code, API, architecture, or deployment changes.
- Finish with a short validation report and unresolved gaps.

## Output format

When reporting documentation work, use:

```markdown
## Documentation — [status]

### Updated files
- [path]: [what changed]

### Verified
- [fact and source]

### Gaps
- [missing or unverified information]

### Validation
- `[command]` — [result]
```
