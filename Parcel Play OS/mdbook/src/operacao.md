# Operação

## Construir o livro

```sh
cd mdbook
mdbook build
```

O HTML será criado em `mdbook/book/`.

## Servir localmente

```sh
cd mdbook
mdbook serve --open
```

O servidor é destinado a desenvolvimento local. Não exponha uma porta de
desenvolvimento sem necessidade.

## Atualizar conteúdo

1. Atualize a fonte canônica na raiz ou em `supervised_learning/`.
2. Atualize a síntese correspondente em `mdbook/src/`.
3. Ajuste `SUMMARY.md` se houver novo capítulo.
4. Rode `mdbook test` e `mdbook build`.
5. Rode `git diff --check`.

Não copie segredos, credenciais, chaves privadas ou caminhos privados
desnecessários para o livro publicado.
