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
 * EditorPane com Realce de Sintaxe Industrial.
 * Licença: EPL-2.0 AND MPL-2.0 AND AGPL-3.0-only
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

        // Listener assíncrono para manter a UI fluida
        codeArea.multiPlainChanges().subscribe(ignore -> runHighlightingAsync());

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

        highlightTask.setOnSucceeded(
                e -> codeArea.setStyleSpans(0, highlightTask.getValue()));

        Thread thread = new Thread(highlightTask);
        thread.setDaemon(true);
        thread.start();
    }

    private StyleSpans<Collection<String>> computeHighlighting(String text) {
        StyleSpansBuilder<Collection<String>> spansBuilder =
                new StyleSpansBuilder<>();

        // Mutable value for use inside the lambda
        final int[] lastKwEnd = { 0 };

        // Limit processing for very large files
        String processableText = text.length() > 50000
                ? text.substring(0, 50000)
                : text;

        scanner.tokenize(processableText, (type, start, end) -> {

            int spacer = start - lastKwEnd[0];
            if (spacer > 0) {
                spansBuilder.add(Collections.emptyList(), spacer);
            }

            spansBuilder.add(Collections.singleton(type), end - start);

            lastKwEnd[0] = end;
        });

        int remaining = text.length() - lastKwEnd[0];
        if (remaining > 0) {
            spansBuilder.add(Collections.emptyList(), remaining);
        }

        return spansBuilder.create();
    }

    public String getText() {
        return codeArea.getText();
    }

    public File getFile() {
        return currentFile;
    }
}