#!/usr/bin/env bash
set -Eeuo pipefail

echo "========================================="
echo " Project Wizard - Etapa 19.5"
echo " Sincronização Final de Mapeamento"
echo "========================================="

# 1. Garantir que o CSS use os seletores exatos esperados pelo RichTextFX
echo "[1/2] Atualizando seletores no projectwizard.css..."
cat > src/main/resources/themes/projectwizard.css <<'EOF'
/* Estilos para os tokens de código */
.token-keyword { -fx-fill: #ff7b72; -fx-font-weight: bold; }
.token-string { -fx-fill: #a5d6ff; }
.token-comment { -fx-fill: #8b949e; -fx-font-style: italic; }
.token-identifier { -fx-fill: #d2a8ff; }
.token-default { -fx-fill: #adbac7; }

/* Configuração do editor */
.code-area {
    -fx-background-color: #0d1117;
    -fx-font-family: 'Consolas', 'Monospace';
    -fx-font-size: 13px;
    -fx-text-fill: #adbac7;
}
EOF

# 2. Forçar o JavaTokenScanner a retornar as strings IDÊNTICAS aos seletores CSS
echo "[2/2] Unificando strings no JavaTokenScanner.java..."
python3 <<'PY'
from pathlib import Path
p = Path("src/main/java/com/projectwizard/service/editor/JavaTokenScanner.java")
if p.exists():
    txt = p.read_text()
    # Substitui nomes curtos por nomes com prefixo 'token-' para bater com o CSS
    txt = txt.replace('"keyword"', '"token-keyword"')
    txt = txt.replace('"string"', '"token-string"')
    txt = txt.replace('"comment"', '"token-comment"')
    txt = txt.replace('"identifier"', '"token-identifier"')
    txt = txt.replace('"default"', '"token-default"')
    p.write_text(txt)
    print("✔ Mapeamento de tokens unificado com o CSS.")
PY

echo "========================================="
echo " 🎉 MAPEAMENTO SINCRONIZADO!"
echo "========================================="
echo "🚀 Execute: mvn clean javafx:run"
echo "-----------------------------------------"
echo "Dica: Ao abrir, digite 'public class Test' no editor."
echo "Se 'public' e 'class' ficarem vermelhos/rosa,"
echo "o realce industrial está 100% ativo!"