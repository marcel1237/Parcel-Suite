package com.projectwizard.view;

import com.projectwizard.core.ApplicationContext;
import javafx.scene.Scene;
import javafx.scene.control.Menu;
import javafx.scene.control.MenuBar;
import javafx.scene.control.MenuItem;
import javafx.scene.control.SplitPane;
import javafx.scene.layout.BorderPane;
import javafx.scene.layout.VBox;
import javafx.stage.Stage;

public class MainWindow {

    private final ApplicationContext context = new ApplicationContext();

    public void show(Stage stage) {

        BorderPane root = new BorderPane();

        MenuBar menuBar = new MenuBar();

        Menu fileMenu = new Menu("File");
        Menu helpMenu = new Menu("Help");

        MenuItem exitItem = new MenuItem("Exit");
        exitItem.setOnAction(e -> stage.close());

        MenuItem aboutItem = new MenuItem("About");

        aboutItem.setOnAction(e ->
                context.getDialogService().showInformation(
                        "About Project Wizard",
                        context.getApplicationName()
                        + "\n\nVersion " + context.getVersion()
                        + "\n\nDesktop Project Generator"
                        + "\nBuilt with JavaFX"
                )
        );

        fileMenu.getItems().add(exitItem);
        helpMenu.getItems().add(aboutItem);

        menuBar.getMenus().addAll(fileMenu, helpMenu);

        VBox top = new VBox(
                menuBar,
                new MainToolBar()
        );

        SplitPane splitPane = new SplitPane(
                new NavigationPane(),
                new WorkspacePane()
        );

        splitPane.setDividerPositions(0.22);

        root.setTop(top);
        root.setCenter(splitPane);
        root.setBottom(new StatusBar());

        Scene scene = new Scene(root, 1100, 700);

        stage.setTitle(context.getApplicationName());
        stage.setScene(scene);

        stage.centerOnScreen();
        stage.show();

    }

}
