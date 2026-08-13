#!/usr/bin/env bash
set -Eeuo pipefail

echo "========================================="
echo " Project Wizard - Etapa 18.0"
echo " Motor de Realce de Sintaxe (JDT Core)"
echo "========================================="

# 1. Adicionar dependência do JDT Core ao pom.xml
echo "[1/4] Integrando JDT Core ao Maven..."
python3 <<'PY'
import xml.etree.ElementTree as ET
from pathlib import Path

path = Path("pom.xml")
ET.register_namespace('', "http://maven.apache.org/POM/4.0.0")
tree = ET.parse(path)
root = tree.getroot()
ns = {'m': 'http://maven.apache.org/POM/4.0.0'}

deps = root.find('m:dependencies', ns)
# Verifica se já existe
if not any(d.find('m:artifactId', ns).text == 'org.eclipse.jdt.core' for d in deps.findall('m:dependency', ns)):
    new_dep = ET.SubElement(deps, 'dependency')
    ET.SubElement(new_dep, 'groupId').text = 'org.eclipse.jdt'
    ET.SubElement(new_dep, 'artifactId').text = 'org.eclipse.jdt.core'
    ET.SubElement(new_dep, 'version').text = '3.39.0'
    tree.write(path, encoding='utf-8', xml_declaration=True)
    print("✔ Dependência JDT Core adicionada.")
else:
    print("ℹ JDT Core já está no pom.xml.")
PY

# 2. Criar o Scanner de Tokens Java
echo "[2/4] Criando JavaTokenScanner.java..."
mkdir -p src/main/java/com/projectwizard/service/editor
cat > src/main/java/com/projectwizard/service/editor/JavaTokenScanner.java <<'EOF'
package com.projectwizard.service.editor;

import org.eclipse.jdt.core.compiler.ITerminalSymbols;
import org.eclipse.jdt.internal.compiler.parser.Scanner;

public class JavaTokenScanner {
    private final Scanner scanner = new Scanner();

    public void tokenize(String source, TokenHandler handler) {
        scanner.setSource(source.toCharArray());
        try {
            int token;
            while ((token = scanner.getNextToken()) != ITerminalSymbols.TokenNameEOF) {
                int start = scanner.getCurrentTokenStartPosition();
                int end = scanner.getCurrentTokenEndPosition();
                String type = getStyleClass(token);
                handler.onToken(type, start, end + 1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private String getStyleClass(int token) {
        return switch (token) {
            case ITerminalSymbols.TokenNameIdentifier -> "token-identifier";
            case ITerminalSymbols.TokenNameStringLiteral -> "token-string";
            case ITerminalSymbols.TokenNameCOMMENT_BLOCK, ITerminalSymbols.TokenNameCOMMENT_LINE -> "token-comment";
            case ITerminalSymbols.TokenNameint, ITerminalSymbols.TokenNamepublic, ITerminalSymbols.TokenNameclass, 
                 ITerminalSymbols.TokenNamestatic, ITerminalSymbols.TokenNamevoid, ITerminalSymbols.TokenNamereturn -> "token-keyword";
            default -> "token-default";
        };
    }

    public interface TokenHandler {
        void onToken(String type, int start, int end);
    }
}
EOF

# 3. Adicionar estilos de código ao CSS do AtlantaFX
echo "[3/4] Atualizando projectwizard.css..."
mkdir -p src/main/resources/themes
cat >> src/main/resources/themes/projectwizard.css <<'EOF'
.token-keyword { -fx-fill: #ff7b72; -fx-font-weight: bold; }
.token-string { -fx-fill: #a5d6ff; }
.token-comment { -fx-fill: #8b949e; -fx-font-style: italic; }
.token-identifier { -fx-fill: #d2a8ff; }
.token-default { -fx-fill: #adbac7; }
EOF

# 4. Atualizar EditorPane para aceitar o motor (Placeholder para UI Rica)
echo "[4/4] Preparando EditorPane para Highlighting..."
python3 <<'PY'
from pathlib import Path
p = Path("src/main/java/com/projectwizard/view/editor/EditorPane.java")
if p.exists():
    txt = p.read_text()
    if "JavaTokenScanner" not in txt:
        txt = txt.replace("import javafx.scene.layout.BorderPane;", 
                          "import javafx.scene.layout.BorderPane;\nimport com.projectwizard.service.editor.JavaTokenScanner;")
        p.write_text(txt)
        print("✔ EditorPane pronto para receber o motor de realce.")
PY

echo "========================================="
echo " 🎉 ETAPA 18.0 CONCLUÍDA!"
echo "========================================="
echo "Nota: O JDT Core agora está integrado [2]."
echo "A TextArea padrão foi marcada para upgrade para RichTextFX"
echo "ou TextFlow na próxima etapa para exibir as cores."
echo "========================================="
echo "🚀 Execute: mvn clean compile"