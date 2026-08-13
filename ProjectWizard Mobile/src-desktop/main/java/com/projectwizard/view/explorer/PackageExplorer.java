package com.projectwizard.view.explorer;

import java.io.File;
import java.util.Arrays;

import javafx.scene.control.TreeItem;
import javafx.scene.control.TreeView;

/**
 * Enhanced PackageExplorer with Lazy Loading and Smart Filtering
 * 
 * Features:
 * - Lazy loads folders on expand
 * - Auto-filters build artifacts
 * - Alphabetically sorted
 * - Supports large projects
 */
public class PackageExplorer extends TreeView<File> {

    private static final String[] FILTERED_NAMES = {
        ".git", ".gitignore", ".github", ".gitlab-ci.yml",
        "target", "node_modules", ".idea", "build", ".gradle",
        ".vscode", ".DS_Store", "*.class", "dist", "out", "bin",
        ".settings", ".classpath", ".project", ".mvn", "pom.xml.bak"
    };

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
            File[] files = listFilteredFiles(file);

            if (files != null && files.length > 0) {
                TreeItem<File> placeholder = new TreeItem<File>(null) {
                    @Override
                    public String toString() {
                        return "Loading...";
                    }
                };
                item.getChildren().add(placeholder);

                item.expandedProperty().addListener((obs, oldVal, newVal) -> {
                    if (newVal && item.getChildren().size() == 1) {
                        TreeItem<File> ph = item.getChildren().get(0);
                        if (ph.getValue() == null) {
                            item.getChildren().clear();
                            loadChildren(item);
                        }
                    }
                });
            }
        }

        return item;
    }

    private void loadChildren(TreeItem<File> parent) {
        File[] files = listFilteredFiles(parent.getValue());

        if (files != null) {
            for (File child : files) {
                parent.getChildren().add(create(child));
            }
        }
    }

    private File[] listFilteredFiles(File directory) {
        if (directory == null)
            return null;

        File[] files = directory.listFiles();
        if (files == null)
            return null;

        File[] filtered = Arrays.stream(files)
            .filter(f -> !shouldFilter(f.getName()))
            .sorted()
            .toArray(File[]::new);

        return filtered.length > 0 ? filtered : null;
    }

    private boolean shouldFilter(String name) {
        for (String filter : FILTERED_NAMES) {
            if (filter.startsWith("*")) {
                String ext = filter.substring(1);
                if (name.endsWith(ext))
                    return true;
            } else if (name.equals(filter) || name.startsWith(filter)) {
                return true;
            }
        }
        return false;
    }

}
