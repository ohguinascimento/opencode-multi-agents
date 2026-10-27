---
description: Exibe o modo atual de permissões e orienta como alternar entre modo autônomo e seguro
agent: tech-lead
---

# Comando: /mode

## Descrição
Exibe o estado atual das permissões de modificação e execução do OpenCode e explica como alternar entre o **Modo Autônomo** (sem solicitar confirmação para cada alteração de arquivo ou comando) e o **Modo Seguro** (solicitando confirmação manual a cada passo).

## Uso
```
/mode
```

## Modos Disponíveis

### 1. Modo Autônomo (Auto-Approve) - Padrão Recomendado
- **Comportamento**: Os agentes implementam código, criam arquivos, executam comandos de teste e delegam tarefas automaticamente, **sem pausar para pedir confirmação**.
- **Configuração no `opencode.json`**:
  ```json
  "permission": {
    "read": "allow",
    "edit": "allow",
    "bash": "allow",
    "task": { "*": "allow" }
  }
  ```
- **Como Iniciar no Terminal**:
  - Windows: `.\start.ps1 -Auto` ou simplesmente `.\start.ps1`
  - Linux/Mac: `./start.sh --auto` ou simplesmente `./start.sh`
- **Como Ativar**:
  - Windows: `powershell .\set-mode.ps1 auto`
  - Linux/Mac: `./set-mode.sh auto`

---

### 2. Modo Seguro (Interativo)
- **Comportamento**: O OpenCode pausa e exibe uma caixa de diálogo/pergunta toda vez que um agente tenta modificar um arquivo ou rodar um comando bash.
- **Configuração no `opencode.json`**:
  ```json
  "permission": {
    "read": "allow",
    "edit": "ask",
    "bash": "ask",
    "task": { "*": "ask" }
  }
  ```
- **Como Iniciar no Terminal**:
  - Windows: `.\start.ps1 -Ask`
  - Linux/Mac: `./start.sh --ask`
- **Como Ativar**:
  - Windows: `powershell .\set-mode.ps1 ask`
  - Linux/Mac: `./set-mode.sh ask`

---

## Como verificar o status atual no terminal:
- Windows: `.\set-mode.ps1 status`
- Linux/Mac: `./set-mode.sh status`
