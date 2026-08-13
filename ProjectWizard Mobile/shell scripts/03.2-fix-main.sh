#!/usr/bin/env bash
set -Eeuo pipefail

echo "========================================="
echo " Corrigindo Main.java"
echo "========================================="

if [ ! -f pom.xml ]; then
    echo "Execute este script dentro da pasta ProjectWizard."
    exit 1
fi

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
echo " Main.java atualizado!"
echo "========================================="
echo
echo "Execute:"
echo
echo "mvn clean javafx:run"
