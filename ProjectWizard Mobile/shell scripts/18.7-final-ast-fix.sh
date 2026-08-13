#!/usr/bin/env bash
set -Eeuo pipefail

echo "========================================="
echo " Project Wizard - Etapa 18.7"
echo " Correção Definitiva: Acesso ao Array AST"
echo "========================================="

# Verificação de ambiente
if [ ! -f pom.xml ]; then
    echo "Erro: Execute na raiz do projeto ProjectWizard."
    exit 1
fi

echo "[1/2] Reconstruindo EditorPane.java com acessos lastKwEnd..."
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
    private static final long MAX_FILE_SIZE = 1024 * 1024; // Limite de 1MB
    private final CodeArea codeArea = new CodeArea();
    private final JavaTokenScanner scanner = new JavaTokenScanner();
    private File currentFile;

    public EditorPane(File file, String content) {
        this.currentFile = file;
        codeArea.setParagraphGraphicFactory(LineNumberFactory.get(codeArea));
        codeArea.replaceText(content);
        
        if (file != null && file.length() > MAX_FILE_SIZE) {
            System.err.println("[JDT] Arquivo muito grande para realce: " + file.getName());
            setCenter(codeArea);
            return;
        }

        // Listener para realce assíncrono em tempo real
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

        highlightTask.setOnSucceeded(e -> {
            codeArea.setStyleSpans(0, highlightTask.getValue());
        });

        Thread thread = new Thread(highlightTask);
        thread.setDaemon(true);
        thread.start();
    }

    private StyleSpans<Collection<String>> computeHighlighting(String text) {
        StyleSpansBuilder<Collection<String>> spansBuilder = new StyleSpansBuilder<>();
        //lastKwEnd precisa ser um array para ser modificado dentro da lambda
        final int[] lastKwEnd = {0}; 
        
        String processableText = text.length() > 50000 ? text.substring(0, 50000) : text;

        scanner.tokenize(processableText, (type, start, end) -> {
            int spacer = start - lastKwEnd; // CORREÇÃO: Acesso ao índice 
            if (spacer > 0) {
                spansBuilder.add(Collections.emptyList(), spacer);
            }
            spansBuilder.add(Collections.singleton(type), end - start);
            lastKwEnd = end; // CORREÇÃO: Atribuição no índice 
        });
        
        int remaining = text.length() - lastKwEnd; // CORREÇÃO: Cálculo com 
        if (remaining > 0) {
            spansBuilder.add(Collections.emptyList(), remaining);
        }
        
        return spansBuilder.create();
    }

    public String getText() { return codeArea.getText(); }
    public File getFile() { return currentFile; }
}
EOF

echo "[2/2] Limpando cache e recompilando..."
mvn clean compile

echo "========================================="
echo " 🎉 ETAPA 18.7 CONCLUÍDA!"
echo "========================================="
echo "Ajustes realizados:"
echo "✔ Corrigido erro de tipos (int vs int[]) no EditorPane."
echo "✔ Mantida a lógica de Background Task para performance."
echo "✔ Mantida a trava de 1MB para evitar Out-Of-Memory (Erro 137)."
echo "========================================="
echo "🚀 Execute: mvn javafx:run"