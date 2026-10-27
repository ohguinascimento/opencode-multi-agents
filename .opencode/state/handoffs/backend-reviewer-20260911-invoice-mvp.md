# Backend Reviewer — Handoff 2026-09-11

## Contexto

Revisão backend do MVP `invoice-processor` em `D:\Projetos\invoice-processor`.

## Achados da Revisão (Backend Reviewer)

| ID | Severidade | Descrição | Arquivo | Status |
|----|-----------|-----------|---------|--------|
| C1 | Crítica | Race condition em `create_job`: IntegrityError não tratado ao inserir job duplicado | `repositories.py` | **Corrigido** |
| A2 | Alta | `insert_items_batch` usava transação implícita sem atomicidade garantida | `repositories.py` | **Corrigido** |
| A3 | Alta | Falta de `update_invoice_item_count` para atualizar contagem de itens | `repositories.py` | **Corrigido** |
| A4 | Alta | `main.py` sem CORS configurado — bloqueia chamadas cross-origin | `main.py` | **Corrigido** |
| A5 | Alta | `config.py` sem `CORS_ORIGINS` — configuração incompleta | `config.py` | **Corrigido** |
| M4 | Média | `worker.py` expunha path completo do arquivo em logs | `worker.py` | **Corrigido** |

## Correções Aplicadas (Backend Dev)

- **C1**: `repositories.py` trata `aiomysql.IntegrityError` em `create_job`
- **A2**: `insert_items_batch` usa uma conexão e commit único (atomicidade)
- **A3**: `update_invoice_item_count` existe e é chamado após inserção de itens
- **A4**: `main.py` inclui `CORSMiddleware`
- **A5**: `config.py` inclui `CORS_ORIGINS`
- **M4**: `worker.py` não expõe path completo em logs

## Evidências Pós-Correção

Comandos executados com exit 0:

```bash
python -m compileall app scripts tests    # exit 0 — compilação limpa
python tests/test_pdf_parser.py           # exit 0 — 14/14 testes PASS
python -c "from app.main import app; print('ok')"  # exit 0 — import ok
```

Validação por leitura (Tech Lead):
- `repositories.py`: trata `aiomysql.IntegrityError`, `insert_items_batch` usa conexão e commit único, `update_invoice_item_count` existe
- `main.py`: `CORSMiddleware` presente, escrita atômica com `tempfile`/`os.replace`
- `config.py`: `CORS_ORIGINS` definido
- `worker.py`: não expõe path completo

## Limitações Remanescentes

| ID | Descrição | Mitigação |
|----|-----------|-----------|
| R-003 | Sem autenticação nos endpoints (abertos) | Adicionar API key ou JWT na v2; não expor em produção sem auth |
| R-001 | PDFs escaneados retornam erro `scanned_pdf` | Adicionar Tesseract/PaddleOCR na v2 |
| R-002 | Parser regex BR pode falhar em layouts exóticos | Fallback raw_text; parsers específicos por banco na v2 |
| R-004 | Pool e batch podem precisar de tuning em volume | Monitorar métricas após coleta de dados reais |

## Gate Status

- **backend**: `passed` (mantido — correções validadas)
- **próximo agente**: `security`
