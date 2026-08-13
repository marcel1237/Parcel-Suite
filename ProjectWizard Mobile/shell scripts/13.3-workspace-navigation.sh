#!/usr/bin/env bash
set -e

echo "========================================="
echo " Project Wizard - Etapa 13.3"
echo " Workspace Navigation"
echo "========================================="

BASE="src/main/java/com/projectwizard"

mkdir -p "$BASE/navigation"

############################################################
# NavigationTarget
############################################################

cat > "$BASE/navigation/NavigationTarget.java" <<'EOF'
package com.projectwizard.navigation;

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

############################################################
# NavigationListener
############################################################

cat > "$BASE/navigation/NavigationListener.java" <<'EOF'
package com.projectwizard.navigation;

public interface NavigationListener {

    void navigateTo(NavigationTarget target);

}
EOF

############################################################
# NavigationService
############################################################

cat > "$BASE/navigation/NavigationService.java" <<'EOF'
package com.projectwizard.navigation;

public class NavigationService {

    private NavigationListener listener;

    public void setListener(NavigationListener listener) {

        this.listener = listener;

    }

    public void navigateTo(NavigationTarget target) {

        if (listener != null) {

            listener.navigateTo(target);

        }

    }

}
EOF

echo
echo "========================================="
echo " Etapa 13.3 criada."
echo "========================================="
echo
echo "Arquivos criados:"
echo
echo "navigation/"
echo "  NavigationTarget.java"
echo "  NavigationListener.java"
echo "  NavigationService.java"
echo
echo "Nenhum arquivo existente foi alterado."
echo
echo "Execute:"
echo
echo "mvn clean javafx:run"
echo