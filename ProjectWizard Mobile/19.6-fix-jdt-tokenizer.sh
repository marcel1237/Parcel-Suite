#!/usr/bin/env bash

set -e

echo "=========================================="
echo " Project Wizard 19.6"
echo " JDT Tokenizer Fix"
echo "=========================================="

FILE=src/main/java/com/projectwizard/service/editor/JavaTokenScanner.java

cp "$FILE" "$FILE.bak19_6"

cat > "$FILE" <<'EOF'
package com.projectwizard.service.editor;

import org.eclipse.jdt.core.compiler.ITerminalSymbols;
import org.eclipse.jdt.internal.compiler.parser.Scanner;

@SuppressWarnings("restriction")
public class JavaTokenScanner {

    private final Scanner scanner = new Scanner();

    public void tokenize(String source, TokenHandler handler) {

        if (source == null || handler == null)
            return;

        scanner.setSource(source.toCharArray());

        try {

            int token;

            while ((token = scanner.getNextToken())
                    != ITerminalSymbols.TokenNameEOF) {

                int start = scanner.getCurrentTokenStartPosition();
                int end   = scanner.getCurrentTokenEndPosition() + 1;

                if (start < 0)
                    continue;

                if (end < start)
                    continue;

                if (start > source.length())
                    continue;

                if (end > source.length())
                    end = source.length();

                if (start == end)
                    continue;

                handler.onToken(
                        getStyleClass(token),
                        start,
                        end
                );
            }

        } catch (Exception e) {

            System.err.println(
                    "[JDT] Erro na tokenização: "
                            + e.getMessage()
            );

        } finally {

            scanner.setSource((char[]) null);

        }

    }

    private String getStyleClass(int token) {

        return switch (token) {

            case ITerminalSymbols.TokenNameIdentifier ->
                    "token-identifier";

            case ITerminalSymbols.TokenNameStringLiteral ->
                    "token-string";

            case ITerminalSymbols.TokenNameCOMMENT_BLOCK,
                 ITerminalSymbols.TokenNameCOMMENT_LINE ->
                    "token-comment";

            case ITerminalSymbols.TokenNameint,
                 ITerminalSymbols.TokenNamepublic,
                 ITerminalSymbols.TokenNameclass,
                 ITerminalSymbols.TokenNamestatic,
                 ITerminalSymbols.TokenNamevoid,
                 ITerminalSymbols.TokenNamereturn,
                 ITerminalSymbols.TokenNameprivate,
                 ITerminalSymbols.TokenNameprotected,
                 ITerminalSymbols.TokenNameif,
                 ITerminalSymbols.TokenNameelse,
                 ITerminalSymbols.TokenNamefor,
                 ITerminalSymbols.TokenNamewhile,
                 ITerminalSymbols.TokenNametry,
                 ITerminalSymbols.TokenNamecatch,
                 ITerminalSymbols.TokenNamefinally,
                 ITerminalSymbols.TokenNamenew,
                 ITerminalSymbols.TokenNameimport,
                 ITerminalSymbols.TokenNamepackage ->

                    "token-keyword";

            default ->
                    "token-default";

        };

    }

    public interface TokenHandler {

        void onToken(
                String type,
                int start,
                int end
        );

    }

}
EOF

echo
echo "=========================================="
echo "19.6 aplicado."
echo
echo "Execute:"
echo
echo "mvn clean javafx:run"