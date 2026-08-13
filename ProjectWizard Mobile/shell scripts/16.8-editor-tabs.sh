#!/usr/bin/env bash
set -Eeuo pipefail

#==============================================================================
# PROJECT WIZARD - STAGE 16.8 - EDITOR TABS
#==============================================================================
#
# Abre arquivos no editor com suporte a múltiplas abas (TabPane).
#
# Componentes:
# 1. EditorSupport   - utilitário compartilhado (leitura, extensões, tamanho)
# 2. EditorPane      - conteúdo de uma aba (um arquivo)
# 3. EditorHost      - TabPane com openFile(), abas fecháveis, sem duplicatas
# 4. ProjectWorkspace - double-click abre arquivo em aba
# 5. OpenProjectView  - preview em abas; remove alerta intrusivo de sucesso
#
# Pré-requisitos: 16.5C, 16.6, 16.7.x
#
# License: EPL-2.0 AND MPL-2.0 AND AGPL-3.0-only
#
#==============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

print_banner() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  ${PURPLE}STAGE 16.8 - EDITOR TABS${NC}                              ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  Abrir arquivos no editor com múltiplas abas           ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

check_environment() {
    if [ ! -f pom.xml ]; then
        echo -e "${RED}❌ Error: Execute na raiz do ProjectWizard${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Environment OK${NC}"
}

backup_file() {
    local file="$1"
    if [ -f "$file" ]; then
        cp "$file" "${file}.bak.16.8"
        echo -e "${YELLOW}  ↳ backup: ${file}.bak.16.8${NC}"
    fi
}

create_directories() {
    echo ""
    echo -e "${CYAN}▶ Criando diretórios...${NC}"
    mkdir -p src/main/java/com/projectwizard/view/editor
    echo -e "${GREEN}✓ Done${NC}"
}

#==============================================================================
# 1. EDITOR SUPPORT
#==============================================================================

create_editor_support() {
    echo ""
    echo -e "${CYAN}▶ [1/5] Criando EditorSupport...${NC}"

    cat > src/main/java/com/projectwizard/view/editor/EditorSupport.java <<'EOF'
package com.projectwizard.view.editor;

import java.io.File;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;

public final class EditorSupport {

    private static final String[] TEXT_EXTENSIONS = {
        ".java", ".xml", ".json", ".properties", ".yml", ".yaml",
        ".md", ".txt", ".html", ".fxml", ".css", ".scss", ".sql", ".sh",
        ".gradle", ".kt", ".groovy", ".toml", ".ini", ".cfg", ".log"
    };

    private static final int MAX_PREVIEW_CHARS = 50_000;

    private EditorSupport() {
    }

    public static boolean isTextFile(File file) {
        if (file == null) {
            return false;
        }
        String name = file.getName().toLowerCase();
        for (String ext : TEXT_EXTENSIONS) {
            if (name.endsWith(ext)) {
                return true;
            }
        }
        return false;
    }

    public static String readFileContent(File file) throws Exception {
        if (!isTextFile(file)) {
            return "[Binary file: " + file.getName() + "]";
        }
        String content = Files.readString(file.toPath(), StandardCharsets.UTF_8);
        if (content.length() > MAX_PREVIEW_CHARS) {
            int remaining = content.length() - MAX_PREVIEW_CHARS;
            content = content.substring(0, MAX_PREVIEW_CHARS)
                    + "\n\n... [Truncated: " + remaining + " chars] ...";
        }
        return content;
    }

    public static String formatSize(long bytes) {
        if (bytes <= 0) {
            return "0 B";
        }
        final String[] units = {"B", "KB", "MB", "GB"};
        int digitGroups = (int) (Math.log10(bytes) / Math.log10(1024));
        digitGroups = Math.min(digitGroups, units.length - 1);
        return String.format("%.1f %s", bytes / Math.pow(1024, digitGroups), units[digitGroups]);
    }

}
EOF

    echo -e "${GREEN}  ✓ EditorSupport.java${NC}"
}

#==============================================================================
# 2. EDITOR PANE (conteúdo de uma aba)
#==============================================================================

create_editor_pane() {
    echo -e "${CYAN}▶ [2/5] Criando EditorPane...${NC}"

    cat > src/main/java/com/projectwizard/view/editor/EditorPane.java <<'EOF'
package com.projectwizard.view.editor;

import java.io.File;

import javafx.scene.control.TextArea;
import javafx.scene.layout.BorderPane;

public class EditorPane extends BorderPane {

    private final File file;
    private final TextArea textArea;

    public EditorPane(File file, String content) {
        this.file = file;

        textArea = new TextArea(content != null ? content : "");
        textArea.setStyle("-fx-font-family: 'Courier New'; -fx-font-size: 12;");
        textArea.setWrapText(false);
        textArea.setEditable(false);

        setCenter(textArea);
    }

    public File getFile() {
        return file;
    }

    public String getTabLabel() {
        return file.getName();
    }

}
EOF

    echo -e "${GREEN}  ✓ EditorPane.java${NC}"
}

#==============================================================================
# 3. EDITOR HOST (TabPane)
#==============================================================================

create_editor_host() {
    echo -e "${CYAN}▶ [3/5] Atualizando EditorHost (TabPane)...${NC}"

    local file="src/main/java/com/projectwizard/view/editor/EditorHost.java"
    backup_file "$file"

    cat > "$file" <<'EOF'
package com.projectwizard.view.editor;

import java.io.File;
import java.util.LinkedHashMap;
import java.util.Map;

import javafx.geometry.Insets;
import javafx.scene.control.Label;
import javafx.scene.control.Tab;
import javafx.scene.control.TabPane;
import javafx.scene.control.TextArea;
import javafx.scene.layout.BorderPane;
import javafx.scene.layout.StackPane;
import javafx.scene.text.Font;
import javafx.scene.text.FontWeight;

public class EditorHost extends BorderPane {

    private final TabPane tabPane;
    private final Map<String, Tab> openTabs = new LinkedHashMap<>();
    private final StackPane emptyState;

    public EditorHost() {
        tabPane = new TabPane();
        tabPane.setTabClosingPolicy(TabPane.TabClosingPolicy.ALL_TABS);

        Label hint = new Label("Double-click a file in the explorer to open it here.");
        hint.setFont(Font.font("System", FontWeight.NORMAL, 13));
        hint.setStyle("-fx-text-fill: #888;");

        emptyState = new StackPane(hint);
        emptyState.setPadding(new Insets(40));
        emptyState.setStyle("-fx-background-color: #fafafa;");

        tabPane.getTabs().addListener((javafx.collections.ListChangeListener.Change<? extends Tab> change) -> {
            while (change.next()) {
                for (Tab removed : change.getRemoved()) {
                    Object path = removed.getUserData();
                    if (path instanceof String key) {
                        openTabs.remove(key);
                    }
                }
            }
            emptyState.setVisible(tabPane.getTabs().isEmpty());
        });

        StackPane root = new StackPane(tabPane, emptyState);
        setCenter(root);
    }

    public void openFile(File file) {
        if (file == null || !file.isFile()) {
            return;
        }

        String path = file.getAbsolutePath();

        if (openTabs.containsKey(path)) {
            tabPane.getSelectionModel().select(openTabs.get(path));
            return;
        }

        try {
            String content = EditorSupport.readFileContent(file);
            EditorPane pane = new EditorPane(file, content);

            Tab tab = new Tab(pane.getTabLabel(), pane);
            tab.setUserData(path);
            tab.setOnClosed(e -> openTabs.remove(path));

            openTabs.put(path, tab);
            tabPane.getTabs().add(tab);
            tabPane.getSelectionModel().select(tab);
            emptyState.setVisible(false);

        } catch (Exception e) {
            TextArea error = new TextArea("❌ Error opening file:\n" + e.getMessage());
            error.setEditable(false);
            error.setStyle("-fx-font-family: 'Courier New'; -fx-text-fill: #c62828;");

            Tab tab = new Tab(file.getName(), error);
            tab.setUserData(path);
            tab.setOnClosed(ev -> openTabs.remove(path));

            openTabs.put(path, tab);
            tabPane.getTabs().add(tab);
            tabPane.getSelectionModel().select(tab);
            emptyState.setVisible(false);
        }
    }

    public void clear() {
        tabPane.getTabs().clear();
        openTabs.clear();
        emptyState.setVisible(true);
    }

    public int getOpenTabCount() {
        return openTabs.size();
    }

}
EOF

    echo -e "${GREEN}  ✓ EditorHost.java${NC}"
}

#==============================================================================
# 4. PROJECT WORKSPACE
#==============================================================================

create_project_workspace() {
    echo -e "${CYAN}▶ [4/5] Atualizando ProjectWorkspace...${NC}"

    local file="src/main/java/com/projectwizard/workspace/ProjectWorkspace.java"
    backup_file "$file"

    cat > "$file" <<'EOF'
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
EOF

    echo -e "${GREEN}  ✓ ProjectWorkspace.java${NC}"
}

#==============================================================================
# 5. OPEN PROJECT VIEW
#==============================================================================

create_open_project_view() {
    echo -e "${CYAN}▶ [5/5] Atualizando OpenProjectView...${NC}"

    local file="src/main/java/com/projectwizard/view/openproject/OpenProjectView.java"
    backup_file "$file"

    cat > "$file" <<'EOF'
package com.projectwizard.view.openproject;

import java.io.File;

import javafx.geometry.Insets;
import javafx.scene.control.*;
import javafx.scene.layout.*;
import javafx.stage.DirectoryChooser;
import javafx.stage.Window;

import com.projectwizard.view.explorer.PackageExplorer;
import com.projectwizard.view.explorer.FileTreeCell;
import com.projectwizard.view.editor.EditorHost;
import com.projectwizard.view.editor.EditorSupport;
import com.projectwizard.service.git.GitService;
import com.projectwizard.core.navigation.NavigationController;
import com.projectwizard.core.navigation.NavigationTarget;

public class OpenProjectView extends BorderPane {

    private final TextField pathField = new TextField();
    private final Button browseButton = new Button("Browse...");
    private final Button openButton = new Button("Open");
    private final Button cancelButton = new Button("Cancel");
    private File selectedDirectory;
    private final PackageExplorer explorer = new PackageExplorer();
    private final TextArea info = new TextArea();
    private final EditorHost editorHost = new EditorHost();
    private GitService gitService;

    public OpenProjectView() {
        setPadding(new Insets(20));

        Label title = new Label("Open Project");
        title.setStyle("-fx-font-size:26px;-fx-font-weight:bold;");

        pathField.setPromptText("Choose a project folder...");
        pathField.setEditable(false);

        HBox pathBox = new HBox(10, pathField, browseButton);
        HBox.setHgrow(pathField, Priority.ALWAYS);

        info.setEditable(false);
        info.setText("Choose a folder to continue.");
        info.setWrapText(true);
        VBox.setVgrow(info, Priority.ALWAYS);

        openButton.setDisable(true);
        browseButton.setOnAction(e -> handleBrowse());
        openButton.setOnAction(e -> handleOpen());
        cancelButton.setOnAction(e -> handleCancel());

        HBox buttons = new HBox(10, openButton, cancelButton);
        VBox center = new VBox(20, title, pathBox, info, buttons);

        TabPane tabPane = new TabPane();
        tabPane.setTabClosingPolicy(TabPane.TabClosingPolicy.UNAVAILABLE);
        tabPane.getTabs().addAll(
            new Tab("📁 Explorer", explorer),
            new Tab("📝 Editor", editorHost)
        );

        SplitPane split = new SplitPane();
        split.getItems().addAll(tabPane, center);
        split.setDividerPositions(0.40);

        setCenter(split);
        setupDoubleClickHandler();
    }

    private void handleBrowse() {
        Window window = getScene().getWindow();
        DirectoryChooser chooser = new DirectoryChooser();
        chooser.setTitle("Open Project Folder");

        File dir = chooser.showDialog(window);
        if (dir != null) {
            selectedDirectory = dir;
            gitService = new GitService(dir);

            explorer.setCellFactory(v -> new FileTreeCell());
            explorer.openProject(dir);
            pathField.setText(dir.getAbsolutePath());

            info.setText("Folder selected:\n\n" + dir.getAbsolutePath()
                    + "\n\n" + gitService.getRepositoryInfo()
                    + "\n\n💡 Double-click files to preview in tabs. Click Open to load workspace!");

            openButton.setDisable(false);
        }
    }

    private void handleOpen() {
        if (selectedDirectory == null) {
            showAlert("Error", "No folder selected!", Alert.AlertType.ERROR);
            return;
        }

        try {
            NavigationController.getInstance()
                    .navigateWithProject(NavigationTarget.WORKSPACE, selectedDirectory);
        } catch (Exception e) {
            showAlert("Error", "Failed: " + e.getMessage(), Alert.AlertType.ERROR);
        }
    }

    private void handleCancel() {
        pathField.clear();
        selectedDirectory = null;
        openButton.setDisable(true);
        info.setText("Choose a folder to continue.");
        explorer.setRoot(null);
        editorHost.clear();
    }

    private void setupDoubleClickHandler() {
        explorer.setOnMouseClicked(event -> {
            if (event.getClickCount() == 2) {
                TreeItem<File> selected = explorer.getSelectionModel().getSelectedItem();
                if (selected != null && selected.getValue() != null && selected.getValue().isFile()) {
                    File file = selected.getValue();
                    if (EditorSupport.isTextFile(file)) {
                        editorHost.openFile(file);
                        info.setText("📄 " + file.getName()
                                + "\n📍 " + file.getAbsolutePath()
                                + "\n📑 Tabs open: " + editorHost.getOpenTabCount());
                    }
                }
            }
        });
    }

    private void showAlert(String title, String message, Alert.AlertType type) {
        Alert alert = new Alert(type);
        alert.setTitle(title);
        alert.setHeaderText(null);
        alert.setContentText(message);
        alert.showAndWait();
    }

}
EOF

    echo -e "${GREEN}  ✓ OpenProjectView.java${NC}"
}

#==============================================================================
# COMPILE
#==============================================================================

compile_project() {
    echo ""
    echo -e "${CYAN}▶ Compilando...${NC}"
    if mvn -q compile; then
        echo -e "${GREEN}✓ Compilação OK${NC}"
    else
        echo -e "${RED}❌ Falha na compilação. Verifique os erros acima.${NC}"
        exit 1
    fi
}

#==============================================================================
# SUMMARY
#==============================================================================

print_summary() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  ${GREEN}✅ STAGE 16.8 - EDITOR TABS READY${NC}                     ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}✓ Novos / atualizados:${NC}"
    echo -e "  [✓] EditorSupport.java  - leitura UTF-8, extensões, truncamento"
    echo -e "  [✓] EditorPane.java     - conteúdo de uma aba"
    echo -e "  [✓] EditorHost.java     - TabPane, openFile(), abas fecháveis"
    echo -e "  [✓] ProjectWorkspace    - double-click → aba no editor"
    echo -e "  [✓] OpenProjectView     - preview em abas, sem alerta de sucesso"
    echo ""
    echo -e "${PURPLE}🚀 TESTE:${NC}"
    echo -e "  mvn clean javafx:run"
    echo -e "  → Open Project → Browse → double-click em arquivos .java"
    echo -e "  → Abas aparecem no editor; reabrir mesmo arquivo foca a aba existente"
    echo -e "  → Open → workspace com explorer + editor em abas"
    echo ""
}

main() {
    print_banner
    check_environment
    create_directories
    create_editor_support
    create_editor_pane
    create_editor_host
    create_project_workspace
    create_open_project_view
    compile_project
    print_summary
}

main
