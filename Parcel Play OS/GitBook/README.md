# PlayOS — Documentação para GitBook

Esta pasta contém uma base Markdown organizada para ser conectada ao GitBook
por Git Sync. Ela não publica um site sozinha e não contém credenciais,
tokens ou configuração de uma organização GitBook.

## Como usar

1. Crie uma conta em [app.gitbook.com](https://app.gitbook.com/).
2. Crie um Docs site e uma seção para o PlayOS.
3. Configure **Git Sync** com o repositório GitHub ou GitLab.
4. Aponte a sincronização para esta pasta.
5. Revise a prévia e publique o site pela interface do GitBook.

O GitBook mantém o conteúdo em páginas e grupos. Neste repositório, `README.md`
é a página inicial e `SUMMARY.md` documenta a árvore proposta para a seção.

## Escopo

O conteúdo é uma síntese navegável dos documentos canônicos do PlayOS. A fonte
de verdade continua na raiz do projeto, em `supervised_learning/`, nos
catálogos e nos artefatos de `build/`.

Estados técnicos seguem o vocabulário do projeto: `fact`, `inference`,
`decision`, `proposal`, `implementation`, `result` e `unknown`.

## Comandos úteis

```sh
git diff --check
git status --short
```

O GitBook CLI é opcional e exige Node.js 18 ou posterior:

```sh
npm install @gitbook/cli -g
gitbook --version
gitbook login
gitbook whoami
```

Não execute comandos de autenticação sem uma decisão explícita de conectar
este checkout a uma conta GitBook.

