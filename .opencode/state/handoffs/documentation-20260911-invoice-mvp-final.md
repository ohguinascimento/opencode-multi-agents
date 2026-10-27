# Documentation — Handoff Final 2026-09-11

## Contexto

Fechamento operacional do MVP `invoice-processor` em `D:\Projetos\invoice-processor`.
Documentation consolida o resumo final do projeto, referencia as evidências dos agentes
anteriores (68/68 testes + E2E real validado pelo DevOps) e encerra o workflow
`invoice_processor_mvp` registrando o estado final em `workflow.json`.

## Resumo do Projeto

| Item | Valor |
|------|-------|
| Projeto | `invoice-processor` (MVP processador de faturas de cartão em PDF) |
| Path | `D:\Projetos\invoice-processor` |
| Tipo | Backend-only (sem frontend; escopo confirmado pelo usuário) |
| Stack | Python 3.12 / FastAPI (async) / PyMuPDF (`fitz`) / ARQ + Redis 7 / aiomysql + MySQL 8 / Pydantic v2 |
| Auth | API Key via header `X-API-Key` (`secrets.compare_digest`) em todas as rotas `/api/v1/*` |
| Rate limit | In-memory, default 10 uploads/min (`POST /api/v1/invoices/process`) |
| Fila | ARQ worker via Redis; fallback inline via `PROCESS_INLINE=true` |
| Deploy | Docker Compose (`inv-app`, `inv-worker`, `inv-mysql`, `inv-redis`) |

## Arquivos Principais

| Arquivo | Propósito |
|---------|-----------|
| `app/main.py` | Entrypoint FastAPI — saúde, upload/process, job, itens |
| `app/config.py` | Settings pydantic-settings (`APP_ENV`, `API_KEY`, limits, CORS) |
| `app/middleware.py` | Autenticação X-API-Key + Rate Limit |
| `app/db.py` | Pool aiomysql (5–20) + transações |
| `app/pdf_parser.py` | Extração/parse PyMuPDF + regex BR + `ScannedPdfError` |
| `app/repositories.py` | Acesso a dados (jobs, invoices, items; batch; cursor pagination) |
| `app/schemas.py` | Modelos Pydantic v2 |
| `app/worker.py` | ARQ worker + `process_invoice_job` + erros genéricos |
| `sql/schema.sql` | DDL 4 tabelas (InnoDB, utf8mb4, índices) |
| `scripts/init_db.py` | Aplica schema via aiomysql |
| `scripts/make_sample_pdf.py` | Gera PDF de fatura de exemplo |
| `docker-compose.yml` | Orquestração (portas host MySQL 3307 / Redis 6380, bind 127.0.0.1) |
| `Dockerfile` / `.dockerignore` | Imagem não-root, sem segredos/upload na imagem |
| `README.md` | Runbook "Setup — rodar o MVP hoje" (Passos 1–6) + referência completa |
| `tests/` | 6 suites: `test_pdf_parser`, `test_auth_ratelimit`, `test_pdf_validation`, `test_app_helpers`, `test_schemas_config`, `test_app_smoke` |

## Endpoints

| Método | Rota | Descrição | Auth |
|--------|------|-----------|------|
| `GET` | `/health` | Healthcheck público (indica estado do db e redis) | Não |
| `POST` | `/api/v1/invoices/process` | Upload multipart de PDF → valida → cria job ARQ | `X-API-Key` |
| `GET` | `/api/v1/invoices/jobs/{job_id}` | Status do job (queued/running/completed/failed) | `X-API-Key` |
| `GET` | `/api/v1/invoices/{invoice_id}/items?limit=&last_id=` | Itens extraídos (paginação por cursor) | `X-API-Key` |

Erros de negócio documentados no README: `unauthorized`, `rate_limited`,
`encrypted_pdf`, `pdf_too_large`, `scanned_pdf`, `invalid_pdf`, `file_too_large`,
`empty_file`, `parse_error`, `persistence_error`, `file_missing`.

## Comandos para Rodar (Runbook — fonte: README do produto)

```bash
# 1. Ambiente
Copy-Item .env.example .env                     # Linux/Mac: cp .env.example .env
.venv\Scripts\python.exe -c "import secrets; print(secrets.token_urlsafe(32))"  # gerar API_KEY

# 2. Infra (portas host: MySQL 3307, Redis 6380)
docker compose up -d mysql redis
docker compose ps                                # aguardar inv-mysql e inv-redis healthy

# 3. Schema (volume novo aplica sozinho; se existir: docker compose down -v e subir de novo)
.venv\Scripts\python.exe scripts/init_db.py

# 4. API + worker (Modo A — tudo via Docker)
docker compose up -d --build
# Modo B (local): uvicorn app.main:app --reload --port 8000 + python -m arq app.worker.WorkerSettings

# 5. Validar
curl.exe http://127.0.0.1:8000/health
.venv\Scripts\python.exe scripts/make_sample_pdf.py
curl.exe -X POST http://127.0.0.1:8000/api/v1/invoices/process -H "X-API-Key: SUA-CHAVE" -F "file=@sample_fatura.pdf" -F "external_id=cliente-123"
curl.exe -H "X-API-Key: SUA-CHAVE" http://127.0.0.1:8000/api/v1/invoices/jobs/1
curl.exe -H "X-API-Key: SUA-CHAVE" "http://127.0.0.1:8000/api/v1/invoices/1/items?limit=50&last_id=0"
```

## Evidências

- **Suíte de testes: 68/68 PASS** (via `pytest`):
  parser PDF 14/14, auth + rate limit 14/14, validação PDF 5/5,
  helpers 13/13 (QA), schemas/config 12/12 (QA), smoke app 10/10 (QA).
- **E2E real (DevOps, infra MySQL + Redis + ARQ reais):** compose válido; build ok;
  ciclo down/up ok; health `inv-mysql`/`inv-redis` healthy; sem chave → 401;
  `POST /process` criou job via ARQ; `GET /jobs/1` → `completed`, `invoice_id=1`,
  `item_count=4`; `GET /items` → 4 itens corretos; `innodb_trx` vazio;
  modo local `uvicorn` porta 8001 ok.
- **Validação por leitura (Tech Lead):** README verificado — runbook Passos 1–6
  reproduzível, estrutura de arquivos e stack coerentes com o código, endpoints,
  erros de negócio e seção de testes documentados.

## Gate Status (final)

| Gate | Status | Base |
|------|--------|------|
| architecture | `passed` | ADR aprovado + handoffs architect/data + implementação alinhada |
| backend | `passed` | Comandos exit 0 + validação por leitura |
| frontend | `waived` | Não aplicável — produto backend-only por escopo confirmado pelo usuário; sem frontend no MVP |
| security | `passed` | S1 crítica + S2–S5 altas corrigidas; sem vulnerabilidades críticas/altas remanescentes |
| qa | `passed` | 68/68 testes PASS (com ressalva de E2E infra, coberto pelo DevOps) |
| devops | `passed` | Compose/build/health ok + E2E real ARQ/MySQL/Redis + runbook no README |

## Riscos Remanescentes (v2)

| ID | Descrição | Mitigação |
|----|-----------|-----------|
| R-001 | Sem OCR: PDFs escaneados → `scanned_pdf` | Tesseract/PaddleOCR na v2; erro explícito, não trava pipeline |
| R-002 | Parser genérico regex BR pode falhar em layouts exóticos | Fallback `raw_text`; parsers específicos por banco na v2 |
| R-003 | API key única compartilhada (sem escopo por usuário) | Mitigado no MVP (X-API-Key + rate limit); evoluir para JWT/OAuth2 na v2 |
| R-004 | Volume de dados desconhecido: pool/batch podem precisar de tuning | Monitorar métricas após dados reais |
| R-006 | Rate limit em memória não escala multi-instância | Migrar para Redis (distribuído) na v2 |
| R-007 | `.env` local com `API_KEY` (gitignored) | Não versionar `.env`; rotacionar chave se exposta |

## Próximos Passos

1. **v2 — OCR** para PDFs escaneados (Tesseract/PaddleOCR) e parsers específicos
   por banco para layouts exóticos (R-001/R-002).
2. **v2 — Auth por usuário**: migrar de API key única para JWT/OAuth2 com escopos
   (R-003) e rate limit distribuído em Redis (R-006).
3. **Monitoramento**: instrumentar métricas de throughput/latência para calibrar
   pool `aiomysql` e batch (R-004).
4. **CI/CD**: adicionar pipeline automatizado (lint + `pytest` + build da imagem)
   e estratégia de rollback para o compose em ambiente real.

## Arquivos Alterados (Este Repositório — Documentação/Estado Operacional)

| Arquivo | Mudança |
|---------|---------|
| `.opencode/state/handoffs/documentation-20260911-invoice-mvp-final.md` | **Criado** — handoff final de documentação |
| `.opencode/state/workflow.json` | Atualizado para encerramento: `documentation` em `completed_agents`, `pending_agents` vazio, `current_agent` null, `status: completed`, artifact do handoff final, `frontend` waiver justificado e histórico de fechamento |

Nenhum arquivo de produto em `D:\Projetos\invoice-processor` foi alterado por este agente.

## Observação Final

O MVP `invoice-processor` está **entregue e operacional**: backend FastAPI rodando
via Docker Compose, E2E real validado (ARQ/MySQL/Redis), 68/68 testes PASS e runbook
documentado no README do produto. O workflow `invoice_processor_mvp` está **concluído**
com todos os gates aplicáveis `passed` (`frontend` `waived` por escopo backend-only
confirmado pelo usuário). Riscos remanescentes são conhecidos e endereçados na v2.