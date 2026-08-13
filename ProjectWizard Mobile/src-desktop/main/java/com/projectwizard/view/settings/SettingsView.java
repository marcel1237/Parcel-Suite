package com.projectwizard.view.settings;

import javafx.geometry.Pos;
import javafx.scene.control.Label;
import javafx.scene.layout.BorderPane;

public class SettingsView extends BorderPane {

    public SettingsView() {

        Label label = new Label("Settings");

        label.setStyle(
            "-fx-font-size:28px;" +
            "-fx-font-weight:bold;"
        );

        setCenter(label);

        BorderPane.setAlignment(label, Pos.CENTER);

    }

}
