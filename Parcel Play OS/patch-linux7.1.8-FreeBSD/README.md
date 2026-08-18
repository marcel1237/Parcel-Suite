# Patchset Linux 7.1.8 → FreeBSD 15.1-p2

Este diretório prepara patches nativos para o FreeBSD inspirados em mecanismos
do Linux 7.1.8. Nenhum código GPL do Linux é copiado para o FreeBSD.

## Fonte FreeBSD auditada

- caminho: `/home/marcel/Parcel Suite/Operating Systems/freebsd-15.1.0-p2`;
- versão: FreeBSD 15.1-RELEASE-p2;
- tag: `release/15.1.0-p2`;
- commit: `aadd58dddcbc78f4d5594827b46b5633552b15ce`;
- remote: `https://git.FreeBSD.org/src.git`;
- checkout raso, destacado e limpo durante a auditoria.

## Série inicial

| Patch | Conteúdo | Risco |
|---|---|---|
| 0001 | manual de tradução Linux/FreeBSD | baixo |
| 0002 | configuração amd64 `PARCEL-LAB` | laboratório |
| 0003 | testes ATF de baseline | baixo |

O perfil `PARCEL-LAB` inclui `GENERIC-DEBUG`, TSLOG e KCOV. Ele não é kernel de
produção e nunca deve substituir automaticamente `GENERIC`.

## Descoberta principal

FreeBSD já possui equivalentes de grande parte dos mecanismos Linux estudados:

- epoch/SMR para leitura concorrente;
- ULE e múltiplos schedulers selecionáveis;
- RACCT/RCTL;
- Jails, VNET e Capsicum;
- sendfile e kTLS;
- failpoints;
- KASAN, KCSAN, KMSAN e KCOV;
- DTrace, HWPMC, KTR, TSLOG, WITNESS e INVARIANTS;
- MAC Framework;
- LinuxKPI para drivers, não para importar subsistemas GPL arbitrários.

Logo, “o melhor do Linux” significa preencher lacunas comprovadas usando
arquitetura FreeBSD, não duplicar recursos existentes.

## Verificação

Contra a fonte fornecida, sem escrever nela:

```bash
./scripts/check-series.sh --compatibility-only \
  '/home/marcel/Parcel Suite/Operating Systems/freebsd-15.1.0-p2'
```

Aplicação final exige clone/worktree limpo em caminho sem espaços:

```bash
./scripts/validate-target.sh /caminho/freebsd-15.1-p2
./scripts/apply-series.sh --apply /caminho/freebsd-15.1-p2
```

## Segurança e licença

- patches são BSD-2-Clause;
- não copiar código GPL-2.0 do Linux;
- Linux é referência de comportamento, testes e arquitetura;
- fault injection e sanitizers ficam em VM/laboratório;
- manter kernel GENERIC funcional como fallback;
- novos patches funcionais precisam de benchmarks e revisão por subsistema.
