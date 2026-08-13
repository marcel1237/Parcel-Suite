#!/usr/bin/env bash
set -e

echo "========================================="
echo " Project Wizard - Etapa 16.5C"
echo " Finalizando Integração do Package Explorer"
echo "========================================="

FILE="src/main/java/com/projectwizard/view/openproject/OpenProjectView.java"

if [ ! -f "$FILE" ]; then
    echo "ERRO: Arquivo não encontrado: $FILE"
    exit 1
fi

# Backup de segurança
cp "$FILE" "$FILE.pre16_5C"

echo "Aplicando lógica de abertura de projeto no $FILE..."

# O script utiliza Python para uma substituição precisa do bloco de código,
# conforme sugerido nas instruções da etapa 16.5B [1].
python3 <<'PY'
from pathlib import Path

p = Path("src/main/java/com/projectwizard/view/openproject/OpenProjectView.java")
txt = p.read_text()

# Localiza o ponto onde o alerta de "Projeto Aberto" era exibido
# e substitui pela inicialização e carregamento do PackageExplorer
old_logic = """Alert alert = new Alert(AlertType.INFORMATION);
            alert.setTitle("Projeto Aberto");
            alert.setHeaderText(null);
            alert.setContentText("Abrindo: " + selectedDirectory.getAbsolutePath());
            alert.showAndWait();"""

new_logic = """// Inicializa e carrega o explorador com o diretório selecionado
            explorer.setCellFactory(v -> new FileTreeCell());
            explorer.openProject(selectedDirectory);
            
            // Log de status
            System.out.println("[EXPLORER] Projeto carregado: " + selectedDirectory.getName());"""

if old_logic in txt:
    txt = txt.replace(old_logic, new_logic)
    p.write_text(txt)
    print("✔ Sucesso: Lógica do Alert substituída pelo PackageExplorer.")
else:
    print("⚠ Aviso: Bloco de Alert não encontrado. Verifique se a Etapa 16.5A/B foi aplicada corretamente.")
PY

echo
echo "========================================="
echo " Etapa 16.5C concluída!"
echo "========================================="
echo
echo "O OpenProjectView agora carrega os arquivos"
echo "diretamente na TreeView lateral."
echo
echo "Execute para testar:"
echo "mvn clean javafx:run"