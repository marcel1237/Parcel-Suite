#!/usr/bin/env bash
set -Eeuo pipefail

echo "========================================="
echo " Project Wizard - Etapa 18.5"
echo " Correção Sintática: JavaTokenScanner"
echo "========================================="

# 1. Validar diretório
if [ ! -f pom.xml ]; then
    echo "Erro: Execute na raiz do ProjectWizard."
    exit 1
fi

# 2. Reescrever JavaTokenScanner.java com a sintaxe correta
echo "[1/1] Restaurando integridade do JavaTokenScanner..."
cat > src/main/java/com/projectwizard/service/editor/JavaTokenScanner.java <<'EOF'
package com.projectwizard.service.editor;

import org.eclipse.jdt.core.compiler.ITerminalSymbols;
import org.eclipse.jdt.internal.compiler.parser.Scanner;

public class JavaTokenScanner {
    private final Scanner scanner = new Scanner();

    public void tokenize(String source, TokenHandler handler) {
        if (source == null) return;
        
        // Define a fonte para análise
        scanner.setSource(source.toCharArray());
        
        try {
            int token;
            // Loop principal de tokenização do JDT Core
            while ((token = scanner.getNextToken()) != ITerminalSymbols.TokenNameEOF) {
                int start = scanner.getCurrentTokenStartPosition();
                int end = scanner.getCurrentTokenEndPosition();
                String type = getStyleClass(token);
                handler.onToken(type, start, end + 1);
            }
        } catch (Exception e) {
            System.err.println("[JDT] Erro na tokenização: " + e.getMessage());
        } finally {
            // OTIMIZAÇÃO: Limpa a referência do array de caracteres no scanner interno
            // Isso ajuda o Garbage Collector (G1GC) a liberar memória pesada [18.4]
            scanner.setSource((char[]) null);
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

echo "========================================="
echo " 🎉 ETAPA 18.5 CONCLUÍDA!"
echo "========================================="
echo "Novidades:"
echo "✔ Erros de 'try without catch' resolvidos."
echo "✔ Limpeza de memória movida para o bloco 'finally'."
echo "✔ Integridade da classe restaurada."
echo "========================================="
echo "🚀 Execute: mvn clean compile"