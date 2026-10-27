# Security — Handoff 2026-09-11

## Contexto

Auditoria de segurança do MVP `invoice-processor` em `D:\Projetos\invoice-processor`.
Backend Dev aplicou as correções; Tech Lead validou por leitura e comandos.

## Achados da Auditoria (Security)

| ID | Severidade | Descrição | Arquivo(s) | Status |
|----|-----------|-----------|------------|--------|
| S1 | **Crítica** | Ausência de autenticação e risco IDOR: endpoints `/api/v1/*` abertos; `job_id`/`invoice_id` sequenciais poderiam ser consultados por qualquer cliente sem autorização | `main.py`, `middleware.py` (novo) | **Corrigido** |
| S2 | Alta | Ausência de rate limit — DoS via uploads em massa sobrecarregando worker/Redis/storage | `middleware.py` (novo), `config.py`, `.env.example` | **Corrigido** |
| S3 | Alta | Docker/Redis/ports sem hardening: portas 3306/6379 publicadas para qualquer interface, Redis sem senha, imagem rodando como root, sem `.dockerignore` (risco de incluir `.env`/PDFs na imagem) | `docker-compose.yml`, `Dockerfile`, `.dockerignore` (novo), `.env.example` | **Corrigido** |
| S4 | Alta | Validação de PDF insuficiente (apenas magic bytes): PDFs criptografados/com senha, sem páginas ou acima do limite de páginas eram aceitos e gravados | `main.py`, `config.py`, `tests/test_pdf_validation.py` (novo) | **Corrigido** |
| S5 | Alta | Mensagens de erro expunham detalhes internos (paths, exceções) ao cliente — vazamento de informação | `worker.py` | **Corrigido** |

## Correções Aplicadas (Backend Dev)

- **S1**: `app/middleware.py` — `ApiKeyMiddleware` valida header `X-API-Key` em todas as rotas `/api/v1/*` com `secrets.compare_digest` (timing-safe); `validate_api_key_startup` falha no startup em `APP_ENV=production` sem API_KEY válida.
- **S2**: `app/middleware.py` — `RateLimitMiddleware` em memória (default 10 uploads/min em `POST /api/v1/invoices/process`), com cleanup periódico de buckets; configurável via `RATE_LIMIT_UPLOADS_PER_MINUTE`.
- **S3**: `docker-compose.yml` — portas MySQL/Redis bound a `127.0.0.1`; Redis com `--requirepass`; `Dockerfile` roda como usuário não-root (`appuser`); `.dockerignore` exclui `.env`, `storage/uploads`, `tests/`, etc.
- **S4**: `app/main.py` — `_validate_pdf_structure` via PyMuPDF (criptografia/senha, PDF sem páginas, `MAX_PDF_PAGES`) executada **antes** de gravar o arquivo; escrita permanece atômica (`tempfile` + `os.replace`).
- **S5**: `app/worker.py` — `_ERROR_MESSAGES` genéricos por `error_code`; detalhes internos registrados apenas em log/banco.
- **Ambiente**: `.env.example` documenta `API_KEY`, `RATE_LIMIT_UPLOADS_PER_MINUTE` e `CORS_ORIGINS`; `requirements.txt` adiciona `httpx` (testes); `README.md` atualizado com uso de auth/rate limit.

## Arquivos de Produto Alterados

`app/middleware.py`, `app/config.py`, `app/main.py`, `app/worker.py`, `Dockerfile`, `.dockerignore`, `docker-compose.yml`, `.env.example`, `README.md`, `requirements.txt`, `tests/test_auth_ratelimit.py`, `tests/test_pdf_validation.py` — em `D:\Projetos\invoice-processor` (não editados por este agente).

## Evidências Pós-Correção

Comandos reportados com exit 0:

```bash
python -m compileall app scripts tests              # exit 0 — compilação limpa
python tests/test_pdf_parser.py                     # exit 0 — 14/14 testes PASS
python tests/test_auth_ratelimit.py                 # exit 0 — 14/14 testes PASS (auth + rate limit)
python tests/test_pdf_validation.py                 # exit 0 — 5/5 testes PASS (validação PDF)
python -c "from app.main import app; print('ok')"   # exit 0 — import ok
```

Validação por leitura (Tech Lead):
- `middleware.py`: `secrets.compare_digest` para X-API-Key; rate limit em memória com cleanup; `/health` aberto, `/api/v1/*` protegido.
- `main.py`: validação estrutural PyMuPDF (criptografia, páginas) antes de gravar; fail-fast em produção para API_KEY e `CORS_ORIGINS='*'`; leitura limitada por `MAX_UPLOAD_SIZE_MB`.
- `config.py`: `APP_ENV`, `API_KEY`, `RATE_LIMIT_UPLOADS_PER_MINUTE`, `MAX_PDF_PAGES`, `MAX_UPLOAD_SIZE_MB`.
- `Dockerfile`: usuário não-root (`appuser`), storage com permissões.
- `docker-compose.yml`: `127.0.0.1:3306:3306` e `127.0.0.1:6379:6379`; `redis-server --requirepass`.
- `worker.py`: mensagens genéricas por `error_code`; path completo não exposto ao cliente.
- Testes `test_auth_ratelimit.py` (14) e `test_pdf_validation.py` (5) presentes e executáveis sem MySQL/Redis.

## Limitações Remanescentes (Riscos Residuais)

| ID | Descrição | Mitigação |
|----|-----------|-----------|
| R-001 | Sem OCR: PDFs escaneados retornam erro `scanned_pdf` | Tesseract/PaddleOCR na v2; erro explícito, sem travar pipeline |
| R-002 | Parser genérico regex BR pode falhar em layouts exóticos | Fallback `raw_text`; parsers específicos por banco na v2 |
| R-003 | Autenticação por API key única compartilhada (sem escopo por usuário) | **Mitigado para o MVP por X-API-Key + rate limit**; evoluir para JWT/OAuth2 com escopos na v2 |
| R-004 | Volume de dados desconhecido: pool/batch podem precisar de tuning | Monitorar métricas após coleta de dados reais |
| R-006 | Rate limit em memória não escala multi-instância/replicas | Migrar bucket para Redis (rate limit distribuído) em v2; aceitável em single-instance |

## Gate Status

- **security**: `passed` — sem vulnerabilidades críticas/altas remanescentes; evidências em `last_validation` e neste handoff.
- **próximo agente**: `qa-engineer`