# Patchset FreeBSD → Linux vanilla 7.1.8

Área exclusiva para preparar patches inspirados no FreeBSD 15 `sys/kern` para
o Linux upstream 7.1.8 usado pelo Parcel Play OS.

O objetivo é traduzir hipóteses e testes para mecanismos Linux existentes. O
patchset não copia subsistemas internos FreeBSD.

## Estado da série

| Patch | Conteúdo | Estado |
|---|---|---|
| 0001 | regras de tradução FreeBSD/Linux | pronto para revisão |
| 0002 | bootconfig opt-in de initcalls | pronto para revisão |
| 0003 | selftests de sendfile e recursos | pronto para revisão |

Configurações destrutivas estão fora da série automática. Scheduler ULE,
kTLS/VFS e algoritmos só receberão patches funcionais após evidência.

## Descobertas específicas do 7.1.8

A árvore contém nativamente:

- `kernel/sched/ext.c` e selftests `sched_ext`;
- NTSYNC oficial em `drivers/misc/ntsync.c`;
- bootconfig e `kernel/trace/trace_boot.c`;
- framework de fault injection;
- sendfile, splice e kTLS;
- BPF, namespaces, cgroups, seccomp e Landlock.

Assim, ULE deve ser estudado por uma política eBPF `sched_ext`, e não por porte
de `sched_ule.c`. NTSYNC não deve ser reimplementado.

## Estado da fonte local

`Kernels/kernel linux-7.1.8/` declara versão 7.1.8, contém cerca de 93.616
arquivos e 1,8 GiB, mas:

- não possui metadados Git;
- não possui `.config`;
- está em caminho com espaços, rejeitado pelo Kbuild;
- não possui origem, tag ou commit verificáveis localmente.

Ela agora contém a integração PlayOS aplicada e compilada. A área limpa usada
no build é `/home/marcel/kernel-work/playos-7.1.8`; isso resolve os espaços, mas
não substitui a futura obtenção de uma fonte oficial verificável em Git.

O primeiro `bzImage`, os 14 módulos e o initramfs foram produzidos com sucesso.
Consulte `results/BUILD_PLAYOS_7.1.8_2026-08-18.md`.

## Verificação

```bash
./scripts/check-kit.sh
./scripts/check-series.sh --compatibility-only \
  '../Kernels/kernel linux-7.1.8'
```

Em uma árvore oficial preparada:

```bash
./scripts/validate-target.sh /caminho/linux-7.1.8
./scripts/check-series.sh /caminho/linux-7.1.8
./scripts/apply-series.sh --apply /caminho/linux-7.1.8
```

## Reversão

Antes de commits:

```bash
./scripts/reverse-series.sh --reverse /caminho/linux-7.1.8
```

Depois de commits, usar `git revert`.

## Segurança

O fragmento `config/parcel-lab.config` é somente para VM/laboratório. Ele não
faz parte da série automática. O kernel vanilla baseline e um kernel de
fallback devem permanecer disponíveis.
