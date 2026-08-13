#!/usr/bin/env bash
set -Eeuo pipefail

echo "========================================="
echo " Project Wizard - Etapa 16.9"
echo " Habilitando Edição no Editor de Código"
echo "========================================="

# Verificação de ambiente
if [ ! -f pom.xml ]; then
    echo "Erro: Execute na raiz do projeto ProjectWizard."
    exit 1
fi

echo "[1/3] Atualizando EditorHost para permitir escrita..."
# Altera o construtor do EditorHost para setEditable(true)
python3 <<'PY'
from pathlib import Path
files = [
    "src/main/java/com/projectwizard/view/editor/EditorHost.java",
    "src/main/java/com/projectwizard/view/editor/EditorPane.java"
]

for file_path in files:
    p = Path(file_path)
    if p.exists():
        txt = p.read_text()
        # Remove a trava de somente leitura
        txt = txt.replace("editor.setEditable(false);", "editor.setEditable(true);")
        txt = txt.replace("setEditable(false);", "setEditable(true);")
        p.write_text(txt)
        print(f"✔ Editabilidade habilitada em: {file_path}")
PY

echo "[2/3] Adicionando listener de modificação (Dirty State)..."
# Adiciona lógica básica para detectar mudanças no texto
python3 <<'PY'
from pathlib import Path
p = Path("src/main/java/com/projectwizard/view/editor/EditorHost.java")
if p.exists():
    txt = p.read_text()
    if "textProperty().addListener" not in txt:
        # Insere o listener de modificação após a criação do editor
        old = "editor = new TextArea();"
        new = """editor = new TextArea();
        editor.textProperty().addListener((obs, oldVal, newVal) -> {
            System.out.println("[EDITOR] Texto modificado - Status: Dirty");
        });"""
        txt = txt.replace(old, new)
        p.write_text(txt)
        print("✔ Listener de modificação adicionado ao EditorHost.")
PY

echo "[3/3] Atualizando OpenProjectView (Removendo travas de preview)..."
# Garante que ao abrir o arquivo no OpenProjectView, o editor não seja resetado para read-only
sed -i 's/editorHost.setEditable(false);/editorHost.setEditable(true);/g' src/main/java/com/projectwizard/view/openproject/OpenProjectView.java 2>/dev/null || true

echo "========================================="
echo " 🎉 ETAPA 16.9 CONCLUÍDA!"
echo "========================================="
echo "Alterações realizadas:"
echo "✔ EditorHost e EditorPane agora permitem entrada de texto."
echo "✔ Adicionado log no terminal para detectar mudanças (Fase 3 Prep)."
echo "✔ OpenProjectView sincronizado com modo de edição."
echo "========================================="
echo "🚀 Teste agora: mvn clean javafx:run"
echo "Abra um projeto e tente digitar no editor lateral ou nas abas."