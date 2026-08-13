package com.projectwizard;

import com.projectwizard.view.MainWindow;
//import javafx.application.Application;
import javafx.scene.Scene;
import javafx.stage.Stage;
import com.projectwizard.theme.ThemeManager;
import com.projectwizard.theme.ThemeType;
import com.projectwizard.view.sidebar.Sidebar;
import com.projectwizard.view.dashboard.DashboardView;


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
package com.projectwizard.view.openproject;

import java.io.File;

import javafx.geometry.Insets;
import javafx.scene.control.*;
import javafx.scene.layout.*;
import javafx.stage.DirectoryChooser;
import javafx.stage.Window;

import com.projectwizard.view.explorer.PackageExplorer;
import com.projectwizard.view.explorer.FileTreeCell;

public class OpenProjectView extends BorderPane {

    private final TextField pathField = new TextField();

    private final Button browseButton = new Button("Browse...");

    private final Button openButton = new Button("Open");

    private final Button cancelButton = new Button("Cancel");

    private File selectedDirectory;

    private final PackageExplorer explorer =
            new PackageExplorer();

    public OpenProjectView() {

        setPadding(new Insets(20));

        ////////////////////////////////////////////////////////

        Label title = new Label("Open Project");

        title.setStyle(
                "-fx-font-size:26px;" +
                "-fx-font-weight:bold;"
        );

        ////////////////////////////////////////////////////////

        pathField.setPromptText("Choose a project folder...");
        pathField.setEditable(false);

        HBox pathBox = new HBox(
                10,
                pathField,
                browseButton
        );

        HBox.setHgrow(pathField, Priority.ALWAYS);

        ////////////////////////////////////////////////////////

        TextArea info = new TextArea();

        info.setEditable(false);

        info.setText(
                "Choose a folder to continue."
        );

        VBox.setVgrow(info, Priority.ALWAYS);

        ////////////////////////////////////////////////////////

        openButton.setDisable(true);

        browseButton.setOnAction(e -> {

            Window window = getScene().getWindow();

            DirectoryChooser chooser =
                    new DirectoryChooser();

            chooser.setTitle("Open Project Folder");

            File dir = chooser.showDialog(window);

            if (dir != null) {

                selectedDirectory = dir;

                explorer.setCellFactory(v -> new FileTreeCell());

                explorer.openProject(dir);

                pathField.setText(
                        dir.getAbsolutePath()
                );

                info.setText(
                        "Folder selected:\n\n"
                        + dir.getAbsolutePath()
                );

                openButton.setDisable(false);

            }

        });

        ////////////////////////////////////////////////////////

        openButton.setOnAction(e -> {

            System.out.println(
                    "[PROJECT] "
                    + selectedDirectory.getAbsolutePath()
            );

            Alert alert = new Alert(
                    Alert.AlertType.INFORMATION
            );

            alert.setTitle("Project Wizard");

            alert.setHeaderText("Folder Selected");

            alert.setContentText(
                    selectedDirectory.getAbsolutePath()
            );

            alert.showAndWait();

        });

        cancelButton.setOnAction(e -> {

            pathField.clear();

            selectedDirectory = null;

            openButton.setDisable(true);

            info.setText(
                    "Choose a folder to continue."
            );

        });

        ////////////////////////////////////////////////////////

        HBox buttons = new HBox(
                10,
                openButton,
                cancelButton
        );

        VBox center = new VBox(
                20,
                title,
                pathBox,
                info,
                buttons
        );

        
SplitPane split = new SplitPane();

split.getItems().addAll(
        explorer,
        center
);

split.setDividerPositions(0.30);

setCenter(split);


    }

}
package com.projectwizard.view.explorer;

import java.io.File;

import javafx.scene.control.TreeItem;
import javafx.scene.control.TreeView;

public class PackageExplorer extends TreeView<File> {

    public PackageExplorer() {

        setShowRoot(true);

    }

    public void openProject(File rootFolder) {

        if (rootFolder == null)
            return;

        TreeItem<File> root = create(rootFolder);

        setRoot(root);

        root.setExpanded(true);

    }

    private TreeItem<File> create(File file) {

        TreeItem<File> item = new TreeItem<>(file);

        if (file.isDirectory()) {

            File[] files = file.listFiles();

            if (files != null) {

                java.util.Arrays.sort(files);

                for (File child : files) {

                    item.getChildren().add(create(child));

                }

            }

        }

        return item;

    }

}
package com.projectwizard.view.explorer;

import java.io.File;

import javafx.scene.control.TreeCell;

public class FileTreeCell extends TreeCell<File> {

    @Override
    protected void updateItem(File item, boolean empty) {

        super.updateItem(item, empty);

        if (empty || item == null) {

            setText(null);

        } else {

            setText(item.getName().isBlank()
                    ? item.getAbsolutePath()
                    : item.getName());

        }

    }

}
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
package com.projectwizard.view;

import com.projectwizard.core.navigation.NavigationController;

import com.projectwizard.view.dashboard.DashboardView;
import javafx.scene.Node;
import javafx.scene.layout.BorderPane;

public class WorkspacePane extends BorderPane {

    private static WorkspacePane instance;

    public WorkspacePane() {

        instance = this;

        NavigationController.getInstance().setWorkspace(this);

        showDashboard();

    }

    public static WorkspacePane getInstance() {

        return instance;

    }

    public void setContent(Node node) {

        setCenter(node);

    }

    public void showDashboard() {

        setContent(new DashboardView());

    }

}
package com.projectwizard.view.about;

import javafx.geometry.Pos;
import javafx.scene.control.Label;
import javafx.scene.layout.BorderPane;

public class AboutView extends BorderPane {

    public AboutView() {

        Label label = new Label("About Project Wizard");

        label.setStyle(
            "-fx-font-size:28px;" +
            "-fx-font-weight:bold;"
        );

        setCenter(label);

        BorderPane.setAlignment(label, Pos.CENTER);

    }

}
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
package com.projectwizard.view.templates;

import javafx.geometry.Pos;
import javafx.scene.control.Label;
import javafx.scene.layout.BorderPane;

public class TemplatesView extends BorderPane {

    public TemplatesView() {

        Label label = new Label("Templates");

        label.setStyle(
            "-fx-font-size:28px;" +
            "-fx-font-weight:bold;"
        );

        setCenter(label);

        BorderPane.setAlignment(label, Pos.CENTER);

    }

}
package com.projectwizard.view.newproject;

import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.control.Button;
import javafx.scene.control.ComboBox;
import javafx.scene.control.Label;
import javafx.scene.control.Separator;
import javafx.scene.control.TextField;
import javafx.scene.layout.BorderPane;
import javafx.scene.layout.GridPane;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;

public class NewProjectView extends BorderPane {

    public NewProjectView() {

        setPadding(new Insets(20));

        VBox left = new VBox(15);

        left.getChildren().addAll(
                createStep("① Project"),
                createStep("② Language"),
                createStep("③ Framework"),
                createStep("④ Dependencies"),
                createStep("⑤ Git"),
                createStep("⑥ Summary")
        );

        left.setPrefWidth(220);

        GridPane form = new GridPane();

        form.setHgap(10);
        form.setVgap(12);

        Label title = new Label("Create New Project");

        title.setStyle(
                "-fx-font-size:26px;" +
                "-fx-font-weight:bold;"
        );

        TextField projectName = new TextField();

        TextField group = new TextField("com.example");

        TextField artifact = new TextField();

        ComboBox<String> language = new ComboBox<>();

        language.getItems().addAll(
                "Java",
                "Kotlin",
                "Groovy"
        );

        language.getSelectionModel().selectFirst();

        ComboBox<String> build = new ComboBox<>();

        build.getItems().addAll(
                "Maven",
                "Gradle"
        );

        build.getSelectionModel().selectFirst();

        form.add(title,0,0,2,1);

        form.add(new Label("Project Name"),0,1);
        form.add(projectName,1,1);

        form.add(new Label("Group"),0,2);
        form.add(group,1,2);

        form.add(new Label("Artifact"),0,3);
        form.add(artifact,1,3);

        form.add(new Label("Language"),0,4);
        form.add(language,1,4);

        form.add(new Label("Build Tool"),0,5);
        form.add(build,1,5);

        HBox buttons = new HBox(10);

        Button back = new Button("◀ Back");

        Button next = new Button("Next ▶");

        Button finish = new Button("Finish");

        buttons.getChildren().addAll(
                back,
                next,
                finish
        );

        buttons.setAlignment(Pos.CENTER_RIGHT);

        VBox center = new VBox(20);

        center.getChildren().addAll(

                form,

                new Separator(),

                buttons

        );

        setLeft(left);

        setCenter(center);

    }

    private Label createStep(String text){

        Label label = new Label(text);

        label.setMaxWidth(Double.MAX_VALUE);

        label.setStyle(
                "-fx-font-size:15px;" +
                "-fx-padding:8;"
        );

        return label;

    }

}
package com.projectwizard.view;

import com.projectwizard.core.ApplicationContext;
import com.projectwizard.core.navigation.NavigationController;
import com.projectwizard.core.navigation.NavigationTarget;

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

        //////////////////////////////////////////////////////
        // MENU
        //////////////////////////////////////////////////////

        MenuBar menuBar = new MenuBar();

        Menu fileMenu = new Menu("File");
        Menu helpMenu = new Menu("Help");

        MenuItem exitItem = new MenuItem("Exit");
        exitItem.setOnAction(e -> stage.close());

        MenuItem aboutItem = new MenuItem("About");

        aboutItem.setOnAction(e ->
            NavigationController.getInstance()
                    .navigate(NavigationTarget.ABOUT)
        );

        fileMenu.getItems().add(exitItem);
        helpMenu.getItems().add(aboutItem);

        menuBar.getMenus().addAll(fileMenu, helpMenu);

        VBox top = new VBox(
                menuBar,
                new MainToolBar()
        );

        //////////////////////////////////////////////////////
        // WORKSPACE
        //////////////////////////////////////////////////////

        WorkspacePane workspace = new WorkspacePane();

        NavigationController
                .getInstance()
                .setWorkspace(workspace);

        NavigationPane navigation = new NavigationPane();

        SplitPane split = new SplitPane();

        split.getItems().addAll(

                navigation,

                workspace

        );

        split.setDividerPositions(0.22);

        //////////////////////////////////////////////////////
        // ROOT
        //////////////////////////////////////////////////////

        root.setTop(top);
        root.setCenter(split);
        root.setBottom(new StatusBar());

        Scene scene = new Scene(root,1100,700);

        stage.setTitle(context.getApplicationName());

        stage.setScene(scene);

        stage.centerOnScreen();

        stage.show();

        //////////////////////////////////////////////////////
        // DASHBOARD INICIAL
        //////////////////////////////////////////////////////

        NavigationController
                .getInstance()
                .navigate(NavigationTarget.HOME);

    }

}
package com.projectwizard.view.dashboard;

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

        Button openProject = new Button("Open Project");

        getChildren().addAll(

                title,

                subtitle,

                newProject,

                openProject

        );

    }

}
package com.projectwizard.view;

import com.projectwizard.core.ApplicationContext;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.control.Label;
import javafx.scene.layout.HBox;
import javafx.scene.layout.Priority;

public class StatusBar extends HBox {

    public StatusBar() {

        ApplicationContext context = new ApplicationContext();

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
package com.projectwizard.view.github;

import javafx.geometry.Pos;
import javafx.scene.control.Label;
import javafx.scene.layout.BorderPane;

public class GitHubView extends BorderPane {

    public GitHubView() {

        Label label = new Label("GitHub");

        label.setStyle(
            "-fx-font-size:28px;" +
            "-fx-font-weight:bold;"
        );

        setCenter(label);

        BorderPane.setAlignment(label, Pos.CENTER);

    }

}
package com.projectwizard.view.projecttype;

import javafx.geometry.Insets;
import javafx.scene.control.*;
import javafx.scene.layout.*;

public class ProjectTypeView extends BorderPane {

    public ProjectTypeView() {

        setPadding(new Insets(15));

        ///////////////////////////////////////////////////////
        // TOPO
        ///////////////////////////////////////////////////////

        Label title = new Label("Choose Project Type");

        title.setStyle(
                "-fx-font-size:28px;" +
                "-fx-font-weight:bold;"
        );

        TextField search = new TextField();
        search.setPromptText("Search templates...");

        ComboBox<String> category = new ComboBox<>();

        category.getItems().addAll(
                "All",
                "Java",
                "Desktop",
                "Spring",
                "Library",
                "CLI"
        );

        category.getSelectionModel().selectFirst();

        HBox toolbar = new HBox(10);

        HBox.setHgrow(search, Priority.ALWAYS);

        toolbar.getChildren().addAll(
                search,
                category
        );

        VBox top = new VBox(15);

        top.getChildren().addAll(
                title,
                toolbar
        );

        setTop(top);

        ///////////////////////////////////////////////////////
        // ESQUERDA (CATÁLOGO)
        ///////////////////////////////////////////////////////

        FlowPane cards = new FlowPane();

        cards.setHgap(15);
        cards.setVgap(15);

        cards.getChildren().addAll(

                new ProjectCard(
                        "☕",
                        "Java Console",
                        "Classic Java application."
                ),

                new ProjectCard(
                        "🖥",
                        "JavaFX Desktop",
                        "Desktop application with AtlantaFX."
                ),

                new ProjectCard(
                        "🌱",
                        "Spring Boot",
                        "REST API template."
                ),

                new ProjectCard(
                        "📦",
                        "Maven",
                        "Standard Maven project."
                ),

                new ProjectCard(
                        "🐘",
                        "Gradle",
                        "Standard Gradle project."
                ),

                new ProjectCard(
                        "📚",
                        "Java Library",
                        "Reusable library."
                )

        );

        ScrollPane scroll = new ScrollPane(cards);

        scroll.setFitToWidth(true);

        ///////////////////////////////////////////////////////
        // DIREITA (DETAILS)
        ///////////////////////////////////////////////////////

        VBox details = new VBox(12);

        details.setPadding(new Insets(15));

        details.setPrefWidth(320);

        Label detailsTitle = new Label("Template Details");

        detailsTitle.setStyle(
                "-fx-font-size:22px;" +
                "-fx-font-weight:bold;"
        );

        Label projectName = new Label("JavaFX Desktop");

        projectName.setStyle(
                "-fx-font-size:18px;" +
                "-fx-font-weight:bold;"
        );

        Label description = new Label(
                "Desktop application using JavaFX\n" +
                "with AtlantaFX Theme."
        );

        description.setWrapText(true);

        Separator sep = new Separator();

        Label tech = new Label(
                "Java 17\n" +
                "JavaFX\n" +
                "AtlantaFX\n" +
                "Maven"
        );

        Button create = new Button("Create Project");

        create.setMaxWidth(Double.MAX_VALUE);

        details.getChildren().addAll(

                detailsTitle,

                projectName,

                description,

                sep,

                tech,

                new Separator(),

                create

        );

        ///////////////////////////////////////////////////////

        SplitPane split = new SplitPane();

        split.getItems().addAll(

                scroll,

                details

        );

        split.setDividerPositions(0.70);

        setCenter(split);

    }

}
package com.projectwizard.view.projecttype;

import javafx.geometry.Insets;
import javafx.scene.control.Label;
import javafx.scene.layout.VBox;

public class ProjectCard extends VBox {

    public ProjectCard(
            String icon,
            String title,
            String description
    ) {

        setSpacing(6);
        setPadding(new Insets(15));

        setPrefWidth(260);

        setStyle(
            "-fx-background-radius:10;" +
            "-fx-border-radius:10;" +
            "-fx-border-color:#555;" +
            "-fx-padding:15;"
        );

        Label iconLabel = new Label(icon);
        iconLabel.setStyle("-fx-font-size:28px;");

        Label titleLabel = new Label(title);
        titleLabel.setStyle(
                "-fx-font-size:18px;" +
                "-fx-font-weight:bold;"
        );

        Label descriptionLabel =
                new Label(description);

        descriptionLabel.setWrapText(true);

        getChildren().addAll(
                iconLabel,
                titleLabel,
                descriptionLabel
        );

    }

}
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
package com.projectwizard.view;

import javafx.scene.control.Button;
import javafx.scene.control.ToolBar;

public class MainToolBar extends ToolBar {

    public MainToolBar() {

        getItems().addAll(

                new Button("New Project"),
                new Button("Open"),
                new Button("Settings")

        );

    }

}
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
package com.projectwizard.service;

public class SettingsService {

    public String getTheme() {

        return "Default";

    }

}
package com.projectwizard.service;

public class ProjectService {

    public void createProject() {

        System.out.println("Project creation will be implemented in a future step.");

    }

}
package com.projectwizard.service;

import java.nio.file.Files;
import java.nio.file.Path;

public class FileSystemService {

    public boolean exists(Path path) {

        return Files.exists(path);

    }

}
package com.projectwizard.service;

import javafx.scene.control.Alert;
import javafx.scene.control.Alert.AlertType;

public class DialogService {

    public void showInformation(String title, String message) {

        Alert alert = new Alert(AlertType.INFORMATION);

        alert.setTitle(title);
        alert.setHeaderText(null);
        alert.setContentText(message);

        alert.showAndWait();

    }

}
package com.projectwizard.service;

import com.projectwizard.view.WorkspacePane;
import javafx.scene.Node;

public class NavigationService {

    private WorkspacePane workspace;

    public void setWorkspace(WorkspacePane workspace) {
        this.workspace = workspace;
    }

    public void navigate(Node node) {
        if (workspace != null) {
            workspace.setContent(node);
        }
    }

}
package com.projectwizard.theme;

public enum ThemeType {

    DRACULA,

    NORD_DARK,
    NORD_LIGHT,

    PRIMER_DARK,
    PRIMER_LIGHT,

    CUPERTINO_DARK,
    CUPERTINO_LIGHT

}
package com.projectwizard.theme;

import atlantafx.base.theme.CupertinoDark;
import atlantafx.base.theme.CupertinoLight;
import atlantafx.base.theme.Dracula;
import atlantafx.base.theme.NordDark;
import atlantafx.base.theme.NordLight;
import atlantafx.base.theme.PrimerDark;
import atlantafx.base.theme.PrimerLight;
import javafx.application.Application;

public final class ThemeManager {

    private static ThemeType currentTheme = ThemeType.PRIMER_DARK;

    private ThemeManager() {
    }

    public static ThemeType getCurrentTheme() {

        return currentTheme;

    }

    public static void apply(ThemeType theme) {

        currentTheme = theme;

        switch (theme) {

            case DRACULA ->
                Application.setUserAgentStylesheet(
                        new Dracula().getUserAgentStylesheet());

            case NORD_DARK ->
                Application.setUserAgentStylesheet(
                        new NordDark().getUserAgentStylesheet());

            case NORD_LIGHT ->
                Application.setUserAgentStylesheet(
                        new NordLight().getUserAgentStylesheet());

            case PRIMER_DARK ->
                Application.setUserAgentStylesheet(
                        new PrimerDark().getUserAgentStylesheet());

            case PRIMER_LIGHT ->
                Application.setUserAgentStylesheet(
                        new PrimerLight().getUserAgentStylesheet());

            case CUPERTINO_DARK ->
                Application.setUserAgentStylesheet(
                        new CupertinoDark().getUserAgentStylesheet());

            case CUPERTINO_LIGHT ->
                Application.setUserAgentStylesheet(
                        new CupertinoLight().getUserAgentStylesheet());

        }

    }

}
package com.projectwizard.core;

public final class Version {

    private Version() {
    }

    public static final String VERSION = "0.1.0";

}
package com.projectwizard.core;

public final class Constants {

    private Constants() {
    }

    public static final String APPLICATION_NAME = "Project Wizard";

}
package com.projectwizard.core;

import com.projectwizard.service.DialogService;
import com.projectwizard.service.FileSystemService;
import com.projectwizard.service.NavigationService;
import com.projectwizard.service.ProjectService;
import com.projectwizard.service.SettingsService;

public class ApplicationContext {

    private static final NavigationService navigationService = new NavigationService();

    private final DialogService dialogService = new DialogService();
    private final FileSystemService fileSystemService = new FileSystemService();
    private final ProjectService projectService = new ProjectService();
    private final SettingsService settingsService = new SettingsService();

    public String getApplicationName() {
        return Constants.APPLICATION_NAME;
    }

    public String getVersion() {
        return Version.VERSION;
    }

    public DialogService getDialogService() {
        return dialogService;
    }

    public FileSystemService getFileSystemService() {
        return fileSystemService;
    }

    public ProjectService getProjectService() {
        return projectService;
    }

    public SettingsService getSettingsService() {
        return settingsService;
    }

    public NavigationService getNavigationService() {
        return navigationService;
    }

}
package com.projectwizard.core.navigation;

import com.projectwizard.view.WorkspacePane;
import com.projectwizard.view.about.AboutView;
import com.projectwizard.view.dashboard.DashboardView;
import com.projectwizard.view.git.GitView;
import com.projectwizard.view.github.GitHubView;
import com.projectwizard.view.newproject.NewProjectView;
import com.projectwizard.view.openproject.OpenProjectView;
import com.projectwizard.view.settings.SettingsView;
import com.projectwizard.view.templates.TemplatesView;

public final class NavigationController {

    private static final NavigationController INSTANCE =
            new NavigationController();

    private WorkspacePane workspace;

    private NavigationController() {
    }

    public static NavigationController getInstance() {
        return INSTANCE;
    }

    public void setWorkspace(WorkspacePane workspace) {
        this.workspace = workspace;
    }

    public void navigate(NavigationTarget target) {

        if (workspace == null)
            return;

        switch (target) {

            case HOME ->
                    workspace.setContent(new DashboardView());

            case NEW_PROJECT ->
                    workspace.setContent(new NewProjectView());

            case OPEN_PROJECT ->
                    workspace.setContent(new OpenProjectView());

            case TEMPLATES ->
                    workspace.setContent(new TemplatesView());

            case GIT ->
                    workspace.setContent(new GitView());

            case GITHUB ->
                    workspace.setContent(new GitHubView());

            case SETTINGS ->
                    workspace.setContent(new SettingsView());

            case ABOUT ->
                    workspace.setContent(new AboutView());

        }

    }

}
package com.projectwizard.core.navigation;

public enum NavigationTarget {

    HOME,
    NEW_PROJECT,
    OPEN_PROJECT,
    TEMPLATES,
    GIT,
    GITHUB,
    SETTINGS,
    ABOUT

}
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
