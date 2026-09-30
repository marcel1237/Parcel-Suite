#!/bin/bash
# ==============================================================================
# Script Mestre de Gerenciamento do Build — Angel OS KDE-Full
# ==============================================================================

set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
PROJECT_ROOT=$(cd -- "$SCRIPT_DIR/.." &>/dev/null && pwd)

GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN}          ANGEL OS KDE-FULL — BUILD SYSTEM v1.0.0            ${NC}"
echo -e "${CYAN}                 \"The Linux unix-like\"                      ${NC}"
echo -e "${CYAN}============================================================${NC}"

source "$PROJECT_ROOT/config/angel-os.conf" 2>/dev/null || true

echo -e "\n${YELLOW}Configurações Ativas:${NC}"
echo -e "  - Sistema: ${GREEN}${OS_NAME} (${OS_FLAVOR:-KDE-Full})${NC}"
echo -e "  - Kernel Alvo: ${GREEN}${TARGET_KERNEL_NAME} ${TARGET_KERNEL_VERSION}${NC}"
echo -e "  - Base: ${GREEN}${DEFAULT_BASE}${NC}"
echo -e "  - Desktop Padrão: ${GREEN}${DEFAULT_DESKTOP}${NC}"
echo -e "  - Gerenciador de Sessão: ${GREEN}${DEFAULT_DISPLAY_MANAGER}${NC}"

show_help() {
    echo -e "\n${CYAN}Uso:${NC} ./scripts/build_angel_os.sh [opção]"
    echo -e "\n${YELLOW}Opções Gerais:${NC}"
    echo -e "  --check       Verifica o ambiente e dependências de build"
    echo -e "  --seraphin    Prepara/compila o kernel Seraphin (Vanilla 7.3)"
    echo -e "  --querubin    Prepara/compila o mini-kernel Querubin"
    echo -e "  --help        Exibe esta mensagem de ajuda"
    echo -e "\n${YELLOW}Fases do Roadmap Angel OS KDE-Full:${NC}"
    echo -e "  --fase1       Executa FASE 1: Kernel Vanilla 7.3 → initramfs → Angel OS base → shell"
    echo -e "  --fase2       Executa FASE 2: systemd → udev → rede → áudio"
    echo -e "  --fase3       Executa FASE 3: DRM → Mesa → Vulkan → Wayland → KWin"
    echo -e "  --fase4       Executa FASE 4: Qt → KDE Frameworks → KDE Plasma Full → SDDM"
}

case "$1" in
    --check)
        "$SCRIPT_DIR/bootstrap_env.sh"
        ;;
    --seraphin)
        echo -e "\n${CYAN}>> Preparando subsistema Kernel Seraphin (Linux Vanilla 7.3)...${NC}"
        echo "Caminho: $PROJECT_ROOT/Seraphin: Angel Linux Kernel/"
        ;;
    --querubin)
        echo -e "\n${CYAN}>> Preparando subsistema Mini-Kernel Querubin...${NC}"
        echo "Caminho: $PROJECT_ROOT/Querubin: Linux mini-kernel/"
        ;;
    --fase1)
        echo -e "\n${CYAN}>> [FASE 1] Construindo Kernel Vanilla 7.3 + Initramfs Próprio + Base Angel OS...${NC}"
        ;;
    --fase2)
        echo -e "\n${CYAN}>> [FASE 2] Configurando systemd + udev + NetworkManager + PipeWire...${NC}"
        ;;
    --fase3)
        echo -e "\n${CYAN}>> [FASE 3] Montando DRM + Mesa + Vulkan + Wayland + KWin...${NC}"
        ;;
    --fase4)
        echo -e "\n${CYAN}>> [FASE 4] Integrando Qt6 + KDE Frameworks + KDE Plasma Full + SDDM...${NC}"
        ;;
    *)
        show_help
        ;;
esac
