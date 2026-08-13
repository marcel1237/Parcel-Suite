#!/usr/bin/env bash
set -e

echo "========================================="
echo " Project Wizard - Etapa 15.2"
echo " Project Cards"
echo "========================================="

BASE="src/main/java/com/projectwizard/view/projecttype"

mkdir -p "$BASE"

############################################################
# ProjectCard
############################################################

cat > "$BASE/ProjectCard.java" <<'EOF'
package com.projectwizard.view.projecttype;

import javafx.geometry.Insets;
import javafx.scene.control.Label;
import javafx.scene.layout.VBox;

public class ProjectCard extends VBox {

    public ProjectCard(
            String icon,
            String title,
            String description
    ) {

        setSpacing(6);
        setPadding(new Insets(15));

        setPrefWidth(260);

        setStyle(
            "-fx-background-radius:10;" +
            "-fx-border-radius:10;" +
            "-fx-border-color:#555;" +
            "-fx-padding:15;"
        );

        Label iconLabel = new Label(icon);
        iconLabel.setStyle("-fx-font-size:28px;");

        Label titleLabel = new Label(title);
        titleLabel.setStyle(
                "-fx-font-size:18px;" +
                "-fx-font-weight:bold;"
        );

        Label descriptionLabel =
                new Label(description);

        descriptionLabel.setWrapText(true);

        getChildren().addAll(
                iconLabel,
                titleLabel,
                descriptionLabel
        );

    }

}
EOF

############################################################
# ProjectTypeView
############################################################

cat > "$BASE/ProjectTypeView.java" <<'EOF'
package com.projectwizard.view.projecttype;

import javafx.geometry.Insets;
import javafx.scene.control.Label;
import javafx.scene.control.ScrollPane;
import javafx.scene.layout.FlowPane;
import javafx.scene.layout.VBox;

public class ProjectTypeView extends VBox {

    public ProjectTypeView() {

        setSpacing(20);
        setPadding(new Insets(20));

        Label title =
                new Label("Choose Project Type");

        title.setStyle(
                "-fx-font-size:28px;" +
                "-fx-font-weight:bold;"
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

        getChildren().addAll(
                title,
                scroll
        );

    }

}
EOF

echo
echo "========================================="
echo " Project Cards criados."
echo "========================================="
echo
echo "Execute:"
echo
echo "mvn clean javafx:run"
echo
echo "Próxima etapa:"
echo "15.3 - Pesquisa + Categorias + Filtros"