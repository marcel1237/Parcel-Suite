#!/usr/bin/env bash
set -e

echo "========================================="
echo " Project Wizard - Etapa 16.5C"
echo " Editor Host"
echo "========================================="

mkdir -p src/main/java/com/projectwizard/view/editor

###############################################################################
# EditorHost
###############################################################################

cat > src/main/java/com/projectwizard/view/editor/EditorHost.java <<'EOF'
package com.projectwizard.view.editor;

import javafx.scene.control.Label;
import javafx.scene.control.Tab;
import javafx.scene.control.TabPane;

public class EditorHost extends TabPane {

    public EditorHost() {

        Tab welcome = new Tab("Welcome");

        welcome.setClosable(false);

        welcome.setContent(
                new Label(
                        """
                        Welcome to Project Wizard

                        Open a project to begin.
                        """
                )
        );

        getTabs().add(welcome);

    }

}
EOF

###############################################################################
# WorkspacePane
###############################################################################

FILE="src/main/java/com/projectwizard/view/WorkspacePane.java"

cp "$FILE" "$FILE.bak16_5C"

python3 <<'PY'
from pathlib import Path

p=Path("src/main/java/com/projectwizard/view/WorkspacePane.java")
txt=p.read_text()

if "EditorHost" not in txt:
    txt=txt.replace(
        "import javafx.scene.layout.BorderPane;",
        """import javafx.scene.layout.BorderPane;
import javafx.scene.control.SplitPane;
import com.projectwizard.view.editor.EditorHost;
import com.projectwizard.view.explorer.PackageExplorer;"""
    )

txt=txt.replace(
"""public class WorkspacePane extends BorderPane {""",
"""public class WorkspacePane extends BorderPane {

    private final PackageExplorer explorer =
            new PackageExplorer();

    private final EditorHost editor =
            new EditorHost();
"""
)

txt=txt.replace(
"""    public void showDashboard() {

        setContent(new DashboardView());

    }""",
"""    public void showDashboard() {

        SplitPane split = new SplitPane(
                explorer,
                editor
        );

        split.setDividerPositions(0.28);

        setCenter(split);

    }

    public PackageExplorer getExplorer() {
        return explorer;
    }

    public EditorHost getEditor() {
        return editor;
    }
""")

p.write_text(txt)
PY

###############################################################################
# OpenProjectView
###############################################################################

FILE="src/main/java/com/projectwizard/view/openproject/OpenProjectView.java"

cp "$FILE" "$FILE.bak16_5C"

python3 <<'PY'
from pathlib import Path

p=Path("src/main/java/com/projectwizard/view/openproject/OpenProjectView.java")
txt=p.read_text()

if "WorkspacePane" not in txt:
    txt=txt.replace(
        "import com.projectwizard.view.explorer.FileTreeCell;",
        """import com.projectwizard.view.explorer.FileTreeCell;
import com.projectwizard.view.WorkspacePane;"""
    )

old="""
            Alert alert = new Alert(
                    Alert.AlertType.INFORMATION
            );

            alert.setTitle("Project Wizard");

            alert.setHeaderText("Folder Selected");

            alert.setContentText(
                    selectedDirectory.getAbsolutePath()
            );

            alert.showAndWait();
"""

new="""
            WorkspacePane workspace =
                    WorkspacePane.getInstance();

            workspace.getExplorer()
                    .setCellFactory(v -> new FileTreeCell());

            workspace.getExplorer()
                    .openProject(selectedDirectory);

            workspace.showDashboard();
"""

txt=txt.replace(old,new)

p.write_text(txt)
PY

echo
echo "========================================="
echo "16.5C concluída."
echo "========================================="
echo
echo "Execute:"
echo
echo "mvn clean javafx:run"