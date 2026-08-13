package com.projectwizard;

import javafx.application.Application;
import javafx.stage.Stage;

public class Main extends Application {

    private final App app = new App();

    @Override
    public void start(Stage stage) {

        app.start(stage);

    }

    public static void main(String[] args) {

        launch(args);

    }

}
