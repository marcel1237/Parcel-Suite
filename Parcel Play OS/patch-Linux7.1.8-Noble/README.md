# Linux 7.1.8 → Ubuntu Noble 6.8.4

Série de backports Linux nativos selecionados para enriquecer o kernel PlayOS
Noble sem misturar subsistemas grandes ou ABI incompatível.

## Primeiro backport: NTSYNC

NTSYNC foi selecionado porque possui driver isolado, UAPI documentada e
selftest upstream. O código-base vem de `Kernels/kernel linux-7.1.8`.

Adaptações exigidas pelo Noble 6.8.4:

- `kzalloc_obj()` → `kzalloc(sizeof(...), GFP_KERNEL)`;
- `kmalloc_flex()` → `kmalloc(struct_size(...), GFP_KERNEL)`;
- API nova `FD_PREPARE` → fluxo 6.8 com `get_unused_fd_flags()`,
  `anon_inode_getfile()` e `fd_install()`.

O recurso é configurado como módulo (`CONFIG_NTSYNC=m`) para permitir rollback
e impedir que um backport de gaming se torne dependência obrigatória do boot.

## Fora desta série inicial

`sched_ext` não será copiado diretamente. No 7.1.8 ele envolve scheduler, BPF,
tracepoints, UAPI e extensa suíte de testes. Um backport para 6.8 exige série
upstream própria, revisão de segurança e regressão de scheduler.

## Estado

`implementation`: aplicado à fonte Noble e compilado como módulo com BTF.
O selftest userspace também compila. A execução funcional e o boot permanecem
pendentes porque o kernel atualmente em execução não oferece `/dev/ntsync`.

Veja `results/VALIDACAO_NTSYNC_2026-08-19.md` para os limites exatos da
evidência.
