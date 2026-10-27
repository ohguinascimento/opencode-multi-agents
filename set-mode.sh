#!/bin/bash
# ============================================
# opencode-multi-agents - Permission Mode Switcher (Linux/Mac)
# ============================================

CONFIG_FILE="opencode.json"
MODE="${1:-status}"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "[ERRO] Arquivo opencode.json nao encontrado!"
    exit 1
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

show_status() {
    EDIT=$(node -e "const c = require('./opencode.json'); console.log(c.permission?.edit || 'ask');")
    BASH=$(node -e "const c = require('./opencode.json'); console.log(c.permission?.bash || 'ask');")

    echo
    echo -e "${CYAN}=============================================${NC}"
    echo -e "${CYAN}  Status do Modo de Permissoes (OpenCode)${NC}"
    echo -e "${CYAN}=============================================${NC}"
    echo

    if [ "$EDIT" = "allow" ] && [ "$BASH" = "allow" ]; then
        echo -e "Modo Atual: ${GREEN}AUTONOMO (Sem pedir permissao)${NC}"
        echo -e "Modificacoes de arquivo: ${GREEN}AUTOMATICAS (allow)${NC}"
        echo -e "Comandos bash/terminal: ${GREEN}AUTOMATICOS (allow)${NC}"
    else
        echo -e "Modo Atual: ${YELLOW}SEGURO / INTERATIVO (Pede permissao)${NC}"
        echo -e "Modificacoes de arquivo: ${YELLOW}INTERATIVO ($EDIT)${NC}"
        echo -e "Comandos bash/terminal: ${YELLOW}INTERATIVO ($BASH)${NC}"
    fi

    echo
    echo -e "${BLUE}Comandos para alternar:${NC}"
    echo "  ./set-mode.sh auto   - Nao pede permissao para modificacoes (Modo Rapido)"
    echo "  ./set-mode.sh ask    - Pede permissao a cada modificacao (Modo Seguro)"
    echo "  ./set-mode.sh status - Exibe este status"
    echo
}

set_mode() {
    local target="$1"
    node -e "
        const fs = require('fs');
        const file = '$CONFIG_FILE';
        const data = JSON.parse(fs.readFileSync(file, 'utf8'));
        if ('$target' === 'auto') {
            data.permission.edit = 'allow';
            data.permission.bash = 'allow';
            data.permission.task = { '*': 'allow' };
        } else {
            data.permission.edit = 'ask';
            data.permission.bash = 'ask';
            data.permission.task = { '*': 'ask' };
        }
        fs.writeFileSync(file, JSON.stringify(data, null, 2) + '\n');
    "
    if [ "$target" = "auto" ]; then
        echo -e "${GREEN}[OK] Modo AUTONOMO ativado: o OpenCode executara modificacoes e comandos sem pedir permissao.${NC}"
    else
        echo -e "${YELLOW}[OK] Modo SEGURO ativado: o OpenCode solicitara confirmacao para cada modificacao.${NC}"
    fi
    echo -e "${CYAN}[INFO] Se o OpenCode estiver aberto, reinicie-o para aplicar a mudanca.${NC}"
    echo
}

case "$MODE" in
    auto)
        set_mode "auto"
        ;;
    ask)
        set_mode "ask"
        ;;
    status|*)
        show_status
        ;;
esac
