# Portal de documentação PlayOS

Primeira versão do portal HTML que unifica a navegação da documentação BSD,
Linux e PlayOS. Ele é estático, local e não foi publicado.

## Arquivos

- `index.html`: estrutura e conteúdo editorial;
- `styles.css`: design responsivo e acessível;
- `app.js`: busca, filtros e renderização;
- `generate_portal.py`: gera dados pelos catálogos;
- `generated-data.js`: saída gerada, não editar manualmente;
- `validate_portal.py`: valida IDs, métricas e caminhos;
- `Makefile`: geração e validação em um comando.

## Recursos atuais

- apresentação da base supervisionada;
- indicadores de fontes, documentos, entradas e QA;
- todos os documentos do inventário com links diretos;
- busca sem dependências;
- filtros FreeBSD, família BSD, BSD–Linux, PlayOS e evidências;
- painel de estado real dos kernels;
- roadmap BSD;
- layout responsivo e suporte a movimento reduzido.

## Fonte de verdade

O HTML é uma camada de navegação. Os Markdown, catálogos e datasets em
`supervised_learning/` continuam sendo as fontes editáveis e verificáveis.

## Atualização

Depois de alterar Markdown ou catálogos:

```sh
make -C documentation-portal validate
```

O comando regenera cartões e métricas, valida a base supervisionada e verifica
todos os caminhos usados pelo portal.

## Limites atuais

- Markdown ainda abre como arquivo, sem renderização dentro do portal;
- não existe roteamento por documento ou busca full-text semântica;
- portal não foi publicado nem testado visualmente em múltiplos navegadores.

## Próxima evolução

1. renderizar Markdown em páginas internas;
2. adicionar grafo de relações e breadcrumb;
3. exibir fontes, confiança e estado em cada documento;
4. criar busca full-text e build estático reproduzível;
5. executar testes de acessibilidade e responsividade;
6. publicar somente após revisão do conteúdo sensível e dos caminhos locais.
