# Como publicar no GitBook

## Fluxo oficial

O GitBook oferece três caminhos principais: editar no editor visual, trabalhar
com um agente ou sincronizar um repositório GitHub/GitLab. Este diretório foi
preparado para o terceiro caminho.

1. Crie uma organização e um Docs site no GitBook.
2. Crie uma seção para a documentação do PlayOS.
3. Em **Git Sync**, autorize GitHub ou GitLab e escolha o repositório.
4. Configure esta pasta como o diretório da seção.
5. Abra um pull request para revisar alterações antes do merge.
6. Use **Preview** para conferir a renderização.
7. Publique somente depois de revisar links, frontmatter e blocos GitBook.

O Git Sync é bidirecional: commits no repositório e alterações feitas no
editor do GitBook podem ser sincronizados. A configuração de acesso, domínio,
visibilidade e publicação permanece no GitBook hospedado.

## Segurança

Não coloque tokens, cookies, chaves ou arquivos `.env` neste diretório. Para
uso do CLI, autentique somente no ambiente local apropriado e prefira variáveis
de ambiente ou o armazenamento seguro do próprio CLI.

## Limite local

Não há um servidor GitBook local equivalente ao `mdbook build`. A validação
local desta pasta cobre Markdown, links relativos, estrutura e higiene Git;
a renderização final deve ser conferida no Preview do GitBook.

