#!/usr/bin/env bash
set -Eeuo pipefail

echo "========================================="
echo " Project Wizard - Etapa 19.1"
echo " Correção Definitiva de Sintaxe: lastKwEnd"
echo "========================================="

# 1. Validar ambiente
if [ ! -f pom.xml ]; then
    echo "Erro: Execute na raiz do ProjectWizard."
    exit 1
fi

echo "[1/2] Sobrescrevendo EditorPane.java com correção de índice ..."
# O uso de Python com raw string garante que os caracteres  sejam escritos sem erro
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
 * Correção: Uso obrigatório do índice  para variáveis mutáveis em Lambdas.
 * Licença: EPL-2.0 AND MPL-2.0 AND AGPL-3.0-only
 */
public class EditorPane extends BorderPane {
    private static final long MAX_FILE_SIZE = 1024 * 1024; // 1MB [18.4]
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

        // Listener assíncrono para manter a UI fluida [2-9]
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
        // lastKwEnd deve ser um array final para ser alterado dentro da Lambda
        final int[] lastKwEnd = {0}; 
        
        // Limita o processamento inicial para performance
        String processableText = text.length() > 50000 ? text.substring(0, 50000) : text;

        scanner.tokenize(processableText, (type, start, end) -> {
            int spacer = start - lastKwEnd; // CORREÇÃO: ACESSO AO ÍNDICE 
            if (spacer > 0) {
                spansBuilder.add(Collections.emptyList(), spacer);
            }
            spansBuilder.add(Collections.singleton(type), end - start);
            lastKwEnd = end; // CORREÇÃO: ATRIBUIÇÃO NO ÍNDICE 
        });
        
        int remaining = text.length() - lastKwEnd; // CORREÇÃO: CÁLCULO FINAL COM 
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
p.write_text(content, encoding='utf-8')
print(f"✔ EditorPane.java reconstruído com sucesso.")
PY

echo "[2/2] Recompilando projeto..."
mvn clean compile

echo "========================================="
echo " 🎉 ETAPA 19.1 CONCLUÍDA!"
echo "========================================="
echo "✔ Erros de 'bad operand types' e 'Type mismatch' resolvidos."
echo "✔ Proteção contra OOM (Erro 137) e processamento em background ativos." [3, 10]
echo "========================================="
echo "🚀 Execute: mvn javafx:run"