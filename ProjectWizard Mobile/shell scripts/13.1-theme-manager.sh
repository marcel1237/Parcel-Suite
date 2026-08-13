#!/usr/bin/env bash
set -Eeuo pipefail

echo "========================================="
echo " Project Wizard - Etapa 13.1"
echo " Theme Manager"
echo "========================================="

if [ ! -f pom.xml ]; then
    echo "Execute este script dentro da pasta ProjectWizard."
    exit 1
fi

mkdir -p src/main/java/com/projectwizard/theme

cat > src/main/java/com/projectwizard/theme/ThemeType.java <<'EOF'
package com.projectwizard.theme;

public enum ThemeType {

    DRACULA,

    NORD_DARK,
    NORD_LIGHT,

    PRIMER_DARK,
    PRIMER_LIGHT,

    CUPERTINO_DARK,
    CUPERTINO_LIGHT

}
EOF

cat > src/main/java/com/projectwizard/theme/ThemeManager.java <<'EOF'
package com.projectwizard.theme;

import atlantafx.base.theme.CupertinoDark;
import atlantafx.base.theme.CupertinoLight;
import atlantafx.base.theme.Dracula;
import atlantafx.base.theme.NordDark;
import atlantafx.base.theme.NordLight;
import atlantafx.base.theme.PrimerDark;
import atlantafx.base.theme.PrimerLight;
import javafx.application.Application;

public final class ThemeManager {

    private static ThemeType currentTheme = ThemeType.DRACULA;

    private ThemeManager() {
    }

    public static ThemeType getCurrentTheme() {

        return currentTheme;

    }

    public static void apply(ThemeType theme) {

        currentTheme = theme;

        switch (theme) {

            case DRACULA ->
                Application.setUserAgentStylesheet(
                        new Dracula().getUserAgentStylesheet());

            case NORD_DARK ->
                Application.setUserAgentStylesheet(
                        new NordDark().getUserAgentStylesheet());

            case NORD_LIGHT ->
                Application.setUserAgentStylesheet(
                        new NordLight().getUserAgentStylesheet());

            case PRIMER_DARK ->
                Application.setUserAgentStylesheet(
                        new PrimerDark().getUserAgentStylesheet());

            case PRIMER_LIGHT ->
                Application.setUserAgentStylesheet(
                        new PrimerLight().getUserAgentStylesheet());

            case CUPERTINO_DARK ->
                Application.setUserAgentStylesheet(
                        new CupertinoDark().getUserAgentStylesheet());

            case CUPERTINO_LIGHT ->
                Application.setUserAgentStylesheet(
                        new CupertinoLight().getUserAgentStylesheet());

        }

    }

}
EOF

echo
echo "========================================="
echo " ThemeManager criado com sucesso."
echo "========================================="
echo
echo "Próximo passo:"
echo "Substituir o código atual do App.java"
echo "por ThemeManager.apply(ThemeType.DRACULA);"
echo
echo "Depois execute:"
echo
echo "mvn clean javafx:run"