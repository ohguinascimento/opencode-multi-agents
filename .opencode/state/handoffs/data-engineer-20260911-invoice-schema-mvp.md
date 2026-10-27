# Handoff: Data Engineer — Invoice Schema MVP

**Date**: 2026-09-11
**Agent**: Data Engineer
**Task**: Validar e refinar o schema MySQL para processamento de faturas de cartão em PDF (MVP para hoje)

## Estado do Workflow (não alterado)

- `workflow.json`: `status = not_started`, `workflow = null`, `project = null`, gates **pending**, `blockers = []`, `history = []`.
- **Este handoff NÃO alterou `workflow.json` e não deve ser alterado por este resultado.**
- Motivo: a evidência do Data Engineer é apenas **proposta textual**; não há evidência executável (schema aprovado, código, testes) nem aprovação humana/caminho-alvo confirmado.
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

## Proposta do Data Engineer (NÃO é fato aprovado)

Status: `proposed` — refinamento técnico do schema, **aguardando aprovação humana** e implementação.

### Schema MySQL 8 Proposto

#### Tabelas

| Tabela | Propósito | Observações |
|--------|-----------|-------------|
| `processing_jobs` | Controle de processamento (status, tentativas, timestamps) | Nomenclatura recomendada em vez de `jobs` ou `invoice_processing_jobs` |
| `invoices` | Fatura raiz | `file_hash CHAR(64)` UNIQUE para idempotência |
| `invoice_items` | Itens/transações da fatura | `item_hash` **não UNIQUE** no MVP (compras idênticas possíveis) |
| `processing_errors` | Erros por job | FK para `processing_jobs` |

#### Configurações de Tabela

- **Engine**: InnoDB
- **Charset**: `utf8mb4_unicode_ci`
- **Timestamps**: `DATETIME(3)` para precisão de milissegundos

#### Colunas-Chave

| Tabela | Coluna | Tipo | Observação |
|--------|--------|------|------------|
| `processing_jobs` | `file_hash` | `CHAR(64)` UNIQUE | Idempotência no upload |
| `processing_jobs` | `status` | `ENUM(...)` | Estados do job |
| `invoices` | `file_hash` | `CHAR(64)` UNIQUE | Idempotência na fatura |
| `invoice_items` | `item_hash` | `CHAR(64)` | **Não UNIQUE** no MVP |

#### Índices Recomendados

| Tabela | Índice | Coluna(s) | Motivo |
|--------|--------|-----------|--------|
| `processing_jobs` | `idx_status_created` | `status`, `created_at` | Filtragem por status e ordenação temporal |
| `invoices` | `idx_statement_date` | `statement_date` | Consultas por período |
| `invoice_items` | `idx_invoice_id_position` | `invoice_id`, `item_position` | Acesso rápido por fatura e ordenação |
| `invoice_items` | `idx_invoice_id_amount` | `invoice_id`, `amount` | Consultas agregadas por fatura |

### Padrões de Performance

| Padrão | Recomendação |
|--------|--------------|
| Parse do PDF | **Fora da transação** (arquivo temporário) |
| Writes no MySQL | **Transação curta** apenas para gravação |
| Batch inserts | `executemany` com chunks de **500 registros** |
| Connection pool | **aiomysql** com pool 5–20 conexões |
| `max_allowed_packet` | Configurar para **64MB** |
| Paginação | **Cursor-based** (`WHERE id > last_id`) em vez de OFFSET |

### Idempotência

| Cenário | Comportamento Proposto |
|---------|------------------------|
| Upload duplicado (mesmo `file_hash`) | Retorna job existente usando hash + UNIQUE |
| Verificação | `SELECT ... FOR UPDATE` para evitar race condition |
| `item_hash` | **Não UNIQUE** no MVP (compras idênticas são válidas) |
| Reprocessamento | **Ainda pendente** — definição não concluída |

### Riscos Identificados

| Risco | Mitigação Rápida |
|-------|------------------|
| `packet too large` | `max_allowed_packet = 64MB` |
| Locks por transações longas | Transações curtas; parse fora |
| Decimal/locale | Usar `DECIMAL(15,2)` explícito; não confiar em `float` |
| Timezone | Gravar `DATETIME` em UTC; converter na apresentação |
| JSON hot path | Evitar colunas JSON em queries frequentes; usar `TEXT` ou normalizar |

## Decisões Pendentes / Blockers

| # | Item | Quem resolve | Impacto |
|---|------|--------------|---------|
| 1 | **Caminho absoluto do projeto não confirmado** | Usuário | Bloqueia toda implementação |
| 2 | **Política de reprocessamento** | Usuário/Architect | Afeta schema de jobs e fluxo de retry |
| 3 | **Volume-alvo** (jobs/dia, itens/job) | Usuário | Afeta dimensionamento de pool e batch |
| 4 | **JSON vs TEXT para metadata** | Data Engineer/Architect | Trade-off flexibilidade vs performance |
| 5 | Aprovação do schema proposto | Usuário | Gate `architecture` continua `pending` |

## Próximos Agentes Sugeridos

1. **Backend Dev** — implementar schema e código **somente após** confirmação do caminho absoluto do projeto
2. **Architect** — validar decisões pendentes (reprocessamento, metadata)
3. **QA / Security** — cobertura mínima após implementação

## Arquivos Alterados

| Arquivo | Mudança |
|---------|---------|
| `.opencode/state/handoffs/data-engineer-20260911-invoice-schema-mvp.md` | **Criado** — registro do resultado do Data Engineer |

## Observação de Escrita

O arquivo foi criado com sucesso em `D:\Agents\opencode-multi-agents\.opencode\state\handoffs\data-engineer-20260911-invoice-schema-mvp.md`.
