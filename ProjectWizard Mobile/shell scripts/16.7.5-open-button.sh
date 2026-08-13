#!/usr/bin/env bash

set -e

FILE=src/main/java/com/projectwizard/view/WorkspacePane.java

cp "$FILE" "$FILE.bak16_7"

python3 <<'PY'
from pathlib import Path

p = Path("src/main/java/com/projectwizard/view/WorkspacePane.java")
txt = p.read_text()

if "NavigationController" not in txt:
    txt = txt.replace(
        "package com.projectwizard.view;",
        """package com.projectwizard.view;

import com.projectwizard.core.navigation.NavigationController;"""
    )

if "setWorkspace(this);" not in txt:
    idx = txt.find("{")
    if idx != -1:
        pos = txt.find("\n", idx)
        txt = txt[:pos+1] + \
"""
        NavigationController.getInstance().setWorkspace(this);

""" + txt[pos+1:]

p.write_text(txt)

print("WorkspacePane registrado.")
PY

echo
echo "Pronto."
echo
echo "Execute:"
echo "mvn clean javafx:run"