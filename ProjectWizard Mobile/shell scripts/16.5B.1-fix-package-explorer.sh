#!/usr/bin/env bash
set -e

echo "========================================="
echo " Project Wizard - 16.5B FIX"
echo " Integrando Package Explorer"
echo "========================================="

FILE="src/main/java/com/projectwizard/view/openproject/OpenProjectView.java"

cp "$FILE" "$FILE.preExplorer"

python3 <<'PY'
from pathlib import Path

p = Path("src/main/java/com/projectwizard/view/openproject/OpenProjectView.java")

txt = p.read_text()

if "PackageExplorer" not in txt:
    txt = txt.replace(
        "import javafx.stage.Window;",
        """import javafx.stage.Window;

import com.projectwizard.view.explorer.PackageExplorer;
import com.projectwizard.view.explorer.FileTreeCell;"""
    )

if "private final PackageExplorer explorer" not in txt:
    txt = txt.replace(
        "private File selectedDirectory;",
        """private File selectedDirectory;

    private final PackageExplorer explorer =
            new PackageExplorer();"""
    )

txt = txt.replace(
    """selectedDirectory = dir;

                pathField.setText(
                        dir.getAbsolutePath()
                );""",
    """selectedDirectory = dir;

                explorer.setCellFactory(v -> new FileTreeCell());

                explorer.openProject(dir);

                pathField.setText(
                        dir.getAbsolutePath()
                );"""
)

txt = txt.replace(
    "setCenter(center);",
    """
SplitPane split = new SplitPane();

split.getItems().addAll(
        explorer,
        center
);

split.setDividerPositions(0.30);

setCenter(split);
"""
)

p.write_text(txt)
PY

echo
echo "========================================="
echo "Explorer integrado."
echo "========================================="
echo
echo "Execute:"
echo
echo "mvn clean javafx:run"