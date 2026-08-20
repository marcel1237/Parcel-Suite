# Diretriz principal para Inteligências Artificiais — PlayOS

Este é o arquivo de entrada obrigatório para qualquer IA, agente de código ou
assistente que trabalhe neste projeto.

## Regra de inicialização

Ao iniciar uma nova conversa ou tarefa:

1. Leia este arquivo completamente.
2. Não comece analisando todo o repositório.
3. Leia `supervised_learning/README.md`.
4. Leia `supervised_learning/INDEX.md`.
5. Consulte `supervised_learning/catalog/topics.tsv` para localizar o assunto.
6. Consulte somente as entradas de `supervised_learning/knowledge/` relacionadas
   à solicitação.
7. Confirme fontes em `supervised_learning/catalog/sources.tsv`.
8. Confirme o estado real em `supervised_learning/catalog/implementations.tsv`
   e `supervised_learning/catalog/decisions.tsv`.
9. Só analise código-fonte ou outros documentos quando a pergunta exigir
   evidência adicional, implementação ou atualização da base.

O usuário pode simplificar o início dizendo apenas:

> Leia `AGENTS.md` e continue o PlayOS.

## Objetivo do projeto

PlayOS é um sistema operacional em desenvolvimento que estuda e integra ideias
de BSD e Linux sem fingir que seus kernels possuem ABI compatível. A prioridade
de pesquisa é BSD, sobretudo FreeBSD 15.1, mantendo Linux como plataforma,
comparação e possível backend do produto.

O objetivo não é copiar kernels inteiros uns dentro dos outros. O objetivo é
obter comportamentos melhores por mecanismos nativos, experimentos medidos,
patches pequenos e arquitetura userspace quando apropriado.

## Prioridade de assuntos

Ordem padrão de dedicação:

1. FreeBSD 15.1: kernel, userland, boot, Jails, segurança, rede, storage,
   virtualização, instalador e compatibilidade.
2. Comparação FreeBSD–Linux com evidência reproduzível.
3. OpenBSD e NetBSD, elevando sua cobertura somente após obter fontes
   primárias auditáveis.
4. Arquitetura PlayOS e contratos comuns entre backends.
5. Linux Noble 6.8.4 e Linux vanilla 7.1.8 modificados.
6. Protótipos NitroCore e demais propostas experimentais.

Prioridade não significa aceitar uma proposta sem prova.

## Baselines que nunca devem ser confundidos

- Fonte FreeBSD completa: FreeBSD 15.1-RELEASE-p2 em
  `/home/marcel/Parcel Suite/Operating Systems/freebsd-15.1.0-p2`.
- `Kernels/FreeBSD 15` é uma cópia parcial; não substitui a fonte completa.
- `Kernels/ubuntu 26 resolute kernel` contém Ubuntu Noble Linux 6.8.4 apesar do
  nome histórico da pasta.
- Ubuntu Resolute oficial foi identificado pelo projeto como Linux 7.0; sua
  fonte correspondente ainda não está presente como baseline correto.
- `Kernels/kernel linux-7.1.8` é Linux vanilla 7.1.8.
- Builds Noble e 7.1.8 foram concluídos, mas ainda não foram inicializados em
  QEMU ou hardware como kernels PlayOS validados.

Se uma informação de versão divergir, confirme no código e atualize a base. Não
repita silenciosamente nomes de pastas como se fossem identidade técnica.

## Hierarquia de evidência

Use esta ordem:

1. código-fonte identificado por versão/commit e linhas;
2. resultado reproduzível de build ou teste;
3. documentação primária upstream;
4. relatório local que cite fontes anteriores;
5. inferência explicitamente identificada;
6. proposta ainda sem validação.

O arquivo `PROGRESSO.md` é um registro cronológico, não substitui fonte
primária. Documentos históricos ou conceituais não devem superar resultados
mais recentes.

## Vocabulário obrigatório de estado

Toda conclusão relevante deve ser classificada como uma destas categorias:

- `fact`: confirmado em fonte ou execução;
- `inference`: conclusão derivada de evidência;
- `decision`: direção aprovada do projeto;
- `proposal`: ideia ainda não implementada;
- `implementation`: código ou patch existente;
- `result`: teste ou medição executada;
- `unknown`: não determinado pela base atual.

Não use como sinônimos:

- documentado;
- proposto;
- implementado;
- compilado;
- empacotado;
- inicializado;
- testado em runtime;
- testado em hardware;
- pronto para produção.

## Regra FreeBSD–Linux

FreeBSD `sys/kern` não é uma biblioteca e não pode ser simplesmente adicionado
ao Kbuild Linux. FreeBSD e Linux possuem estruturas, APIs, locking, memória,
VFS, rede, scheduler, drivers e ABI internas diferentes.

Fluxo permitido:

1. definir o comportamento desejado;
2. localizar o mecanismo FreeBSD e sua evidência;
3. procurar equivalente nativo no kernel alvo;
4. criar baseline sem patch;
5. comparar política e comportamento;
6. reimplementar somente a menor ideia necessária usando APIs nativas;
7. revisar licença;
8. testar correção, segurança, regressão e desempenho;
9. rejeitar a mudança se ela não superar o mecanismo existente.

Não portar diretamente para Linux:

- ULE;
- Jails/prison/VNET;
- VFS/vnode/namei;
- mbufs e stack de rede;
- Newbus/KOBJ;
- mutexes e primitives SMP BSD;
- UMA ou page queues completas;
- subsistemas `sys/kern` acoplados.

No sentido Linux→FreeBSD, não copiar código GPL indiscriminadamente. Preferir
especificação comportamental, implementação BSD nativa, wrappers pequenos e
clean-room quando necessário. LinuxKPI não é conversor universal.

## Equivalências que exigem cuidado

- Jail não é apenas “namespace FreeBSD”.
- Namespaces Linux não equivalem sozinhos a Jail.
- Capsicum não é Landlock.
- RCTL não é cgroup v2 com outro nome.
- `mbuf` não é `sk_buff` intercambiável.
- vnode não é inode/dentry intercambiável.
- UMA não é SLUB intercambiável.
- bhyve não é KVM com a mesma interface.
- Linuxulator não fornece um kernel Linux real.
- AF_XDP não é porte de `bpf_zerocopy.c`.
- ARC/dbuf não deve ser transplantado para controlar page cache Linux.

Compare metas, semântica, invariantes e resultados; não somente nomes.

## Protocolo por tipo de pedido

### Se o usuário pedir explicação ou análise

1. Consulte a base supervisionada.
2. Responda com estado e fontes.
3. Abra código somente para confirmar lacunas ou detalhes solicitados.
4. Não altere código sem pedido de implementação.

### Se o usuário pedir auditoria

1. Compare documentação, catálogos, código e resultados.
2. Liste divergências por gravidade.
3. Diferencie erro, risco, dívida técnica e falta de evidência.
4. Não declare produção sem todos os gates.

### Se o usuário pedir implementação

1. Confirme baseline e branch.
2. Preserve mudanças existentes do usuário.
3. Faça a menor alteração nativa e revisável.
4. Crie patch quando o trabalho pertencer aos patchsets.
5. Compile/teste proporcionalmente ao risco.
6. Atualize documentação, catálogo de implementação e progresso.
7. Registre limitações e próximos gates.

### Se o usuário pedir comparação de sistemas

Use a mesma versão, hardware, configuração, workload, repetição e métrica. Se
isso não existir, forneça análise estrutural e marque desempenho como
`unknown`. Nunca invente números.

### Se o usuário pedir recomendação

Separe recomendação para desktop, servidor, laboratório, hardware e produto.
Explique trade-offs e grau de evidência. Recomendações que causem muito trabalho
ou risco precisam de critérios verificáveis.

## Protocolo de documentação

Toda análise material deve enriquecer a documentação, sem criar prosa duplicada.

1. Atualize uma entrada existente quando o assunto já possuir fonte canônica.
2. Crie nova entrada em `supervised_learning/knowledge/` quando houver novo
   conhecimento estável.
3. Adicione fonte em `supervised_learning/catalog/sources.tsv` quando ela for canônica.
4. Adicione ou atualize tópico em `supervised_learning/catalog/topics.tsv`.
5. Registre decisão em `supervised_learning/catalog/decisions.tsv`.
6. Registre código, patch ou artefato em `supervised_learning/catalog/implementations.tsv`.
7. Atualize `supervised_learning/catalog/document_inventory.tsv` para novos documentos relevantes.
8. Crie exemplos QA quando a conclusão prevenir erro recorrente.
9. Atualize `PROGRESSO.md` com resultado, validação e limite.
10. Execute o validador.

Cada entrada técnica deve informar ID, tipo, confiança, estado, data e fontes.
Links internos devem ser relativos quando possível.

## Portal HTML

O portal inicial está em `documentation-portal/index.html`. Ele é uma camada de
navegação; Markdown, TSV e JSONL continuam sendo as fontes de verdade.

Ao adicionar conteúdo importante:

1. atualize primeiro a base Markdown/catalogada;
2. depois atualize ou gere o portal;
3. verifique todos os links;
4. não publique caminhos privados ou conteúdo sensível;
5. não considere o HTML mais atual que os catálogos.

## Validação obrigatória

Antes de concluir mudanças na base:

```sh
python3 supervised_learning/tools/validate_knowledge.py
```

Smoke tests:

```sh
make -C supervised_learning query-smoke
```

Busca local:

```sh
python3 supervised_learning/tools/query_knowledge.py FreeBSD Jails Linux
```

Para alterações de código, execute também build/testes específicos e
`git diff --check`. Não esconda warnings relevantes.

## Regras contra alucinação

- Se a evidência não existe, responda `não determinado`.
- Não invente benchmark, FPS, latência ou compatibilidade.
- Não atribua detalhes internos à Sony/PlayStation sem fonte primária.
- Não prometa compatibilidade total de GPU, áudio, anti-cheat ou hardware.
- Presença de driver não comprova funcionamento.
- Build bem-sucedido não comprova boot.
- Selftest executado no kernel host não comprova o novo kernel.
- Patch estático não comprova implementação funcional.
- Documento de arquitetura não comprova produto entregue.

## Segurança e preservação

- Trate as fontes externas FreeBSD como somente leitura, salvo autorização
  explícita para alterá-las.
- Não instale kernel, módulos, bootloader ou entrada GRUB no host sem autorização
  explícita.
- Não sobrescreva mudanças existentes do usuário.
- Não use operações Git destrutivas.
- Builds devem usar staging e diretórios isolados.
- Credenciais, chaves privadas e senhas nunca entram na documentação.
- Mudanças de boot, partição, Secure Boot ou hardware exigem confirmação clara.

## Estado mínimo que deve ser comunicado

Ao finalizar uma tarefa, informe de forma objetiva:

1. o que foi concluído;
2. quais arquivos foram alterados;
3. quais testes passaram;
4. warnings e riscos encontrados;
5. o que permanece pendente;
6. qual é o próximo gate técnico.

## Arquivos de entrada rápida

- `supervised_learning/README.md`: regras de consulta;
- `supervised_learning/INDEX.md`: índice temático;
- `supervised_learning/catalog/topics.tsv`: roteamento;
- `supervised_learning/catalog/sources.tsv`: fontes;
- `supervised_learning/catalog/decisions.tsv`: decisões;
- `supervised_learning/catalog/implementations.tsv`: estado real;
- `supervised_learning/governance/EVIDENCE_POLICY.md`: política de evidência;
- `supervised_learning/ROADMAP_BSD_KNOWLEDGE.md`: prioridade BSD;
- `documentation-portal/index.html`: visão visual;
- `PROGRESSO.md`: histórico.

## Princípio final

Leia primeiro a base organizada. Investigue o repositório somente para responder
à pergunta atual, confirmar evidência ou implementar uma mudança autorizada.
Profundidade é desejada; repetição e análise indiscriminada não são.
