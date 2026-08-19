# Implementação da base supervisionada BSD/PlayOS

Data: 19 de agosto de 2026

## Resultado

A antiga coleção de duas notas foi convertida em uma base operacional de
conhecimento, recuperação e avaliação, com prioridade para FreeBSD e comparação
controlada com Linux. A validação estrutural e três consultas de fumaça passaram.

## Entregas

- README operacional e índice;
- política de evidência e recusa;
- esquemas JSON para conhecimento e QA;
- 25 fontes canônicas catalogadas;
- inventário de descoberta de 65 documentos relacionados;
- 11 tópicos roteáveis;
- 10 decisões explícitas;
- 7 implementações/propostas com estado e validação;
- 8 entradas de conhecimento técnico;
- 44 exemplos QA: 20 treino, 8 validação, 8 adversariais e 8 avaliação;
- validador sem dependências externas;
- buscador lexical local;
- Makefile para validação e smoke tests;
- correção das duas notas legadas com avisos e links relativos.

## Prioridade BSD aplicada

A cobertura mais profunda foi destinada a:

- identidade e capacidades FreeBSD 15.1-p2;
- mapa de `sys/kern`;
- Jails, VNET, Capsicum, MAC, RACCT/RCTL;
- rede, sendfile, kTLS, armazenamento, OpenZFS e bhyve;
- mapeamento FreeBSD–Linux e regras de portabilidade;
- estratégia FreeBSD no PlayOS;
- diferença de evidência para OpenBSD e NetBSD.

## Correções de confiabilidade

A base agora impede ou sinaliza:

- confusão entre Noble 6.8.4 e Resolute Linux 7.0;
- porte direto de `sys/kern`, ULE, Jails, VFS, mbufs, locks e Newbus;
- inferência de compatibilidade de hardware por presença de código;
- afirmação de que Linuxulator fornece kernel Linux;
- promoção de build sem boot a release de produção;
- benchmarks, FPS, latência ou detalhes Sony sem evidência;
- confusão entre propostas NitroCore e implementações validadas.

## Validação executada

`make -C supervised_learning validate query-smoke` retornou sucesso.

O validador confirmou IDs únicos, JSONL válido, referências conhecidas, fontes
locais existentes, documentos inventariados e caminhos de implementações. As
consultas de fumaça recuperaram corretamente:

- `FreeBSD sys/kern`;
- `Ubuntu Resolute Noble`;
- `Jails namespaces Capsicum`.

## Limites honestos

Esta entrega torna a base útil para consulta/RAG e avaliação inicial, mas não é
um treinamento completo de modelo. Ainda faltam fontes completas OpenBSD e
NetBSD, entradas por símbolo/arquivo FreeBSD, execução FreeBSD em VM, benchmarks
comparativos e expansão do corpus para pelo menos 250 exemplos.

O validador garante consistência estrutural; verdade técnica continua dependendo
das fontes primárias e testes citados.

## Próximo ciclo recomendado

1. Construir e inicializar FreeBSD 15.1 em VM.
2. Registrar hardware virtual, boot, rede, ZFS, Jail, bhyve e Linuxulator.
3. Criar entradas detalhadas para os arquivos críticos de `sys/kern`.
4. Produzir benchmarks FreeBSD versus Noble/7.1.8 com metodologia comum.
5. Adicionar fontes OpenBSD/NetBSD e elevar sua evidência.
6. Expandir QA e adicionar avaliador semântico de respostas.
