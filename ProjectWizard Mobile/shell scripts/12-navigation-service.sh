#!/usr/bin/env bash
set -Eeuo pipefail

echo "========================================="
echo " Project Wizard - Etapa 12"
echo " Navigation Service"
echo "========================================="

if [ ! -f pom.xml ]; then
    echo "Execute este script dentro da pasta ProjectWizard."
    exit 1
fi

mkdir -p src/main/java/com/projectwizard/service

cat > src/main/java/com/projectwizard/service/NavigationService.java <<'EOF'
package com.projectwizard.service;

import com.projectwizard.view.WorkspacePane;
import javafx.scene.Node;

public class NavigationService {

    private WorkspacePane workspace;

    public void setWorkspace(WorkspacePane workspace) {
        this.workspace = workspace;
    }

    public void navigate(Node node) {
        if (workspace != null) {
            workspace.show(node);
        }
    }

}
EOF

cat > src/main/java/com/projectwizard/core/ApplicationContext.java <<'EOF'
package com.projectwizard.core;

import com.projectwizard.service.DialogService;
import com.projectwizard.service.FileSystemService;
import com.projectwizard.service.NavigationService;
import com.projectwizard.service.ProjectService;
import com.projectwizard.service.SettingsService;

public class ApplicationContext {

    private static final NavigationService navigationService = new NavigationService();

    private final DialogService dialogService = new DialogService();
    private final FileSystemService fileSystemService = new FileSystemService();
    private final ProjectService projectService = new ProjectService();
    private final SettingsService settingsService = new SettingsService();

    public String getApplicationName() {
        return Constants.APPLICATION_NAME;
    }

    public String getVersion() {
        return Version.VERSION;
    }

    public DialogService getDialogService() {
        return dialogService;
    }

    public FileSystemService getFileSystemService() {
        return fileSystemService;
    }

    public ProjectService getProjectService() {
        return projectService;
    }

    public SettingsService getSettingsService() {
        return settingsService;
    }

    public NavigationService getNavigationService() {
        return navigationService;
    }

}
EOF

cat > src/main/java/com/projectwizard/view/WorkspacePane.java <<'EOF'
package com.projectwizard.view;

import com.projectwizard.core.ApplicationContext;
import com.projectwizard.view.views.HomeView;
import javafx.scene.Node;
import javafx.scene.layout.BorderPane;

public class WorkspacePane extends BorderPane {

    public WorkspacePane() {

        ApplicationContext context = new ApplicationContext();
        context.getNavigationService().setWorkspace(this);

        show(new HomeView());

    }

    public void show(Node node) {

        setCenter(node);

    }

}
EOF

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

        newProject.setOnAction(e ->
                context.getNavigationService().navigate(new NewProjectView())
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

cat > src/main/java/com/projectwizard/view/views/NewProjectView.java <<'EOF'
package com.projectwizard.view.views;

import com.projectwizard.core.ApplicationContext;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.layout.BorderPane;
import javafx.scene.layout.HBox;

public class NewProjectView extends BorderPane {

    public NewProjectView() {

        ApplicationContext context = new ApplicationContext();

        setPadding(new Insets(20));

        Label title = new Label("New Project");
        title.setStyle("-fx-font-size:24px;-fx-font-weight:bold;");

        Button back = new Button("← Home");

        back.setOnAction(e ->
                context.getNavigationService().navigate(new HomeView())
        );

        HBox top = new HBox(15, back, title);
        top.setAlignment(Pos.CENTER_LEFT);

        setTop(top);

    }

}
EOF

echo
echo "========================================="
echo " Etapa 12 concluída!"
echo "========================================="
echo
echo "Execute:"
echo
echo "mvn clean javafx:run"
