# Handoff: Architect — Invoice Backend MVP

**Date**: 2026-09-11
**Agent**: Architect
**Task**: Definir stack, fluxo, schema e API mínima para backend Python de processamento de faturas de cartão em PDF com persistência em MySQL (MVP para hoje)

## Estado do Workflow (não alterado)

- `workflow.json`: `status = not_started`, `workflow = null`, `project = null`, gates **pending**, `blockers = []`, `history = []`.
- **Este handoff NÃO alterou `workflow.json` e não deve ser alterado por este resultado.**
- Motivo: a evidência do Architect é apenas **proposta textual**; não há evidência executável (schema aprovado, código, testes) nem aprovação humana/caminho-alvo confirmado.
- Nenhum gate pode ser marcado como `accepted` — em especial `architecture`, que continua `pending` até aprovação explícita do usuário e confirmação do caminho absoluto do projeto.

## Contexto do Usuário (fatos verificados)

| Fato | Fonte |
|------|-------|
| Backend Python performático para processar faturas de cartão em PDF | Sessão do usuário |
| Persistência em MySQL | Sessão do usuário |
| Volume de processamento ainda desconhecido; itens podem ser gigantes | Sessão do usuário |
| Filas/consumers são permitidos | Sessão do usuário |
| MVP precisa ficar pronto **hoje** (prazo agressivo) | Sessão do usuário |
| Caminho absoluto do projeto **ainda não confirmado** | `.opencode/AGENT-POLICY.md` + sessão |

## Regras de Escopo Aplicadas

- **Nenhum código de produto foi criado** (sem `app/`, `src/`, `backend/`, migrations, schemas SQL, etc.).
- Nenhuma implementação pode ocorrer antes da confirmação do caminho absoluto do projeto (política AGENT-POLICY).
- Este arquivo é documentação operacional do pacote opencode-multi-agents (exceção permitida).

## Proposta do Architect (NÃO é fato aprovado)

Status: `proposed` — aceita como direção técnica, **aguardando aprovação humana** e validação pelo Data Engineer.

### Stack Recomendada
- **API/App**: FastAPI
- **Fila**: ARQ + Redis (primário); Celery + Redis como alternativa madura
- **Extração de PDF**: PyMuPDF (primário para PDF com texto); OCR fora do escopo do MVP
- **Validação/Modelos**: Pydantic v2
- **Banco**: aiomysql direto (sem ORM pesado) para MySQL

### Fluxo Proposto
1. Endpoint recebe PDF (`file` upload ou `file_url`)
2. Validação: tipo, tamanho, hash do arquivo
3. Salva arquivo temporário
4. Cria job no MySQL com `status = queued`
5. Enfileira job no worker
6. Worker: extrai texto → detecta layout → parseia → normaliza → valida
7. Grava itens em batch
8. Atualiza status e registra erros no job

### Schema Proposto (para validação do Data Engineer)
- `jobs` — controle de processamento (status, tentativas, timestamps)
- `invoices` — fatura raiz (com `file_hash` para idempotência)
- `invoice_items` — itens/transações da fatura
- `job_errors` — erros por job
- Índices sugeridos: `file_hash`, `status`, datas, `invoice_id`, `item_hash`

### Performance
- Hash do PDF para deduplicação/idempotência
- Batch inserts em chunks de 500–1000 registros
- Workers paralelos com backpressure
- Retry com backoff
- Limite de upload MVP: 50MB
- Parser em memória para o MVP; evoluir depois para streaming / `LOAD DATA INFILE` / OCR

### Limites do MVP
- **Sem OCR**: PDFs escaneados retornam erro claro com código `scanned_pdf` (não travar o pipeline)
- Suporte inicial a **1–3 layouts** + fallback genérico (`raw_text`) para formatos desconhecidos

### API Mínima
- `POST /api/v1/invoices/process` — envia PDF para processamento
- `GET /api/v1/invoices/jobs/{job_id}` — consulta status do job
- `GET /api/v1/invoices/{invoice_id}/items` — opcional, itens da fatura

## Decisões Pendentes / Blockers

| # | Item | Quem resolve | Impacto |
|---|------|--------------|---------|
| 1 | **Caminho absoluto do projeto não confirmado** | Usuário | Bloqueia toda implementação |
| 2 | Aprovação da stack (FastAPI + ARQ/PyMuPDF/aiomysql) | Usuário | Gate `architecture` continua `pending` |
| 3 | Validação do schema proposto | Data Engineer | Pode alterar tabelas/índices antes de migration |
| 4 | Escolha final entre ARQ e Celery | Usuário/DevOps | Impacta deploy de workers |
| 5 | Definir volume-alvo para dimensionar workers | Usuário | Afeta configuração de fila/backpressure |

## Próximos Agentes Sugeridos

1. **Data Engineer** — validar/refinar o schema proposto (pode começar mesmo sem caminho confirmado, apenas como proposta)
2. **Backend Dev** — **somente após** confirmação do caminho absoluto do projeto
3. **QA / Security** — cobertura mínima após implementação (ou antes, para definir critérios de aceite)

## Arquivos Alterados

| Arquivo | Mudança |
|---------|---------|
| `.opencode/state/handoffs/architect-20260911-invoice-backend-mvp.md` | **Criado** — registro do resultado do Architect |

## Observação de Escrita

O arquivo foi criado com sucesso em `D:\Agents\opencode-multi-agents\.opencode\state\handoffs\architect-20260911-invoice-backend-mvp.md`.