# Estado do portal HTML de documentação

Data: 19 de agosto de 2026

## Concluído nesta primeira versão

Foi criada a central `documentation-portal/` com identidade visual própria,
navegação editorial e acesso direto aos documentos prioritários.

O portal apresenta:

- FreeBSD como eixo principal;
- família BSD e comparação Linux;
- estado real de Noble 6.8.4, Linux 7.1.8, patchset FreeBSD e Resolute;
- busca e filtros no navegador;
- 22 cartões documentais;
- roadmap para boot e validação FreeBSD;
- indicadores da base supervisionada.

## Validações

- HTML analisado sem erro estrutural pelo parser padrão;
- 15 links/assets estáticos no HTML, nenhum caminho ausente;
- todos os caminhos Markdown embutidos no catálogo foram revisados;
- `git diff --check` passou;
- base supervisionada permanece válida com 68 documentos inventariados,
  10 entradas técnicas e 13 tópicos.

O host bloqueou abertura de socket local no sandbox e não possui Node.js para
`node --check`. Por isso esta rodada não inclui preview HTTP nem teste visual de
navegador. O JavaScript é deliberadamente pequeno, sem dependências e usa apenas
dados estáticos locais.

## Decisão

Manter o portal local nesta fase. A próxima etapa deve automatizar sua geração
a partir dos catálogos para evitar divergência entre HTML e Markdown.
