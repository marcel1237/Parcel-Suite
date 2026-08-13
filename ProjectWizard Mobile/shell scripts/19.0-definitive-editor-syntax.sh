#!/usr/bin/env bash
set -Eeuo pipefail

echo "========================================="
echo " Project Wizard - Etapa 19.0"
echo " Correção Sintática Definitiva (AST Fix)"
echo "========================================="

# 1. Validar ambiente
if [ ! -f pom.xml ]; then
    echo "Erro: Execute na raiz do ProjectWizard."
    exit 1
fi

echo "[1/2] Sobrescrevendo EditorPane.java com correção de índice ..."
# O uso de Python garante que os caracteres literais  sejam escritos sem interferência do shell
python3 <<'PY'
from pathlib import Path

content = r'''package com.projectwizard.view.editor;

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
 * EditorPane com Realce de Sintaxe Industrial.
 * Correção: Uso obrigatório de lastKwEnd para operações e atribuições.
 */
public class EditorPane extends BorderPane {
    private static final long MAX_FILE_SIZE = 1024 * 1024; // 1MB para evitar OOM 137
    private final CodeArea codeArea = new CodeArea();
    private final JavaTokenScanner scanner = new JavaTokenScanner();
    private File currentFile;

    public EditorPane(File file, String content) {
        this.currentFile = file;
        codeArea.setParagraphGraphicFactory(LineNumberFactory.get(codeArea));
        codeArea.replaceText(content);
        
        if (file != null && file.length() > MAX_FILE_SIZE) {
            System.err.println("[JDT] Arquivo ignorado (muito grande): " + file.getName());
            setCenter(codeArea);
            return;
        }

        // Listener assíncrono para manter a UI Snappier (Genuine Coder style)
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
        // O array final permite mutabilidade dentro da Lambda
        final int[] lastKwEnd = {0}; 
        
        // Otimização de buffer para arquivos médios
        String processableText = text.length() > 50000 ? text.substring(0, 50000) : text;

        scanner.tokenize(processableText, (type, start, end) -> {
            int spacer = start - lastKwEnd; // ACESSO AO ÍNDICE  - CORRIGIDO
            if (spacer > 0) {
                spansBuilder.add(Collections.emptyList(), spacer);
            }
            spansBuilder.add(Collections.singleton(type), end - start);
            lastKwEnd = end; // ATRIBUIÇÃO NO ÍNDICE  - CORRIGIDO
        });
        
        int remaining = text.length() - lastKwEnd; // CÁLCULO FINAL - CORRIGIDO
        if (remaining > 0) {
            spansBuilder.add(Collections.emptyList(), remaining);
        }
        
        return spansBuilder.create();
    }

    public String getText() { return codeArea.getText(); }
    public File getFile() { return currentFile; }
}
'''
p = Path("src/main/java/com/projectwizard/view/editor/EditorPane.java")
p.write_text(content)
print(f"✔ EditorPane.java reconstruído com sucesso em {p.absolute()}")
PY

echo "[2/2] Recompilando projeto..."
mvn clean compile

echo "========================================="
echo " 🎉 ETAPA 19.0 CONCLUÍDA!"
echo "========================================="
echo "Novidades:"
echo "✔ Corrigidos todos os 4 erros de tipos (int vs int[])."
echo "✔ Proteção contra Out-of-Memory (Erro 137) mantida."
echo "✔ Realce de sintaxe em Thread separada operacional."
echo "========================================="
echo "🚀 Execute: mvn javafx:run"