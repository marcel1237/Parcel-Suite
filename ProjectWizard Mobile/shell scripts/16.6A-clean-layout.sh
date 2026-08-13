#!/usr/bin/env bash

set -e

echo "=========================================="
echo " Project Wizard - Etapa 16.6A"
echo " Layout Cleanup"
echo "=========================================="

backup() {

    if [ -f "$1" ]; then
        cp "$1" "$1.bak16_6A"
    fi

}

backup src/main/java/com/projectwizard/view/MainWindow.java
backup src/main/java/com/projectwizard/view/WorkspacePane.java
backup src/main/java/com/projectwizard/view/openproject/OpenProjectView.java

###############################################################################
# MainWindow
###############################################################################

cat > src/main/java/com/projectwizard/view/MainWindow.java <<'EOF'
package com.projectwizard.view;

import com.projectwizard.core.ApplicationContext;
import javafx.scene.Scene;
import javafx.scene.control.Menu;
import javafx.scene.control.MenuBar;
import javafx.scene.control.MenuItem;
import javafx.scene.layout.BorderPane;
import javafx.scene.layout.VBox;
import javafx.stage.Stage;

public class MainWindow {

    private final ApplicationContext context =
            new ApplicationContext();

    public void show(Stage stage) {

        BorderPane root = new BorderPane();

        MenuBar menuBar = new MenuBar();

        Menu file = new Menu("File");
        Menu help = new Menu("Help");

        MenuItem exit = new MenuItem("Exit");
        exit.setOnAction(e -> stage.close());

        MenuItem about = new MenuItem("About");

        about.setOnAction(e ->
                context.getDialogService().showInformation(
                        "About",
                        context.getApplicationName()
                                + "\nVersion "
                                + context.getVersion()
                )
        );

        file.getItems().add(exit);
        help.getItems().add(about);

        menuBar.getMenus().addAll(file, help);

        VBox top = new VBox(
                menuBar,
                new MainToolBar()
        );

        root.setTop(top);

        root.setLeft(new Sidebar());

        root.setCenter(
                WorkspacePane.getInstance()
        );

        root.setBottom(
                new StatusBar()
        );

        Scene scene =
                new Scene(root, 1400, 850);

        stage.setScene(scene);
        stage.setTitle(
                context.getApplicationName()
        );

        stage.centerOnScreen();
        stage.show();

    }

}
EOF

###############################################################################
# Remove botão Go Git
###############################################################################

find src/main/java -name "*.java" -print0 |
while IFS= read -r -d '' file
do

sed -i '/Go Git/d' "$file"

sed -i '/GoGit/d' "$file"

sed -i '/GO GIT/d' "$file"

done

###############################################################################
# Remove NavigationPane do MainWindow
###############################################################################

sed -i '/NavigationPane/d' \
src/main/java/com/projectwizard/view/MainWindow.java || true

###############################################################################
# Workspace inicial
###############################################################################

python3 <<'PY'

from pathlib import Path

p=Path("src/main/java/com/projectwizard/view/WorkspacePane.java")

txt=p.read_text()

if "showDashboard();" not in txt:

    print("WorkspacePane já foi customizado.")

PY

echo
echo "=========================================="
echo "16.6A concluída."
echo
echo "Agora a aplicação ficará assim:"
echo
echo " Sidebar | Workspace"
echo
echo "Quando abrir um projeto:"
echo
echo " Sidebar | Package Explorer | Editor"
echo
echo "Execute:"
echo
echo "mvn clean javafx:run"