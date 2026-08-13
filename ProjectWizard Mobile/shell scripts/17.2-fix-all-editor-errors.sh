#!/usr/bin/env bash
set -Eeuo pipefail

echo "========================================="
echo " Project Wizard - Etapa 17.2"
echo " Correção Geral de Símbolos e Hierarquia"
echo "========================================="

# 1. Garantir que o ApplicationContext tenha o método getInstance()
echo "[1/3] Corrigindo ApplicationContext (Singleton)..."
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
        if (instance == null) {
            instance = new ApplicationContext();
        }
        return instance;
    }

    public ProjectService getProjectService() { return projectService; }
    public FileSystemService getFileSystemService() { return fileSystemService; }
    public DialogService getDialogService() { return dialogService; }
}
EOF

# 2. Corrigir EditorPane para expor o texto e o arquivo
echo "[2/3] Corrigindo EditorPane (Getters)..."
python3 <<'PY'
from pathlib import Path
p = Path("src/main/java/com/projectwizard/view/editor/EditorPane.java")
if p.exists():
    txt = p.read_text()
    if "public String getText()" not in txt:
        # Insere antes do último fechamento de chave
        content = """
    public String getText() { return editor.getText(); }
    public java.io.File getFile() { return currentFile; }
}"""
        txt = txt.rstrip().rstrip("}") + content
        p.write_text(txt)
        print("✔ EditorPane atualizado.")
PY

# 3. Corrigir EditorHost para usar a variável interna tabPane corretamente
echo "[3/3] Ajustando chamadas de método no EditorHost..."
python3 <<'PY'
from pathlib import Path
p = Path("src/main/java/com/projectwizard/view/editor/EditorHost.java")
if p.exists():
    txt = p.read_text()
    
    # Corrige chamadas que deveriam ser no tabPane interno, não no BorderPane (this)
    txt = txt.replace("setTabClosingPolicy(", "tabPane.setTabClosingPolicy(")
    txt = txt.replace("getSelectionModel()", "tabPane.getSelectionModel()")
    
    # Garante que o cast para EditorPane na lógica do Save funcione (Java 16+ Pattern Matching)
    # Se o compilador falhar no pattern matching, usamos o modo tradicional
    txt = txt.replace("instanceof EditorPane pane", "instanceof EditorPane")
    
    p.write_text(txt)
    print("✔ EditorHost: Chamadas redirecionadas para tabPane.")
PY

echo "========================================="
echo " 🎉 CORREÇÕES APLICADAS!"
echo "========================================="
echo "Ajustes realizados:"
echo "✔ ApplicationContext: getInstance() restaurado."
echo "✔ EditorPane: Métodos getText() e getFile() adicionados."
echo "✔ EditorHost: Redirecionado métodos de Tab para o objeto interno."
echo "========================================="
echo "🚀 Execute para compilar: mvn clean compile"

