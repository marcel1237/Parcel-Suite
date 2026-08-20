# PlayOS Kernel 7.1.8 com perfil Ubuntu Noble

ID: `KB-PLAYOS-KERNEL-718`

- tipo: `implementation`
- confiança: `high`
- estado: `build-in-progress`
- verificado em: `2026-08-20`
- fontes: `SRC-PLAYOS-KERNEL2-MIGRATION`, `SRC-LINUX718-BUILD`,
  `SRC-RESOLUTE-VERIFY`

## Decisão de baseline

Backports no Noble continuam produzindo Linux 6.8.4. Para criar um kernel cuja
versão-base seja realmente 7.1.8, o PlayOS Kernel 2 usa Linux vanilla 7.1.8 e
transporta para ele a política Ubuntu Noble Generic e os patches PlayOS.
O PlayOS Kernel 1 permanece como fallback 6.8.4.

## Patchset reproduzível

`patch-Noble-PlayOS-Kernel-7.1.8/` contém identidade, configuração completa,
documentação, bootconfig, selftests e scripts de identificação, verificação,
aplicação e preparação. A série passou `git apply --check` contra um alvo 7.1.8
reconstruído sem as alterações locais e produziu `7.1.8-playos-kernel2`.

O perfil mantém AppArmor, Landlock, seccomp, namespaces, cgroup/BPF, DRM,
framebuffer console, kTLS e NTSYNC; BTF habilita sched_ext. Rust e fault
injection permanecem fora do perfil de produção atual.

## Comparação com Resolute

Ubuntu 26.04 Resolute foi lançado com Linux 7.0. O 7.1.8 é posterior, mas em
20/08/2026 kernel.org já listava 7.1.9 como stable e 7.2 como mainline. Logo,
“mais novo” é fato de versão; “melhor” permanece não determinado até boot,
regressão, segurança, empacotamento e hardware.

## Limites

O forward-port não herda ABI de módulos 6.8 nem suporte Canonical. Chaves
Canonical privadas foram removidas; Secure Boot exigirá uma chave PlayOS.
Build, initramfs, pacote Debian, DKMS, boot e runtime são gates independentes.
