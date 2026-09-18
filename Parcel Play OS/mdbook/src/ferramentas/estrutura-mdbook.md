# Estrutura e comandos

## Estrutura criada

```text
mdbook/
├── book.toml
├── README.md
├── src/
│   ├── SUMMARY.md
│   ├── README.md
│   ├── arquitetura/
│   ├── builds/
│   ├── evidencia/
│   └── ferramentas/
└── theme/
    └── custom.css
```

`book/` é gerado pelo mdBook e não deve ser editado manualmente.

## Comandos

Na pasta `mdbook/`:

```sh
mdbook build
mdbook test
mdbook serve --open
mdbook clean
```

`build` gera HTML, `test` verifica os capítulos e links internos suportados,
`serve` inicia o servidor local com recarga e `clean` remove a saída gerada.

## Instalação

Com Rust/Cargo:

```sh
cargo install mdbook
```

Também é possível usar binários pré-compilados publicados pelo projeto
upstream. A versão usada deve ser registrada quando o livro for publicado.
