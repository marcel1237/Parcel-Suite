#!/usr/bin/env bash
set -Eeuo pipefail

echo "========================================="
echo " Project Wizard - Etapa 16.5C FINAL"
echo " Unificação: Editor + Explorer + Ícones"
echo "========================================="

# Verificação de diretório
if [ ! -f pom.xml ]; then
    echo "Execute este script dentro da pasta raiz do ProjectWizard."
    exit 1
fi

# Criação de estrutura
mkdir -p src/main/java/com/projectwizard/view/editor
mkdir -p src/main/java/com/projectwizard/view/explorer
mkdir -p src/main/java/com/projectwizard/view/openproject

echo "[1/5] Criando EditorHost (Sistema de Abas)..."
cat > src/main/java/com/projectwizard/view/editor/EditorHost.java <<'EOF'
package com.projectwizard.view.editor;

import javafx.scene.control.Tab;
import javafx.scene.control.TabPane;
import javafx.scene.layout.Priority;
import javafx.scene.layout.VBox;

public class EditorHost extends TabPane {
    public EditorHost() {
        setTabClosingPolicy(TabClosingPolicy.ALL_TABS);
        VBox.setVgrow(this, Priority.ALWAYS);
    }

    public void openFile(String fileName, String content) {
        Tab tab = new Tab(fileName);
        tab.setContent(new javafx.scene.control.TextArea(content));
        getTabs().add(tab);
        getSelectionModel().select(tab);
    }
}
EOF

echo "[2/5] Atualizando PackageExplorer (Lazy Loading + Filtros)..."
cat > src/main/java/com/projectwizard/view/explorer/PackageExplorer.java <<'EOF'
package com.projectwizard.view.explorer;

import java.io.File;
import java.util.Arrays;
import javafx.scene.control.TreeItem;
import javafx.scene.control.TreeView;

public class PackageExplorer extends TreeView<File> {
    public PackageExplorer() {
        setShowRoot(true);
    }

    public void openProject(File root) {
        TreeItem<File> rootItem = createNode(root);
        rootItem.setExpanded(true);
        setRoot(rootItem);
    }

    private TreeItem<File> createNode(File f) {
        return new TreeItem<File>(f) {
            private boolean isFirstChildren = true;
            private boolean isFirstLeaf = true;
            private boolean isLeaf;

            @Override public boolean isLeaf() {
                if (isFirstLeaf) {
                    isFirstLeaf = false;
                    isLeaf = getValue().isFile();
                }
                return isLeaf;
            }

            @Override public javafx.collections.ObservableList<TreeItem<File>> getChildren() {
                if (isFirstChildren) {
                    isFirstChildren = false;
                    super.getChildren().setAll(buildChildren(this));
                }
                return super.getChildren();
            }

            private javafx.collections.ObservableList<TreeItem<File>> buildChildren(TreeItem<File> TreeItem) {
                File f = TreeItem.getValue();
                if (f != null && f.isDirectory()) {
                    File[] files = f.listFiles(file -> !file.getName().startsWith(".") 
                        && !file.getName().equals("target") 
                        && !file.getName().equals("node_modules"));
                    if (files != null) {
                        Arrays.sort(files, (a, b) -> {
                            if (a.isDirectory() && !b.isDirectory()) return -1;
                            if (!a.isDirectory() && b.isDirectory()) return 1;
                            return a.getName().compareToIgnoreCase(b.getName());
                        });
                        javafx.collections.ObservableList<TreeItem<File>> children = javafx.collections.FXCollections.observableArrayList();
                        for (File childFile : files) {
                            children.add(createNode(childFile));
                        }
                        return children;
                    }
                }
                return javafx.collections.FXCollections.emptyObservableList();
            }
        };
    }
}
EOF

echo "[3/5] Atualizando FileTreeCell (Ícones e Estilo)..."
cat > src/main/java/com/projectwizard/view/explorer/FileTreeCell.java <<'EOF'
package com.projectwizard.view.explorer;

import java.io.File;
import javafx.scene.control.TreeCell;
import javafx.scene.text.Text;

public class FileTreeCell extends TreeCell<File> {
    @Override
    protected void updateItem(File item, boolean empty) {
        super.updateItem(item, empty);
        if (empty || item == null) {
            setText(null);
            setGraphic(null);
        } else {
            String icon = item.isDirectory() ? "📁 " : getFileIcon(item.getName());
            setText(icon + item.getName());
        }
    }

    private String getFileIcon(String name) {
        if (name.endsWith(".java")) return "☕ ";
        if (name.endsWith(".xml") || name.endsWith(".pom")) return "📦 ";
        if (name.endsWith(".sh")) return "🐚 ";
        if (name.endsWith(".md")) return "📝 ";
        return "📄 ";
    }
}
EOF

echo "[4/5] Integrando WorkspacePane com EditorHost..."
python3 <<'PY'
from pathlib import Path
p = Path("src/main/java/com/projectwizard/view/WorkspacePane.java")
txt = p.read_text()
if "EditorHost" not in txt:
    txt = txt.replace("import javafx.scene.layout.BorderPane;", 
                      "import javafx.scene.layout.BorderPane;\nimport com.projectwizard.view.editor.EditorHost;")
    txt = txt.replace("public class WorkspacePane extends BorderPane {", 
                      "public class WorkspacePane extends BorderPane {\n    private EditorHost editorHost = new EditorHost();")
p.write_text(txt)
PY

echo "[5/5] Finalizando OpenProjectView (Lógica Real de Abertura)..."
cat > src/main/java/com/projectwizard/view/openproject/OpenProjectView.java <<'EOF'
package com.projectwizard.view.openproject;

import java.io.File;
import javafx.geometry.Insets;
import javafx.scene.control.*;
import javafx.scene.layout.*;
import javafx.stage.DirectoryChooser;
import com.projectwizard.view.explorer.PackageExplorer;
import com.projectwizard.view.explorer.FileTreeCell;

public class OpenProjectView extends BorderPane {
    private final PackageExplorer explorer = new PackageExplorer();
    private final StackPane centerArea = new StackPane(new Label("Selecione um arquivo para editar"));

    public OpenProjectView() {
        setPadding(new Insets(10));
        
        // Toolbar de seleção
        HBox topBar = new HBox(10);
        TextField pathField = new TextField();
        pathField.setEditable(false);
        HBox.setHgrow(pathField, Priority.ALWAYS);
        
        Button btnBrowse = new Button("Browse...");
        Button btnOpen = new Button("Open Project");
        btnOpen.setDisable(true);

        btnBrowse.setOnAction(e -> {
            File dir = new DirectoryChooser().showDialog(getScene().getWindow());
            if (dir != null) {
                pathField.setText(dir.getAbsolutePath());
                btnOpen.setDisable(false);
            }
        });

        btnOpen.setOnAction(e -> {
            File selected = new File(pathField.getText());
            explorer.setCellFactory(v -> new FileTreeCell());
            explorer.openProject(selected);
            System.out.println("[EXPLORER] Projeto carregado: " + selected.getName());
        });

        topBar.getChildren().addAll(new Label("Project Path:"), pathField, btnBrowse, btnOpen);
        setTop(topBar);
        BorderPane.setMargin(topBar, new Insets(0, 0, 10, 0));

        // Layout principal com SplitPane
        SplitPane split = new SplitPane();
        split.getItems().addAll(explorer, centerArea);
        split.setDividerPositions(0.30);
        setCenter(split);
    }
}
EOF

echo "========================================="
echo " 🎉 ETAPA 16.5C CONCLUÍDA COM SUCESSO!"
echo "========================================="
echo "Novidades unificadas:"
echo "✔ EditorHost preparado para abas [1]"
echo "✔ PackageExplorer com Lazy Loading e ícones [4, 5]"
echo "✔ Lógica de 'Alert' removida e projeto abrindo real [6]"
echo "========================================="
echo "🚀 Execute: mvn clean javafx:run"