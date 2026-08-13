#!/usr/bin/env bash
set -Eeuo pipefail

echo "========================================="
echo " Project Wizard - Etapa 16.5C"
echo " Enhanced Open Folder with Lazy Loading"
echo " File Icons, Filtering & Double-Click"
echo "========================================="

if [ ! -f pom.xml ]; then
    echo "Execute este script dentro da pasta ProjectWizard."
    exit 1
fi

# Create directory structure if needed
mkdir -p src/main/java/com/projectwizard/view/openproject
mkdir -p src/main/java/com/projectwizard/view/explorer

# ============================================================
# 1. Enhanced PackageExplorer with Lazy Loading & Filtering
# ============================================================

EXPLORER_FILE="src/main/java/com/projectwizard/view/explorer/PackageExplorer.java"
cp "$EXPLORER_FILE" "$EXPLORER_FILE.pre16_5C"

cat > "$EXPLORER_FILE" <<'EOF'
package com.projectwizard.view.explorer;

import java.io.File;
import java.util.Arrays;

import javafx.scene.control.TreeItem;
import javafx.scene.control.TreeView;

public class PackageExplorer extends TreeView<File> {

    private static final String[] FILTERED_NAMES = {
        ".git", ".gitignore", "target", "node_modules", ".idea", 
        "build", ".vscode", ".DS_Store", "*.class"
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

        // Listen for expansion events for lazy loading
        root.expandedProperty().addListener((obs, oldVal, newVal) -> {
            if (newVal && root.getChildren().size() == 1) {
                TreeItem<File> placeholder = root.getChildren().get(0);
                if (placeholder.getValue() == null) {
                    root.getChildren().clear();
                    loadChildren(root);
                }
            }
        });
    }

    private TreeItem<File> create(File file) {
        TreeItem<File> item = new TreeItem<>(file);

        if (file.isDirectory()) {
            File[] files = listFilteredFiles(file);

            if (files != null && files.length > 0) {
                // Add placeholder for lazy loading
                item.getChildren().add(
                    new TreeItem<File>(null) {
                        @Override
                        public String toString() {
                            return "Loading...";
                        }
                    }
                );

                // Setup lazy loading listener
                item.expandedProperty().addListener((obs, oldVal, newVal) -> {
                    if (newVal && item.getChildren().size() == 1) {
                        TreeItem<File> placeholder = item.getChildren().get(0);
                        if (placeholder.getValue() == null) {
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

        // Filter out unwanted files/folders
        File[] filtered = Arrays.stream(files)
            .filter(f -> !shouldFilter(f.getName()))
            .sorted()
            .toArray(File[]::new);

        return filtered.length > 0 ? filtered : null;
    }

    private boolean shouldFilter(String name) {
        for (String filter : FILTERED_NAMES) {
            if (filter.startsWith("*")) {
                // Handle wildcard like *.class
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
EOF

echo "✔ PackageExplorer.java enhanced"

# ============================================================
# 2. Enhanced FileTreeCell with Icons
# ============================================================

CELL_FILE="src/main/java/com/projectwizard/view/explorer/FileTreeCell.java"
cp "$CELL_FILE" "$CELL_FILE.pre16_5C"

cat > "$CELL_FILE" <<'EOF'
package com.projectwizard.view.explorer;

import java.io.File;

import javafx.scene.control.TreeCell;
import javafx.scene.text.Text;
import javafx.scene.layout.HBox;
import javafx.geometry.Insets;

public class FileTreeCell extends TreeCell<File> {

    @Override
    protected void updateItem(File item, boolean empty) {
        super.updateItem(item, empty);

        if (empty || item == null) {
            setText(null);
            setGraphic(null);
        } else {
            String displayName = item.getName().isBlank()
                    ? item.getAbsolutePath()
                    : item.getName();

            // Add icon based on file type
            String icon = getIcon(item);
            Text iconText = new Text(icon);
            iconText.setStyle("-fx-font-size: 14px;");

            HBox hbox = new HBox(8, iconText, new Text(displayName));
            hbox.setPadding(new Insets(2));

            setGraphic(hbox);
            setText(null);
        }
    }

    private String getIcon(File file) {
        if (file == null)
            return "❓";

        if (file.isDirectory()) {
            return "📁";
        }

        String name = file.getName().toLowerCase();

        if (name.endsWith(".java"))
            return "☕";
        if (name.endsWith(".class"))
            return "🔶";
        if (name.endsWith(".jar"))
            return "📦";
        if (name.endsWith(".xml") || name.endsWith(".pom"))
            return "⚙";
        if (name.endsWith(".json"))
            return "📋";
        if (name.endsWith(".md") || name.endsWith(".txt"))
            return "📄";
        if (name.endsWith(".yml") || name.endsWith(".yaml"))
            return "⚙";
        if (name.endsWith(".properties"))
            return "🔧";
        if (name.endsWith(".css") || name.endsWith(".scss"))
            return "🎨";
        if (name.endsWith(".html") || name.endsWith(".fxml"))
            return "🌐";
        if (name.endsWith(".sql"))
            return "🗄";
        if (name.endsWith(".sh") || name.endsWith(".bat"))
            return "⚡";
        if (name.endsWith(".git"))
            return "🌿";

        return "📄";
    }

}
EOF

echo "✔ FileTreeCell.java enhanced with icons"

# ============================================================
# 3. Enhanced OpenProjectView with Double-Click Handler
# ============================================================

OPENPROJECT_FILE="src/main/java/com/projectwizard/view/openproject/OpenProjectView.java"
cp "$OPENPROJECT_FILE" "$OPENPROJECT_FILE.pre16_5C"

cat > "$OPENPROJECT_FILE" <<'EOF'
package com.projectwizard.view.openproject;

import java.io.File;
import java.nio.file.Files;

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
    private final PackageExplorer explorer = new PackageExplorer();
    private final TextArea info = new TextArea();

    public OpenProjectView() {
        setPadding(new Insets(20));

        ////////////////////////////////////////////////////////
        // TITLE
        ////////////////////////////////////////////////////////

        Label title = new Label("Open Project");
        title.setStyle(
                "-fx-font-size:26px;" +
                "-fx-font-weight:bold;"
        );

        ////////////////////////////////////////////////////////
        // PATH SELECTION
        ////////////////////////////////////////////////////////

        pathField.setPromptText("Choose a project folder...");
        pathField.setEditable(false);

        HBox pathBox = new HBox(10, pathField, browseButton);
        HBox.setHgrow(pathField, Priority.ALWAYS);

        ////////////////////////////////////////////////////////
        // INFO PANEL
        ////////////////////////////////////////////////////////

        info.setEditable(false);
        info.setText("Choose a folder to continue.");
        info.setWrapText(true);
        VBox.setVgrow(info, Priority.ALWAYS);

        ////////////////////////////////////////////////////////
        // BUTTONS
        ////////////////////////////////////////////////////////

        openButton.setDisable(true);

        browseButton.setOnAction(e -> handleBrowse());
        openButton.setOnAction(e -> handleOpen());
        cancelButton.setOnAction(e -> handleCancel());

        HBox buttons = new HBox(10, openButton, cancelButton);

        ////////////////////////////////////////////////////////
        // CENTER PANEL
        ////////////////////////////////////////////////////////

        VBox center = new VBox(
                20,
                title,
                pathBox,
                info,
                buttons
        );

        ////////////////////////////////////////////////////////
        // MAIN LAYOUT (Split between explorer and controls)
        ////////////////////////////////////////////////////////

        SplitPane split = new SplitPane();
        split.getItems().addAll(explorer, center);
        split.setDividerPositions(0.30);

        setCenter(split);

        ////////////////////////////////////////////////////////
        // DOUBLE-CLICK HANDLER
        ////////////////////////////////////////////////////////

        setupDoubleClickHandler();
    }

    private void handleBrowse() {
        Window window = getScene().getWindow();

        DirectoryChooser chooser = new DirectoryChooser();
        chooser.setTitle("Open Project Folder");

        File dir = chooser.showDialog(window);

        if (dir != null) {
            selectedDirectory = dir;

            // Set up tree cell factory
            explorer.setCellFactory(v -> new FileTreeCell());

            // Open project in tree
            explorer.openProject(dir);

            // Update UI
            pathField.setText(dir.getAbsolutePath());
            info.setText("Folder selected:\n\n" + dir.getAbsolutePath()
                    + "\n\nDouble-click any file to preview.");

            openButton.setDisable(false);
        }
    }

    private void handleOpen() {
        if (selectedDirectory == null)
            return;

        System.out.println("[PROJECT] " + selectedDirectory.getAbsolutePath());

        Alert alert = new Alert(Alert.AlertType.INFORMATION);
        alert.setTitle("Project Wizard");
        alert.setHeaderText("Folder Selected");
        alert.setContentText(selectedDirectory.getAbsolutePath());
        alert.showAndWait();
    }

    private void handleCancel() {
        pathField.clear();
        selectedDirectory = null;
        openButton.setDisable(true);
        info.setText("Choose a folder to continue.");
        explorer.setRoot(null);
    }

    private void setupDoubleClickHandler() {
        explorer.setOnMouseClicked(event -> {
            if (event.getClickCount() == 2) {
                TreeItem<File> selected = explorer.getSelectionModel().getSelectedItem();

                if (selected != null && selected.getValue() != null) {
                    File file = selected.getValue();

                    if (file.isFile()) {
                        previewFile(file);
                    }
                }
            }
        });
    }

    private void previewFile(File file) {
        try {
            // Only preview text files (not binary)
            if (isTextFile(file)) {
                String content = new String(Files.readAllBytes(file.toPath()));

                // Limit preview to first 1000 characters
                if (content.length() > 1000) {
                    content = content.substring(0, 1000) + "\n\n[... truncated ...]";
                }

                info.setText(
                        "File: " + file.getName() + "\n" +
                        "Path: " + file.getAbsolutePath() + "\n" +
                        "Size: " + file.length() + " bytes\n\n" +
                        "--- PREVIEW ---\n\n" +
                        content
                );
            } else {
                info.setText(
                        "File: " + file.getName() + "\n" +
                        "Path: " + file.getAbsolutePath() + "\n" +
                        "Size: " + file.length() + " bytes\n\n" +
                        "[Binary file - cannot preview]"
                );
            }
        } catch (Exception e) {
            info.setText("Error reading file:\n" + e.getMessage());
        }
    }

    private boolean isTextFile(File file) {
        String name = file.getName().toLowerCase();
        String[] textExtensions = {
            ".java", ".xml", ".json", ".properties", ".yml", ".yaml",
            ".md", ".txt", ".html", ".fxml", ".css", ".sql", ".sh", ".bat"
        };

        for (String ext : textExtensions) {
            if (name.endsWith(ext))
                return true;
        }

        return false;
    }

}
EOF

echo "✔ OpenProjectView.java enhanced with double-click preview"

# ============================================================
# SUCCESS MESSAGE
# ============================================================

echo
echo "========================================="
echo "Etapa 16.5C concluída com sucesso!"
echo "========================================="
echo
echo "🎉 Novidades:"
echo
echo "✔ PackageExplorer com lazy loading"
echo "✔ Filtragem automática (.git, target, node_modules, etc)"
echo "✔ Ícones de arquivo por tipo (☕ Java, 📦 JAR, 🗄 SQL, etc)"
echo "✔ Double-click para visualizar preview de arquivos"
echo "✔ Limite de preview (primeiros 1000 chars para performance)"
echo "✔ Suporte a detecção de arquivos binários"
echo
echo "📋 Arquivos modificados:"
echo "  - PackageExplorer.java"
echo "  - FileTreeCell.java"
echo "  - OpenProjectView.java"
echo
echo "🚀 Execute:"
echo
echo "mvn clean javafx:run"
echo