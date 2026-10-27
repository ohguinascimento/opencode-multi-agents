# Handoff: Backend Dev — Invoice Processor MVP

**Date**: 2026-09-11
**Agent**: Backend Dev
**Task**: Implementar MVP Python do processador de faturas de cartão em PDF com persistência em MySQL

## Caminho Alvo Confirmado

- **Caminho absoluto**: `D:\Projetos\invoice-processor`
- **Autorização**: Usuário confirmou caminho e autorizou criação de código de produto neste diretório.
- **`.opencode/AGENT-POLICY.md`**: Exceção aplicada; agente autorizado a escrever neste path.

## Arquivos Principais Criados

| Arquivo | Propósito |
|---------|-----------|
| `README.md` | Documentação do projeto |
| `.env.example` | Variáveis de ambiente (template) |
| `requirements.txt` | Dependências Python |
| `docker-compose.yml` | Orquestração (app + MySQL + Redis) |
| `Dockerfile` | Build da imagem da aplicação |
| `app/main.py` | Entrypoint FastAPI (endpoints de upload e consulta) |
| `app/config.py` | Configuração via pydantic-settings |
| `app/db.py` | Pool de conexões aiomysql |
| `app/pdf_parser.py` | Extração e parse de PDF (PyMuPDF) |
| `app/repositories.py` | Acesso a dados (CRUD, batch inserts, cursor pagination) |
| `app/schemas.py` | Modelos Pydantic v2 |
| `app/worker.py` | Worker ARQ para processamento assíncrono |
| `sql/schema.sql` | DDL das 4 tabelas (InnoDB, utf8mb4) |
| `scripts/init_db.py` | Script de inicialização do banco |
| `tests/test_pdf_parser.py` | Testes unitários do parser |
| `storage/uploads/.gitkeep` | Diretório para uploads (placeholder) |

## Comandos Executados e Exit Codes (reportados pelo Backend Dev)

| Comando | Exit Code | Observação |
|---------|-----------|------------|
| `python -m compileall app scripts tests` | **0** | Todos os módulos compilam sem erro |
| `pip install -r requirements.txt` | **0** | Dependências instaladas |
| `python tests/test_pdf_parser.py` | **0** | 14/14 testes PASS (após patch no test_hash_and_position) |
| `python -c "from app.main import app; print('ok')"` | **0** | FastAPI app importa corretamente |

## Validação Independente pelo Tech Lead

O Tech Lead realizou leitura direta dos arquivos-fonte para validar a conformidade com as propostas do Architect e Data Engineer:

### `sql/schema.sql`
- Contém 4 tabelas: `processing_jobs`, `invoices`, `invoice_items`, `processing_errors`.
- `invoice_items.item_position`: `INT UNSIGNED` (conforme proposta 0-based).
- `invoice_items.item_hash`: `CHAR(64)` (SHA-256, não UNIQUE no MVP).
- Índices presentes: `idx_invoice_position`, `idx_invoice_cursor` (cursor pagination), `idx_invoice_amount`.
- Foreign keys com `ON DELETE CASCADE`, engine InnoDB, charset utf8mb4.

### `app/repositories.py`
- Batch inserts via `executemany`.
- Cursor-based pagination: `WHERE invoice_id = %s AND id > %s`.
- Campos `item_position` e `item_hash` presentes em insert e select.

### `app/pdf_parser.py`
- Usa PyMuPDF (`fitz`).
- Detecta PDF sem texto via `ScannedPdfError` (exceção customizada).
- Regex genérico brasileiro para extração de valores.
- Normaliza valores para `Decimal`.
- Gera `item_position` 0-based e `item_hash` via SHA-256.

## Limitações do MVP

| Limitação | Impacto | Mitigação Sugerida |
|-----------|---------|---------------------|
| **Sem OCR** | PDFs escaneados (sem texto embutido) retornam erro `scanned_pdf` | Adicionar Tesseract/PaddleOCR na v2 |
| **Parser genérico** | Layouts específicos de bancos não são otimizados; regex genérico pode errar valores em formatos exóticos | Criar parsers específicos por banco (layout 1, layout 2, ...) |
| **Sem autenticação** | Endpoints abertos; qualquer um pode enviar PDFs e consultar jobs | Adicionar API key, JWT ou OAuth2 na v2 |
| **MySQL e Redis precisam estar disponíveis** | App falha na inicialização sem ambos | `docker-compose up -d` resolve no dev; verificar no deploy |
| **Portas 3306/6379 podem conflitar** | Se já houver MySQL/Redis no host, compose pode falhar | Ajustar portas no `docker-compose.yml` ou usar redes isoladas |
| **Sem rate limiting** | Uploads em massa podem sobrecarregar o worker | Adicionar rate limit no FastAPI (v2) |
| **Volume de dados desconhecido** | Pool e batch podem precisar de tuning | Monitorar e ajustar após coleta de métricas reais |

## Próximos Passos

| # | Agente | Responsabilidade |
|---|--------|------------------|
| 1 | **Backend Reviewer** | Revisão de código, qualidade, padrões, tratamento de erros |
| 2 | **Security** | Auditoria de segurança (OWASP, secrets, input validation) |
| 3 | **QA Engineer** | Testes de integração e E2E (upload, processamento, consulta) |
| 4 | **DevOps** | Validar Docker build, health check, variáveis de ambiente |
| 5 | **Documentation** | Gerar documentação final (README, API docs, setup guide) |

## Arquivos Alterados

| Arquivo | Mudança |
|---------|---------|
| `.opencode/state/handoffs/backend-dev-20260911-invoice-mvp.md` | **Criado** — handoff do Backend Dev |

## Observação de Escrita

O arquivo foi criado com sucesso em `D:\Agents\opencode-multi-agents\.opencode\state\handoffs\backend-dev-20260911-invoice-mvp.md`.
