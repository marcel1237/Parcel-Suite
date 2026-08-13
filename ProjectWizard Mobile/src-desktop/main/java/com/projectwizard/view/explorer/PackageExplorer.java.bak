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
