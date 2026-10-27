# Repository Instructions

## Scope
- This repo is the `opencode-multi-agents` package: OpenCode agents, commands, skills, schemas, state, and operational docs.
- **Do not assume the repo root is the user's product project.** `.opencode/AGENT-POLICY.md` requires asking for and confirming the absolute target path before creating product code (`app/`, `src/`, `frontend/`, `backend/`, `tests`, etc.).

## OpenCode Config
- `opencode.json` is strict-schema (`$schema: https://opencode.ai/config.json`); invalid fields prevent startup.
- Instructions loaded: `AGENTS.md`, `README.md`, `.opencode/AGENT-POLICY.md`, `.opencode/memory/project.md`, `.opencode/memory/decisions/README.md`.
- After changing `opencode.json`, `.opencode/agents/*`, `.opencode/command/*`, `.opencode/skills/*`, or plugins: **tell user to restart OpenCode**; config is not hot-reloaded.
- Paths: agents in `.opencode/agents/*.md` (plural); commands in `.opencode/command/*.md` (singular); skills in `.opencode/skills/<name>/SKILL.md`.
- Available skills: `api-design`, `database-design`, `documentation`, `security-best-practices`, `system-design`, `testing-strategies`.

## Multi-Agent Package Commands
- Start OpenCode: `./start.sh` or `.\start.ps1` (shell scripts that install/find `opencode` and launch UI). Pass `-Auto` (PowerShell) or `--auto` (Bash) to run non-interactively without prompting for permissions.
- Switch permission modes: `.\set-mode.ps1 [auto|ask]` (Windows) or `./set-mode.sh [auto|ask]` (Linux/Mac).
- Sync skills to Antigravity: `.\sync-skills.ps1` (Windows) or `./sync-skills.sh` (Linux/Mac) mirrors `.opencode/skills/` into `.agents/skills/` and `~/.gemini/config/skills/`.
- `/setup`, `/start-project`, `/review-code`, `/mode`, etc. are **slash commands typed inside the OpenCode UI**, not shell commands.
- Install into another project: `./install.sh <target-dir>` or `.\install.ps1 -TargetDir "C:\path\to\project"` (copies agents, commands, skills, Antigravity `.agents/skills`, opencode.json, scripts, env/gitignore templates).

## Antigravity IDE Integration
- Workspace skills root: `.agents/skills/<name>/SKILL.md`
- Global skills root: `~/.gemini/config/skills/<name>/SKILL.md`
- Rules: `AGENTS.md` is automatically loaded by Antigravity as workspace instructions.

## Verification Shortcuts
- OpenCode config: ensure `opencode.json` is valid JSON; agent/command/skill paths match directory names.

