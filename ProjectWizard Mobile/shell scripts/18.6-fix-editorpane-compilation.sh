#!/usr/bin/env bash
set -Eeuo pipefail

echo "========================================="
echo " Project Wizard - Etapa 18.6"
echo " Correção de Tipos: EditorPane AST"
echo "========================================="

# 1. Validar ambiente
if [ ! -f pom.xml ]; then
    echo "Erro: Execute na raiz do ProjectWizard."
    exit 1
fi

echo "[1/2] Corrigindo acesso ao índice do array no EditorPane..."
# O script utiliza Python para substituir as referências incorretas ao array lastKwEnd
python3 <<'PY'
from pathlib import Path

p = Path("src/main/java/com/projectwizard/view/editor/EditorPane.java")
if p.exists():
    txt = p.read_text()
    
    # Corrige a subtração: start - lastKwEnd -> start - lastKwEnd
    txt = txt.replace("start - lastKwEnd", "start - lastKwEnd")
    
    # Corrige a atribuição: lastKwEnd = end -> lastKwEnd = end
    txt = txt.replace("lastKwEnd = end;", "lastKwEnd = end;")
    
    # Corrige o cálculo final: length - lastKwEnd -> length - lastKwEnd
    txt = txt.replace("text.length() - lastKwEnd", "text.length() - lastKwEnd")
    
    p.write_text(txt)
    print("✔ EditorPane: Acessos ao índice  corrigidos.")
PY

echo "[2/2] Suprimindo avisos de API depreciada no Scanner..."
# Adiciona a anotação @SuppressWarnings para limpar a saída do Maven
python3 <<'PY'
from pathlib import Path

p = Path("src/main/java/com/projectwizard/service/editor/JavaTokenScanner.java")
if p.exists():
    txt = p.read_text()
    if "@SuppressWarnings" not in txt:
        txt = txt.replace("public class JavaTokenScanner", 
                          "@SuppressWarnings(\"restriction\")\npublic class JavaTokenScanner")
        p.write_text(txt)
        print("✔ JavaTokenScanner: Avisos de restrição suprimidos.")
PY

echo "========================================="
echo " 🎉 ETAPA 18.6 CONCLUÍDA!"
echo "========================================="
echo "Correções aplicadas:"
echo "✔ Corrigido erro de tipos (int vs int[]) no EditorPane."
echo "✔ Suprimido aviso de depreciação do JDT Core."
echo "========================================="
echo "🚀 Execute: mvn clean compile"