# mdBook no PlayOS

## O que é mdBook

mdBook é uma ferramenta escrita em Rust para transformar Markdown em um livro
navegável, com índice, busca, temas, impressão e servidor local. A
documentação oficial está em
<https://rust-lang.github.io/mdBook/>.

## Pesquisa realizada

Foram consultadas as páginas oficiais sobre:

- guia geral: <https://rust-lang.github.io/mdBook/index.html>;
- configuração: <https://rust-lang.github.io/mdBook/format/configuration/index.html>;
- índice `SUMMARY.md`: <https://rust-lang.github.io/mdBook/format/summary.html>;
- CLI: <https://rust-lang.github.io/mdBook/cli/index.html>;
- temas: <https://rust-lang.github.io/mdBook/format/theme/index.html>.

## Decisão local

O PlayOS mantém este livro isolado em `mdbook/`, sem mover ou sobrescrever os
Markdown canônicos. O livro contém sínteses estáveis e aponta para os caminhos
originais do repositório.
