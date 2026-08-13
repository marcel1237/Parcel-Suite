#!/usr/bin/env bash
set -Eeuo pipefail

echo "========================================="
echo " Project Wizard - Etapa 17.1"
echo " Correção de Erro de Compilação no Editor"
echo "========================================="

# Verificação de diretório
if [ ! -f pom.xml ]; then
    echo "Execute este script na raiz do ProjectWizard."
    exit 1
fi

FILE="src/main/java/com/projectwizard/view/editor/EditorHost.java"

if [ ! -f "$FILE" ]; then
    echo "ERRO: Arquivo não encontrado: $FILE"
    exit 1
fi

echo "Corrigindo chamada de setupToolBar()..."

# O script utiliza Python para remover o prefixo 'tabPane.' da chamada do método
python3 <<'PY'
from pathlib import Path
p = Path("src/main/java/com/projectwizard/view/editor/EditorHost.java")
txt = p.read_text()

# Corrige: tabPane.setupToolBar() -> setupToolBar()
# E garante que o método seja chamado de forma independente
if "tabPane.setupToolBar()" in txt:
    txt = txt.replace("tabPane.setupToolBar();", "setupToolBar();")
    p.write_text(txt)
    print("✔ Sucesso: Prefixo 'tabPane.' removido da chamada.")
elif "setupToolBar()" in txt:
    print("ℹ O método já parece estar sendo chamado corretamente.")
else:
    print("⚠ Aviso: Chamada setupToolBar() não encontrada para correção.")
PY

echo
echo "========================================="
echo " Etapa 17.1 concluída!"
echo "========================================="
echo "O erro 'cannot find symbol setupToolBar()' foi resolvido."
echo "Execute para compilar:"
echo "mvn clean compile"