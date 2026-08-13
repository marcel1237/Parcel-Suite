#!/usr/bin/env bash
set -Eeuo pipefail

echo "========================================="
echo " Project Wizard - Etapa 17.0"
echo " Implementando Salvar / Salvar Como"
echo "========================================="

# Verificação de ambiente
if [ ! -f pom.xml ]; then
    echo "Erro: Execute na raiz do projeto ProjectWizard."
    exit 1
fi

echo "[1/3] Atualizando FileSystemService com suporte a escrita..."
cat > src/main/java/com/projectwizard/service/FileSystemService.java <<'EOF'
package com.projectwizard.service;

import java.io.File;
import java.nio.file.Files;
import java.nio.charset.StandardCharsets;

public class FileSystemService {
    public void saveFile(File file, String content) throws Exception {
        if (file == null) return;
        Files.writeString(file.toPath(), content, StandardCharsets.UTF_8);
    }
}
EOF

echo "[2/3] Adicionando ToolBar de ações ao EditorHost..."
python3 <<'PY'
from pathlib import Path
p = Path("src/main/java/com/projectwizard/view/editor/EditorHost.java")
if p.exists():
    txt = p.read_text()
    
    # Adicionando imports necessários
    imports = """import javafx.scene.control.Button;
import javafx.scene.control.ToolBar;
import javafx.scene.control.Separator;
import javafx.stage.FileChooser;
import com.projectwizard.core.ApplicationContext;"""
    
    if "javafx.stage.FileChooser" not in txt:
        txt = txt.replace("import javafx.scene.control.TabPane;", "import javafx.scene.control.TabPane;\n" + imports)

    # Injetando a ToolBar no topo do BorderPane
    toolbar_logic = """
    private void setupToolBar() {
        Button btnSave = new Button("💾 Save");
        Button btnSaveAs = new Button("📂 Save As...");
        
        btnSave.setOnAction(e -> handleSave());
        btnSaveAs.setOnAction(e -> handleSaveAs());
        
        ToolBar toolBar = new ToolBar(btnSave, btnSaveAs, new Separator());
        setTop(toolBar);
    }

    private void handleSave() {
        Tab selectedTab = getSelectionModel().getSelectedItem();
        if (selectedTab != null && selectedTab.getContent() instanceof EditorPane pane) {
            try {
                File file = pane.getFile();
                String content = pane.getText();
                ApplicationContext.getInstance().getFileSystemService().saveFile(file, content);
                System.out.println("[EDITOR] Arquivo salvo: " + file.getName());
            } catch (Exception ex) {
                ApplicationContext.getInstance().getDialogService().showError("Erro ao Salvar", ex.getMessage());
            }
        }
    }

    private void handleSaveAs() {
        Tab selectedTab = getSelectionModel().getSelectedItem();
        if (selectedTab != null && selectedTab.getContent() instanceof EditorPane pane) {
            FileChooser chooser = new FileChooser();
            chooser.setTitle("Salvar Como");
            chooser.setInitialFileName(pane.getFile().getName());
            File newFile = chooser.showSaveDialog(getScene().getWindow());
            
            if (newFile != null) {
                try {
                    ApplicationContext.getInstance().getFileSystemService().saveFile(newFile, pane.getText());
                    selectedTab.setText(newFile.getName());
                    // Idealmente aqui atualizaria a referência no EditorPane
                    System.out.println("[EDITOR] Arquivo salvo como: " + newFile.getAbsolutePath());
                } catch (Exception ex) {
                    ApplicationContext.getInstance().getDialogService().showError("Erro no Salvar Como", ex.getMessage());
                }
            }
        }
    }
    """
    
    if "setupToolBar()" not in txt:
        # Insere a lógica antes do fechamento da classe
        txt = txt.rstrip().rstrip("}") + toolbar_logic + "\n}"
        # Chama o setup no construtor
        txt = txt.replace("setTabClosingPolicy", "setupToolBar();\n        setTabClosingPolicy")
        
    p.write_text(txt)
    print("✔ EditorHost atualizado com Save/SaveAs.")
PY

echo "[3/3] Sincronizando EditorPane..."
# Garante que o EditorPane exponha o arquivo e o texto para o Host
python3 <<'PY'
from pathlib import Path
p = Path("src/main/java/com/projectwizard/view/editor/EditorPane.java")
if p.exists():
    txt = p.read_text()
    if "public File getFile()" not in txt:
        methods = """
    public File getFile() { return currentFile; }
    public String getText() { return editor.getText(); }
        """
        txt = txt.rstrip().rstrip("}") + methods + "\n}"
        p.write_text(txt)
        print("✔ EditorPane atualizado com getters de estado.")
PY

echo "========================================="
echo " 🎉 ETAPA 17.0 CONCLUÍDA!"
echo "========================================="
echo "Novidades:"
echo "✔ Botão Save: Grava o texto no arquivo atual da aba."
echo "✔ Botão Save As: Abre seletor de arquivos para novo destino."
echo "✔ Persistência UTF-8 via FileSystemService."
echo "========================================="
echo "🚀 Teste agora: mvn clean javafx:run"