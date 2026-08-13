#!/usr/bin/env bash
set -e

echo "========================================="
echo " Project Wizard - Etapa 13.2"
echo " Sidebar + Dashboard"
echo "========================================="

BASE=src/main/java/com/projectwizard

mkdir -p $BASE/view/sidebar
mkdir -p $BASE/view/dashboard

###########################################################
# Sidebar.java
###########################################################

cat > $BASE/view/sidebar/Sidebar.java <<'EOF'
package com.projectwizard.view.sidebar;

import javafx.geometry.Insets;
import javafx.scene.control.Button;
import javafx.scene.layout.VBox;

public class Sidebar extends VBox {

    private final Button homeButton = new Button("🏠 Home");
    private final Button newProjectButton = new Button("📦 New Project");
    private final Button openProjectButton = new Button("📂 Open Project");
    private final Button templatesButton = new Button("📁 Templates");
    private final Button gitButton = new Button("🌿 Git");
    private final Button settingsButton = new Button("⚙ Settings");
    private final Button aboutButton = new Button("ℹ About");

    public Sidebar() {

        setSpacing(8);
        setPadding(new Insets(10));
        setPrefWidth(220);

        homeButton.setMaxWidth(Double.MAX_VALUE);
        newProjectButton.setMaxWidth(Double.MAX_VALUE);
        openProjectButton.setMaxWidth(Double.MAX_VALUE);
        templatesButton.setMaxWidth(Double.MAX_VALUE);
        gitButton.setMaxWidth(Double.MAX_VALUE);
        settingsButton.setMaxWidth(Double.MAX_VALUE);
        aboutButton.setMaxWidth(Double.MAX_VALUE);

        getChildren().addAll(
                homeButton,
                newProjectButton,
                openProjectButton,
                templatesButton,
                gitButton,
                settingsButton,
                aboutButton
        );
    }
}
EOF

###########################################################
# DashboardView.java
###########################################################

cat > $BASE/view/dashboard/DashboardView.java <<'EOF'
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

        title.setStyle("-fx-font-size:28px; -fx-font-weight:bold;");

        Label subtitle =
                new Label("Create amazing projects");

        Button newProject =
                new Button("New Project");

        Button openProject =
                new Button("Open Project");

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
echo "Etapa 13.2 criada."
echo
echo "Agora altere apenas o App.java."
echo
echo "Substitua o painel central pelo Dashboard"
echo "e coloque a Sidebar na esquerda:"
echo
echo "root.setLeft(new Sidebar());"
echo "root.setCenter(new DashboardView());"
echo
echo "Imports:"
echo
echo "import com.projectwizard.view.sidebar.Sidebar;"
echo "import com.projectwizard.view.dashboard.DashboardView;"
echo
echo "Depois execute:"
echo
echo "mvn clean javafx:run"
echo