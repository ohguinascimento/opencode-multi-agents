# Handoff: AGENTS.md Update

**Date**: 2026-09-11
**Agent**: Documentation Analyst
**Task**: Update AGENTS.md to be compact, high-signal, repo-specific guidance

## Sources Read
- `AGENTS.md` (current version)
- `opencode.json` (verified schema, model, instructions, skills, agents)
- `.opencode/AGENT-POLICY.md` (product code policy)
- `README.md` (commands, setup flow)
- `docs/development.md` (Fleet app conventions, env, troubleshooting)
- `composer.json` and `frontend/package.json` (verified via context)
- `.opencode/state/workflow.json` (status: not_started, gates: pending)

## Files Changed
| File | Change |
|------|--------|
| `AGENTS.md` | Updated in place: compacted, removed fluff, preserved all verified facts |

## Verified Facts
- `opencode.json` uses `$schema: https://opencode.ai/config.json`, model `opencode/big-pickle`
- Instructions list matches: `AGENTS.md`, `README.md`, `.opencode/AGENT-POLICY.md`, `.opencode/memory/project.md`, `.opencode/memory/decisions/README.md`
- Agent files: `.opencode/agents/*.md` (plural); command files: `.opencode/command/*.md` (singular); skills: `.opencode/skills/<name>/SKILL.md`
- `.env.example` root is multi-agent/AI config, not Laravel (confirmed in `docs/development.md`)
- No `tests/` directory; frontend has `npm run build` and `npm run lint` only
- Fleet app: Laravel 12/PHP 8.2 backend, React 18/TS/Vite frontend, Docker with auto-migrate

## Validation Done
- Read final `AGENTS.md` after edit: all sections present and compact
- `opencode.json` not modified (no config-time change needed)
- No ADRs exist in `.opencode/memory/decisions/` (only README and TEMPLATE)
- No changes to `workflow.json` (no executable evidence to update gates)

## Validation Pending
- Cannot run shell commands to verify JSON validity or file system state
- User should verify OpenCode loads the updated instructions (restart/new session recommended)

## Limitations
- Did not run `opencode.json` through JSON validator (no shell access)
- Did not verify agent files exist on disk (relied on context and existing AGENTS.md claims)
- `workflow.json` not modified as no evidence of gate completion exists

## Recommendations
- **Restart OpenCode** or start a new session to ensure updated AGENTS.md is loaded
- If any agent paths or skill names are wrong, they will be caught on next OpenCode startup (strict schema validation)
