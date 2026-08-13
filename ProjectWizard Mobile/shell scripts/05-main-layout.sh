#!/usr/bin/env bash
set -Eeuo pipefail

echo "========================================="
echo " Project Wizard - Etapa 05"
echo " Main Layout"
echo "========================================="

if [ ! -f pom.xml ]; then
    echo "Execute este script dentro da pasta ProjectWizard."
    exit 1
fi

cat > src/main/java/com/projectwizard/view/MainWindow.java <<'EOF'
package com.projectwizard.view;

import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.Menu;
import javafx.scene.control.MenuBar;
import javafx.scene.control.MenuItem;
import javafx.scene.control.SplitPane;
import javafx.scene.control.ToolBar;
import javafx.scene.layout.BorderPane;
import javafx.scene.layout.HBox;
import javafx.scene.layout.Priority;
import javafx.scene.layout.StackPane;
import javafx.scene.layout.VBox;
import javafx.stage.Stage;

public class MainWindow {

    public void show(Stage stage) {

        BorderPane root = new BorderPane();

        // Menu

        MenuBar menuBar = new MenuBar();

        Menu fileMenu = new Menu("File");
        Menu helpMenu = new Menu("Help");

        MenuItem exitItem = new MenuItem("Exit");
        exitItem.setOnAction(e -> stage.close());

        MenuItem aboutItem = new MenuItem("About");

        fileMenu.getItems().add(exitItem);
        helpMenu.getItems().add(aboutItem);

        menuBar.getMenus().addAll(fileMenu, helpMenu);

        // Toolbar

        ToolBar toolBar = new ToolBar(
                new Button("New Project"),
                new Button("Open"),
                new Button("Settings")
        );

        VBox top = new VBox(menuBar, toolBar);

        // Navigation

        Label navigation = new Label("Navigation");

        StackPane navigationPane = new StackPane(navigation);
        navigationPane.setPrefWidth(220);

        // Workspace

        Label workspace = new Label("Workspace");

        StackPane workspacePane = new StackPane(workspace);

        SplitPane splitPane = new SplitPane();
        splitPane.getItems().addAll(navigationPane, workspacePane);
        splitPane.setDividerPositions(0.22);

        // Status Bar

        Label status = new Label("Ready");
        Label version = new Label("1.0");

        HBox spacer = new HBox();
        HBox.setHgrow(spacer, Priority.ALWAYS);

        HBox statusBar = new HBox(
                status,
                spacer,
                version
        );

        statusBar.setPadding(new Insets(6,10,6,10));
        statusBar.setAlignment(Pos.CENTER_LEFT);

        root.setTop(top);
        root.setCenter(splitPane);
        root.setBottom(statusBar);

        Scene scene = new Scene(root, 1100, 700);

        stage.setTitle("Project Wizard");
        stage.setScene(scene);
        stage.centerOnScreen();
        stage.show();

    }

}
EOF

echo
echo "========================================="
echo " Etapa 05 concluída!"
echo "========================================="
echo
echo "Execute:"
echo
echo "mvn clean javafx:run"
