# Repository Instructions

## Scope
- This repo is the `opencode-multi-agents` package: OpenCode agents, commands, skills, schemas, state, and operational docs.
- **Do not assume the repo root is the user's product project.** `.opencode/AGENT-POLICY.md` requires asking for and confirming the absolute target path before creating product code (`app/`, `src/`, `frontend/`, `backend/`, `tests`, etc.).
- The root also contains Fleet Management Laravel/React files and a duplicate-ish `fleet-management/` tree; treat these as product code only after the user explicitly confirms which path is the target.

## OpenCode Config
- `opencode.json` is strict-schema (`$schema: https://opencode.ai/config.json`); invalid fields prevent startup.
- Instructions loaded: `AGENTS.md`, `README.md`, `.opencode/AGENT-POLICY.md`, `.opencode/memory/project.md`, `.opencode/memory/decisions/README.md`.
- After changing `opencode.json`, `.opencode/agents/*`, `.opencode/command/*`, `.opencode/skills/*`, or plugins: **tell user to restart OpenCode**; config is not hot-reloaded.
- Paths: agents in `.opencode/agents/*.md` (plural); commands in `.opencode/command/*.md` (singular); skills in `.opencode/skills/<name>/SKILL.md`.
- Available skills: `api-design`, `database-design`, `documentation`, `security-best-practices`, `system-design`, `testing-strategies`.

## Multi-Agent Package Commands
- Start OpenCode: `./start.sh` or `.\start.ps1` (shell scripts that install/find `opencode` and launch UI). Pass `-Auto` (PowerShell) or `--auto` (Bash) to run non-interactively without prompting for permissions.
- Switch permission modes: `.\set-mode.ps1 [auto|ask]` (Windows) or `./set-mode.sh [auto|ask]` (Linux/Mac).
- `/setup`, `/start-project`, `/review-code`, `/mode`, etc. are **slash commands typed inside the OpenCode UI**, not shell commands.
- Install into another project: `./install.sh <target-dir>` or `.\install.ps1 -TargetDir "C:\path\to\project"` (copies agents, commands, skills, opencode.json, scripts, env/gitignore templates).

## Fleet App Boundaries (Only If Target Is Confirmed)
- Backend: `bootstrap/app.php` wires routes; API routes in `routes/api.php`; domain code under `app/Domains/<Domain>/` (Controller → Service → Repository).
- Frontend: entrypoint `frontend/src/main.tsx`; Vite dev server on `5173`, proxies `/api` to `http://localhost:8080`.
- Stack: Laravel 12/PHP 8.2, Sanctum, Horizon, MySQL, MongoDB, Redis (backend); React 18/TS/Vite/Tailwind (frontend).
- `.env.example` root is for the multi-agent package (AI config), **not** a Laravel env template. Do not use it for app setup.
- Docker: `docker compose up -d --build`; entrypoint runs `php artisan migrate --force` on boot; seed manually: `docker compose exec app php artisan db:seed --force`.
- No standardized backend tests (`tests/` absent); frontend has build/lint only: `npm run build`, `npm run lint`.

## Verification Shortcuts
- OpenCode config: ensure `opencode.json` is valid JSON; agent/command/skill paths match directory names.
- Backend (when app target confirmed): `php -l <file>`, `php artisan route:list`.
- Frontend (when app target confirmed): from `frontend/`, `npm run lint` then `npm run build`.
