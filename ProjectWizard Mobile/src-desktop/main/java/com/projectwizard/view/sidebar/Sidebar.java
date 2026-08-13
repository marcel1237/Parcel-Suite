package com.projectwizard.view.sidebar;

import com.projectwizard.core.navigation.NavigationController;
import com.projectwizard.core.navigation.NavigationTarget;

import javafx.geometry.Insets;
import javafx.scene.control.Button;
import javafx.scene.layout.Priority;
import javafx.scene.layout.VBox;

public class Sidebar extends VBox {

    public Sidebar() {

        setSpacing(6);
        setPadding(new Insets(10));
        setPrefWidth(220);

        create("🏠 Home", NavigationTarget.HOME);
        create("📦 New Project", NavigationTarget.NEW_PROJECT);
        create("📂 Open Project", NavigationTarget.OPEN_PROJECT);
        create("📚 Templates", NavigationTarget.TEMPLATES);
        create("🌱 Git", NavigationTarget.GIT);
        create("🐙 GitHub", NavigationTarget.GITHUB);
        create("⚙ Settings", NavigationTarget.SETTINGS);
        create("ℹ About", NavigationTarget.ABOUT);

    }

    private void create(String text, NavigationTarget target) {

        Button b = new Button(text);

        b.setMaxWidth(Double.MAX_VALUE);

        VBox.setVgrow(b, Priority.NEVER);

        b.setOnAction(e -> {

            System.out.println("[NAV] " + target);

            NavigationController
                    .getInstance()
                    .navigate(target);

        });

        getChildren().add(b);

    }

}
