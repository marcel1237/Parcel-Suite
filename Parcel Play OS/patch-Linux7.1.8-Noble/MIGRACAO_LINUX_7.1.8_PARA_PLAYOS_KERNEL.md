# Migração Linux 7.1.8 para PlayOS Kernel

Data da auditoria: 2026-08-19

## Regra de encerramento da fonte 7.1.8

A árvore `Kernels/kernel linux-7.1.8` não deve ser removida até que:

1. os patches aplicados existam fora dela;
2. fontes e licenças estejam preservadas nos patches;
3. cada candidato relevante tenha classificação explícita;
4. o PlayOS Kernel compile, inicialize e possua rollback;
5. hashes ou uma referência upstream permitam reconstruir a origem.

Esta auditoria não autoriza apagar a árvore.

## Aplicado

### NTSYNC

- estado: `implementation`, módulo compilado com BTF;
- origem funcional: Linux 7.1.8;
- destino: Noble 6.8.4;
- pendente: assinatura, boot e 11 selftests no kernel produzido.

### mseal

- estado: `implementation`, objetos MM e selftest compilados;
- base escolhida: implementação inicial oficial Linux 6.10, por compatibilidade
  com o modelo `vm_flags` do Noble;
- referência de maturidade: Linux 7.1.8;
- destino: syscall 462 no PlayOS Kernel x86-64 e arquiteturas que usam a tabela
  asm-generic;
- link concluído no `bzImage`; pendentes boot e selftest no kernel produzido.

### Identidade

- novo sufixo: `-playos-kernel1`;
- motivo: diferenciar o produto sem chamar um kernel Linux de FreeBSD.

## Já existente no Noble

Não devem ser copiados como subsistemas completos:

- io_uring, kTLS, Landlock e DAMON;
- DAMON_RECLAIM e LRU_GEN/MGLRU;
- BPF JIT e BPF LSM;
- IOMMUFD, HID-BPF e NETKIT;
- DRM accelerator framework e TCP-AO;
- fs-verity, fscrypt, userfaultfd, futex/futex2, pidfd e memfd.

Somente correções pontuais com commit upstream identificado e teste específico
podem ser consideradas.

## Adiado como projeto separado

### sched_ext

Cruza scheduler, BPF, verifier, tracing, UAPI e selftests. Não cabe em um patch
isolado e precisa de baseline de latência, throughput e segurança.

### Rust e EXECMEM

Exigem toolchain e infraestrutura de kernel coerentes. Atualizar apenas partes
produziria uma árvore sem suporte reproduzível.

### Atualizações gráficas completas

DRM, amdgpu, i915 e xe mudam em conjunto. No Ubuntu, drivers devem vir
preferencialmente de uma pilha HWE/OEM compatível, ou de uma série upstream com
matriz de hardware definida.

## Rejeitado no perfil atual

### DRM Panic

A configuração inicial exige `!FRAMEBUFFER_CONSOLE`, enquanto o Generic atual
usa `CONFIG_FRAMEBUFFER_CONSOLE=y`. Desabilitar o console de framebuffer para
uma tela de panic suportada por poucos drivers reduziria a recuperação.

### fwctl

No 7.1.8 seus consumidores locais incluem CXL e drivers mlx5, bnxt e PDS. O
framework sem essas stacks não oferece benefício; portar todas elas equivale a
atualizar grandes subsistemas de hardware.

### Novas raízes sem alvo de produto

- `gpib`: instrumentação específica;
- `dibs`: infraestrutura sem caso de uso PlayOS definido;
- `resctrl`: implementação ligada a MPAM e arquiteturas específicas.

Não serão importadas apenas para aumentar a quantidade de código.

## Drivers de hardware

Diferenças de IDs e drivers individuais só podem ser avaliadas após definir a
matriz mínima de GPU, rede, áudio, armazenamento, Wi-Fi e plataformas. Presença
na árvore 7.1.8 não comprova compatibilidade com as APIs 6.8.

## Próximos gates

1. concluir sem erros o alvo global `modules` e eliminar artefatos antigos;
2. confirmar assinatura de todos os módulos, incluindo NTSYNC;
3. gerar initramfs e checksums;
4. inicializar em QEMU ou hardware de teste;
5. executar kselftests NTSYNC, mseal e regressões MM;
6. congelar a matriz de hardware antes de selecionar drivers adicionais;
7. criar snapshot ou referência reproduzível antes de remover a fonte 7.1.8.
