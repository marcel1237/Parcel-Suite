# Primeiro build do kernel PlayOS FreeBSD Lab

**Data:** 18 de agosto de 2026  
**Resultado:** `bzImage` compilado com sucesso  
**Kernel release:** `6.8.4-playos-freebsd-lab1-g74134bfb6b72-dirty`

## Baselines

- Linux: Ubuntu Noble 6.8.4, commit
  `74134bfb6b720ca18a73931662cbcc8170ef1bed`;
- FreeBSD de referência: 15.1-RELEASE-p2, commit
  `aadd58dddcbc78f4d5594827b46b5633552b15ce`;
- branch de trabalho: `codex/playos-freebsd-syskern-6.8-lab`;
- worktree de build: `/home/marcel/kernel-work/playos-noble/source`;
- saída: `/home/marcel/kernel-work/playos-noble/out`;
- compilador: GCC 15.2.0;
- paralelismo: 2.

O marcador `dirty` é esperado porque as mudanças continuam staged e ainda não
foram commitadas. Esse artefato é laboratório e não deve ser instalado como
kernel de produção.

## Configuração

O build usou `x86_64_defconfig` como base, seguido dos fragmentos
`playos-production.config` e `playos-lab.config`. Isso valida integração técnica,
mas ainda não equivale à configuração Ubuntu Noble Generic/annotations.

Confirmados no `.config`:

- namespaces e user/PID/network namespaces;
- cgroup v2 e cgroup BPF;
- seccomp/filter;
- Landlock e AppArmor;
- kTLS e TLS device;
- ftrace, tracepoints, PSI, bootconfig, kprobes e BPF syscall;
- fault injection, failslab e fail_page_alloc no laboratório.

## Mudanças do kernel

Além da identidade, documentação, bootconfig e selftests, o build revelou
incompatibilidades reais da árvore Noble antiga com GCC 15. Foram corrigidas:

1. `lsm_key_alloc()` limitado a `security.c`;
2. dois helpers AppArmor limitados a `file.c`;
3. precedência explicitada na condição ASPM do r8169;
4. validação correta do array `cpufreq_driver.name`;
5. EFI libstub x86 compilado explicitamente como GNU11;
6. kernel x86 comprimido compilado explicitamente como GNU11.

Os quatro primeiros eliminam warnings promovidos a erro. Os dois últimos
preservam o padrão de linguagem esperado pelo Linux 6.8 diante do default C23
do GCC 15.

## Selftests

Quatro programas/roteiros passaram pela infraestrutura kselftest:

| Teste | Resultado |
|---|---|
| sendfile sobre AF_UNIX | PASS |
| consulta da ABI Landlock | PASS, ABI 8 no kernel host |
| inventário geral | PASS, fault injection SKIP esperado |
| isolamento | PASS para cgroup v2, namespaces, seccomp, PSI e AppArmor |

Esses testes rodam no kernel do host, não no `bzImage` recém-compilado. A prova
do novo kernel depende de boot em VM.

## Artefatos

Copiados para `build/playos-noble/output/`:

| Arquivo | SHA-256 |
|---|---|
| `vmlinuz-6.8.4-playos-freebsd-lab1` | `cc659c8229d607758fd238a4ab57580ffd533fe83c760bf0cd54ec50270bae46` |
| `config-6.8.4-playos-freebsd-lab1` | `f52c587c67c24977fb4ba7de40a59a2199fc5fe7e075f3d3f968c894a8d407ab` |
| `System.map-6.8.4-playos-freebsd-lab1` | `9af3af7e7d1d4553e8cb72caedb7026e2268a0a9e83ae8c11b33002fda7970d0` |
| `initramfs-6.8.4-playos-freebsd-lab1.img` | `d87accf72b8878798d06645c2332170b5e9782999ef832f2b52096c2481e9022` |

Tamanhos na saída de build:

- `bzImage`: 14.050.304 bytes;
- `vmlinux`: 53.911.432 bytes.

O comando `file` reconheceu o artefato como kernel x86 bootável, relocável,
com protocolo 2.15 e handoff EFI 32/64 bits.

## O que ainda não foi feito

- commit da série;
- configuração Ubuntu Generic real;
- empacotamento Debian;
- assinatura/Secure Boot;
- instalação no GRUB;
- boot em QEMU/hardware;
- execução dos selftests no novo kernel;
- benchmark Linux versus FreeBSD;
- aplicação de scheduler, VFS ou rede derivados do FreeBSD.

## Módulos

O build completo de módulos e o `modules_install` passaram. A instalação foi
direcionada para uma área de staging isolada, sem modificar `/lib/modules` do
host:

`/home/marcel/kernel-work/playos-noble/stage/lib/modules/6.8.4-playos-freebsd-lab1-g74134bfb6b72-dirty/`

Foram instalados nove módulos (EFI variables, telemetria térmica x86 e módulos
de netfilter/NAT habilitados pela configuração atual). A quantidade pequena é
consequência do `x86_64_defconfig`; a configuração Ubuntu Generic deverá gerar
um conjunto muito maior.

## Initramfs

O Dracut 110 gerou uma imagem genérica de 46 MiB com microcode Intel/AMD,
systemd-initrd, suporte a rootfs em bloco, virtiofs e o diretório de módulos da
nova release. `lsinitrd` confirmou a estrutura CPIO e a inclusão do módulo
`efivarfs`. O Dracut avisou que não havia a release no `/lib/modules` do host e
que não pôde atualizar o cache global de `console-setup`; isso é esperado na
geração isolada e não modificou o host. O boot em VM continuará sendo o teste
decisivo da imagem.

## Próximo gate

Instalar uma ferramenta de virtualização ou levar os artefatos a um host com
QEMU, iniciar o kernel com rootfs descartável, confirmar `uname -r`, executar
os selftests dentro dele e testar fault injection
somente após snapshot. O kernel Ubuntu oficial deve permanecer como fallback.
