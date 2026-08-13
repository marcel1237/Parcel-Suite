package com.projectwizard.view.github;

import javafx.geometry.Pos;
import javafx.scene.control.Label;
import javafx.scene.layout.BorderPane;

public class GitHubView extends BorderPane {

    public GitHubView() {

        Label label = new Label("GitHub");

        label.setStyle(
            "-fx-font-size:28px;" +
            "-fx-font-weight:bold;"
        );

        setCenter(label);

        BorderPane.setAlignment(label, Pos.CENTER);

    }

}
