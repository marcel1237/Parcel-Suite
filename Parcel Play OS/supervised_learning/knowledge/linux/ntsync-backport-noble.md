# Backport NTSYNC do Linux 7.1.8 para Noble

ID: `KB-LINUX-NTSYNC-NOBLE`

- tipo: `implementation`
- confiança: `high`
- estado: `implemented-no-runtime`
- verificado em: `2026-08-19`
- fontes: `SRC-NTSYNC-NOBLE`, `SRC-LINUX718-BUILD`, `SRC-NOBLE-BUILD`

## O que foi incorporado

O driver NTSYNC, sua UAPI, documentação e kselftest do Linux 7.1.8 foram
portados para a árvore Noble 6.8.4. APIs de alocação e publicação de descritores
que não existem no 6.8 foram adaptadas para equivalentes nativos dessa versão.
O recurso fica em módulo por meio de `CONFIG_NTSYNC=m`, facilitando rollback.

## Evidência disponível

`ntsync.ko` compilou inicialmente para `6.8.4-playos-freebsd-lab1+` e depois foi
reconstruído para `6.8.4-playos-kernel1+`; ambos contêm BTF gerado com pahole
1.31. O selftest userspace compilou, mas não pode ser executado de forma
funcional no kernel host porque `/dev/ntsync` não existe nele.

Portanto, o estado correto é compilável e integrado, não validado em runtime e
não pronto para produção.

## Limite arquitetural

`sched_ext` também existe no Linux 7.1.8, mas não foi transplantado. Ele cruza
scheduler, BPF, tracing, UAPI e testes; uma cópia direta para 6.8 teria risco de
ABI e concorrência muito superior ao benefício. Deve ser tratado como estudo e
série de backports independente.
