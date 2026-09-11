# Gates obrigatórios

Um agente não pode avançar enquanto o gate predecessor estiver `failed` ou `blocked`.

## Critérios

| Gate | Critérios mínimos | Evidência obrigatória |
|---|---|---|
| architecture | requisitos, stack, ADRs e riscos definidos | ADRs e resumo de arquitetura |
| backend | migrations, API, validações e testes backend funcionando | comandos e exit codes |
| frontend | build, TypeScript e fluxos principais funcionando | build e testes |
| security | sem vulnerabilidades críticas/altas e sem secrets expostos | relatório de auditoria |
| qa | testes unitários, integração e E2E críticos aprovados | relatório e cobertura |
| devops | build reproduzível, health check e rollback documentados | logs de validação |

## Estados

- `pending`: ainda não executado
- `running`: em execução
- `passed`: aprovado
- `failed`: reprovado; bloqueia dependências
- `blocked`: não pode executar; bloqueia dependências
- `waived`: liberado manualmente com justificativa e aprovação

Nunca use `passed` sem registrar a evidência em `last_validation` ou no handoff do agente.
