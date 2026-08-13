#!/usr/bin/env bash
set -Eeuo pipefail

echo "========================================="
echo " Project Wizard - Etapa 17.3 FINAL"
echo " Sincronização Geral e Limpeza de Símbolos"
echo "========================================="

# 1. Restaurar ApplicationContext com Singleton e Metadados exigidos
echo "[1/5] Corrigindo ApplicationContext..."
cat > src/main/java/com/projectwizard/core/ApplicationContext.java <<'EOF'
package com.projectwizard.core;

import com.projectwizard.service.*;

public class ApplicationContext {
    private static ApplicationContext instance;
    private final ProjectService projectService = new ProjectService();
    private final FileSystemService fileSystemService = new FileSystemService();
    private final DialogService dialogService = new DialogService();

    private ApplicationContext() {}

    public static synchronized ApplicationContext getInstance() {
        if (instance == null) instance = new ApplicationContext();
        return instance;
    }

    public String getApplicationName() { return "Project Wizard"; }
    public String getVersion() { return "1.0.0"; }
    
    public ProjectService getProjectService() { return projectService; }
    public FileSystemService getFileSystemService() { return fileSystemService; }
    public DialogService getDialogService() { return dialogService; }
}
EOF

# 2. Corrigir DialogService para suportar a assinatura showError(String, String)
echo "[2/5] Atualizando DialogService..."
cat > src/main/java/com/projectwizard/service/DialogService.java <<'EOF'
package com.projectwizard.service;

import javafx.scene.control.Alert;
import javafx.scene.control.Alert.AlertType;

public class DialogService {
    public void showError(String title, String message) {
        Alert alert = new Alert(AlertType.ERROR);
        alert.setTitle(title);
        alert.setHeaderText(null);
        alert.setContentText(message);
        alert.showAndWait();
    }
    
    public void showInfo(String title, String message) {
        Alert alert = new Alert(AlertType.INFORMATION);
        alert.setTitle(title);
        alert.setHeaderText(null);
        alert.setContentText(message);
        alert.showAndWait();
    }
}
EOF

# 3. Limpar EditorPane (Declarar 'editor' e remover duplicatas de getFile)
echo "[3/5] Reconstruindo EditorPane..."
cat > src/main/java/com/projectwizard/view/editor/EditorPane.java <<'EOF'
package com.projectwizard.view.editor;

import java.io.File;
import javafx.scene.control.TextArea;
import javafx.scene.layout.BorderPane;

public class EditorPane extends BorderPane {
    private final TextArea editor = new TextArea();
    private File currentFile;

    public EditorPane(File file, String content) {
        this.currentFile = file;
        editor.setText(content);
        editor.setStyle("-fx-font-family: 'Consolas', 'Monospace'; -fx-font-size: 13px;");
        setCenter(editor);
    }

    public String getText() { return editor.getText(); }
    public File getFile() { return currentFile; }
}
EOF

# 4. Corrigir EditorHost (Declarar tabPane e ajustar lógica de pattern matching)
echo "[4/5] Corrigindo EditorHost..."
cat > src/main/java/com/projectwizard/view/editor/EditorHost.java <<'EOF'
package com.projectwizard.view.editor;

import javafx.scene.control.*;
import javafx.scene.layout.*;
import javafx.stage.FileChooser;
import java.io.File;
import com.projectwizard.core.ApplicationContext;

public class EditorHost extends BorderPane {
    private final TabPane tabPane = new TabPane();

    public EditorHost() {
        tabPane.setTabClosingPolicy(TabPane.TabClosingPolicy.ALL_TABS);
        setupToolBar();
        setCenter(tabPane);
    }

    private void setupToolBar() {
        Button btnSave = new Button("💾 Save");
        Button btnSaveAs = new Button("📂 Save As...");
        btnSave.setOnAction(e -> handleSave());
        btnSaveAs.setOnAction(e -> handleSaveAs());
        setTop(new ToolBar(btnSave, btnSaveAs));
    }

    private void handleSave() {
        Tab selected = tabPane.getSelectionModel().getSelectedItem();
        if (selected != null && selected.getContent() instanceof EditorPane pane) {
            try {
                ApplicationContext.getInstance().getFileSystemService().saveFile(pane.getFile(), pane.getText());
                System.out.println("[SAVE] Arquivo salvo: " + pane.getFile().getName());
            } catch (Exception ex) {
                ApplicationContext.getInstance().getDialogService().showError("Error", ex.getMessage());
            }
        }
    }

    private void handleSaveAs() {
        Tab selected = tabPane.getSelectionModel().getSelectedItem();
        if (selected != null && selected.getContent() instanceof EditorPane pane) {
            FileChooser chooser = new FileChooser();
            File file = chooser.showSaveDialog(getScene().getWindow());
            if (file != null) {
                try {
                    ApplicationContext.getInstance().getFileSystemService().saveFile(file, pane.getText());
                    selected.setText(file.getName());
                } catch (Exception ex) {
                    ApplicationContext.getInstance().getDialogService().showError("Error", ex.getMessage());
                }
            }
        }
    }

    public void openFile(File file, String content) {
        Tab tab = new Tab(file.getName());
        tab.setContent(new EditorPane(file, content));
        tabPane.getTabs().add(tab);
        tabPane.getSelectionModel().select(tab);
    }
}
EOF

# 5. Ajustar MainWindow e StatusBar para usar o Singleton getInstance()
echo "[5/5] Corrigindo chamadas de Singleton..."
sed -i 's/new ApplicationContext()/ApplicationContext.getInstance()/g' src/main/java/com/projectwizard/view/MainWindow.java
sed -i 's/new ApplicationContext()/ApplicationContext.getInstance()/g' src/main/java/com/projectwizard/view/StatusBar.java

echo "========================================="
echo " 🎉 CORREÇÃO CONCLUÍDA!"
echo "========================================="
echo "🚀 Execute: mvn clean compile"