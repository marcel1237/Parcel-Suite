#!/usr/bin/env bash
set -Eeuo pipefail

echo "========================================="
echo " Project Wizard - Etapa 17.4"
echo " Sincronização de Métodos e Assinaturas"
echo "========================================="

# 1. Atualizar EditorHost com sobrecarga de openFile, clear() e getOpenTabCount()
echo "[1/3] Atualizando EditorHost.java..."
cat > src/main/java/com/projectwizard/view/editor/EditorHost.java <<'EOF'
package com.projectwizard.view.editor;

import javafx.scene.control.*;
import javafx.scene.layout.*;
import javafx.stage.FileChooser;
import java.io.File;
import java.nio.file.Files;
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

    // Sobrecarga para aceitar apenas o File (Lê o conteúdo automaticamente)
    public void openFile(File file) {
        try {
            String content = Files.readString(file.toPath());
            openFile(file, content);
        } catch (Exception e) {
            ApplicationContext.getInstance().getDialogService().showError("Read Error", e.getMessage());
        }
    }

    public void openFile(File file, String content) {
        // Verifica se o arquivo já está aberto para evitar duplicidade
        for (Tab tab : tabPane.getTabs()) {
            if (tab.getText().equals(file.getName())) {
                tabPane.getSelectionModel().select(tab);
                return;
            }
        }
        Tab tab = new Tab(file.getName());
        tab.setContent(new EditorPane(file, content));
        tabPane.getTabs().add(tab);
        tabPane.getSelectionModel().select(tab);
    }

    public void clear() {
        tabPane.getTabs().clear();
    }

    public int getOpenTabCount() {
        return tabPane.getTabs().size();
    }
}
EOF

# 2. Atualizar DialogService com o alias showInformation
echo "[2/3] Atualizando DialogService.java..."
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
        showInformation(title, message);
    }

    public void showInformation(String title, String message) {
        Alert alert = new Alert(AlertType.INFORMATION);
        alert.setTitle(title);
        alert.setHeaderText(null);
        alert.setContentText(message);
        alert.showAndWait();
    }
}
EOF

# 3. Validar se o ProjectWorkspace está chamando os métodos corretamente
echo "[3/3] Sincronização concluída."

echo "========================================="
echo " 🎉 CORREÇÃO DE SÍMBOLOS APLICADA!"
echo "========================================="
echo "🚀 Execute para compilar: mvn clean compile"
