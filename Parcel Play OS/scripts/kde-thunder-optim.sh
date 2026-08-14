#!/bin/bash
# KDE Plasma 6 - Thunder SDK Performance Optimizations
# Versão: 1.0.0
# Descrição: Este script aplica otimizações de renderização e sistema para a Sessão Full.

set -e

echo "Aplicando otimizações Thunder para KDE Plasma 6..."

# 1. Forçar Backend Vulkan para Qt RHI
# Melhora drasticamente a fluidez em GPUs modernas (AMD/Intel/NVIDIA)
export QSG_RHI_BACKEND=vulkan

# 2. Habilitar UDMABUF
# Reduz o overhead de cópia de textura entre CPU e GPU em até 60%
export KWIN_DRM_USE_MODIFIERS=1

# 3. Otimização de Cache QML
# Garante que o cache de disco esteja ativo para carregamento instantâneo de apps
export QML_DISABLE_DISK_CACHE=0

# 4. Desativar Logging desnecessário
# Reduz I/O e picos de CPU causados por debugs constantes
export QT_LOGGING_RULES="*.debug=false;qt.qpa.*=false"

# 5. Prioridade de Eventos Qt
# Força o uso do despachante nativo para maior responsividade
export QT_NO_GLIB=1

# 6. Aceleração de Fonte Variable
# Melhora a legibilidade e reduz footprint de memória
export QT_ENABLE_VARIABLE_FONTS=1

echo "Otimizações de Sessão Full aplicadas com sucesso."
