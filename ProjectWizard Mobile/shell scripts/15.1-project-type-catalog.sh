#!/usr/bin/env bash
set -e

echo "========================================="
echo " Project Wizard - Etapa 15.1"
echo " Project Type Catalog"
echo "========================================="

BASE="src/main/java/com/projectwizard/view/projecttype"

mkdir -p "$BASE"

cat > "$BASE/ProjectTypeView.java" <<'EOF'
package com.projectwizard.view.projecttype;

import javafx.geometry.Insets;
import javafx.scene.control.ListView;
import javafx.scene.control.Label;
import javafx.scene.layout.BorderPane;
import javafx.scene.layout.VBox;

public class ProjectTypeView extends BorderPane {

    public ProjectTypeView() {

        setPadding(new Insets(20));

        Label title = new Label("Choose Project Type");

        title.setStyle(
                "-fx-font-size:26px;" +
                "-fx-font-weight:bold;"
        );

        ListView<String> projects = new ListView<>();

        projects.getItems().addAll(

                "☕ Java Console",

                "🖥 JavaFX Desktop",

                "🌱 Spring Boot",

                "📦 Maven Project",

                "🐘 Gradle Project",

                "📚 Java Library"

        );

        VBox box = new VBox(15);

        box.getChildren().addAll(

                title,

                projects

        );

        setCenter(box);

    }

}
EOF

echo
echo "========================================="
echo " ProjectTypeView criada."
echo "========================================="
echo
echo "Próxima etapa (15.2):"
echo
echo "- Cards modernos"
echo "- Ícones AtlantaFX"
echo "- Pesquisa"
echo "- Categorias"
echo
echo "Execute:"
echo
echo "mvn clean javafx:run"