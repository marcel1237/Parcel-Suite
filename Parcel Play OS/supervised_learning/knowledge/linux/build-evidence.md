# Evidências dos builds Linux

ID: `KB-LINUX-BUILDS`

- tipo: `result`
- confiança: `high`
- estado: `current`
- verificado em: `2026-08-19`
- fontes: `SRC-NOBLE-BUILD`, `SRC-LINUX718-BUILD`, `SRC-RESOLUTE-VERIFY`,
  `SRC-PLAYOS-KERNEL1`

## Ubuntu Noble 6.8.4

O build mais representativo usou `amd64-generic` exportado das annotations
Ubuntu. Resultado registrado:

- release `6.8.4-playos-freebsd-lab1+`;
- `bzImage` concluído;
- 6.467 módulos `.ko` instalados em staging;
- BTF no kernel e módulos;
- kTLS como módulo;
- AppArmor e Landlock habilitados;
- fault injection desativado no perfil de produção;
- initramfs genérico de 286 MiB;
- hashes verificados;
- sem boot em QEMU/hardware.

Rust permaneceu desativado porque a versão exata exigida pelo kernel 6.8 não
estava disponível na toolchain local compatível.

## Linux vanilla 7.1.8

O build de laboratório registrou:

- release `7.1.8-playos-freebsd-lab1`;
- kernel e 14 módulos em staging;
- NTSYNC e kTLS;
- BTF com toolchain local pahole 1.31;
- `CONFIG_SCHED_CLASS_EXT=y`;
- initramfs e hashes;
- sem boot em QEMU/hardware.

## Interpretação

Esses resultados provam compilabilidade e geração de artefatos, não correção em
runtime. QEMU não foi instalado porque a instalação global exigia autenticação
sudo interativa. Nenhum desses builds deve ser chamado de release de produção.

## Incremento NTSYNC no Noble

Em 2026-08-19, o NTSYNC do Linux 7.1.8 foi integrado à fonte Noble e compilado
isoladamente como `ntsync.ko`, com BTF e `vermagic` do build Noble. O selftest
userspace compilou, mas seus 11 casos não puderam abrir `/dev/ntsync` no kernel
host. Esse incremento ainda não faz parte da evidência do build Generic completo
acima; exige novo build completo, boot, carregamento e regressão.

## PlayOS Kernel 1

Em 2026-08-19, o Noble recebeu NTSYNC, `mseal` e a identidade de produto
`6.8.4-playos-kernel1+`. O `bzImage` de 14.914.048 bytes foi ligado com BTF,
contém `__x64_sys_mseal` e `do_mseal`, e possui SHA-256
`03f2675bcc4e5bdbccf9e2cbeeeb8b01d4b998a22e769a0996ac1a61e55752ca`.
O módulo NTSYNC foi reconstruído com BTF e `vermagic` da nova release.

O alvo global `modules` ainda não é evidência aprovada: o diretório incremental
continha módulos da identidade anterior e a reconstrução paralela sofreu falhas
em dependências temporárias `fixdep`. Uma reparação serial está em execução.
Também faltam initramfs, assinatura, boot e testes executados sob este kernel.
