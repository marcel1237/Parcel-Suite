# Evidências dos builds Linux

ID: `KB-LINUX-BUILDS`

- tipo: `result`
- confiança: `high`
- estado: `current`
- verificado em: `2026-08-19`
- fontes: `SRC-NOBLE-BUILD`, `SRC-LINUX718-BUILD`, `SRC-RESOLUTE-VERIFY`

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
