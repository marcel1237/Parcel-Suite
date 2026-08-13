#!/usr/bin/env bash
set -Eeuo pipefail

echo "========================================="
echo " Project Wizard - Etapa 07"
echo " Core da Aplicação"
echo "========================================="

if [ ! -f pom.xml ]; then
    echo "Execute este script dentro da pasta ProjectWizard."
    exit 1
fi

mkdir -p src/main/java/com/projectwizard/core

cat > src/main/java/com/projectwizard/core/Constants.java <<'EOF'
package com.projectwizard.core;

public final class Constants {

    private Constants() {
    }

    public static final String APPLICATION_NAME = "Project Wizard";

}
EOF

cat > src/main/java/com/projectwizard/core/Version.java <<'EOF'
package com.projectwizard.core;

public final class Version {

    private Version() {
    }

    public static final String VERSION = "0.1.0";

}
EOF

cat > src/main/java/com/projectwizard/core/ApplicationContext.java <<'EOF'
package com.projectwizard.core;

public class ApplicationContext {

    public String getApplicationName() {
        return Constants.APPLICATION_NAME;
    }

    public String getVersion() {
        return Version.VERSION;
    }

}
EOF

cat > src/main/java/com/projectwizard/view/StatusBar.java <<'EOF'
package com.projectwizard.view;

import com.projectwizard.core.ApplicationContext;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.control.Label;
import javafx.scene.layout.HBox;
import javafx.scene.layout.Priority;

public class StatusBar extends HBox {

    public StatusBar() {

        ApplicationContext context = new ApplicationContext();

        Label status = new Label("Ready");

        Label version = new Label(context.getVersion());

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
echo " Core criado com sucesso!"
echo "========================================="
echo
echo "Execute:"
echo
echo "mvn clean javafx:run"
