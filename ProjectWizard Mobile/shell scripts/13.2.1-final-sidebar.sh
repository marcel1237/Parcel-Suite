#!/usr/bin/env bash
set -e

echo "========================================="
echo " Project Wizard - Etapa 13.2 Final"
echo " Modern Sidebar"
echo "========================================="

FILE="src/main/java/com/projectwizard/view/NavigationPane.java"

if [ ! -f "$FILE" ]; then
    echo "ERRO: NavigationPane.java não encontrado."
    exit 1
fi

cp "$FILE" "$FILE.bak"

cat > "$FILE" <<'EOF'
package com.projectwizard.view;

import javafx.geometry.Insets;
import javafx.scene.control.Button;
import javafx.scene.layout.Priority;
import javafx.scene.layout.VBox;

public class NavigationPane extends VBox {

    public NavigationPane() {

        setSpacing(8);
        setPadding(new Insets(10));
        setPrefWidth(230);

        createButton("🏠 Home");
        createButton("📦 New Project");
        createButton("📂 Open Project");
        createButton("📁 Templates");

        getChildren().add(new javafx.scene.control.Separator());

        createButton("🌿 Git");
        createButton("☁ GitHub");

        getChildren().add(new javafx.scene.control.Separator());

        createButton("⚙ Settings");
        createButton("ℹ About");

        VBox spacer = new VBox();
        VBox.setVgrow(spacer, Priority.ALWAYS);

        getChildren().add(spacer);

        Button version = new Button("Project Wizard 1.0");
        version.setMaxWidth(Double.MAX_VALUE);
        version.setDisable(true);

        getChildren().add(version);
    }

    private void createButton(String text) {

        Button button = new Button(text);

        button.setMaxWidth(Double.MAX_VALUE);
        button.setPrefHeight(36);

        getChildren().add(button);

    }

}
EOF

echo
echo "========================================="
echo "Etapa 13.2 concluída!"
echo "========================================="
echo
echo "Sidebar modernizada com sucesso."
echo
echo "Execute:"
echo
echo "mvn clean javafx:run"
echo