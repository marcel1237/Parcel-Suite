package com.projectwizard.view.git;

import javafx.geometry.Pos;
import javafx.scene.control.Label;
import javafx.scene.layout.BorderPane;

public class GitView extends BorderPane {

    public GitView() {

        Label label = new Label("Git");

        label.setStyle(
            "-fx-font-size:28px;" +
            "-fx-font-weight:bold;"
        );

        setCenter(label);

        BorderPane.setAlignment(label, Pos.CENTER);

    }

}
