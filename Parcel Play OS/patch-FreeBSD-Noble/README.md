# FreeBSD 15.1 → Ubuntu Noble PlayOS Kernel

Patchset específico para criar o kernel `playos-freebsd` sobre Ubuntu Noble
Linux 6.8. Este trabalho é separado do antigo alvo Ubuntu Resolute.

## Fontes fixadas

| Papel | Revisão |
|---|---|
| alvo Linux | Ubuntu Noble, Linux 6.8.4, pacote base 6.8.0-30.30 |
| commit Linux | `74134bfb6b720ca18a73931662cbcc8170ef1bed` |
| referência FreeBSD | FreeBSD 15.1-RELEASE-p2 |
| commit FreeBSD | `aadd58dddcbc78f4d5594827b46b5633552b15ce` |
| tag FreeBSD | `release/15.1.0-p2` |

Fonte FreeBSD auditada:

```text
/home/marcel/Parcel Suite/Operating Systems/freebsd-15.1.0-p2
```

Essa árvore é referência somente leitura. Nenhuma alteração PlayOS deve ser
feita dentro dela.

## Objetivo

“Cheio de coisas do FreeBSD” significa incorporar capacidades e políticas
úteis, mantendo implementação nativa Linux:

- observabilidade de boot inspirada em boottrace/TSLOG;
- fault injection inspirado em failpoints;
- isolamento inspirado em Jails/VNET/RCTL/Capsicum;
- benchmarks de sendfile/kTLS;
- políticas de recursos inspiradas em RACCT/RCTL;
- pesquisa de scheduler baseada em propriedades do ULE;
- testes de VFS, locks, memória e rede;
- FreeBSD Core virtualizado quando for necessário executar semântica BSD real.

Não significa compilar `sys/kern/*.c` no Kbuild.

## Estado aplicado

A branch no repositório do kernel é:

```text
codex/playos-freebsd-syskern-6.8-lab
```

Ela contém mudanças staged e ainda não commitadas:

- regras de tradução FreeBSD → Linux;
- amostra bootconfig opt-in;
- selftests de capacidades e sendfile;
- identidade `-playos-freebsd-lab1`.

## Dois kernels PlayOS

### Produção

`playos-freebsd` usa mecanismos Linux maduros, diagnóstico seguro e políticas
userspace. Não habilita fault injection nem sanitizers caros.

### Laboratório

`playos-freebsd-lab` habilita fault injection e diagnóstico opt-in, usa ABI e
pacote próprios e só inicia em VM/disco recuperável. KASAN, KCSAN e KCOV serão
variantes separadas.

O kernel Ubuntu Noble oficial permanece instalado como fallback.

## Estrutura

- `MANIFEST.md`: identidade e limites;
- `ROADMAP.md`: ordem de implementação;
- `config/playos-production.config`: recursos Linux equivalentes para produção;
- `config/playos-lab.config`: diagnóstico de laboratório;
- `integration-matrix.tsv`: fonte FreeBSD, destino Linux e maturidade;
- `results/`: builds, boots e benchmarks futuros.

## Regra de promoção

Uma mudança somente entra em produção com problema reproduzível, benchmark,
teste automatizado, proveniência/licença, build, boot em VM e fallback. Recursos
que já existem no Linux são configurados e testados, não duplicados.
