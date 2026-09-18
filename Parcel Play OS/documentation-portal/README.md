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
- visualizador interno de Markdown com conversão para HTML no navegador;
- botão de tela cheia durante a leitura dos documentos;
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

- a renderização usa Markdown básico e não cobre todos os blocos específicos de
  GitBook;
- ao abrir o portal diretamente com `file://`, navegadores podem bloquear
  `fetch` de arquivos locais; sirva o repositório por HTTP para usar o
  visualizador;
- não existe roteamento por documento ou busca full-text semântica;
- portal não foi publicado nem testado visualmente em múltiplos navegadores.

## Próxima evolução

1. adicionar grafo de relações e breadcrumb;
2. exibir fontes, confiança e estado em cada documento;
3. criar busca full-text e build estático reproduzível;
4. executar testes de acessibilidade e responsividade;
5. publicar somente após revisão do conteúdo sensível e dos caminhos locais.
