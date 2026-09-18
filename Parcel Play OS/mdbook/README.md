# mdBook do PlayOS

Este diretório contém o livro técnico navegável do PlayOS.

## Requisitos

- Rust e Cargo;
- `mdbook`.

Instalação:

```sh
cargo install mdbook
```

## Comandos

```sh
cd mdbook
mdbook build
mdbook test
mdbook serve --open
```

A fonte está em `src/`. A saída HTML gerada fica em `book/`.

## Escopo

O livro é uma síntese navegável. As fontes canônicas continuam na raiz do
projeto, em `supervised_learning/`, nos catálogos e nos artefatos de `build/`.
