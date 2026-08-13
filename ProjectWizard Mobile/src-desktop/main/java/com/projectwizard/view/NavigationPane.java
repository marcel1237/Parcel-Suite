package com.projectwizard.view;

import com.projectwizard.core.navigation.NavigationController;
import com.projectwizard.core.navigation.NavigationTarget;
import javafx.geometry.Insets;
import javafx.scene.control.Button;
import javafx.scene.control.Separator;
import javafx.scene.layout.Priority;
import javafx.scene.layout.VBox;

public class NavigationPane extends VBox {

    public NavigationPane() {

        setSpacing(8);
        setPadding(new Insets(10));
        setPrefWidth(230);

        addButton("🏠 Home", NavigationTarget.HOME);
        addButton("📦 New Project", NavigationTarget.NEW_PROJECT);
        addButton("📂 Open Project", NavigationTarget.OPEN_PROJECT);
        addButton("📁 Templates", NavigationTarget.TEMPLATES);

        getChildren().add(new Separator());

        addButton("🌿 Git", NavigationTarget.GIT);
        addButton("☁ GitHub", NavigationTarget.GITHUB);

        getChildren().add(new Separator());

        addButton("⚙ Settings", NavigationTarget.SETTINGS);
        addButton("ℹ About", NavigationTarget.ABOUT);

        VBox spacer = new VBox();
        VBox.setVgrow(spacer, Priority.ALWAYS);

        getChildren().add(spacer);

        Button version = new Button("Project Wizard 1.0");
        version.setDisable(true);
        version.setMaxWidth(Double.MAX_VALUE);

        getChildren().add(version);
    }

    private void addButton(String text, NavigationTarget target) {

        Button button = new Button(text);

        button.setPrefHeight(36);
        button.setMaxWidth(Double.MAX_VALUE);

        button.setOnAction(e ->
                NavigationController
                        .getInstance()
                        .navigate(target));

        getChildren().add(button);

    }

}
