#!/usr/bin/env bash
set -e

echo "========================================="
echo " Project Wizard - Etapa 15.3"
echo " Search + Categories"
echo "========================================="

FILE="src/main/java/com/projectwizard/view/projecttype/ProjectTypeView.java"

if [ ! -f "$FILE" ]; then
    echo "Arquivo não encontrado:"
    echo "$FILE"
    exit 1
fi

cp "$FILE" "$FILE.bak"

cat > "$FILE" <<'EOF'
package com.projectwizard.view.projecttype;

import javafx.geometry.Insets;
import javafx.scene.control.ComboBox;
import javafx.scene.control.Label;
import javafx.scene.control.ScrollPane;
import javafx.scene.control.TextField;
import javafx.scene.layout.FlowPane;
import javafx.scene.layout.HBox;
import javafx.scene.layout.Priority;
import javafx.scene.layout.VBox;

public class ProjectTypeView extends VBox {

    public ProjectTypeView() {

        setSpacing(20);
        setPadding(new Insets(20));

        Label title = new Label("Choose Project Type");

        title.setStyle(
                "-fx-font-size:28px;" +
                "-fx-font-weight:bold;"
        );

        TextField search = new TextField();

        search.setPromptText("Search templates...");

        ComboBox<String> category = new ComboBox<>();

        category.getItems().addAll(

                "All",

                "Java",

                "Desktop",

                "Spring",

                "Library",

                "CLI"

        );

        category.getSelectionModel().selectFirst();

        ComboBox<String> filter = new ComboBox<>();

        filter.getItems().addAll(

                "All",

                "Favorites",

                "Recent"

        );

        filter.getSelectionModel().selectFirst();

        HBox toolbar = new HBox(10);

        HBox.setHgrow(search, Priority.ALWAYS);

        toolbar.getChildren().addAll(

                search,

                category,

                filter

        );

        FlowPane cards = new FlowPane();

        cards.setHgap(20);

        cards.setVgap(20);

        cards.getChildren().addAll(

                new ProjectCard(
                        "☕",
                        "Java Console",
                        "Classic Java application."
                ),

                new ProjectCard(
                        "🖥",
                        "JavaFX Desktop",
                        "Desktop application with JavaFX."
                ),

                new ProjectCard(
                        "🌱",
                        "Spring Boot",
                        "REST API using Spring Boot."
                ),

                new ProjectCard(
                        "📦",
                        "Maven Project",
                        "Standard Maven structure."
                ),

                new ProjectCard(
                        "🐘",
                        "Gradle Project",
                        "Standard Gradle structure."
                ),

                new ProjectCard(
                        "📚",
                        "Java Library",
                        "Reusable Java library."
                )

        );

        ScrollPane scroll = new ScrollPane(cards);

        scroll.setFitToWidth(true);

        VBox.setVgrow(scroll, Priority.ALWAYS);

        getChildren().addAll(

                title,

                toolbar,

                scroll

        );

    }

}
EOF

echo
echo "========================================="
echo " Etapa 15.3 concluída."
echo "========================================="
echo
echo "Novidades:"
echo "  ✔ Pesquisa"
echo "  ✔ Categorias"
echo "  ✔ Favoritos (placeholder)"
echo "  ✔ Recentes (placeholder)"
echo
echo "Execute:"
echo
echo "mvn clean javafx:run"