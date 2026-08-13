#!/bin/bash
# Parcel Play OS - Master Build Orchestrator
# Versão: 1.0.0

set -e

# Configurações de Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}==============================================${NC}"
echo -e "${BLUE}   PARCEL PLAY OS - INICIANDO CONSTRUÇÃO      ${NC}"
echo -e "${BLUE}==============================================${NC}"

# Definir variáveis de ambiente
export PARCEL_ROOT=$(pwd)
export BUILD_DIR="${PARCEL_ROOT}/build-env"
export SCRIPTS_DIR="${PARCEL_ROOT}/scripts"

mkdir -p "$BUILD_DIR"

# Executar Etapas
echo -e "${GREEN}[1/8] Etapa: Gênese (Bootstrap da Toolchain)...${NC}"
# bash "${SCRIPTS_DIR}/01-bootstrap-toolchain.sh"

echo -e "${GREEN}[2/8] Etapa: Núcleo Vital (Kernel NitroCore)...${NC}"
# bash "${SCRIPTS_DIR}/02-build-nitrocore.sh"

echo -e "${GREEN}[3/8] Etapa: Estrutura Óssea (FHS 3.0)...${NC}"
bash "${SCRIPTS_DIR}/03-setup-fhs.sh"

echo -e "${BLUE}==============================================${NC}"
echo -e "${GREEN}   ETAPAS INICIAIS CONCLUÍDAS COM SUCESSO!    ${NC}"
echo -e "${BLUE}==============================================${NC}"
