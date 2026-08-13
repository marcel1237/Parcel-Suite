#!/usr/bin/env bash
set -Eeuo pipefail

echo "========================================="
echo " Project Wizard - Etapa 11.1"
echo " Workspace Navigation"
echo "========================================="

if [ ! -f pom.xml ]; then
    echo "Execute este script dentro da pasta ProjectWizard."
    exit 1
fi

mkdir -p src/main/java/com/projectwizard/view/views

cat > src/main/java/com/projectwizard/view/views/HomeView.java <<'EOF'
package com.projectwizard.view.views;

import com.projectwizard.core.ApplicationContext;
import javafx.geometry.Pos;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.layout.VBox;

public class HomeView extends VBox {

    public HomeView() {

        ApplicationContext context = new ApplicationContext();

        setSpacing(20);
        setAlignment(Pos.CENTER);

        Label title = new Label(context.getApplicationName());
        title.setStyle("-fx-font-size:28px;-fx-font-weight:bold;");

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

cat > src/main/java/com/projectwizard/view/views/NewProjectView.java <<'EOF'
package com.projectwizard.view.views;

import javafx.geometry.Insets;
import javafx.scene.control.Label;
import javafx.scene.layout.BorderPane;

public class NewProjectView extends BorderPane {

    public NewProjectView() {

        setPadding(new Insets(20));

        setTop(new Label("New Project"));

    }

}
EOF

cat > src/main/java/com/projectwizard/view/WorkspacePane.java <<'EOF'
package com.projectwizard.view;

import com.projectwizard.view.views.HomeView;
import javafx.scene.Node;
import javafx.scene.layout.BorderPane;

public class WorkspacePane extends BorderPane {

    public WorkspacePane() {

        show(new HomeView());

    }

    public void show(Node node) {

        setCenter(node);

    }

}
EOF

echo
echo "========================================="
echo " Workspace reorganizado!"
echo "========================================="
echo
echo "Execute:"
echo
echo "mvn clean javafx:run"
