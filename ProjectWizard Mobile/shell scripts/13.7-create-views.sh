#!/usr/bin/env bash
set -e

echo "========================================="
echo " Project Wizard - Etapa 13.7"
echo " Create Base Views"
echo "========================================="

BASE="src/main/java/com/projectwizard/view"

create_view() {

DIR="$BASE/$1"
CLASS="$2"
TITLE="$3"

mkdir -p "$DIR"

cat > "$DIR/$CLASS.java" <<EOF
package com.projectwizard.view.$1;

import javafx.geometry.Pos;
import javafx.scene.control.Label;
import javafx.scene.layout.BorderPane;

public class $CLASS extends BorderPane {

    public $CLASS() {

        Label label = new Label("$TITLE");

        label.setStyle(
            "-fx-font-size:28px;" +
            "-fx-font-weight:bold;"
        );

        setCenter(label);

        BorderPane.setAlignment(label, Pos.CENTER);

    }

}
EOF

echo "Criado: $CLASS"

}

create_view newproject NewProjectView "New Project"

create_view openproject OpenProjectView "Open Project"

create_view templates TemplatesView "Templates"

create_view git GitView "Git"

create_view github GitHubView "GitHub"

create_view settings SettingsView "Settings"

create_view about AboutView "About Project Wizard"

echo
echo "========================================="
echo "Views criadas com sucesso."
echo "========================================="
echo
echo "Execute:"
echo
echo "mvn clean javafx:run"