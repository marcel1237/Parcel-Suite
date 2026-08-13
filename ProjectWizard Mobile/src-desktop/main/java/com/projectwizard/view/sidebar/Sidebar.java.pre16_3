package com.projectwizard.view.sidebar;

import javafx.geometry.Insets;
import javafx.scene.control.Button;
import javafx.scene.layout.VBox;

public class Sidebar extends VBox {

    private final Button homeButton = new Button("🏠 Home");
    private final Button newProjectButton = new Button("📦 New Project");
    private final Button openProjectButton = new Button("📂 Open Project");
    private final Button templatesButton = new Button("📁 Templates");
    private final Button gitButton = new Button("🌿 Git");
    private final Button settingsButton = new Button("⚙ Settings");
    private final Button aboutButton = new Button("ℹ About");

    public Sidebar() {

        setSpacing(8);
        setPadding(new Insets(10));
        setPrefWidth(220);

        homeButton.setMaxWidth(Double.MAX_VALUE);
        newProjectButton.setMaxWidth(Double.MAX_VALUE);
        openProjectButton.setMaxWidth(Double.MAX_VALUE);
        templatesButton.setMaxWidth(Double.MAX_VALUE);
        gitButton.setMaxWidth(Double.MAX_VALUE);
        settingsButton.setMaxWidth(Double.MAX_VALUE);
        aboutButton.setMaxWidth(Double.MAX_VALUE);

        getChildren().addAll(
                homeButton,
                newProjectButton,
                openProjectButton,
                templatesButton,
                gitButton,
                settingsButton,
                aboutButton
        );
    }
}
