#!/usr/bin/env bash
set -Eeuo pipefail

echo "========================================="
echo " Project Wizard - Etapa 3"
echo " Main Window"
echo "========================================="

if [ ! -f pom.xml ]; then
    echo "Execute este script dentro da pasta ProjectWizard."
    exit 1
fi

cat > src/main/java/com/projectwizard/App.java <<'EOF'
package com.projectwizard;

import javafx.geometry.Pos;
import javafx.scene.Scene;
import javafx.scene.control.Label;
import javafx.scene.control.Menu;
import javafx.scene.control.MenuBar;
import javafx.scene.control.MenuItem;
import javafx.scene.control.SeparatorMenuItem;
import javafx.scene.layout.BorderPane;
import javafx.scene.layout.StackPane;
import javafx.stage.Stage;

public class App {

    public void start(Stage stage) {

        BorderPane root = new BorderPane();

        MenuBar menuBar = new MenuBar();

        Menu fileMenu = new Menu("File");
        Menu helpMenu = new Menu("Help");

        MenuItem exitItem = new MenuItem("Exit");
        exitItem.setOnAction(e -> stage.close());

        MenuItem aboutItem = new MenuItem("About");

        fileMenu.getItems().addAll(exitItem);

        helpMenu.getItems().addAll(aboutItem);

        menuBar.getMenus().addAll(fileMenu, helpMenu);

        Label welcome = new Label("Welcome to Project Wizard!");

        StackPane center = new StackPane(welcome);
        center.setAlignment(Pos.CENTER);

        Label status = new Label("Ready");

        root.setTop(menuBar);
        root.setCenter(center);
        root.setBottom(status);

        Scene scene = new Scene(root, 1000, 650);

        stage.setTitle("Project Wizard");
        stage.setScene(scene);
        stage.centerOnScreen();
        stage.show();

    }

}
EOF

echo
echo "========================================="
echo " Main Window criada!"
echo "========================================="
echo
echo "Execute:"
echo
echo "mvn clean javafx:run"
