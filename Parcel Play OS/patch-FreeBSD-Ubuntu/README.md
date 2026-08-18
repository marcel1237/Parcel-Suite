# Patchset FreeBSD → Ubuntu Resolute

Este diretório é a área exclusiva de preparação dos patches inspirados no
`Kernels/FreeBSD 15/sys/kern` para o kernel Ubuntu Resolute do Parcel Play OS.

O alvo oficial é Ubuntu 26.04 LTS Resolute com Linux 7.0. A validação já feita
contra a árvore local Noble 6.8 é somente uma checagem de compatibilidade e não
valida o patchset para o Resolute real.

O patchset traduz conceitos FreeBSD para APIs Linux. Ele **não copia** os
subsistemas FreeBSD e não afirma que ULE, Jails, VNET, Capsicum, sendfile ou
kTLS FreeBSD foram portados.

## Estado

| Item | Estado | Aplicação |
|---|---|---|
| 0001 — documentação da tradução | pronto para revisão | produção/lab |
| 0002 — amostra bootconfig | pronto para revisão | lab |
| 0003 — selftests Parcel | pronto para revisão | build/teste |
| 0004 — identidade `-playos-freebsd-lab1` | aplicado no laboratório 6.8 | somente lab |
| configuração fault injection | fragmento preparado | somente lab/VM |
| scheduler inspirado no ULE | bloqueado | requer Resolute real com `sched_ext` |
| alterações kTLS/VFS | bloqueadas | requer benchmark em rede/hardware real |
| algoritmos no kernel | bloqueados | requer consumidor e KUnit |

## Estrutura

```text
patch-FreeBSD-Ubuntu/
├── README.md
├── MANIFEST.md
├── series
├── patches/
├── config/
├── bootconfig/
├── scripts/
├── tests/
├── results/
└── proposals/
```

## Requisitos do alvo

- clone/worktree oficial Ubuntu Resolute;
- caminho completo sem espaços nem dois-pontos;
- árvore Git limpa;
- branch e commit fixados;
- `debian.master/changelog` declarando `resolute`;
- `Makefile` declarando Linux `7.0`;
- espaço para build e VM de teste;
- kernel Ubuntu oficial mantido como fallback.

A árvore atualmente localizada em
`Kernels/ubuntu 26 resolute kernel/` não atende aos requisitos: é um clone raso
no commit `74134bfb6b720ca18a73931662cbcc8170ef1bed`, contém Noble 6.8 e está em
caminho com espaços.

## Verificação

Em um alvo Resolute correto:

```bash
./scripts/validate-target.sh /caminho/sem-espacos/ubuntu-resolute
./scripts/check-series.sh /caminho/sem-espacos/ubuntu-resolute
```

Para verificar compatibilidade sintática contra a árvore 6.8 local, sem
confundi-la com Resolute:

```bash
./scripts/check-series.sh --allow-non-resolute \
  '../Kernels/ubuntu 26 resolute kernel'
```

## Aplicação

A aplicação é deliberadamente explícita:

```bash
./scripts/apply-series.sh --apply /caminho/sem-espacos/ubuntu-resolute
```

O script valida identidade, limpeza da árvore e todos os patches antes de
escrever. Ele usa `git apply`, não cria commits e não habilita fault injection.

Depois da aplicação, revisar e criar um commit por patch. Não agrupar a série
inteira em um commit opaco.

## Configuração de laboratório

`config/parcel-lab.config` é um fragmento de intenção. Ele não integra sozinho
um flavour ao empacotamento Ubuntu e não faz parte da série automática. Antes
de usá-lo, deve ser convertido para políticas por arquitetura/flavour em
`debian.master/config/annotations`.

Nunca habilitar o fragmento no kernel generic de produção.

## Reversão

Antes de criar commits, os patches podem ser revertidos na ordem inversa:

```bash
./scripts/reverse-series.sh --reverse /caminho/sem-espacos/ubuntu-resolute
```

Se os patches já tiverem sido commitados, a reversão deve ocorrer por
`git revert`, preservando o histórico.

## Gates

Nenhum patch funcional novo entra em `series` sem:

1. problema reproduzível;
2. baseline oficial fixado;
3. teste antes/depois;
4. licença e autoria conhecidas;
5. rollback documentado;
6. boot em VM;
7. ausência de regressão relevante;
8. kernel oficial disponível como fallback.
