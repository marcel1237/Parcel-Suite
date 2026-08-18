#!/bin/bash
# Nitro-Pre-Optimization: CPU Architecture Detection & Compiler Setup
# Versão: 1.0.0

set -e

echo "NitroCore: Detectando arquitetura para otimização extrema..."

# 1. Detectar nível de microarquitetura x86-64 (v1, v2, v3, v4)
# v3 = AVX2, BMI2, MOVBE, etc.
# v4 = AVX-512
CPU_FLAGS=$(grep -m1 flags /proc/cpuinfo)

if echo "$CPU_FLAGS" | grep -q "avx512"; then
    NITRO_ARCH="znver4" # Ou x86-64-v4
    echo ">> [Nitro-Boost] AVX-512 Detectado (Level v4). Usando -march=$NITRO_ARCH"
elif echo "$CPU_FLAGS" | grep -q "avx2"; then
    NITRO_ARCH="znver3" # Ou x86-64-v3
    echo ">> [Nitro-Boost] AVX2 Detectado (Level v3). Usando -march=$NITRO_ARCH"
else
    NITRO_ARCH="native"
    echo ">> [Nitro-Safe] Arquitetura genérica detectada. Usando -march=native"
fi

# 2. Exportar flags para o Makefile do Kernel
# -Ofast: Aceleração matemática para física 3D e Nitro-Engine
# -fno-plt: Redução de saltos indiretos para maior segurança e velocidade
export KCFLAGS="-Ofast -march=$NITRO_ARCH -flto=thin -fno-plt -pipe"
export KAFLAGS="-march=$NITRO_ARCH"

# 3. Habilitar suporte a NTSYNC e Nitro-Storage no ambiente de build
export NITRO_FLAGS="-DCONFIG_NITRO_NTSYNC=y -DCONFIG_NITRO_STORAGE=y"

echo "Flags de compilação configuradas para Nível $NITRO_ARCH: $KCFLAGS"
