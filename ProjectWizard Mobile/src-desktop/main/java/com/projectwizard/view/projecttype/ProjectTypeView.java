package com.projectwizard.view.projecttype;

import javafx.geometry.Insets;
import javafx.scene.control.*;
import javafx.scene.layout.*;

public class ProjectTypeView extends BorderPane {

    public ProjectTypeView() {

        setPadding(new Insets(15));

        ///////////////////////////////////////////////////////
        // TOPO
        ///////////////////////////////////////////////////////

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

        HBox toolbar = new HBox(10);

        HBox.setHgrow(search, Priority.ALWAYS);

        toolbar.getChildren().addAll(
                search,
                category
        );

        VBox top = new VBox(15);

        top.getChildren().addAll(
                title,
                toolbar
        );

        setTop(top);

        ///////////////////////////////////////////////////////
        // ESQUERDA (CATÁLOGO)
        ///////////////////////////////////////////////////////

        FlowPane cards = new FlowPane();

        cards.setHgap(15);
        cards.setVgap(15);

        cards.getChildren().addAll(

                new ProjectCard(
                        "☕",
                        "Java Console",
                        "Classic Java application."
                ),

                new ProjectCard(
                        "🖥",
                        "JavaFX Desktop",
                        "Desktop application with AtlantaFX."
                ),

                new ProjectCard(
                        "🌱",
                        "Spring Boot",
                        "REST API template."
                ),

                new ProjectCard(
                        "📦",
                        "Maven",
                        "Standard Maven project."
                ),

                new ProjectCard(
                        "🐘",
                        "Gradle",
                        "Standard Gradle project."
                ),

                new ProjectCard(
                        "📚",
                        "Java Library",
                        "Reusable library."
                )

        );

        ScrollPane scroll = new ScrollPane(cards);

        scroll.setFitToWidth(true);

        ///////////////////////////////////////////////////////
        // DIREITA (DETAILS)
        ///////////////////////////////////////////////////////

        VBox details = new VBox(12);

        details.setPadding(new Insets(15));

        details.setPrefWidth(320);

        Label detailsTitle = new Label("Template Details");

        detailsTitle.setStyle(
                "-fx-font-size:22px;" +
                "-fx-font-weight:bold;"
        );

        Label projectName = new Label("JavaFX Desktop");

        projectName.setStyle(
                "-fx-font-size:18px;" +
                "-fx-font-weight:bold;"
        );

        Label description = new Label(
                "Desktop application using JavaFX\n" +
                "with AtlantaFX Theme."
        );

        description.setWrapText(true);

        Separator sep = new Separator();

        Label tech = new Label(
                "Java 17\n" +
                "JavaFX\n" +
                "AtlantaFX\n" +
                "Maven"
        );

        Button create = new Button("Create Project");

        create.setMaxWidth(Double.MAX_VALUE);

        details.getChildren().addAll(

                detailsTitle,

                projectName,

                description,

                sep,

                tech,

                new Separator(),

                create

        );

        ///////////////////////////////////////////////////////

        SplitPane split = new SplitPane();

        split.getItems().addAll(

                scroll,

                details

        );

        split.setDividerPositions(0.70);

        setCenter(split);

    }

}
