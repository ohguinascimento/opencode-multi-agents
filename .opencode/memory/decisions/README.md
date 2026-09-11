# Memória de decisões

Use esta pasta para registrar decisões aprovadas que devem continuar válidas entre sessões e agentes.

## Regras

1. Uma decisão deve ter uma fonte: usuário, arquivo, teste ou decisão anterior.
2. Não alterar uma decisão `accepted` silenciosamente.
3. Para mudar uma decisão, crie uma nova ADR e marque a anterior como `superseded`.
4. Propostas não são fatos e não devem orientar implementação sem aprovação.
5. Se houver conflito, pare a tarefa dependente e informe o Tech Lead.

## Status

- `proposed`: aguardando aprovação.
- `accepted`: aprovada e obrigatória.
- `rejected`: rejeitada, mantida apenas para histórico.
- `superseded`: substituída por outra decisão.
