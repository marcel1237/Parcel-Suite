package com.projectwizard.workspace;

import java.io.File;

import javafx.geometry.Insets;
import javafx.scene.control.SplitPane;
import javafx.scene.control.TreeItem;
import javafx.scene.layout.BorderPane;

import com.projectwizard.model.Project;
import com.projectwizard.view.editor.EditorHost;
import com.projectwizard.view.editor.EditorSupport;
import com.projectwizard.view.explorer.PackageExplorer;
import com.projectwizard.view.explorer.FileTreeCell;

public class ProjectWorkspace extends BorderPane {

    private Project currentProject;
    private PackageExplorer explorer;
    private EditorHost editor;
    private ProjectHeader header;

    public ProjectWorkspace() {
        setPadding(new Insets(0));
    }

    public void loadProject(File projectRoot) {
        currentProject = new Project(projectRoot);
        header = new ProjectHeader(currentProject);
        setTop(header);

        explorer = new PackageExplorer();
        explorer.setCellFactory(v -> new FileTreeCell());
        explorer.openProject(projectRoot);

        editor = new EditorHost();
        setupFileOpenHandler();

        SplitPane splitPane = new SplitPane();
        splitPane.getItems().addAll(explorer, editor);
        splitPane.setDividerPositions(0.25);

        setCenter(splitPane);
    }

    private void setupFileOpenHandler() {
        explorer.setOnMouseClicked(event -> {
            if (event.getClickCount() == 2) {
                TreeItem<File> selected = explorer.getSelectionModel().getSelectedItem();
                if (selected != null && selected.getValue() != null) {
                    File file = selected.getValue();
                    if (file.isFile() && EditorSupport.isTextFile(file)) {
                        editor.openFile(file);
                    }
                }
            }
        });
    }

    public Project getCurrentProject() {
        return currentProject;
    }

}
