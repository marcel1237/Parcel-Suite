#!/usr/bin/env bash
set -Eeuo pipefail

echo "========================================="
echo " Project Wizard - Etapa 09"
echo " Welcome Pane"
echo "========================================="

if [ ! -f pom.xml ]; then
    echo "Execute este script dentro da pasta ProjectWizard."
    exit 1
fi

mkdir -p src/main/java/com/projectwizard/view

cat > src/main/java/com/projectwizard/view/WelcomePane.java <<'EOF'
package com.projectwizard.view;

import com.projectwizard.core.ApplicationContext;
import javafx.geometry.Pos;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.layout.VBox;

public class WelcomePane extends VBox {

    public WelcomePane() {

        ApplicationContext context = new ApplicationContext();

        setSpacing(20);
        setAlignment(Pos.CENTER);

        Label title = new Label(context.getApplicationName());
        title.setStyle("-fx-font-size: 28px; -fx-font-weight: bold;");

        Label version = new Label("Version " + context.getVersion());

        Button newProject = new Button("New Project");
        newProject.setPrefWidth(180);

        Button openProject = new Button("Open Project");
        openProject.setPrefWidth(180);

        getChildren().addAll(
                title,
                version,
                newProject,
                openProject
        );

    }

}
EOF

cat > src/main/java/com/projectwizard/view/WorkspacePane.java <<'EOF'
package com.projectwizard.view;

import javafx.scene.layout.BorderPane;

public class WorkspacePane extends BorderPane {

    public WorkspacePane() {

        setCenter(new WelcomePane());

    }

}
EOF

echo
echo "========================================="
echo " Welcome Pane criada!"
echo "========================================="
echo
echo "Execute:"
echo
echo "mvn clean javafx:run"
