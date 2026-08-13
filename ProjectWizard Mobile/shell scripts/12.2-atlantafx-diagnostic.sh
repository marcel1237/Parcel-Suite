#!/usr/bin/env bash
set -Eeuo pipefail

echo
echo "========================================="
echo " Project Wizard - AtlantaFX Diagnostic"
echo "========================================="
echo

if [ ! -f pom.xml ]; then
    echo "ERRO: execute dentro da pasta ProjectWizard"
    exit 1
fi

mkdir -p .backup

cp pom.xml .backup/pom.xml.$(date +%Y%m%d_%H%M%S)

echo
echo "[1/5] Verificando dependência..."
echo

if grep -q "atlantafx-base" pom.xml; then
    echo "OK - Dependência encontrada."
else
    echo "ATENÇÃO - Dependência não encontrada."
fi

echo
echo "[2/5] Baixando dependências Maven..."
echo

mvn dependency:resolve

echo
echo "[3/5] Procurando JAR AtlantaFX..."
echo

JAR=$(find ~/.m2 -iname "atlantafx-base-*.jar" | sort | tail -1)

if [ -z "${JAR:-}" ]; then
    echo "ERRO: AtlantaFX não encontrado."
    exit 1
fi

echo
echo "Encontrado:"
echo "$JAR"

echo
echo "[4/5] Classes relacionadas a Dracula..."
echo

jar tf "$JAR" | grep -i dracula || true

echo
echo "[5/5] Classes Theme..."
echo

jar tf "$JAR" | grep -i theme | head -100 || true

echo
echo "========================================="
echo " DIAGNÓSTICO CONCLUÍDO"
echo "========================================="
echo
echo "Copie toda a saída e me envie."
echo
