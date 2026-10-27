#!/usr/bin/env bash
# ============================================
# sync-skills.sh - Sincroniza Skills OpenCode -> Antigravity
# ============================================

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo -e "${CYAN}=============================================${NC}"
echo -e "${CYAN}  Sincronizador de Skills: OpenCode -> Antigravity${NC}"
echo -e "${CYAN}=============================================${NC}"
echo ""

SOURCE_SKILLS=".opencode/skills"
if [ ! -d "$SOURCE_SKILLS" ]; then
    echo -e "${RED}[ERRO] Diretório $SOURCE_SKILLS não encontrado!${NC}"
    exit 1
fi

GLOBAL_GEMINI_SKILLS="$HOME/.gemini/config/skills"
LOCAL_AGENTS_SKILLS=".agents/skills"

# 1. Sincronizar Workspace (.agents/skills)
echo -e "${CYAN}[1/2] Sincronizando para Workspace (.agents/skills)...${NC}"
mkdir -p "$LOCAL_AGENTS_SKILLS"
cp -rf "$SOURCE_SKILLS"/* "$LOCAL_AGENTS_SKILLS/"
echo -e "${GREEN}  -> OK: Skills copiadas para $LOCAL_AGENTS_SKILLS${NC}"

# 2. Sincronizar Global Antigravity (~/.gemini/config/skills)
echo -e "${CYAN}[2/2] Sincronizando para Antigravity Global ($GLOBAL_GEMINI_SKILLS)...${NC}"
mkdir -p "$GLOBAL_GEMINI_SKILLS"
cp -rf "$SOURCE_SKILLS"/* "$GLOBAL_GEMINI_SKILLS/"
echo -e "${GREEN}  -> OK: Skills copiadas para $GLOBAL_GEMINI_SKILLS${NC}"

echo ""
echo -e "${GREEN}=============================================${NC}"
echo -e "${GREEN}  Skills sincronizadas com sucesso!${NC}"
echo -e "${GREEN}  As skills especialistas já estão ativas no Antigravity.${NC}"
echo -e "${GREEN}=============================================${NC}"
echo ""
