# ADR-20260911-invoice-backend-stack: Backend stack para Invoice Processor MVP

Status: accepted
Data: 2026-09-11
Autor: Tech Lead (agregando decisões do Architect, Data Engineer e confirmação do usuário)
Fonte: sessão do usuário, handoffs architect+data-engineer+backend-dev, validação por leitura

## Contexto

O usuário precisa de um processador de faturas de cartão de crédito em PDF, com persistência em MySQL, pronto como MVP no dia 2026-09-11. O volume é desconhecido, filas são permitidas, e o prazo é agressivo. O Backend Dev implementou o MVP em `D:\Projetos\invoice-processor` com a stack proposta pelo Architect e schema refinado pelo Data Engineer.

## Decisão

Usar a seguinte stack para o MVP:

| Camada | Tecnologia | Justificativa |
|--------|-----------|---------------|
| API/App | **FastAPI** | Async nativo, tipagem Pydantic v2, performance, docs automáticos |
| Extração de PDF | **PyMuPDF** (fitz) | Rápido, confiável para PDFs com texto, detecta PDFs escaneados |
| Fila/Workers | **ARQ + Redis** | Leve, async, bom para MVP; Celery como alternativa futura se necessário |
| Banco | **MySQL 8 + aiomysql** | Conforme solicitado pelo usuário; aiomysql async direto (sem ORM pesado) |
| Validação | **Pydantic v2** | Tipagem forte, serialização, integração nativa com FastAPI |

## Alternativas Consideradas

- **Celery + Redis** (em vez de ARQ): Mais maduro e documentado, mas mais pesado para MVP; ARQ é suficiente e mantém tudo async.
- **SQLAlchemy + aiomysql**: ORM traz overhead e complexidade para MVP; queries diretas com aiomysql são suficientes.
- **PostgreSQL em vez de MySQL**: Usuário especificou MySQL; PostgreSQL seria preferível para JSONB e certains features, mas não há margem para mudança.
- **OCR (Tesseract/PaddleOCR)**: Fora do escopo do MVP; PDFs escaneados retornam erro explícito.
- **Node.js/Express**: Usuário não especificou linguagem; Python é mais adequado para processamento de PDF e data pipelines.

## Impacto

- **Componentes afetados**: Backend (API + Worker), banco de dados, infraestrutura Docker
- **Arquivos afetados**: Todos os arquivos em `D:\Projetos\invoice-processor` (14 arquivos criados pelo Backend Dev)
- **Riscos**:
  - Sem OCR: PDFs escaneados falham explicitamente
  - Parser genérico: regex BR pode errar em formatos exóticos
  - Sem autenticação: endpoints abertos
  - MySQL/Redis obrigatórios: app não inicia sem ambos
  - Portas 3306/6379 podem conflitar com serviços existentes
- **Migração necessária**: Nenhuma (projeto novo)

## Critérios de Validação

- [x] O usuário confirmou o caminho do projeto (`D:\Projetos\invoice-processor`)
- [x] O usuário autorizou a criação de código de produto neste diretório
- [x] O usuário aprovou continuar com a stack proposta (implícito na autorização do caminho e no fluxo dos agentes)
- [x] Todos os módulos compilam sem erro (`python -m compileall` exit 0)
- [x] Dependências instaladas (`pip install -r requirements.txt` exit 0)
- [x] 14/14 testes unitários passam (`python tests/test_pdf_parser.py` exit 0)
- [x] FastAPI app importa corretamente (`python -c "from app.main import app"` exit 0)
- [x] Schema SQL contém as 4 tabelas com FK, índices e charset corretos
- [x] Repositórios usam executemany, cursor pagination, campos item_position/item_hash
- [x] Parser usa PyMuPDF, ScannedPdfError, regex genérico BR, Decimal normalization, SHA-256 hash
