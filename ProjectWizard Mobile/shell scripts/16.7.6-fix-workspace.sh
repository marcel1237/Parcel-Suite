#!/usr/bin/env bash

set -e

FILE="src/main/java/com/projectwizard/view/MainWindow.java"

cp "$FILE" "$FILE.bak"

python3 <<'PY'
from pathlib import Path

p = Path("src/main/java/com/projectwizard/view/MainWindow.java")
txt = p.read_text()

old = """        root.setCenter(
                WorkspacePane.getInstance()
        );
"""

new = """        WorkspacePane workspace = new WorkspacePane();

        root.setCenter(workspace);
"""

if old in txt:
    txt = txt.replace(old, new)
    p.write_text(txt)
    print("MainWindow corrigido.")
else:
    print("Trecho não encontrado.")
PY

echo
echo "===================================="
echo "Workspace corrigido!"
echo "===================================="
echo
echo "Execute:"
echo
echo "mvn clean javafx:run"