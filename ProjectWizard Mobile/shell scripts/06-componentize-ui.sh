#!/usr/bin/env bash
set -Eeuo pipefail

echo "========================================="
echo " Project Wizard - Etapa 06"
echo " Componentizando a Interface"
echo "========================================="

if [ ! -f pom.xml ]; then
    echo "Execute este script dentro da pasta ProjectWizard."
    exit 1
fi

mkdir -p src/main/java/com/projectwizard/view

cat > src/main/java/com/projectwizard/view/NavigationPane.java <<'EOF'
package com.projectwizard.view;

import javafx.scene.control.Label;
import javafx.scene.layout.StackPane;

public class NavigationPane extends StackPane {

    public NavigationPane() {

        getChildren().add(new Label("Navigation"));

        setPrefWidth(220);

    }

}
EOF

cat > src/main/java/com/projectwizard/view/WorkspacePane.java <<'EOF'
package com.projectwizard.view;

import javafx.scene.control.Label;
import javafx.scene.layout.StackPane;

public class WorkspacePane extends StackPane {

    public WorkspacePane() {

        getChildren().add(new Label("Workspace"));

    }

}
EOF

cat > src/main/java/com/projectwizard/view/MainToolBar.java <<'EOF'
package com.projectwizard.view;

import javafx.scene.control.Button;
import javafx.scene.control.ToolBar;

public class MainToolBar extends ToolBar {

    public MainToolBar() {

        getItems().addAll(

                new Button("New Project"),
                new Button("Open"),
                new Button("Settings")

        );

    }

}
EOF

cat > src/main/java/com/projectwizard/view/StatusBar.java <<'EOF'
package com.projectwizard.view;

import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.control.Label;
import javafx.scene.layout.HBox;
import javafx.scene.layout.Priority;

public class StatusBar extends HBox {

    public StatusBar() {

        Label status = new Label("Ready");

        Label version = new Label("1.0");

        HBox spacer = new HBox();

        HBox.setHgrow(spacer, Priority.ALWAYS);

        getChildren().addAll(
                status,
                spacer,
                version
        );

        setPadding(new Insets(6,10,6,10));
        setAlignment(Pos.CENTER_LEFT);

    }

}
EOF

cat > src/main/java/com/projectwizard/view/MainWindow.java <<'EOF'
package com.projectwizard.view;

import javafx.scene.Scene;
import javafx.scene.control.Menu;
import javafx.scene.control.MenuBar;
import javafx.scene.control.MenuItem;
import javafx.scene.control.SplitPane;
import javafx.scene.layout.BorderPane;
import javafx.scene.layout.VBox;
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

        stage.setTitle("Project Wizard");
        stage.setScene(scene);

        stage.centerOnScreen();
        stage.show();

    }

}
EOF

echo
echo "========================================="
echo " Etapa 06 concluída!"
echo "========================================="
echo
echo "Execute:"
echo
echo "mvn clean javafx:run"
