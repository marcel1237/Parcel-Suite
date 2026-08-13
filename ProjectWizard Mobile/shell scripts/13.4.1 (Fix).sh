#!/usr/bin/env bash
set -e

FILE="src/main/java/com/projectwizard/service/NavigationService.java"

if [ ! -f "$FILE" ]; then
    echo "NavigationService.java não encontrado."
    exit 1
fi

cp "$FILE" "$FILE.bak"

echo "Corrigindo NavigationService..."

sed -i 's/\.show(/.setContent(/g' "$FILE"

echo
echo "======================================"
echo "NavigationService corrigido."
echo "======================================"
echo
echo "Execute:"
echo
echo "mvn clean javafx:run"