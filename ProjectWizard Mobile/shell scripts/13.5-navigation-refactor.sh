#!/usr/bin/env bash
set -e

echo "========================================="
echo " Project Wizard - Etapa 13.5"
echo " Navigation Refactor"
echo "========================================="

BASE="src/main/java/com/projectwizard"

mkdir -p "$BASE/core/navigation"

##############################################
# NavigationTarget
##############################################

cat > "$BASE/core/navigation/NavigationTarget.java" <<'EOF'
package com.projectwizard.core.navigation;

public enum NavigationTarget {

    HOME,
    NEW_PROJECT,
    OPEN_PROJECT,
    TEMPLATES,
    GIT,
    GITHUB,
    SETTINGS,
    ABOUT

}
EOF

##############################################
# NavigationController
##############################################

cat > "$BASE/core/navigation/NavigationController.java" <<'EOF'
package com.projectwizard.core.navigation;

import com.projectwizard.view.WorkspacePane;
import com.projectwizard.view.dashboard.DashboardView;

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

            case HOME -> workspace.showDashboard();

            default -> workspace.showDashboard();

        }

    }

}
EOF

##############################################
# Workspace registration
##############################################

FILE="$BASE/view/WorkspacePane.java"

if grep -q "NavigationController" "$FILE"; then
    echo "WorkspacePane já atualizado."
else

sed -i '/package/a\
\
import com.projectwizard.core.navigation.NavigationController;' "$FILE"

sed -i '/instance = this;/a\
\
        NavigationController.getInstance().setWorkspace(this);' "$FILE"

fi

echo
echo "========================================="
echo "Etapa 13.5 concluída!"
echo "========================================="
echo
echo "Agora existe apenas um controlador central"
echo "de navegação."
echo
echo "Execute:"
echo
echo "mvn clean javafx:run"