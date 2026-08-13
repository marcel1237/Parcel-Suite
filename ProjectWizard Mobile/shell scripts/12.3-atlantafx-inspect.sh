#!/usr/bin/env bash
set -Eeuo pipefail

echo "==========================================="
echo " Project Wizard - AtlantaFX Inspector"
echo "==========================================="
echo

JAR=$(find "$HOME/.m2/repository/io/github/mkpaz" \
      -name "atlantafx-base-*.jar" | sort | tail -1)

if [ -z "${JAR:-}" ]; then
    echo "ERRO: AtlantaFX não encontrado no repositório Maven."
    echo
    echo "Execute:"
    echo "mvn dependency:resolve"
    exit 1
fi

echo "JAR encontrado:"
echo "$JAR"
echo

echo "==========================================="
echo " Classes contendo 'Dracula'"
echo "==========================================="
jar tf "$JAR" | grep -i Dracula || true
echo

echo "==========================================="
echo " Classes contendo 'Theme'"
echo "==========================================="
jar tf "$JAR" | grep -i Theme || true
echo

echo "==========================================="
echo " Classes contendo 'Primer'"
echo "==========================================="
jar tf "$JAR" | grep -i Primer || true
echo

echo "==========================================="
echo " Classes contendo 'Nord'"
echo "==========================================="
jar tf "$JAR" | grep -i Nord || true
echo

echo "==========================================="
echo " Classes contendo 'Cupertino'"
echo "==========================================="
jar tf "$JAR" | grep -i Cupertino || true
echo

echo "==========================================="
echo " Pacotes AtlantaFX"
echo "==========================================="
jar tf "$JAR" \
| cut -d/ -f1-6 \
| sort -u

echo
echo "==========================================="
echo " RELATÓRIO FINAL"
echo "==========================================="
echo
echo "Copie toda a saída deste script e me envie."
echo
echo "Com ela eu monto a correção definitiva"
echo "do App.java sem tentativa e erro."
