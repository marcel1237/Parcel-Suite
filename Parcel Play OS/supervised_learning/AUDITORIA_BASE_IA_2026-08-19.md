# Auditoria da base `supervised_learning`

Data: 19 de agosto de 2026

## Veredito

A hipótese está confirmada. No estado atual, `supervised_learning` não é uma
base suficiente para uma IA responder, planejar ou implementar trabalho no
PlayOS com segurança. Ela contém notas introdutórias úteis, mas não constitui
aprendizado supervisionado, corpus técnico rastreável nem base RAG pronta.

Nota de prontidão para consulta autônoma por IA: **2/10**.

## Dimensão observada

- 2 arquivos Markdown;
- 88 linhas;
- 1.114 palavras;
- nenhum README ou índice da coleção;
- nenhum registro JSONL/JSON/YAML/TSV de pergunta, resposta ou evidência;
- nenhuma taxonomia, esquema, metadado ou teste de recuperação;
- um único link, absoluto em formato `file://`, portanto não portátil;
- cerca de 65 documentos relevantes permanecem espalhados fora da pasta.

## O que a pasta consegue responder

Ela oferece uma descrição breve de oito temas:

- BPF zero-copy;
- páginas wired;
- ARC/dbuf do OpenZFS;
- Jails/prison0;
- áudio;
- ULE;
- SYSINIT/Newbus;
- mutexes adaptativos.

Os arquivos FreeBSD citados existem na fonte completa 15.1-p2. Também foram
confirmados diretamente símbolos como `mi_startup`, `sysinit_list`, `prison0`,
`ts_rltick`, `vm_page_wire` e os limites `dbuf_cache_lowater/hiwater`.

Isso comprova que parte do resumo parte de elementos reais. Porém, a confirmação
só foi possível consultando novamente o código externo, porque a pasta não
registra caminhos completos, linhas, commit, trechos mínimos nem hashes.

## Prova de consultas

Perguntas plausíveis feitas somente contra a pasta e seus resultados:

| Pergunta | Resultado atual |
|---|---|
| Qual commit exato do FreeBSD foi analisado? | Não responde |
| Quais linhas implementam `mi_startup` e sua ordenação? | Não responde |
| Quais invariantes e locks protegem `struct prison`? | Não responde |
| Qual é o equivalente Linux já existente para cada mecanismo? | Parcial e informal |
| O que deve ser portado, adaptado ou rejeitado? | Não responde sistematicamente |
| Qual patch PlayOS implementa cada lição? | Não responde |
| O código NitroCore compila e qual teste comprova a função? | Não responde |
| Quais afirmações são fato, hipótese ou meta? | Não distingue |
| Quais riscos de ABI, licença, segurança e manutenção existem? | Não responde |
| Quais resultados de benchmark sustentam ganho de desempenho? | Não há resultados |
| Como reproduzir a análise em outra máquina? | Não responde |
| Qual documento deve ser recuperado para uma pergunta específica? | Não há índice |

Uma IA poderia repetir o texto geral, mas tenderia a inventar detalhes quando
solicitada a produzir código, patches, números, decisões ou garantias.

## Problemas críticos

### 1. Nome incorreto para o material existente

Aprendizado supervisionado normalmente exige exemplos rotulados, como entrada,
resposta esperada, evidência, classe e critérios de avaliação. Os dois arquivos
atuais são notas narrativas. Podem alimentar uma base de conhecimento, mas ainda
não são um dataset supervisionado.

### 2. Ausência de proveniência

Não constam versão/commit por observação, caminho canônico, intervalo de linhas,
data da leitura, arquitetura, configuração do kernel ou método de validação.
Assim, não é possível detectar quando a fonte muda ou reproduzir conclusões.

Baseline verificado nesta auditoria:

- FreeBSD: `release/15.1.0-p2`, commit já identificado pelo projeto como
  `aadd58dddcbc78f4d5594827b46b5633552b15ce`;
- fonte: `/home/marcel/Parcel Suite/Operating Systems/freebsd-15.1.0-p2/sys`.

### 3. Fato, inferência e proposta estão misturados

Existência de `prison0` é fato verificável. Fazer um Nitro-Root equivalente é
uma proposta. Afirmar que uma camada Newbus permitirá drivers FreeBSD sobre
hardware Linux é uma hipótese de altíssimo risco. Os documentos apresentam
essas categorias lado a lado sem rótulos de confiança.

### 4. Afirmações sem fonte ou validação

As afirmações sobre aproximadamente 85 syscalls da Sony, detalhes internos do
I/O do PS5 e hypervisor/XOM não possuem referências. Da mesma forma, prometer
login abaixo de dois segundos ou áudio idêntico a console não possui baseline,
hardware, métrica ou experimento.

### 5. Traduções técnicas perigosamente simplificadas

- FreeBSD `sys/kern` não é uma biblioteca que possa ser portada diretamente;
- mutexes FreeBSD não devem ser “injetados” no Linux sem respeitar locking,
  preempção, PI, lockdep e modelo de memória Linux;
- Newbus/KOBJ e o driver model Linux não possuem ABI intercambiável;
- `vm_page_wire` não justifica tornar páginas de jogos não evacuáveis;
- namespaces Linux não são uma cópia de Jails e exigem cgroup, LSM, seccomp,
  capabilities, mount propagation e política userspace;
- AF_XDP é uma tecnologia Linux própria, não um porte de `bpf_zerocopy.c`;
- ARC/dbuf e page cache Linux possuem semânticas e consumidores diferentes.

Esses temas podem gerar bons estudos comparativos, mas não instruções diretas
de implementação.

### 6. Cobertura muito pequena

Faltam, entre outros: boot completo, VFS, VM, UMA, epoch/SMR, RCU Linux,
network stack, kTLS/sendfile, Capsicum, MAC/LSM, RCTL/cgroup, scheduler,
OpenZFS, drivers, ABI/syscalls, compatibilidade, build, testes, empacotamento,
Live ISO e resultados dos patchsets Noble/7.1.8.

### 7. Conteúdo do projeto não foi incorporado

Há dezenas de relatórios relevantes fora desta pasta, inclusive auditorias,
matrizes, estudos de `sys/kern`, builds e validações. Uma IA limitada a
`supervised_learning` não consegue descobri-los nem saber qual é atual,
superseded, aprovado ou apenas conceitual.

## Estrutura necessária

A coleção deve separar base de conhecimento e dataset supervisionado:

```text
supervised_learning/
  README.md
  INDEX.md
  schema/
    knowledge-entry.schema.json
    qa-example.schema.json
  catalog/
    sources.tsv
    topics.tsv
    decisions.tsv
    implementations.tsv
  knowledge/
    freebsd/
    linux/
    mappings/
    playos/
  datasets/
    train.jsonl
    validation.jsonl
    adversarial.jsonl
  evaluations/
    questions.jsonl
    expected-results.jsonl
    reports/
  archive/
```

Cada entrada técnica deve conter, no mínimo:

- ID estável;
- título e assunto;
- tipo: fato, inferência, decisão, proposta, implementação ou resultado;
- sistema, versão, commit e arquitetura;
- fonte, caminho e linhas;
- resumo e explicação técnica;
- equivalente no outro kernel;
- restrições e diferenças semânticas;
- aplicação PlayOS e estado real;
- patch/arquivo relacionado;
- teste, comando e resultado;
- riscos;
- nível de confiança;
- data da última verificação;
- relações com outras entradas.

## Critérios para considerar a pasta utilizável

1. Todo fato crítico possui fonte local reproduzível ou referência primária.
2. Toda proposta está explicitamente separada de implementação concluída.
3. Todos os patchsets e resultados têm entrada no catálogo.
4. Perguntas de validação possuem respostas esperadas e evidências obrigatórias.
5. Respostas sem evidência devem resultar em “não determinado”, não inferência.
6. Links relativos funcionam após mover ou clonar o projeto.
7. Um validador detecta IDs duplicados, caminhos quebrados e campos ausentes.
8. A avaliação mede recuperação, fidelidade, atualidade e recusa correta.
9. Pelo menos 90% das perguntas críticas do corpus de validação são respondidas
   com a fonte correta e sem confundir Noble 6.8, Linux 7.1.8 e Resolute 7.0.

## Prioridade recomendada

1. Criar esquema, índice e catálogo de fontes.
2. Importar e classificar os relatórios existentes, sem copiá-los cegamente.
3. Criar entradas rastreáveis para FreeBSD 15.1, Noble 6.8 e Linux 7.1.8.
4. Mapear cada mecanismo FreeBSD para equivalente Linux e decisão PlayOS.
5. Vincular propostas aos patches, builds, testes e pendências reais.
6. Produzir exemplos QA com perguntas negativas e obrigação de recusa.
7. Executar avaliação automatizada antes de chamar a coleção de utilizável.

## Conclusão

O problema não é apenas falta de volume. Falta um contrato que ensine a IA a
distinguir fonte, conclusão, proposta, código existente, resultado medido e
incerteza. Enriquecer somente com mais prosa aumentaria o risco de respostas
convincentes e erradas. O próximo passo correto é construir primeiro o esquema,
o índice, o catálogo e o conjunto de avaliação; depois povoar a base com o
material técnico já existente no projeto.
