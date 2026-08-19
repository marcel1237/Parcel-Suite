# Build PlayOS Linux 7.1.8 com estudos FreeBSD

**Data:** 18 de agosto de 2026  
**Resultado:** kernel, módulos e initramfs compilados  
**Release:** `7.1.8-playos-freebsd-lab1`

## Fonte e alterações

A fonte principal em `Kernels/kernel linux-7.1.8` recebeu identidade PlayOS,
documentação de tradução FreeBSD/Linux, bootconfig de initcalls e selftests de
sendfile, Landlock, recursos e isolamento. A árvore não possui metadados Git;
portanto sua origem e integridade upstream ainda não são verificáveis.

A área limpa de build fica em `/home/marcel/kernel-work/playos-7.1.8`, dividida
em `source`, `out` e `stage`. Alterações futuras devem ocorrer na fonte
principal e ser sincronizadas antes do build.

## Configuração

Foi usado `x86_64_defconfig` com os fragmentos PlayOS de produção e laboratório.
Bootconfig, BPF/JIT, cgroups, namespaces, seccomp, Landlock, AppArmor, PSI,
tracing, kTLS, NTSYNC e fault injection entraram na configuração. NTSYNC e kTLS
foram produzidos como módulos.

`sched_ext` entrou no segundo build com `CONFIG_DEBUG_INFO_BTF=y` e
`CONFIG_SCHED_CLASS_EXT=y`. Como a instalação global exigia autenticação sudo,
o `pahole` 1.31 e `libdwarves1` foram baixados dos pacotes Ubuntu e extraídos
em `/home/marcel/kernel-work/playos-7.1.8/toolchain`, sem alterar o sistema.

## Validação

- segundo `bzImage` concluído com BTF e sched_ext, reconhecido como kernel x86
  bootável e EFI 32/64;
- 14 módulos com BTF compilados e instalados somente no staging;
- initramfs genérico Dracut de 48.058.317 bytes;
- sendfile AF_UNIX: PASS;
- consulta Landlock: PASS, ABI 8 no kernel host;
- inventário: PASS com skips esperados para recursos não carregados;
- cgroup v2, namespaces, seccomp, PSI e AppArmor: PASS no kernel host;
- hashes SHA-256: PASS.

Os selftests ainda não rodaram no novo kernel. Não houve instalação em GRUB,
alteração de `/lib/modules` do host, assinatura ou boot em VM/hardware.

## Artefatos

Os artefatos estão em `build/playos-7.1.8/output/`: kernel, config, System.map,
initramfs e `SHA256SUMS`.

## Próximo gate

Produzir pacote Debian e iniciar os artefatos em QEMU com rootfs descartável.
QEMU continua ausente porque a instalação global exige autenticação sudo. O
kernel oficial deve permanecer como fallback.
