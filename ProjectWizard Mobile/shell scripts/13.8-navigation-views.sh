#!/usr/bin/env bash
set -e

echo "========================================="
echo " Project Wizard - Etapa 13.8"
echo " Navigation Views"
echo "========================================="

FILE="src/main/java/com/projectwizard/core/navigation/NavigationController.java"

if [ ! -f "$FILE" ]; then
    echo "NavigationController.java não encontrado."
    exit 1
fi

cp "$FILE" "$FILE.bak"

cat > "$FILE" <<'EOF'
package com.projectwizard.core.navigation;

import com.projectwizard.view.WorkspacePane;
import com.projectwizard.view.about.AboutView;
import com.projectwizard.view.dashboard.DashboardView;
import com.projectwizard.view.git.GitView;
import com.projectwizard.view.github.GitHubView;
import com.projectwizard.view.newproject.NewProjectView;
import com.projectwizard.view.openproject.OpenProjectView;
import com.projectwizard.view.settings.SettingsView;
import com.projectwizard.view.templates.TemplatesView;

public final class NavigationController {

    private static final NavigationController INSTANCE =
            new NavigationController();

    private WorkspacePane workspace;

    private NavigationController() {
    }

    public static NavigationController getInstance() {
        return INSTANCE;
    }

    public void setWorkspace(WorkspacePane workspace) {
        this.workspace = workspace;
    }

    public void navigate(NavigationTarget target) {

        if (workspace == null)
            return;

        switch (target) {

            case HOME ->
                    workspace.setContent(new DashboardView());

            case NEW_PROJECT ->
                    workspace.setContent(new NewProjectView());

            case OPEN_PROJECT ->
                    workspace.setContent(new OpenProjectView());

            case TEMPLATES ->
                    workspace.setContent(new TemplatesView());

            case GIT ->
                    workspace.setContent(new GitView());

            case GITHUB ->
                    workspace.setContent(new GitHubView());

            case SETTINGS ->
                    workspace.setContent(new SettingsView());

            case ABOUT ->
                    workspace.setContent(new AboutView());

        }

    }

}
EOF

echo
echo "========================================="
echo " Etapa 13.8 concluída!"
echo "========================================="
echo
echo "Agora a Sidebar troca de tela."
echo
echo "Execute:"
echo
echo "mvn clean javafx:run"