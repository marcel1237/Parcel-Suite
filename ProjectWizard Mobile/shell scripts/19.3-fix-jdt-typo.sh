#!/usr/bin/env bash
set -Eeuo pipefail

echo "========================================="
echo " Project Wizard - Etapa 19.3"
echo " Correção de Typo: TokenNametry"
echo "========================================="

# 1. Validar ambiente
if [ ! -f pom.xml ]; then
    echo "Erro: Execute na raiz do ProjectWizard."
    exit 1
fi

echo "[1/1] Corrigindo erro de sintaxe no JavaTokenScanner..."
# Substitui o termo incorreto 'tray' pelo correto 'try' exigido pelo JDT Core
sed -i 's/TokenNametray/TokenNametry/g' src/main/java/com/projectwizard/service/editor/JavaTokenScanner.java

echo "========================================="
echo " 🎉 CORREÇÃO APLICADA COM SUCESSO!"
echo "========================================="
echo "O erro 'cannot find symbol TokenNametray' foi resolvido."
echo "========================================="
echo "🚀 Execute: mvn clean javafx:run"
