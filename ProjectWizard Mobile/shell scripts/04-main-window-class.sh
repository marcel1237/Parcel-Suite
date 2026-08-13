#!/usr/bin/env bash
set -Eeuo pipefail

echo "========================================="
echo " Project Wizard - Etapa 04"
echo " Separando MainWindow"
echo "========================================="

if [ ! -f pom.xml ]; then
    echo "Execute este script dentro da pasta ProjectWizard."
    exit 1
fi

mkdir -p src/main/java/com/projectwizard/view

cat > src/main/java/com/projectwizard/view/MainWindow.java <<'EOF'
package com.projectwizard.view;

import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.Scene;
import javafx.scene.control.Label;
import javafx.scene.control.Menu;
import javafx.scene.control.MenuBar;
import javafx.scene.control.MenuItem;
import javafx.scene.layout.BorderPane;
import javafx.scene.layout.HBox;
import javafx.scene.layout.StackPane;
import javafx.stage.Stage;

public class MainWindow {

    public void show(Stage stage) {

        BorderPane root = new BorderPane();

        MenuBar menuBar = new MenuBar();

        Menu fileMenu = new Menu("File");
        Menu helpMenu = new Menu("Help");

        MenuItem exitItem = new MenuItem("Exit");
        exitItem.setOnAction(e -> stage.close());

        MenuItem aboutItem = new MenuItem("About");

        fileMenu.getItems().add(exitItem);
        helpMenu.getItems().add(aboutItem);

        menuBar.getMenus().addAll(fileMenu, helpMenu);

        Label welcome = new Label("Welcome to Project Wizard!");

        StackPane center = new StackPane(welcome);
        center.setAlignment(Pos.CENTER);

        Label statusLabel = new Label("Ready");

        HBox statusBar = new HBox(statusLabel);
        statusBar.setPadding(new Insets(6, 10, 6, 10));
        statusBar.setAlignment(Pos.CENTER_LEFT);

        root.setTop(menuBar);
        root.setCenter(center);
        root.setBottom(statusBar);

        Scene scene = new Scene(root, 1000, 650);

        stage.setTitle("Project Wizard");
        stage.setScene(scene);
        stage.centerOnScreen();
        stage.show();

    }

}
EOF

cat > src/main/java/com/projectwizard/App.java <<'EOF'
package com.projectwizard;

import com.projectwizard.view.MainWindow;
import javafx.stage.Stage;

public class App {

    public void start(Stage stage) {

        MainWindow window = new MainWindow();
        window.show(stage);

    }

}
EOF

cat > src/main/java/com/projectwizard/Main.java <<'EOF'
package com.projectwizard;

import javafx.application.Application;
import javafx.stage.Stage;

public class Main extends Application {

    private final App app = new App();

    @Override
    public void start(Stage stage) {

        app.start(stage);

    }

    public static void main(String[] args) {

        launch(args);

    }

}
EOF

echo
echo "========================================="
echo " Etapa 04 concluída!"
echo "========================================="
echo
echo "Execute:"
echo
echo "mvn clean javafx:run"
