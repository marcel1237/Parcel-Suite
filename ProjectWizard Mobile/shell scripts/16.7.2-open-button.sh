#!/usr/bin/env bash

set -e

echo "========================================="
echo " Project Wizard 16.7"
echo " Open Button Fix"
echo "========================================="

FILE="src/main/java/com/projectwizard/view/MainToolBar.java"

cp "$FILE" "$FILE.bak16_7"

python3 <<'PY'
from pathlib import Path

p=Path("src/main/java/com/projectwizard/view/MainToolBar.java")
txt=p.read_text()

if "OpenProjectView" not in txt:
    txt=txt.replace(
        "import javafx.scene.control.Button;",
        """import javafx.scene.control.Button;
import com.projectwizard.view.openproject.OpenProjectView;"""
    )

txt=txt.replace(
    "openButton.setOnAction(e -> {});",
    """openButton.setOnAction(e -> {
            OpenProjectView view = new OpenProjectView();
            view.show();
        });"""
)

p.write_text(txt)

print("MainToolBar atualizado.")
PY

echo
echo "========================================="
echo "Concluído."
echo
echo "Execute:"
echo
echo "mvn clean javafx:run"