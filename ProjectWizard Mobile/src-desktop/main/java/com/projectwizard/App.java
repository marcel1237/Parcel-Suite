package com.projectwizard;

import com.projectwizard.view.MainWindow;
//import javafx.application.Application;
import javafx.scene.Scene;
import javafx.stage.Stage;
import com.projectwizard.theme.ThemeManager;
import com.projectwizard.theme.ThemeType;

public class App {

    public void start(Stage stage) {

    	ThemeManager.apply(ThemeType.PRIMER_DARK);
        MainWindow window = new MainWindow();
        window.show(stage);

        Scene scene = stage.getScene();

        if (scene != null) {

            scene.getStylesheets().add(
                    getClass()
                            .getResource("/themes/projectwizard.css")
                            .toExternalForm()
            );

        }

    }

}
