#!/usr/bin/env bash
set -e

echo "========================================="
echo " Project Wizard - Etapa 16.1"
echo " Legacy Isolation"
echo "========================================="

ROOT="src/main/java/com/projectwizard"

mkdir -p "$ROOT/legacy/view"
mkdir -p "$ROOT/legacy/navigation"

move_if_exists() {

    SRC="$1"
    DST="$2"

    if [ -f "$SRC" ]; then
        echo "Movendo $(basename "$SRC")"
        mv "$SRC" "$DST"
    fi

}

###############################################################################
# Views antigas
###############################################################################

move_if_exists \
"$ROOT/view/WelcomePane.java" \
"$ROOT/legacy/view/WelcomePane.java"

move_if_exists \
"$ROOT/view/NewProjectPane.java" \
"$ROOT/legacy/view/NewProjectPane.java"

###############################################################################
# Views antigas (package views)
###############################################################################

if [ -d "$ROOT/view/views" ]; then

    mkdir -p "$ROOT/legacy/view/views"

    find "$ROOT/view/views" -name "*.java" -exec mv {} "$ROOT/legacy/view/views/" \;

    rmdir "$ROOT/view/views" 2>/dev/null || true

fi

###############################################################################
# Navigation antiga
###############################################################################

if [ -d "$ROOT/navigation" ]; then

    mv "$ROOT/navigation" "$ROOT/legacy/"

fi

###############################################################################

echo
echo "========================================="
echo "Arquitetura antiga isolada."
echo "========================================="
echo
echo "Nada foi apagado."
echo
echo "Agora execute:"
echo
echo "mvn clean compile"
echo
echo "Se aparecer algum erro,"
echo "ele mostrará exatamente"
echo "quais classes ainda dependem"
echo "da arquitetura antiga."