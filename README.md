# opencode-multi-agents

12 agentes especializados para o [opencode](https://opencode.ai), trabalhando em colaboração para desenvolver projetos completos.

![Release](https://img.shields.io/badge/release-v0.1.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Agents](https://img.shields.io/badge/agents-13-orange)
![Commands](https://img.shields.io/badge/commands-13-purple)
![Skills](https://img.shields.io/badge/skills-6-yellow)
![Language](https://img.shields.io/badge/language-Portuguese--BR-brightgreen)

## Visão Geral

Este pacote fornece um time completo de agentes de IA que colaboram automaticamente para criar projetos de software, desde a concepção até o deploy.

```
Usuário → Tech Lead → Architect → Data Engineer → UI/UX → Backend → Frontend → Security → QA → DevOps → Documentation
```

## Agentes

| # | Agente | Função |
|---|--------|--------|
| 1 | **Tech Lead** | Orquestra todos os agentes e valida gates |
| 2 | **Architect** | Define System Design, capacidade, resiliência e ADRs |
| 3 | **Data Engineer** | Modela banco de dados, escala e cache |
| 4 | **UI/UX** | Cria design da interface |
| 5 | **Backend Dev** | Implementa APIs resilientes e workers |
| 6 | **Backend Reviewer** | Revisa código backend e System Design |
| 7 | **Frontend Dev** | Implementa interface |
| 8 | **Frontend Reviewer** | Revisa código frontend |
| 9 | **Security** | Auditoria de segurança |
| 10 | **QA Engineer** | Cria testes automatizados |
| 11 | **DevOps** | Configura CI/CD, HA, observabilidade e deploy |
| 12 | **Documentation** | Gera documentação |

## 🚀 Começando Agora

### 📌 O que escolher: Fork ou Template?

Escolha de acordo com seu objetivo:

| Situação | O que fazer | Por quê |
|----------|-------------|---------|
| **Testar / Acompanhar atualizações** | **Fork** | Mantém conexão com o original, sincroniza com 1 clique |
| **Criar um projeto novo independente** | **Use this template** | Repo limpo, sem vínculo, pronto para personalizar |
| **Adicionar num projeto que já existe** | **./install.sh** ou **.\install.ps1** | Copia só os arquivos necessários |

---

### Opção 1: Fork (para testar e acompanhar atualizações)

Recomendado para quem quer testar o sistema, reportar bugs ou acompanhar melhorias.

**Linux / Mac:**
```bash
# 1. No GitHub, abra o repositório original e clique em "Fork"
#    (marque "Copy the main branch only")

# 2. Clone o fork
git clone https://github.com/[seu-usuario]/opencode-multi-agents.git
cd opencode-multi-agents

# 3. Iniciar
chmod +x start.sh
./start.sh
```

**Windows PowerShell:**
```powershell
# 1. No GitHub, abra o repositório original e clique em "Fork"
#    (marque "Copy the main branch only")

# 2. Clone o fork
git clone https://github.com/[seu-usuario]/opencode-multi-agents.git
cd opencode-multi-agents

# 3. Iniciar
.\start.ps1
```

**Para atualizar** (quando houver versões novas):

- **No GitHub:** clique em **"Sync fork"** no seu fork (1 clique)
- **No terminal:**
```bash
git fetch upstream
git merge upstream/main
git push
```

---

### Opção 2: Use this template (para projetos novos)

Recomendado para quem quer iniciar um projeto do zero com os agentes prontos.

```
1. Acesse o repositório original
2. Clique em "Use this template" → "Create a new repository"
3. Escolha um nome para o seu projeto novo (ex: meu-saas)
4. Abra o Codespaces ou clone localmente
5. Execute: ./start.sh (Linux/Mac) ou .\start.ps1 (Windows)
```

> ⚠️ Um repositório criado via template **não recebe atualizações automáticas**.
> Se quiser as versões novas, terá que copiar manualmente ou usar `./install.sh`.

---

### Opção 3: Instalar em projeto existente

**Linux / Mac:**
```bash
./install.sh /caminho/do/seu/projeto
```

**Windows PowerShell:**
```powershell
.\install.ps1 -TargetDir "C:\caminho\do\seu\projeto"
```

---

## ⚠️ IMPORTANTE: Como usar os /comandos

Os comandos como `/setup`, `/start-project` são digitados **DENTRO da interface do opencode**, **NÃO** no terminal bash.

```
❌ ERRADO:   bash$ /setup            ← não funciona!
✅ CORRETO:  bash$ ./start.sh        ← abre o opencode
             opencode> /setup        ← digite dentro do opencode
```

## Configuração

### 1. Configurar Ambiente

Dentro do opencode, execute:

```
/setup
```

O Setup Agent irá:
- Perguntar qual modelo deseja usar
- **Padrão:** modelo gratuito `opencode/big-pickle` (nenhuma API key necessária)
- Se quiser modelos pagos (Anthropic, OpenAI, etc), configure a API key
- Validar a conexão
- Gerar os arquivos necessários (`.env`, `.gitignore`)

> 💡 **Sem API key? Sem problema!** O modelo gratuito já funciona para começar.

### 2. Iniciar Projeto

Dentro do opencode, execute:

```
/start-project "Sistema de gestão escolar para escolas médias"
```

O Tech Lead irá:
- Fazer perguntas sobre o projeto
- Orquestrar todos os agentes
- Cada agente faz suas perguntas e executa seu trabalho
- Ao final, sugere o próximo agente automaticamente

## Comandos Disponíveis

| Comando | Descrição |
|---------|-----------|
| `/setup` | Configurar ambiente (gratuito ou pago) |
| `/start-project` | Iniciar novo projeto |
| `/full-cycle` | Ciclo completo automatizado |
| `/review-code` | Revisão de código |
| `/security-audit` | Auditoria de segurança |
| `/deploy` | Configurar deploy |
| `/status` | Ver progresso |
| `/resume [agente]` | Retomar agente específico |
| `/skip [agente]` | Pular agente |
| `/redo [agente]` | Refazer agente |
| `/setup-status` | Ver configuração |
| `/setup-reset` | Resetar configuração |
| `/mode` | Ver/alternar modo de permissões (autônomo vs seguro) |

### 🛡️ Modos de Permissão (Autônomo vs Seguro)

Você pode alternar se o OpenCode deve pedir confirmação a cada alteração ou agir de forma 100% autônoma:

* **Modo Autônomo (Padrão Recomendado)**: Modifica arquivos, roda comandos de teste e delega tarefas sem interrupções manuais.
  * Ativar no Windows: `powershell .\set-mode.ps1 auto`
  * Ativar no Linux/Mac: `./set-mode.sh auto`
  * Iniciar diretamente: `.\start.ps1 -Auto` ou `./start.sh --auto`
* **Modo Seguro / Interativo**: Exibe um pedido de confirmação (`ask`) antes de cada alteração de arquivo ou comando bash.
  * Ativar no Windows: `powershell .\set-mode.ps1 ask`
  * Ativar no Linux/Mac: `./set-mode.sh ask`
  * Iniciar diretamente: `.\start.ps1 -Ask` ou `./start.sh --ask`
* **Verificar Status Atual**: Execute `.\set-mode.ps1 status` no terminal ou `/mode` dentro do OpenCode.

## Fluxo de Trabalho

```
┌─────────────────────────────────────────────────────────────┐
│  USUÁRIO                                                    │
│  "Quero criar um SaaS de gestão escolar"                   │
│  e confirma pasta absoluta de trabalho                      │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  TECH LEAD                                                  │
│  Pergunta: objetivos, tráfego, volume e SLAs                │
│  → Invoca: Architect                                        │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  ARCHITECT (System Design)                                  │
│  Estimativas de capacidade (QPS, Banda, Storage),           │
│  Topologia C4, Resiliência, SPOFs e Proposta de ADR         │
│  → Invoca: Data Engineer + UI/UX                            │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  DATA ENGINEER + UI/UX (paralelo)                           │
│  Data: Schema, índices, pools e outbox │ UI/UX: Design      │
│  → Invoca: Backend Dev + Frontend Dev                       │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  BACKEND DEV + FRONTEND DEV (paralelo)                      │
│  Backend: APIs, Idempotência, Circuit Breaker, Workers      │
│  → Invoca: Reviewers                                        │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  SECURITY + QA + DEVOPS + DOCUMENTATION                     │
│  Segurança, testes, HA/Observabilidade, docs                │
│  → Relatório final                                          │
└─────────────────────────────────────────────────────────────┘
```

## Provedores Suportados

| Provedor | Modelos | API Key | Status |
|----------|---------|---------|--------|
| OpenCode | big-pickle | Não necessária | ✅ **Padrão (Gratuito)** |
| Anthropic | Claude | Necessária | ✅ Pago |
| OpenAI | GPT-4 | Necessária | ✅ Pago |
| Google | Gemini | Necessária | ✅ Pago |
| LM Studio | Local | Não necessária | ✅ Gratuito (requer hardware) |

## Estrutura do Projeto

```
.opencode/
├── agents/           # 13 agentes
│   ├── tech-lead.md
│   ├── architect.md
│   ├── data-engineer.md
│   ├── backend-dev.md
│   ├── backend-reviewer.md
│   ├── frontend-dev.md
│   ├── frontend-reviewer.md
│   ├── ui-ux.md
│   ├── security.md
│   ├── documentation.md
│   ├── devops.md
│   ├── qa-engineer.md
│   └── setup.md
├── command/          # Comandos
│   ├── setup.md
│   ├── start-project.md
│   ├── review-code.md
│   ├── security-audit.md
│   ├── deploy.md
│   ├── full-cycle.md
│   ├── status.md
│   ├── resume.md
│   ├── skip.md
│   ├── redo.md
│   ├── setup-status.md
│   ├── setup-reset.md
│   └── mode.md
└── skills/           # 6 Skills
    ├── api-design/
    ├── database-design/
    ├── documentation/
    ├── security-best-practices/
    ├── system-design/
    └── testing-strategies/
.devcontainer/       # Codespaces (ambiente pronto)
├── devcontainer.json
└── setup.sh
set-mode.sh          # Alterna permissões (Linux/Mac)
set-mode.ps1         # Alterna permissões (Windows)
install.sh           # Instala em outro projeto (Linux/Mac)
install.ps1          # Instala em outro projeto (Windows)
start.sh             # Inicia com guia interativo (Linux/Mac)
start.ps1            # Inicia com guia interativo (Windows)
```

## Contribuição

1. Fork o projeto
2. Crie uma branch (`git checkout -b feature/novo-agente`)
3. Commit suas mudanças (`git commit -m 'Adiciona novo agente'`)
4. Push para a branch (`git push origin feature/novo-agente`)
5. Abra um Pull Request

## Licença

MIT - Veja [LICENSE](LICENSE) para mais detalhes.

## Links Úteis

- [opencode](https://opencode.ai) - Documentação oficial
- [Repositório](https://github.com/duartebruno496/opencode-multi-agents) - Código fonte
- [Issues](https://github.com/duartebruno496/opencode-multi-agents/issues) - Reportar bugs

## Agradecimentos

- Equipe do opencode pela ferramenta incrível
- Comunidade open source
