# Base supervisionada BSD/Linux/PlayOS

Diretriz principal para agentes e novas sessões: [`../AGENTS.md`](../AGENTS.md).

Esta pasta é a camada de conhecimento verificável do PlayOS. Sua prioridade é
BSD — sobretudo FreeBSD 15.1 — e sua relação correta com Linux e o PlayOS.

Ela não autoriza uma IA a tratar proposta como código pronto. Toda resposta
deve distinguir:

- `fact`: confirmado em fonte ou execução;
- `inference`: conclusão derivada de evidências citadas;
- `decision`: direção aprovada do projeto;
- `proposal`: ideia ainda não implementada;
- `implementation`: alteração existente e localizável;
- `result`: medição ou teste executado;
- `unknown`: informação ainda não determinada.

## Como consultar

1. Comece por [INDEX.md](INDEX.md).
2. Localize o assunto em `catalog/topics.tsv`.
3. Consulte `knowledge/` para a síntese rastreável.
4. Abra a fonte indicada em `catalog/sources.tsv`.
5. Para estado real, confirme `catalog/implementations.tsv` e resultados.
6. Se não houver evidência, responda “não determinado”.

## Como treinar e avaliar

- `datasets/train.jsonl`: exemplos instrutivos;
- `datasets/validation.jsonl`: perguntas separadas para validação;
- `datasets/adversarial.jsonl`: solicitações que exigem correção ou recusa;
- `evaluations/questions.jsonl`: conjunto de avaliação recuperável;
- `schema/`: contratos dos registros;
- `tools/validate_knowledge.py`: valida estrutura, IDs, fontes e JSONL.

## Regra de portabilidade

FreeBSD e Linux têm kernels, ABIs e modelos internos diferentes. O padrão é:

1. usar o mecanismo nativo já existente;
2. comparar política e comportamento;
3. reimplementar uma ideia por APIs nativas;
4. extrair somente algoritmos pequenos e independentes após revisão de licença;
5. rejeitar porte direto de subsistemas acoplados.

Nunca apresentar `sys/kern` como biblioteca que possa ser adicionada ao Kbuild.

## Baselines conhecidos

- FreeBSD: 15.1-RELEASE-p2, fonte externa completa;
- Ubuntu local nomeado “Resolute”: na realidade Noble Linux 6.8.4;
- Linux vanilla: 7.1.8;
- Resolute oficial: Linux 7.0, ainda sem fonte correspondente na pasta local;
- OpenBSD e NetBSD: conhecimento comparativo documental, sem árvores completas
  auditadas neste corpus.

## Validação

Execute:

```sh
python3 supervised_learning/tools/validate_knowledge.py
```

Consulta lexical local:

```sh
python3 supervised_learning/tools/query_knowledge.py FreeBSD Jails Linux
```

Ou, dentro da pasta, execute `make validate` e `make query-smoke`.

O validador não comprova a verdade técnica; ele comprova que o corpus respeita
o contrato mínimo e que as fontes locais declaradas existem.
