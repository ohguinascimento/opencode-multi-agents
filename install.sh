#!/bin/bash

# ============================================
# opencode-multi-agents - Script de Instalação
# ============================================

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para imprimir mensagens
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar se está no diretório correto
check_directory() {
    if [ ! -d ".opencode" ]; then
        print_error "Diretório .opencode não encontrado!"
        print_info "Execute este script na raiz do repositório opencode-multi-agents"
        exit 1
    fi
}

# Verificar se o opencode está instalado
check_opencode() {
    if ! command -v opencode &> /dev/null; then
        print_warning "opencode não encontrado no PATH"
        print_info "Instale o opencode: https://opencode.ai"
        print_info "Continuando com a instalação dos arquivos..."
    else
        print_success "opencode encontrado"
    fi
}

# Criar backup se .env existir
backup_env() {
    if [ -f ".env" ]; then
        print_warning "Arquivo .env já existe"
        read -p "Deseja fazer backup? (s/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Ss]$ ]]; then
            cp .env .env.backup.$(date +%Y%m%d_%H%M%S)
            print_success "Backup criado"
        fi
    fi
}

# Instalar arquivos
install_files() {
    local TARGET_DIR="$1"
    
    print_info "Instalando arquivos em: $TARGET_DIR"
    
    # Criar diretório de destino se não existir
    mkdir -p "$TARGET_DIR/.opencode"
    
    # Copiar agentes
    print_info "Copiando agentes..."
    cp -r .opencode/agents "$TARGET_DIR/.opencode/"
    
    # Copiar comandos
    print_info "Copiando comandos..."
    cp -r .opencode/command "$TARGET_DIR/.opencode/"
    
    # Copiar skills
    print_info "Copiando skills..."
    cp -r .opencode/skills "$TARGET_DIR/.opencode/"
    
    # Copiar configuração
    print_info "Copiando configuração..."
    cp opencode.json "$TARGET_DIR/"
    
    # Copiar scripts de inicialização e modo
    print_info "Copiando scripts..."
    [ -f "start.sh" ] && cp start.sh "$TARGET_DIR/"
    [ -f "start.ps1" ] && cp start.ps1 "$TARGET_DIR/"
    [ -f "set-mode.sh" ] && cp set-mode.sh "$TARGET_DIR/"
    [ -f "set-mode.ps1" ] && cp set-mode.ps1 "$TARGET_DIR/"
    
    # Copiar .gitignore (se não existir)
    if [ ! -f "$TARGET_DIR/.gitignore" ]; then
        cp .gitignore "$TARGET_DIR/"
    else
        # Adicionar entradas ao .gitignore existente
        print_info "Atualizando .gitignore existente..."
        if ! grep -q ".env" "$TARGET_DIR/.gitignore"; then
            echo "" >> "$TARGET_DIR/.gitignore"
            echo "# Configurações sensíveis" >> "$TARGET_DIR/.gitignore"
            echo ".env" >> "$TARGET_DIR/.gitignore"
            echo ".env.local" >> "$TARGET_DIR/.gitignore"
            echo ".env.*.local" >> "$TARGET_DIR/.gitignore"
            echo ".env.backup*" >> "$TARGET_DIR/.gitignore"
        fi
    fi
    
    # Copiar .env.example
    cp .env.example "$TARGET_DIR/"
    
    # Criar .env se não existir
    if [ ! -f "$TARGET_DIR/.env" ]; then
        cp .env.example "$TARGET_DIR/.env"
        print_warning "Arquivo .env criado. Configure suas API keys!"
    fi
    
    print_success "Arquivos instalados com sucesso!"
}

# Mostrar instruções pós-instalação
show_instructions() {
    local TARGET_DIR="$1"
    
    echo
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  Instalação Concluída!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo
    print_info "Arquivos instalados em: $TARGET_DIR"
    echo
    echo -e "${YELLOW}Próximos passos:${NC}"
    echo
    echo "1. Navegue até o diretório do projeto:"
    echo -e "   ${BLUE}cd $TARGET_DIR${NC}"
    echo
    echo "2. Configure suas API keys:"
    echo -e "   ${BLUE}nano .env${NC}"
    echo
    echo "3. Execute o setup no opencode:"
    echo -e "   ${BLUE}/setup${NC}"
    echo
    echo "4. Inicie seu projeto:"
    echo -e "   ${BLUE}/start-project \"descrição do projeto\"${NC}"
    echo
    echo -e "${YELLOW}Comandos disponíveis:${NC}"
    echo "  /setup          - Configurar ambiente"
    echo "  /start-project  - Iniciar novo projeto"
    echo "  /full-cycle     - Ciclo completo automatizado"
    echo "  /review-code    - Revisar código"
    echo "  /security-audit - Auditoria de segurança"
    echo "  /deploy         - Configurar deploy"
    echo "  /status         - Ver progresso"
    echo
}

# Função principal
main() {
    echo
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  opencode-multi-agents Installer${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo
    
    # Verificar argumentos
    if [ $# -eq 0 ]; then
        TARGET_DIR="."
    else
        TARGET_DIR="$1"
    fi
    
    # Executar verificações
    check_directory
    check_opencode
    
    # Perguntar diretório de destino
    if [ "$TARGET_DIR" = "." ]; then
        read -p "Diretório de instalação (Enter = diretório atual): " TARGET_DIR
        if [ -z "$TARGET_DIR" ]; then
            TARGET_DIR="."
        fi
    fi
    
    # Confirmar instalação
    echo
    print_info "Diretório de destino: $TARGET_DIR"
    read -p "Confirmar instalação? (s/n): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        print_info "Instalação cancelada"
        exit 0
    fi
    
    # Backup do .env
    backup_env
    
    # Instalar arquivos
    install_files "$TARGET_DIR"
    
    # Mostrar instruções
    show_instructions "$TARGET_DIR"
}

# Executar
main "$@"
