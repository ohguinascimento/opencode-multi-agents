# DevOps — Handoff 2026-09-11

## Contexto

Ajustes de infraestrutura e validação ponta a ponta do MVP `invoice-processor` em `D:\Projetos\invoice-processor`.
DevOps ajustou e validou o produto para rodar hoje: Docker Compose, ambiente (.env), PDF de exemplo, correções de
persistência e E2E completo com MySQL/Redis/ARQ reais. Tech Lead validou por leitura os arquivos alterados.

## Alterações de Produto (Feitas pelo DevOps)

| Arquivo | Alteração |
|---------|-----------|
| `docker-compose.yml` | Portas do host ajustadas para **3307 (MySQL)** e **6380 (Redis)** para evitar conflito com serviços existentes; serviços `app` e `worker` habilitados; dentro da rede Docker os serviços continuam em `mysql`/`redis` (3306/6379), com sobrescrita de `MYSQL_HOST`/`REDIS_URL` |
| `.env.example` | Documenta portas 3307/6380 e `API_KEY`; template do ambiente |
| `.env` (gitignored) | Criado localmente com `API_KEY` definida; **não versionado** |
| `README.md` | Runbook "Setup — rodar o MVP hoje" (Passos 1 a 6) com sequência mínima e reprodutível |
| `scripts/make_sample_pdf.py` | Script para gerar PDF de fatura de exemplo |
| `app/repositories.py` | Corrige gravação de `amount` e commits read-only |
| `app/db.py` | Corrige commit no `ping`/reconexão |
| `tests/test_app_helpers.py` | Ajustado (suíte total 68/68 testes PASS) |
| `tests/test_pdf_validation.py` | Ajustado (suíte total 68/68 testes PASS) |

Todos os arquivos acima estão em `D:\Projetos\invoice-processor`. Nenhum arquivo deste repositório
(`opencode-multi-agents`) foi alterado pelo DevOps.

## Comandos Executados (Evidências DevOps — Reportados exit 0)

```bash
docker compose config --quiet                       # exit 0 — compose válido
.venv\Scripts\python.exe scripts/make_sample_pdf.py # exit 0 — PDF de exemplo gerado
docker compose build                                # exit 0 — imagens construídas
docker compose up -d --build                        # exit 0 — app/worker/mysql/redis up
docker compose down && docker compose up -d         # exit 0 — ciclo down/up ok
docker compose ps                                   # health mysql (inv-mysql) e redis (inv-redis) ok
pytest                                              # 68/68 testes PASS
```

## E2E Real (MySQL + Redis + ARQ reais)

Fluxo ponta a ponta executado **hoje** contra infraestrutura real:

1. `docker compose up -d` sobe `inv-app`, `inv-worker`, `inv-mysql`, `inv-redis`.
2. Healthcheck: `inv-mysql` e `inv-redis` com status `healthy`.
3. Sem `X-API-Key` → `401 Unauthorized` (auth funcionando).
4. `POST /api/v1/invoices/process` com `X-API-Key` + `sample_fatura.pdf` → job criado via **ARQ/Redis**.
5. `GET /api/v1/invoices/jobs/1` → `status=completed`, `invoice_id=1`, `item_count=4`.
6. `GET /api/v1/invoices/1/items` → retorna **4 itens** com valores corretos.
7. `innodb_trx` vazio após o processamento (sem transações pendentes/leaks).
8. `pytest` → **68/68 testes PASS**.
9. Modo local validado: `uvicorn app.main:app` na porta **8001** funcionou.

## Runbook — Rodar o MVP Hoje

Fonte: seção "Setup — rodar o MVP hoje" do `README.md` do produto (validada por leitura).

```bash
# Passo 1 — copiar .env
Copy-Item .env.example .env         # Windows/PowerShell (Linux/Mac: cp .env.example .env)

# Passo 2 — definir API_KEY (gerar chave forte e colocar no .env)
.venv\Scripts\python.exe -c "import secrets; print(secrets.token_urlsafe(32))"

# Passo 3 — subir infra (portas host: MySQL 3307, Redis 6380)
docker compose up -d mysql redis
docker compose ps                   # aguardar inv-mysql e inv-redis healthy

# Passo 4 — schema (aplica sozinho em volume novo; se volume já existir: docker compose down -v e subir de novo)
.venv\Scripts\python.exe scripts/init_db.py

# Passo 5 — API e worker
docker compose up -d --build        # Modo A (tudo via Docker): inv-app + inv-worker
# ou Modo B (local): .venv\Scripts\activate && uvicorn app.main:app --reload --port 8000
#                    em outro terminal: python -m arq app.worker.WorkerSettings

# Passo 6 — validar com curl (PowerShell: usar curl.exe)
curl.exe http://127.0.0.1:8000/health
.venv\Scripts\python.exe scripts/make_sample_pdf.py
curl.exe -X POST http://127.0.0.1:8000/api/v1/invoices/process -H "X-API-Key: SUA-CHAVE" -F "file=@sample_fatura.pdf" -F "external_id=cliente-123"
curl.exe -H "X-API-Key: SUA-CHAVE" http://127.0.0.1:8000/api/v1/invoices/jobs/1
curl.exe -H "X-API-Key: SUA-CHAVE" "http://127.0.0.1:8000/api/v1/invoices/1/items?limit=50&last_id=0"
```

## Validação por Leitura (Tech Lead)

- `docker-compose.yml`: host usa `3307` (MySQL) e `6380` (Redis); serviços `app` e `worker` habilitados;
  `MYSQL_HOST`/`REDIS_URL` sobrescritos para a rede interna (`mysql`/`redis`).
- `.env.example`: documenta portas e `API_KEY`.
- `app/repositories.py`: corrige gravação de `amount` e commits read-only.
- `app/db.py`: commit no `ping`/reconexão.
- `scripts/make_sample_pdf.py`: existe e gera o PDF de exemplo.
- `README.md`: runbook presente com a sequência Passos 1 a 6.

## Limitações Remanescentes (Riscos)

| ID | Descrição | Status/Mitigação |
|----|-----------|------------------|
| R-001 | Sem OCR: PDFs escaneados → `scanned_pdf` | Tesseract/PaddleOCR na v2; erro explícito, sem travar pipeline |
| R-002 | Parser genérico regex BR pode falhar em layouts exóticos | Fallback `raw_text`; parsers específicos por banco na v2 |
| R-004 | Volume de dados desconhecido: pool/batch podem precisar de tuning | Monitorar métricas e ajustar após dados reais |
| R-006 | Rate limit em memória não escala multi-instância/replicas | Migrar para Redis (distribuído) na v2; aceitável em single-instance |
| R-007 | `.env` local criada com `API_KEY` (gitignored) | Não versionar `.env`; rotacionar a chave se exposta; segredo vive apenas no ambiente local |

## Gate Status

- **devops**: `passed` — compose válido, build ok, ciclo up/down/up ok, health db/redis ok, auth sem chave 401,
  E2E real completo via ARQ/MySQL/Redis (job completed, item_count=4, items corretos, innodb_trx vazio),
  pytest 68/68, modo local porta 8001 validado.
- **próximo agente**: `documentation`