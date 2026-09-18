# PlayOS — Documentação de Engenharia

Este é o livro técnico do PlayOS, gerado com [mdBook](https://rust-lang.github.io/mdBook/).
Ele reúne arquitetura, decisões, builds, artefatos e critérios de validação em
uma navegação única.

## Estado atual

O livro é uma camada de navegação e síntese. Os arquivos Markdown, catálogos,
logs, checksums e artefatos no repositório continuam sendo as fontes de
verdade. A presença de uma página neste livro não transforma uma proposta em
implementação nem um build em boot validado.

## Navegação rápida

- [Estado do projeto](estado-projeto.md)
- [Mapa da pasta `build/`](builds/mapa-build.md)
- [ISO Ubuntu Noble + KDE Full](builds/iso-ubuntu-kde.md)
- [Categorias de estado](evidencia/estados.md)
- [Como usar o mdBook](ferramentas/mdbook.md)

## Princípio de evidência

Toda conclusão técnica deve declarar se é `fact`, `inference`, `decision`,
`proposal`, `implementation`, `result` ou `unknown`. Build concluído não
significa boot concluído; presença de driver não significa funcionamento de
hardware.
