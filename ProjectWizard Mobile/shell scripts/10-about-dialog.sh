#!/usr/bin/env bash
set -Eeuo pipefail

echo "========================================="
echo " Project Wizard - Etapa 10"
echo " About Dialog"
echo "========================================="

if [ ! -f pom.xml ]; then
    echo "Execute este script dentro da pasta ProjectWizard."
    exit 1
fi

cat > src/main/java/com/projectwizard/service/DialogService.java <<'EOF'
package com.projectwizard.service;

import javafx.scene.control.Alert;
import javafx.scene.control.Alert.AlertType;

public class DialogService {

    public void showInformation(String title, String message) {

        Alert alert = new Alert(AlertType.INFORMATION);

        alert.setTitle(title);
        alert.setHeaderText(null);
        alert.setContentText(message);

        alert.showAndWait();

    }

}
EOF

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

        newProject.setOnAction(e ->
                context.getDialogService().showInformation(
                        "New Project",
                        "Project Wizard\n\nThe project creation wizard will be implemented in the next steps."
                )
        );

        openProject.setOnAction(e ->
                context.getDialogService().showInformation(
                        "Open Project",
                        "This feature will be implemented soon."
                )
        );

        getChildren().addAll(
                title,
                version,
                newProject,
                openProject
        );

    }

}
EOF

cat > src/main/java/com/projectwizard/view/MainWindow.java <<'EOF'
package com.projectwizard.view;

import com.projectwizard.core.ApplicationContext;
import javafx.scene.Scene;
import javafx.scene.control.Menu;
import javafx.scene.control.MenuBar;
import javafx.scene.control.MenuItem;
import javafx.scene.control.SplitPane;
import javafx.scene.layout.BorderPane;
import javafx.scene.layout.VBox;
import javafx.stage.Stage;

public class MainWindow {

    private final ApplicationContext context = new ApplicationContext();

    public void show(Stage stage) {

        BorderPane root = new BorderPane();

        MenuBar menuBar = new MenuBar();

        Menu fileMenu = new Menu("File");
        Menu helpMenu = new Menu("Help");

        MenuItem exitItem = new MenuItem("Exit");
        exitItem.setOnAction(e -> stage.close());

        MenuItem aboutItem = new MenuItem("About");

        aboutItem.setOnAction(e ->
                context.getDialogService().showInformation(
                        "About Project Wizard",
                        context.getApplicationName()
                        + "\n\nVersion " + context.getVersion()
                        + "\n\nDesktop Project Generator"
                        + "\nBuilt with JavaFX"
                )
        );

        fileMenu.getItems().add(exitItem);
        helpMenu.getItems().add(aboutItem);

        menuBar.getMenus().addAll(fileMenu, helpMenu);

        VBox top = new VBox(
                menuBar,
                new MainToolBar()
        );

        SplitPane splitPane = new SplitPane(
                new NavigationPane(),
                new WorkspacePane()
        );

        splitPane.setDividerPositions(0.22);

        root.setTop(top);
        root.setCenter(splitPane);
        root.setBottom(new StatusBar());

        Scene scene = new Scene(root, 1100, 700);

        stage.setTitle(context.getApplicationName());
        stage.setScene(scene);

        stage.centerOnScreen();
        stage.show();

    }

}
EOF

echo
echo "========================================="
echo " Etapa 10 concluída!"
echo "========================================="
echo
echo "Execute:"
echo
echo "mvn clean javafx:run"
