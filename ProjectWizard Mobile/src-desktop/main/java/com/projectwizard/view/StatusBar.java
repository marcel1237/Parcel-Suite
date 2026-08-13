package com.projectwizard.view;

import com.projectwizard.core.ApplicationContext;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.control.Label;
import javafx.scene.layout.HBox;
import javafx.scene.layout.Priority;

public class StatusBar extends HBox {

    public StatusBar() {

        ApplicationContext context = ApplicationContext.getInstance();

        Label status = new Label("Ready");

        Label version = new Label(context.getVersion());

        HBox spacer = new HBox();

        HBox.setHgrow(spacer, Priority.ALWAYS);

        getChildren().addAll(
                status,
                spacer,
                version
        );

        setPadding(new Insets(6,10,6,10));
        setAlignment(Pos.CENTER_LEFT);

    }

}
