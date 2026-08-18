# Verificação oficial do kernel Ubuntu Resolute

**Data:** 18 de agosto de 2026  
**Resultado:** Ubuntu 26.04 LTS Resolute Raccoon usa o kernel Linux 7.0.

## Evidência oficial

A Equipe de Kernel da Canonical anunciou que o Ubuntu 26.04 LTS seria entregue
com a versão final do Linux 7.0. O anúncio de lançamento do Ubuntu confirma que
o Resolute Raccoon 26.04 LTS foi publicado em 23 de abril de 2026. O changelog
oficial do pacote `linux` no Launchpad registra, entre outras revisões,
`linux (7.0.0-6.6) resolute`.

Fontes primárias:

- [Anúncio da Equipe de Kernel: Linux 7.0 no Resolute](https://discourse.ubuntu.com/t/26-04-lts-resolute-raccoon-shipping-with-the-final-7-0-linux-kernel/80838)
- [Lançamento do Ubuntu 26.04 LTS](https://discourse.ubuntu.com/t/ubuntu-26-04-resolute-raccoon-lts-released/80833)
- [Changelog oficial do pacote linux no Launchpad](https://launchpad.net/ubuntu/%2Bsource/linux/%2Bchangelog)
- [Cronograma do kernel Resolute](https://discourse.ubuntu.com/t/26-04-resolute-raccoon-kernel-schedule/75827)

O planejamento inicial mencionava `6.20`, mas o upstream adotou a numeração
7.0. A versão final do Ubuntu deve ser identificada pelo pacote publicado e não
pela designação preliminar do cronograma.

## Comparação com a pasta local

| Propriedade | Resolute oficial | Pasta local auditada |
|---|---|---|
| distribuição | Ubuntu 26.04 LTS Resolute | conteúdo Ubuntu Noble |
| kernel | Linux 7.0 | Linux 6.8.4 |
| pacote | série `7.0.0-*` para `resolute` | `6.8.0-30.30` para `noble` |
| data de referência | abril de 2026 | abril de 2024 |
| aptidão como baseline | correta quando fixada em revisão oficial | inadequada |

A pasta `Kernels/ubuntu 26 resolute kernel/` tem remote com o nome Resolute,
mas seu checkout raso está no commit
`74134bfb6b720ca18a73931662cbcc8170ef1bed` e contém código Noble 6.8. Isso
prova que o conteúdo local está incorreto ou desatualizado; o nome do diretório
e a URL do remote não alteram a identidade do checkout.

## Impacto nos trabalhos realizados

- Os três patches em `patch-FreeBSD-Ubuntu/` passaram em
  `git apply --check` somente contra a cópia local Linux 6.8.
- Esse resultado é uma checagem de compatibilidade sintática, não uma validação
  contra Ubuntu Resolute.
- Afirmações sobre ausência de `sched_ext`, NTSYNC ou outras APIs referem-se
  exclusivamente à cópia Noble 6.8 auditada.
- Antes da aplicação final, toda a série deve ser reavaliada e testada contra
  uma árvore oficial Ubuntu Resolute Linux 7.0.

## Critérios obrigatórios para o novo baseline

1. obter a árvore oficial em caminho sem espaços nem dois-pontos;
2. fixar branch, commit completo e remote;
3. confirmar `VERSION = 7` e `PATCHLEVEL = 0` no `Makefile`;
4. confirmar `resolute` no primeiro registro de `debian.master/changelog`;
5. usar clone com o histórico necessário, não o checkout raso atual;
6. registrar `make kernelversion`, configuração e hashes no manifesto;
7. repetir `git apply --check`, build, boot em VM e testes funcionais;
8. revisar novamente `sched_ext`, NTSYNC e as APIs tocadas pela série.

## Veredito

O usuário está correto: o alvo real é Linux 7.0. A árvore local 6.8 deve ser
mantida apenas como referência histórica de compatibilidade ou substituída por
um checkout oficial correto. Nenhum patch pode ser declarado pronto para o
Resolute enquanto não passar pelo baseline 7.0.
