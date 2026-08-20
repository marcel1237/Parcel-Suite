# Manifesto — PlayOS Kernel 7.1.8 com perfil Noble

## Baselines

- origem do kernel: Linux vanilla 7.1.8;
- política/configuração de distribuição: Ubuntu Noble 6.8.4 amd64 Generic;
- produto: PlayOS Kernel 2;
- fallback preservado: PlayOS Kernel 1 sobre Noble 6.8.4;
- licença dos patches de kernel: GPL-2.0 compatível com a árvore Linux.

## Série

1. identidade PlayOS Kernel 2;
2. documentação de estudo FreeBSD/Linux;
3. amostra inerte de bootconfig para initcalls;
4. selftests não destrutivos PlayOS/FreeBSD para sendfile, Landlock, cgroup v2,
   namespaces, seccomp, PSI e AppArmor.

## Configuração

O arquivo completo em `config/ubuntu-noble-generic-7.1.8.config` foi produzido
exportando annotations Noble para `amd64/generic`, removendo chaves Canonical
privadas, desativando Rust/fault injection e reconciliando com `olddefconfig`
do Linux 7.1.8. NTSYNC, BTF e sched_ext estão habilitados.

## Limites

- não contém ainda todo o empacotamento `debian/` da Canonical;
- não promete ABI de módulos Ubuntu 6.8;
- DKMS, Secure Boot, initramfs, pacote Debian e boot são gates pendentes;
- “mais novo que Resolute 7.0” descreve a versão upstream, não prova melhor
  estabilidade, suporte ou compatibilidade.
- em 20/08/2026, 7.1.9 já era a stable atual; 7.1.8 permanece como baseline
  local solicitado e deve ter uma atualização incremental posterior.
