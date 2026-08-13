#!/usr/bin/env bash
set -Eeuo pipefail

echo "========================================="
echo " Project Wizard - Etapa 19.2"
echo " Ativando Cores do Realce de Sintaxe"
echo "========================================="

# 1. Garantir que o projectwizard.css tenha definições de cor robustas
echo "[1/3] Atualizando definições de cores CSS..."
cat > src/main/resources/themes/projectwizard.css <<'EOF'
/* Estilos para o realce de sintaxe no CodeArea */
.token-keyword { -fx-fill: #ff7b72; -fx-font-weight: bold; }
.token-string { -fx-fill: #a5d6ff; }
.token-comment { -fx-fill: #8b949e; -fx-font-style: italic; }
.token-identifier { -fx-fill: #d2a8ff; }
.token-default { -fx-fill: #adbac7; }

/* Garante que o fundo do editor combine com o tema escuro */
.code-area {
    -fx-background-color: #0d1117;
    -fx-font-family: 'Consolas', 'Monospace';
    -fx-font-size: 13px;
}
EOF

# 2. Atualizar JavaTokenScanner para reconhecer MAIS palavras-chave
# Na etapa 18.0, apenas 6 palavras foram mapeadas.
echo "[2/3] Expandindo vocabulário do JavaTokenScanner..."
python3 <<'PY'
from pathlib import Path
p = Path("src/main/java/com/projectwizard/service/editor/JavaTokenScanner.java")
if p.exists():
    txt = p.read_text()
    old_switch = 'case ITerminalSymbols.TokenNameint, ITerminalSymbols.TokenNamepublic, ITerminalSymbols.TokenNameclass, \n                 ITerminalSymbols.TokenNamestatic, ITerminalSymbols.TokenNamevoid, ITerminalSymbols.TokenNamereturn -> "token-keyword";'
    new_switch = """case ITerminalSymbols.TokenNameint, ITerminalSymbols.TokenNamepublic, ITerminalSymbols.TokenNameclass, 
                 ITerminalSymbols.TokenNamestatic, ITerminalSymbols.TokenNamevoid, ITerminalSymbols.TokenNamereturn,
                 ITerminalSymbols.TokenNameprivate, ITerminalSymbols.TokenNameprotected, ITerminalSymbols.TokenNameif,
                 ITerminalSymbols.TokenNameelse, ITerminalSymbols.TokenNamefor, ITerminalSymbols.TokenNamewhile,
                 ITerminalSymbols.TokenNametray, ITerminalSymbols.TokenNamecatch, ITerminalSymbols.TokenNamefinally,
                 ITerminalSymbols.TokenNamenew, ITerminalSymbols.TokenNameimport, ITerminalSymbols.TokenNamepackage -> "token-keyword";"""
    if "TokenNameprivate" not in txt:
        txt = txt.replace(old_switch, new_switch)
        p.write_text(txt)
        print("✔ Scanner expandido com sucesso.")
PY

# 3. Vincular o CSS ao MainWindow
echo "[3/3] Vinculando CSS à cena principal..."
python3 <<'PY'
from pathlib import Path
p = Path("src/main/java/com/projectwizard/view/MainWindow.java")
if p.exists():
    txt = p.read_text()
    if "projectwizard.css" not in txt:
        old = "scene.getStylesheets().add(new PrimerDark().getUserAgentStylesheet());"
        new = old + '\n        scene.getStylesheets().add(getClass().getResource("/themes/projectwizard.css").toExternalForm());'
        txt = txt.replace(old, new)
        p.write_text(txt)
        print("✔ Stylesheet registrado no MainWindow.")
PY

echo "========================================="
echo " 🎉 CORES ATIVADAS!"
echo "========================================="
echo "Nota: O realce agora cobre os principais modificadores e estruturas [18.0, 19.2]."
echo "========================================="
echo "🚀 Execute: mvn clean javafx:run"