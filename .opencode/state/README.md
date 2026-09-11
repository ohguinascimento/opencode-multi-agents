# Estado persistente do workflow

`workflow.json` é a fonte de verdade do andamento do projeto. O Tech Lead deve atualizá-lo antes e depois de cada agente.

Os handoffs ficam em `handoffs/` e nunca devem ser apagados ao refazer uma etapa. Decisões estáveis ficam em `../memory/decisions/`.

Status permitidos: `not_started`, `in_progress`, `paused`, `completed`, `blocked` e `failed`.
