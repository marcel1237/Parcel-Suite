# Portal de documentação PlayOS

Primeira versão do portal HTML que unifica a navegação da documentação BSD,
Linux e PlayOS. Ele é estático, local e não foi publicado.

## Arquivos

- `index.html`: estrutura e conteúdo editorial;
- `styles.css`: design responsivo e acessível;
- `app.js`: catálogo visual, busca e filtros.

## Recursos atuais

- apresentação da base supervisionada;
- indicadores de fontes, documentos, entradas e QA;
- 22 documentos prioritários com links diretos;
- busca sem dependências;
- filtros FreeBSD, família BSD, BSD–Linux, PlayOS e evidências;
- painel de estado real dos kernels;
- roadmap BSD;
- layout responsivo e suporte a movimento reduzido.

## Fonte de verdade

O HTML é uma camada de navegação. Os Markdown, catálogos e datasets em
`supervised_learning/` continuam sendo as fontes editáveis e verificáveis.

## Limites desta primeira versão

- catálogo visual ainda está embutido em `app.js`;
- métricas do cabeçalho são atualizadas manualmente;
- Markdown ainda abre como arquivo, sem renderização dentro do portal;
- não existe gerador automático, roteamento por documento ou busca full-text;
- portal não foi publicado nem testado visualmente em múltiplos navegadores.

## Próxima evolução

1. gerar o catálogo HTML a partir dos TSV/JSONL;
2. renderizar Markdown em páginas internas;
3. adicionar grafo de relações e breadcrumb;
4. exibir fontes, confiança e estado em cada documento;
5. criar build estático reproduzível;
6. executar testes de acessibilidade e responsividade;
7. publicar somente após revisão do conteúdo sensível e dos caminhos locais.
