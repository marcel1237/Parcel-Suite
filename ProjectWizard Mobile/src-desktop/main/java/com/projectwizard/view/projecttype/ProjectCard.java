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
