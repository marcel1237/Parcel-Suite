#!/usr/bin/env bash

set -e

echo "========================================="
echo " Project Wizard - 16.7"
echo " Open Button"
echo "========================================="

FILE="src/main/java/com/projectwizard/view/MainToolBar.java"

cp "$FILE" "$FILE.bak"

cat > "$FILE" <<'EOF'
package com.projectwizard.view;

import javafx.scene.control.Button;
import javafx.scene.control.ToolBar;

import com.projectwizard.view.openproject.OpenProjectView;

public class MainToolBar extends ToolBar {

    public MainToolBar() {

        Button newProject = new Button("New Project");

        Button open = new Button("Open");

        open.setOnAction(e -> {

            OpenProjectView view = new OpenProjectView();
            view.show();

        });

        Button settings = new Button("Settings");

        getItems().addAll(

                newProject,
                open,
                settings

        );

    }

}
EOF

echo
echo "========================================="
echo "Pronto!"
echo
echo "Agora o botão Open abre"
echo "a tela OpenProjectView."
echo
echo "Execute:"
echo
echo "mvn clean javafx:run"