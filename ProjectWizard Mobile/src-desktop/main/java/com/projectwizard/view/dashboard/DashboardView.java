package com.projectwizard.view.dashboard;

import com.projectwizard.core.navigation.NavigationController;
import com.projectwizard.core.navigation.NavigationTarget;
import javafx.geometry.Pos;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.layout.VBox;

public class DashboardView extends VBox {

    public DashboardView() {

        setSpacing(20);

        setAlignment(Pos.CENTER);

        Label title = new Label("Project Wizard");

        title.setStyle("-fx-font-size:30px;-fx-font-weight:bold;");

        Label subtitle = new Label(
                "Create amazing projects"
        );

        Button newProject = new Button("New Project");
        newProject.setOnAction(e -> 
            NavigationController.getInstance().navigate(NavigationTarget.NEW_PROJECT)
        );

        Button openProject = new Button("Open Project");
        openProject.setOnAction(e -> 
            NavigationController.getInstance().navigate(NavigationTarget.OPEN_PROJECT)
        );

        getChildren().addAll(

                title,

                subtitle,

                newProject,

                openProject

        );

    }

}
