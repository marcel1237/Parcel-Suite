#!/usr/bin/env bash

set -e

echo "==========================================="
echo " Project Wizard 16.7"
echo " Workspace Lite"
echo "==========================================="

backup() {
    [ -f "$1" ] && cp "$1" "$1.bak16_7"
}

backup src/main/java/com/projectwizard/view/MainWindow.java
backup src/main/java/com/projectwizard/view/WorkspacePane.java
backup src/main/java/com/projectwizard/view/openproject/OpenProjectView.java

echo
echo "Arquivos salvos em:"
echo " *.bak16_7"
echo

cat <<EOF

Nesta etapa vamos apenas substituir:

Dashboard
Sidebar
Navigation

por

Package Explorer
Editor(TabPane)

quando Open Project finalizar.

Nenhuma outra funcionalidade será alterada.

A próxima etapa (16.8) abrirá arquivos no editor.

EOF

echo
echo "==========================================="
echo "ETAPA 16.7 PREPARADA"
echo "==========================================="
echo
echo "Agora vou gerar os arquivos Java"
echo "específicos da arquitetura Lite."
echo
echo "Esta etapa não adiciona:"
echo
echo "  - Terminal"
echo "  - Git"
echo "  - Problems"
echo "  - Console"
echo "  - Debug"
echo
echo "Somente:"
echo
echo "  Package Explorer"
echo "  Editor"
echo