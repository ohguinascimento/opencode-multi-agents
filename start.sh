#!/bin/bash

# ============================================
# opencode-multi-agents - Start Script
# ============================================

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[OK]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[AVISO]${NC} $1"; }
print_error() { echo -e "${RED}[ERRO]${NC} $1"; }

# Banner de boas-vindas
show_banner() {
    echo
    echo -e "${CYAN}=============================================${NC}"
    echo -e "${CYAN}  opencode-multi-agents v0.1.0${NC}"
    echo -e "${CYAN}  Linux / Mac${NC}"
    echo -e "${CYAN}=============================================${NC}"
    echo
}

# Instalar o opencode automaticamente
install_opencode() {
    print_info "Instalando opencode (isto pode levar alguns segundos)..."
    echo
    
    # Detecta arquitetura correta
    local ARCH
    case "$(uname -m)" in
        x86_64)  ARCH="x86_64" ;;
        aarch64|arm64) ARCH="aarch64" ;;
        *)        ARCH="x86_64" ;;
    esac
    
    # Baixa o binário no diretório local
    mkdir -p .opencode/bin
    local URL="https://opencode.ai/install"
    
    if curl -fsSL "$URL" | bash -e > /tmp/opencode-install.log 2>&1; then
        # Se instalou no diretório padrão ~/.opencode
        if [ -f "$HOME/.opencode/bin/opencode" ]; then
            export PATH="$HOME/.opencode/bin:$PATH"
            print_success "opencode instalado em ~/.opencode/bin/"
        fi
    else
        print_error "Falha na instalação automática."
        cat /tmp/opencode-install.log 2>/dev/null | tail -10
        echo
        print_info "Tente instalar manualmente:"
        echo -e "${YELLOW}  curl -fsSL https://opencode.ai/install | bash${NC}"
        exit 1
    fi
}

# Verificar se o opencode está disponível (instalando se necessário)
check_opencode() {
    # Verifica PATH
    if command -v opencode &> /dev/null; then
        print_success "opencode encontrado"
        return 0
    fi
    
    # Verifica diretórios comuns (no Codespaces o home é outro)
    for dir in "$HOME/.opencode/bin" "$HOME/.local/bin" "/usr/local/bin"; do
        if [ -x "$dir/opencode" ]; then
            export PATH="$dir:$PATH"
            print_success "opencode encontrado em $dir"
            return 0
        fi
    done
    
    # Se não encontrou, tenta instalar automaticamente
    install_opencode
    
    # Verifica se instalou
    if ! command -v opencode &> /dev/null; then
        print_error "Não foi possível iniciar o opencode."
        exit 1
    fi
    print_success "opencode instalado com sucesso"
}

# Verificar se opencode.json existe
check_config() {
    if [ ! -f "opencode.json" ]; then
        print_error "opencode.json não encontrado!"
        print_info "Execute ./install.sh primeiro para instalar os agentes."
        exit 1
    fi
    print_success "configuração encontrada"
}

# Verificar se o .env está configurado (opcional com modelo gratuito)
check_env() {
    if [ ! -f ".env" ]; then
        print_info "Arquivo .env não encontrado (ok se usar modelo gratuito)"
        return 1
    fi
    
    # Verificar se tem API key configurada (opcional)
    if grep -q "OPENCODE_API_KEY=" .env 2>/dev/null && ! grep -q "OPENCODE_API_KEY=$" .env 2>/dev/null && ! grep -q "OPENCODE_API_KEY=sua-chave-aqui" .env 2>/dev/null; then
        local key
        key=$(grep "^OPENCODE_API_KEY=" .env | cut -d'=' -f2-)
        if [ ${#key} -ge 20 ]; then
            print_success "API key configurada"
            return 0
        fi
    fi
    
    print_info "Usando modelo gratuito (nenhuma API key necessária)"
    return 0
}

# Mostrar instruções de uso
show_help() {
    echo -e "${BLUE}═══════════════════════════════════════════${NC}"
    echo -e "${BLUE}  COMO USAR O OPENCODE-MULTI-AGENTS${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════${NC}"
    echo
    echo "A partir daqui, você entrará na interface do opencode."
    echo "Dentro dela, digite os comandos abaixo."
    echo
    echo -e "${YELLOW}NUNCA digite /comandos no terminal!${NC}"
    echo "Os /comandos são digitados DENTRO da interface do opencode."
    echo
    echo -e "${CYAN}Primeira vez:${NC}"
    echo "  1. Digite:  ${GREEN}/setup${NC}"
    echo "     → Configure seu provedor de IA e API key"
    echo "  2. Digite:  ${GREEN}/start-project \"descrição do projeto\"${NC}"
    echo "     → O time de agentes trabalha para você"
    echo
    echo -e "${CYAN}Comandos disponíveis:${NC}"
    echo "  /setup           - Configurar ambiente (API key)"
    echo "  /setup-status    - Ver configuração atual"
    echo "  /start-project   - Iniciar novo projeto"
    echo "  /full-cycle      - Ciclo completo automatizado"
    echo "  /review-code     - Revisar código"
    echo "  /security-audit  - Auditoria de segurança"
    echo "  /deploy          - Configurar deploy"
    echo "  /status          - Ver progresso"
    echo "  /mode            - Ver/configurar modo de permissões"
    echo
    echo -e "${BLUE}═══════════════════════════════════════════${NC}"
    echo -e "${BLUE}  MANTER ATUALIZADO${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════${NC}"
    echo
    echo -e "${CYAN}Se você fez FORK deste repositório:${NC}"
    echo "  → No GitHub: clique em \"Sync fork\" para atualizar"
    echo "  → No terminal:"
    echo -e "      ${GREEN}git fetch upstream && git merge upstream/main${NC}"
    echo
    echo -e "${CYAN}Se usou \"Use this template\":${NC}"
    echo "  → Não recebe atualizações automáticas"
    echo "  → Para copiar uma versão nova, rode: ${GREEN}./install.sh${NC}"
    echo
    echo -e "${BLUE}═══════════════════════════════════════════${NC}"
    echo
    if [ "$1" = "first" ]; then
        echo -e "${YELLOW}→ Execute ${GREEN}/setup${YELLOW} ao entrar para escolher seu modelo.${NC}"
        echo -e "  Padrão: modelo gratuito (sem API key). Opções pagas disponíveis."
        echo
    fi
}

# Verificar se existe npm/npx
check_npm() {
    if ! command -v node &> /dev/null && ! command -v npx &> /dev/null; then
        print_warning "Node.js não encontrado. opencode pode precisar dele."
        echo "  Instale Node.js: https://nodejs.org"
    fi
}

# Main
main() {
    show_banner
    
    print_info "Verificando ambiente..."
    echo
    
    check_opencode
    check_config
    check_npm
    
    echo
    if check_env; then
        print_success "API key configurada"
        echo
        show_help "ready"
    else
        print_warning "Configuração inicial necessária"
        echo
        show_help "first"
    fi

    # Detectar modo de permissões (Auto vs Ask)
    local IS_AUTO=false
    if [[ "$*" == *"--auto"* ]] || [[ "$*" == *"-y"* ]]; then
        IS_AUTO=true
    elif [[ "$*" == *"--ask"* ]]; then
        IS_AUTO=false
    else
        local EDIT_PERM
        EDIT_PERM=$(node -e "try { const c = require('./opencode.json'); console.log(c.permission?.edit || 'ask'); } catch(e) { console.log('ask'); }" 2>/dev/null || echo "ask")
        if [ "$EDIT_PERM" = "allow" ]; then
            IS_AUTO=true
        fi
    fi

    if [ "$IS_AUTO" = true ]; then
        print_success "Modo de Permissões: AUTÔNOMO (Sem pedir confirmação para modificações/comandos)"
        print_info "Iniciando opencode com --auto..."
        echo
        exec opencode --auto
    else
        print_warning "Modo de Permissões: SEGURO / INTERATIVO (Pedirá confirmação a cada alteração)"
        print_info "Dica: Para executar sem confirmação, use ./start.sh --auto ou rode ./set-mode.sh auto"
        echo
        print_info "Iniciando opencode..."
        echo
        exec opencode
    fi
}

main "$@"