#!/usr/bin/env bash
set -Eeuo pipefail

echo "========================================="
echo " Project Wizard - Etapa 19.4"
echo " Sincronização de Cores e Estilos CSS"
echo "========================================="

# 1. Garantir a existência e o conteúdo do projectwizard.css
echo "[1/3] Consolidando projectwizard.css..."
mkdir -p src/main/resources/themes
cat > src/main/resources/themes/projectwizard.css <<'EOF'
/* Estilos para o realce de sintaxe no CodeArea (RichTextFX) */
.token-keyword { 
    -fx-fill: #ff7b72; 
    -fx-font-weight: bold; 
}
.token-string { 
    -fx-fill: #a5d6ff; 
}
.token-comment { 
    -fx-fill: #8b949e; 
    -fx-font-style: italic; 
}
.token-identifier { 
    -fx-fill: #d2a8ff; 
}
.token-default { 
    -fx-fill: #adbac7; 
}

/* Força o fundo escuro para destacar as cores */
.code-area {
    -fx-background-color: #0d1117;
    -fx-font-family: 'Consolas', 'Monospace';
    -fx-font-size: 13px;
    -fx-text-fill: #adbac7;
}
EOF

# 2. Vincular o CSS no MainWindow de forma mais robusta
# Verifica se o carregamento do CSS está usando o caminho correto do classpath
echo "[2/3] Verificando vínculo CSS no MainWindow.java..."
python3 <<'PY'
from pathlib import Path
p = Path("src/main/java/com/projectwizard/view/MainWindow.java")
if p.exists():
    txt = p.read_text()
    # Garante que o CSS personalizado seja carregado APÓS o tema do AtlantaFX
    if "projectwizard.css" not in txt:
        old = "scene.getStylesheets().add(new PrimerDark().getUserAgentStylesheet());"
        new = old + '\n        String customCss = getClass().getResource("/themes/projectwizard.css").toExternalForm();'
        new += '\n        scene.getStylesheets().add(customCss);'
        txt = txt.replace(old, new)
        p.write_text(txt)
        print("✔ MainWindow: Carregamento de CSS injetado.")
    else:
        print("ℹ MainWindow: Stylesheet já parece estar configurado.")
PY

# 3. Garantir que o JavaTokenScanner esteja mapeando os tokens corretamente
# Caso o script 19.2 tenha falhado, este comando garante as strings de classe CSS.
echo "[3/3] Validando strings de tokens no JavaTokenScanner..."
sed -i 's/"keyword"/"token-keyword"/g' src/main/java/com/projectwizard/service/editor/JavaTokenScanner.java
sed -i 's/"string"/"token-string"/g' src/main/java/com/projectwizard/service/editor/JavaTokenScanner.java
sed -i 's/"comment"/"token-comment"/g' src/main/java/com/projectwizard/service/editor/JavaTokenScanner.java
sed -i 's/"identifier"/"token-identifier"/g' src/main/java/com/projectwizard/service/editor/JavaTokenScanner.java

echo "========================================="
echo " 🎉 ETAPA 19.4 CONCLUÍDA!"
echo "========================================="
echo "🚀 Execute: mvn clean javafx:run"
echo "-----------------------------------------"
echo "Nota: Se o fundo do editor ficar azul escuro/preto,"
echo "o CSS foi carregado com sucesso. Se o fundo continuar"
echo "cinza padrão, o caminho do resource no MainWindow"
echo "pode estar falhando."