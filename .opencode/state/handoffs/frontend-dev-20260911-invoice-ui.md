# Frontend Dev — Handoff 2026-09-11

## Contexto

Após o fechamento do MVP backend-only, o usuário solicitou um **frontend React moderno/mobile**
para interagir com o backend `invoice-processor`. Frontend-dev implementou o app em
`D:\Projetos\invoice-processor\frontend` (produto não é repositório Git).

Stack: **React 18 + TypeScript + Vite 5 + CSS Modules** (sem framework CSS; mobile-first).
O app conversa com o backend FastAPI via `VITE_API_BASE_URL` (default `http://127.0.0.1:8000`,
CORS liberado no backend).

## Funcionalidades

| Funcionalidade | Detalhes |
|---|---|
| Upload de PDF | `POST /api/v1/invoices/process` via drag-and-drop ou clique; validação client-side (.pdf, ≤ 50 MB, não vazio); `external_id` opcional; timeout de 30s |
| API key | Painel `X-API-Key` — **padrão: apenas em memória**; persistência no `localStorage` somente com opt-in explícito ("Lembrar neste navegador"); botões Usar/Limpar; campo password com Mostrar/Ocultar |
| Health check | `GET /health` com polling leve a cada 30s; badge Online / Degradado / Offline com detalhes `db` e `redis`; refresh manual |
| Job polling | `GET /api/v1/invoices/jobs/{job_id}` a cada 2,5s com **backoff exponencial** (teto 30s) e **desiste após 5 erros consecutivos**; para sozinho em `completed`/`failed` |
| Consulta manual de job | Input `type=number` com validação **inteiro > 0** (`Number.isInteger`) |
| Itens extraídos | `GET /api/v1/invoices/{invoice_id}/items?limit=50&last_id=0` com paginação por cursor ("Carregar mais"); **tabela no desktop e cards no mobile** |
| Formatação pt-BR | `formatBRL` (BR e decimal canônico), `formatDate`, `formatDateTime`, `formatFileSize`; `formatBRL('')` → `'—'` |
| Acessibilidade | Tokens com variantes **strong** (contraste AA em textos/status), `:focus-visible`, `role=status/alert`, `aria-live`, labels e aria-labels, área de upload navegável por teclado |
| Responsivo | Mobile-first (grid 2 colunas no desktop, empilhado no mobile) |

## Arquivos Principais (Produto — `D:\Projetos\invoice-processor\frontend`)

### Config

| Arquivo | Propósito |
|---|---|
| `package.json` | Scripts `dev`/`build`/`lint`/`test:format`; `engines.node >= 23.6.0`; React 18.3, Vite 5.4, TS 5.6, ESLint 9 |
| `vite.config.ts` | Dev server **host 127.0.0.1** (porta 5173); preview 127.0.0.1:4173 — não expõe na LAN |
| `tsconfig.json` | Config TypeScript (type-stripping + `tsc --noEmit` no build) |
| `eslint.config.js` | ESLint flat config (react-hooks, react-refresh, typescript-eslint) |
| `index.html` | `lang="pt-BR"`, viewport mobile, meta description |
| `.env.example` | Documenta `VITE_API_BASE_URL` |
| `.gitignore`, `package-lock.json` | Ignora `node_modules`/`dist`/`.env`; lockfile |

### `src/`

| Arquivo | Propósito |
|---|---|
| `main.tsx` | Entrypoint React (StrictMode + createRoot) |
| `App.tsx` | Orquestra fluxo: API key → upload → job polling → itens; estados de erro |
| `index.css` | Design tokens (paleta, `-strong` para AA, tipografia, layout) + base global |
| `types.ts` | Tipos espelhando os schemas Pydantic (envelope `{success,data|error}`, `JobStatus`, `InvoiceItem`…) |
| `lib/api.ts` | Cliente HTTP leve + `ApiError` + envelope; **AbortController timeout** (15s default, 30s upload); nenhum `Content-Type` manual (boundary correto do FormData) |
| `lib/errors.ts` | Mensagens amigáveis por código de erro do backend |
| `lib/format.ts` | `formatBRL`, `formatDate`, `formatDateTime`, `formatFileSize` |
| `lib/format.test.ts` | Smoke test de `formatBRL` sem test runner (`node` type-stripping) — 11 casos |
| `hooks/useApiKey.ts` | Chave em memória; **persistência só com opt-in** (`localStorage`, `removeItem` ao limpar/desmarcar) |
| `hooks/useHealth.ts` | Polling de `/health` a cada 30s + refresh manual |
| `hooks/useJobPolling.ts` | Loop com **backoff exponencial** e **limite de 5 erros**; para em terminal |
| `components/` | `ApiKeyForm`, `UploadZone`, `JobCard`, `ItemsView`, `HealthBadge`, `StatusBadge`, `Header`, `ErrorAlert`, `Spinner` (cada um com `.module.css`) |

## Revisões e Correções

### Revisão 1 (frontend-reviewer) — C1/A1/A2/M1/M2, todas corrigidas

| ID | Achado | Correção aplicada |
|---|---|---|
| C1 | `formatBRL('1234.56')` virava `R$ 123.456,00` (corrompia valor canônico) | Heurística: vírgula → formato BR (remove milhar); sem vírgula → decimal canônico (não removes pontos); caso coberto em `format.test.ts` |
| A1 | API key gravada direto no `localStorage` | **Opt-in explícito** ("Lembrar neste navegador"); default apenas memória; desmarcar remove a chave |
| A2 | Vite exposto em `0.0.0.0` | **`host: '127.0.0.1'`** no dev/preview server |
| M1 | Requisições sem timeout podiam pendurar indefinidamente | **`AbortController`** com timeout (15s default; 30s upload) e erro `timeout` amigável |
| M2 | Polling sem controle (loop infinito em erro) | **Backoff exponencial** (2x, teto 30s) + **limite de 5 erros consecutivos**; para em `completed`/`failed` |
| — | Lookup de job aceitava qualquer número | **`Number.isInteger(parsed) && parsed > 0`** antes de chamar `onLookup` |
| — | Sem teste automatizado do formatador | Criado script **`test:format`** (`node src/lib/format.test.ts`) |

### Revisão 2 (frontend-reviewer) — aprovada com ressalvas de contraste → a11y polish

| Ajuste | Detalhes |
|---|---|
| Tokens `-strong` | `--color-success-strong`, `--color-warning-strong`, `--color-danger-strong`, `--color-info-strong`, `--color-primary-strong` adicionados ao tema |
| Contraste AA | Textos de status/badges/alertas usam as variantes `strong` para atingir WCAG AA; text-muted revisados |
| Engines Node | `package.json` declara `node >= 23.6.0` (type-stripping requerido pelo `test:format`) |
| `formatBRL('')` | String vazia/whitespace → `'—'` (não vira `R$ 0,00`) |

## Comandos / Exit Codes (Produto, `D:\Projetos\invoice-processor\frontend`)

```powershell
npm.cmd install          # exit 0 — dependências instaladas
npm.cmd run build        # exit 0 — tsc --noEmit && vite build (dist/ gerado)
npm.cmd run lint         # exit 0 — ESLint sem erros
npm.cmd run test:format  # exit 0 — "formatBRL: todos os casos passaram" (11 casos)
npm.cmd run dev          # smoke — dev server respondeu HTTP 200 (127.0.0.1:5173)
```

Produto **não é git repo** — sem commits/tags no produto. Nenhum arquivo de
`D:\Projetos\invoice-processor` fora de `frontend/` foi alterado nesta etapa
(integração com o backend existente via `VITE_API_BASE_URL` + CORS já liberado).

## Riscos / Limitações Remanescentes

| ID | Descrição | Mitigação / Status |
|---|---|---|
| F-001 | **API key no browser**: mesmo com opt-in, a chave persistida no `localStorage` é legível por scripts (XSS residual) e é um segredo de cliente | Default em memória (sem persistência); desmarcar "Lembrar" remove; v2: migrar para JWT/auth por usuário com escopos (R-003) |
| F-002 | **Sem deploy estático no compose**: o `docker-compose.yml` do backend não publica o frontend buildado | Rodar `npm run build` + `vite preview` (127.0.0.1:4173) ou servir `dist/` via nginx; adicionar serviço estático na v2 |
| F-003 | **`test:format` exige Node >= 23.6** (type-stripping nativo) | `engines.node >= 23.6.0` documentado; usar Node ≥ 23.6 — em versões inferiores o script falha |
| F-004 | **Vulnerabilidades npm de dev deps** reportadas pelo implementador (`npm audit`) | São **dev-only** (não entram no `dist/`); atualizar deps periodicamente; reavaliar na v2 |

## Gate Status

- **frontend**: `passed` — build, lint e `test:format` exit 0; smoke dev HTTP 200;
  revisado em 2 rodadas pelo frontend-reviewer (C1/A1/A2/M1/M2 corrigidos + a11y AA).
  O waiver anterior de frontend foi marcado como **superseded** (frontend implementado depois).
- **próximo agente**: não há — frontend foi solicitação adicional pós-fechamento; workflow permanece `completed`.

## Arquivos Alterados (Este Repositório — Documentação/Estado Operacional)

| Arquivo | Mudança |
|---|---|
| `.opencode/state/handoffs/frontend-dev-20260911-invoice-ui.md` | **Criado** — handoff do frontend (este arquivo) |
| `.opencode/state/workflow.json` | Atualizado: `frontend-dev`/`frontend-reviewer` em `completed_agents`, artifact do handoff, `gates.frontend = passed`, waiver superseded, `last_validation` agregada (backend E2E + frontend), history com `user_requested_frontend`/`frontend_completed`/`frontend_reviewed`/`gate_passed`/`workflow_updated` |

Nenhum arquivo de produto em `D:\Projetos\invoice-processor` foi alterado por este agente de documentação.