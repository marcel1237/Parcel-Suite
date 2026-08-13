#!/usr/bin/env bash
set -e

echo "========================================="
echo " Project Wizard - Etapa 13.4"
echo " Workspace Host"
echo "========================================="

BASE="src/main/java/com/projectwizard"

############################################################
# WorkspacePane
############################################################

cat > "$BASE/view/WorkspacePane.java" <<'EOF'
package com.projectwizard.view;

import com.projectwizard.view.dashboard.DashboardView;
import javafx.scene.Node;
import javafx.scene.layout.BorderPane;

public class WorkspacePane extends BorderPane {

    private static WorkspacePane instance;

    public WorkspacePane() {

        instance = this;

        showDashboard();

    }

    public static WorkspacePane getInstance() {

        return instance;

    }

    public void setContent(Node node) {

        setCenter(node);

    }

    public void showDashboard() {

        setContent(new DashboardView());

    }

}
EOF

############################################################
# DashboardView
############################################################

cat > "$BASE/view/dashboard/DashboardView.java" <<'EOF'
package com.projectwizard.view.dashboard;

import javafx.geometry.Pos;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.layout.VBox;

public class DashboardView extends VBox {

    public DashboardView() {

        setSpacing(20);

        setAlignment(Pos.CENTER);

        Label title = new Label("Project Wizard");

        title.setStyle("-fx-font-size:30px;-fx-font-weight:bold;");

        Label subtitle = new Label(
                "Create amazing projects"
        );

        Button newProject = new Button("New Project");

        Button openProject = new Button("Open Project");

        getChildren().addAll(

                title,

                subtitle,

                newProject,

                openProject

        );

    }

}
EOF

echo
echo "========================================="
echo " Workspace atualizado."
echo "========================================="
echo
echo "Execute:"
echo
echo "mvn clean javafx:run"
echo