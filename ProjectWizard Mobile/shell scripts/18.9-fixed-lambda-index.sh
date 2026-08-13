#!/usr/bin/env bash
set -Eeuo pipefail

echo "========================================="
echo " Project Wizard - Etapa 18.9"
echo " Correção de Acesso ao Índice do Array"
echo "========================================="

# 1. Validar ambiente
if [ ! -f pom.xml ]; then
    echo "Erro: Execute na raiz do ProjectWizard."
    exit 1
fi

echo "[1/2] Corrigindo EditorPane.java (Acesso via )..."
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

/**
 * EditorPane com Realce de Sintaxe Otimizado.
 * Correção: Acesso explícito ao índice  do array de controle do JDT.
 */
public class EditorPane extends BorderPane {
    private static final long MAX_FILE_SIZE = 1024 * 1024; // 1MB
    private final CodeArea codeArea = new CodeArea();
    private final JavaTokenScanner scanner = new JavaTokenScanner();
    private File currentFile;

    public EditorPane(File file, String content) {
        this.currentFile = file;
        codeArea.setParagraphGraphicFactory(LineNumberFactory.get(codeArea));
        codeArea.replaceText(content);
        
        if (file != null && file.length() > MAX_FILE_SIZE) {
            System.err.println("[JDT] Arquivo muito grande para realce.");
            setCenter(codeArea);
            return;
        }

        codeArea.multiPlainChanges()
            .subscribe(ignore -> runHighlightingAsync());

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
        highlightTask.setOnSucceeded(e -> codeArea.setStyleSpans(0, highlightTask.getValue()));
        
        Thread thread = new Thread(highlightTask);
        thread.setDaemon(true);
        thread.start();
    }

    private StyleSpans<Collection<String>> computeHighlighting(String text) {
        StyleSpansBuilder<Collection<String>> spansBuilder = new StyleSpansBuilder<>();
        final int[] lastKwEnd = {0}; // Ponteiro mutável para Lambda
        
        String processableText = text.length() > 50000 ? text.substring(0, 50000) : text;

        scanner.tokenize(processableText, (type, start, end) -> {
            int spacer = start - lastKwEnd; // CORRIGIDO: ACESSO AO ÍNDICE 
            if (spacer > 0) {
                spansBuilder.add(Collections.emptyList(), spacer);
            }
            spansBuilder.add(Collections.singleton(type), end - start);
            lastKwEnd = end; // CORRIGIDO: ATRIBUIÇÃO NO ÍNDICE 
        });
        
        int remaining = text.length() - lastKwEnd; // CORRIGIDO: CÁLCULO FINAL
        if (remaining > 0) {
            spansBuilder.add(Collections.emptyList(), remaining);
        }
        
        return spansBuilder.create();
    }

    public String getText() { return codeArea.getText(); }
    public File getFile() { return currentFile; }
}
EOF

echo "[2/2] Compilando e limpando artefatos..."
mvn clean compile

echo "========================================="
echo " 🎉 ETAPA 18.9 CONCLUÍDA!"
echo "========================================="
echo "✔ Corrigido erro de tipos: int - int[] -> int - int."
echo "✔ Mantida proteção contra Erro 137 (OOM) via G1GC e travas."
echo "========================================="
echo "🚀 Execute: mvn javafx:run"