#!/bin/bash
# ==============================================================================
# Script de Verificação de Ambiente e Dependências — Angel OS
# ==============================================================================

set -e

GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
NC='\033[0m'

echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN}          ANGEL OS — Verificação de Ambiente               ${NC}"
echo -e "${CYAN}============================================================${NC}"

MISSING_TOOLS=()

check_tool() {
    if ! command -v "$1" &>/dev/null; then
        MISSING_TOOLS+=("$1")
        echo -e "${RED}[X] Ferramenta '$1' não encontrada.${NC}"
    else
        echo -e "${GREEN}[OK] Ferramenta '$1' detectada.${NC}"
    fi
}

echo -e "\n${YELLOW}Verificando ferramentas essenciais para compilação/empacotamento:${NC}"
check_tool xorriso
check_tool mksquashfs
check_tool unsquashfs
check_tool gcc
check_tool make

if [ ${#MISSING_TOOLS[@]} -ne 0 ]; then
    echo -e "\n${RED}Algumas dependências estão ausentes: ${MISSING_TOOLS[*]}${NC}"
    echo -e "${YELLOW}Instale as ferramentas necessárias para prosseguir com a criação da ISO Angel OS.${NC}"
else
    echo -e "\n${GREEN}Todos os pré-requisitos estão presentes! O ambiente está pronto para o Angel OS.${NC}"
fi
