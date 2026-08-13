#!/usr/bin/env bash

set -e

echo "========================================="
echo " Project Wizard - Fix Sidebar"
echo "========================================="

FILE="src/main/java/com/projectwizard/view/MainWindow.java"

cp "$FILE" "$FILE.bak"

echo "Removendo import da Sidebar..."
sed -i '/import .*Sidebar;/d' "$FILE"

echo "Removendo root.setLeft(new Sidebar())..."
sed -i '/root\.setLeft(new Sidebar());/d' "$FILE"

echo
echo "========================================="
echo "Correção aplicada."
echo
echo "Backup:"
echo "  $FILE.bak"
echo
echo "Execute:"
echo
echo "mvn clean javafx:run"