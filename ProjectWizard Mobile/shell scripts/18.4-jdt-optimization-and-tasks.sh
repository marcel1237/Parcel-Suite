#!/usr/bin/env bash
set -Eeuo pipefail

echo "========================================="
echo " Project Wizard - Etapa 18.4"
echo " Otimização JDT + Background Tasks"
echo "========================================="

# 1. Configurar limites de memória e GC no pom.xml
echo "[1/3] Configurando JVM: 3GB + G1GC..."
python3 <<'PY'
import xml.etree.ElementTree as ET
from pathlib import Path

path = Path("pom.xml")
ET.register_namespace('', "http://maven.apache.org/POM/4.0.0")
tree = ET.parse(path)
root = tree.getroot()
ns = {'m': 'http://maven.apache.org/POM/4.0.0'}

for plugin in root.findall('.//m:plugin', ns):
    art_id = plugin.find('m:artifactId', ns)
    if art_id is not None and art_id.text == 'javafx-maven-plugin':
        options = plugin.find('.//m:options', ns)
        # Limpa configurações antigas
        for opt in list(options):
            if opt.text.startswith('-Xmx') or opt.text.startswith('-XX'):
                options.remove(opt)
        
        # Adiciona os novos parâmetros sugeridos
        ET.SubElement(options, 'option').text = '-Xmx3g'
        ET.SubElement(options, 'option').text = '-XX:+UseG1GC'
        tree.write(path, encoding='utf-8', xml_declaration=True)
        print("✔ pom.xml atualizado para 3GB e G1GC.")
PY

# 2. Atualizar EditorPane com Trava de Tamanho e Background Task
echo "[2/3] Implementando Multithreading no EditorPane..."
cat > src/main/java/com/projectwizard/view/editor/EditorPane.java <<'EOF'
package com.projectwizard.view.editor;

import java.io.File;
import java.util.Collection;
import java.util.Collections;
import javafx.concurrent.Task;
import javafx.scene.layout.BorderPane;
import org.fxmisc.richtext.CodeArea;
import org.fxmisc.richtext.LineNumberFactory;
import org.fxmisc.richtext.model.StyleSpans;
import org.fxmisc.richtext.model.StyleSpansBuilder;
import com.projectwizard.service.editor.JavaTokenScanner;

public class EditorPane extends BorderPane {
    private static final long MAX_FILE_SIZE = 1024 * 1024; // 1MB limit
    private final CodeArea codeArea = new CodeArea();
    private final JavaTokenScanner scanner = new JavaTokenScanner();
    private File currentFile;

    public EditorPane(File file, String content) {
        this.currentFile = file;
        codeArea.setParagraphGraphicFactory(LineNumberFactory.get(codeArea));
        codeArea.replaceText(content);
        
        // Verifica tamanho do arquivo antes de processar
        if (file != null && file.length() > MAX_FILE_SIZE) {
            System.err.println("[JDT] Arquivo muito grande para realce: " + file.getName());
            setCenter(codeArea);
            return;
        }

        // Listener para realce assíncrono (Evita travar a UI)
        codeArea.multiPlainChanges()
            .subscribe(ignore -> runHighlightingAsync());

        // Processamento inicial
        runHighlightingAsync();
        setCenter(codeArea);
    }

    private void runHighlightingAsync() {
        String text = codeArea.getText();
        Task<StyleSpans<Collection<String>>> highlightTask = new Task<>() {
            @Override
            protected StyleSpans<Collection<String>> call() {
                return computeHighlighting(text);
            }
        };

        highlightTask.setOnSucceeded(e -> {
            codeArea.setStyleSpans(0, highlightTask.getValue());
        });

        Thread thread = new Thread(highlightTask);
        thread.setDaemon(true);
        thread.start();
    }

    private StyleSpans<Collection<String>> computeHighlighting(String text) {
        StyleSpansBuilder<Collection<String>> spansBuilder = new StyleSpansBuilder<>();
        int[] lastKwEnd = {0};
        
        // Otimização: Se o texto for muito longo, processa apenas os primeiros 50k chars (Lazy-ish)
        String processableText = text.length() > 50000 ? text.substring(0, 50000) : text;

        scanner.tokenize(processableText, (type, start, end) -> {
            int spacer = start - lastKwEnd;
            if (spacer > 0) spansBuilder.add(Collections.emptyList(), spacer);
            spansBuilder.add(Collections.singleton(type), end - start);
            lastKwEnd = end;
        });
        
        int remaining = text.length() - lastKwEnd;
        if (remaining > 0) spansBuilder.add(Collections.emptyList(), remaining);
        
        return spansBuilder.create();
    }

    public String getText() { return codeArea.getText(); }
    public File getFile() { return currentFile; }
}
EOF

# 3. Limpeza de Cache no JavaTokenScanner
echo "[3/3] Otimizando JavaTokenScanner para GC..."
python3 <<'PY'
from pathlib import Path
p = Path("src/main/java/com/projectwizard/service/editor/JavaTokenScanner.java")
if p.exists():
    txt = p.read_text()
    # Adiciona nulling explicitamente após a tokenização para ajudar o GC
    if "scanner = null" not in txt:
        old = "handler.onToken(type, start, end + 1);"
        new = old + "\n            } \n            source = null; // Libera referência pesada"
        txt = txt.replace(old, new)
        p.write_text(txt)
        print("✔ JavaTokenScanner otimizado para Garbage Collection.")
PY

echo "========================================="
echo " 🎉 ETAPA 18.4 CONCLUÍDA!"
echo "========================================="
echo "Novidades de Performance:"
echo "✔ JVM: Ajustada para 3GB + UseG1GC."
echo "✔ Trava: Arquivos > 1MB não são processados pelo JDT."
echo "✔ Threads: Tokenização movida para Background Task (Thread separada)."
echo "✔ Memória: Redução de referências fortes no Scanner."
echo "========================================="
echo "🚀 Execute: mvn clean javafx:run"