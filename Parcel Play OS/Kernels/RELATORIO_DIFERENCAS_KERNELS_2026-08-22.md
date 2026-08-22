# Relatório integral das diferenças em `Kernels/`

- ID: `PLAYOS-KERNEL-OVERLAY-AUDIT-001`
- tipo: `audit`
- confiança: `high`
- estado: `current`
- data: 2026-08-22
- método: comparação byte a byte (`rsync -rcni` e `cmp`) contra baselines
  externos identificados em `config/kernel-sources.conf`
- fontes: árvores externas somente leitura, Git da fonte Noble e patchsets
  PlayOS existentes

## Resultado executivo

`Kernels/` passou a ser um conjunto de overlays: guarda somente arquivos novos
ou diferentes. Os originais completos ficam fora do projeto e são configurados
em `config/kernel-sources.conf`.

| Overlay | Baseline externo | Entradas comparadas antes | Divergentes preservados |
|---|---|---:|---:|
| Linux 7.1.8 | `Linux Kernels/kernel linux-7.1.8` | 93.723 | 9 |
| Noble 6.8.4 | `Linux Kernels/ubuntu 26 resolute kernel` | 83.640 | 40 |
| FreeBSD 15 | `Operating Systems/freebsd-15.1.0-p2/sys` | 248 | 0 |
| FreeBSD 16 | `Operating Systems/freebsd-src release 16 canary/sys` | 250 | 0 |
| Conectiva 4 | `Operating Systems/cl4/src/kernel-2.2.5-23cl` | 4.722 | 0 |

Diretórios `.git`, objetos de build e metadados não são alterações de fonte e
não integram o overlay. FreeBSD e Conectiva ficaram sem código interno porque
suas cópias eram idênticas aos baselines externos.

## Linux vanilla 7.1.8 — 9 arquivos

| Arquivo | Tipo | Alteração detalhada |
|---|---|---|
| `localversion-playos` | novo | Acrescenta a identidade local `-playos-kernel2` à release do kernel. |
| `Documentation/admin-guide/parcel-freebsd-study.rst` | novo | Define FreeBSD como fonte de hipóteses, mapeia boottrace, failpoints, ULE, sendfile/kTLS, Jails/VNET, Capsicum e namecache para mecanismos Linux e proíbe porte direto de internos BSD. |
| `tools/bootconfig/samples/parcel-initcall-trace.bconf` | novo | Cria tracing opt-in de initcalls e `sched_process_exec`, com instância `parcel_boot` e buffer de 4096 KiB. |
| `tools/testing/selftests/Makefile` | modificado | Registra `parcel_freebsd` na suíte global de kselftests. |
| `tools/testing/selftests/parcel_freebsd/Makefile` | novo | Compila testes C de sendfile/Landlock e registra dois testes shell, com warnings tratados como erro. |
| `tools/testing/selftests/parcel_freebsd/parcel_features.sh` | novo | Emite TAP com oito sondagens: tracing, cgroups, namespaces, política BPF, sched_ext, NTSYNC, kTLS e fault injection. Recursos opcionais ausentes viram `SKIP`. |
| `tools/testing/selftests/parcel_freebsd/parcel_isolation.sh` | novo | Emite TAP para cgroup v2, namespaces, seccomp, PSI e AppArmor. |
| `tools/testing/selftests/parcel_freebsd/parcel_landlock.c` | novo | Consulta a versão da ABI Landlock; distingue disponibilidade, ausência suportada como `SKIP` e erro real. |
| `tools/testing/selftests/parcel_freebsd/parcel_sendfile.c` | novo | Valida integridade de 16 KiB enviados de arquivo temporário para `socketpair(AF_UNIX)` por `sendfile`. |

## Ubuntu Noble Linux 6.8.4 — 40 arquivos

### Identidade, documentação e estudos PlayOS

| Arquivo | Tipo | Alteração detalhada |
|---|---|---|
| `localversion-playos` | novo | Define identidade local do PlayOS Kernel 1. |
| `Documentation/admin-guide/parcel-freebsd-study.rst` | novo | Mesma política comparativa FreeBSD→Linux usada no 7.1.8. |
| `tools/bootconfig/samples/parcel-initcall-trace.bconf` | novo | Mesmo tracing opt-in de initcalls/process exec usado no 7.1.8. |
| `tools/testing/selftests/Makefile` | modificado | Registra as suítes `drivers/ntsync` e `parcel_freebsd`. |
| `tools/testing/selftests/parcel_freebsd/Makefile` | novo | Regras de compilação/execução dos testes PlayOS. |
| `tools/testing/selftests/parcel_freebsd/parcel_features.sh` | novo | Sondagens TAP de recursos do perfil PlayOS. |
| `tools/testing/selftests/parcel_freebsd/parcel_isolation.sh` | novo | Sondagens TAP de isolamento Linux. |
| `tools/testing/selftests/parcel_freebsd/parcel_landlock.c` | novo | Consulta reproduzível da ABI Landlock. |
| `tools/testing/selftests/parcel_freebsd/parcel_sendfile.c` | novo | Teste de integridade do caminho `sendfile`. |

### Backport NTSYNC do Linux 7.1.8

| Arquivo | Tipo | Alteração detalhada |
|---|---|---|
| `Documentation/userspace-api/index.rst` | modificado | Inclui as páginas `mseal` e `ntsync` no índice userspace. |
| `Documentation/userspace-api/ntsync.rst` | novo | Documenta dispositivo, objetos e ioctls da emulação de primitivas NT. |
| `drivers/misc/Kconfig` | modificado | Adiciona opção tristate `CONFIG_NTSYNC`. |
| `drivers/misc/Makefile` | modificado | Liga `ntsync.o` quando `CONFIG_NTSYNC` está habilitado. |
| `drivers/misc/ntsync.c` | novo | Implementa o driver NTSYNC backportado: semáforos, mutexes, eventos, waits e interface de arquivo/ioctl. |
| `include/uapi/linux/ntsync.h` | novo | Define ABI pública, estruturas e ioctls NTSYNC. |
| `tools/testing/selftests/drivers/ntsync/.gitignore` | novo | Ignora o executável produzido pelo selftest. |
| `tools/testing/selftests/drivers/ntsync/Makefile` | novo | Integra a compilação do teste NTSYNC ao kselftest. |
| `tools/testing/selftests/drivers/ntsync/config` | novo | Exige `CONFIG_NTSYNC` para o teste. |
| `tools/testing/selftests/drivers/ntsync/ntsync.c` | novo | Suíte TAP extensa de criação, sinalização, ownership e espera dos objetos NT. |

### Backport `mseal`

| Arquivo | Tipo | Alteração detalhada |
|---|---|---|
| `Documentation/userspace-api/mseal.rst` | novo | Documenta semântica, restrições e uso da syscall `mseal`. |
| `arch/x86/entry/syscalls/syscall_64.tbl` | modificado | Reserva syscall x86-64 número 462 para `mseal`. |
| `include/uapi/asm-generic/unistd.h` | modificado | Publica `__NR_mseal=462` e eleva `__NR_syscalls` para 463. |
| `include/linux/syscalls.h` | modificado | Declara `sys_mseal(start, len, flags)`. |
| `include/linux/mm.h` | modificado | Reserva `VM_SEALED` no bit 63 em 64 bits. |
| `mm/Makefile` | modificado | Compila `mseal.o` para MMU em arquiteturas 64-bit. |
| `mm/internal.h` | modificado | Declara validação de flags e helpers que bloqueiam mudanças em intervalos selados; fornece fallback em 32-bit. |
| `mm/mseal.c` | novo | Implementa selagem de VMAs, valida intervalos e impede alterações destrutivas posteriores. |
| `mm/madvise.c` | modificado | Recusa conselhos destrutivos sobre mapeamentos selados e libera corretamente o lock no erro. |
| `mm/mmap.c` | modificado | Recusa `munmap` de regiões seladas. |
| `mm/mprotect.c` | modificado | Recusa mudança de proteção/metadados após selagem. |
| `mm/mremap.c` | modificado | Recusa movimentação ou redimensionamento de intervalos selados. |
| `tools/testing/selftests/mm/Makefile` | modificado | Inclui `mseal_test` na suíte MM. |
| `tools/testing/selftests/mm/mseal_test.c` | novo | Exercita syscall, alinhamento, lacunas, VMA split/merge e bloqueio de `munmap`, `mprotect`, `mremap` e `madvise`. |

### Correções de compilação/compatibilidade da árvore Noble

| Arquivo | Tipo | Alteração detalhada |
|---|---|---|
| `arch/x86/boot/compressed/Makefile` | modificado | Força `-std=gnu11` no decompressor x86 para compatibilidade do compilador usado. |
| `drivers/firmware/efi/libstub/Makefile` | modificado | Força `-std=gnu11` no EFI stub x86. |
| `drivers/cpufreq/cpufreq.c` | modificado | Troca teste incorreto do array `name` por teste de `name[0]`. |
| `drivers/net/ethernet/realtek/r8169_main.c` | modificado | Parentetiza explicitamente a expressão ASPM, preservando precedência e eliminando warning ambíguo. |
| `security/apparmor/file.c` | modificado | Torna dois helpers locais `static`, evitando símbolos globais sem protótipo. |
| `security/security.c` | modificado | Torna `lsm_key_alloc` local `static`. |
| `tools/lib/bpf/libbpf.c` | modificado | Usa `const char *` em `next_path`, corrigindo descarte de qualificador. |

## Como auditar e podar novamente

```sh
scripts/prune-kernel-overlays.sh --audit
scripts/prune-kernel-overlays.sh --apply --confirm-prune-identical
```

O modo `--apply` remove somente arquivos regulares cujo conteúdo seja igual ao
arquivo relativo no baseline. Arquivos diferentes e arquivos sem equivalente
externo são preservados. Diretórios vazios são removidos depois.

## Como reconstruir uma árvore completa para build

Nunca compile diretamente o overlay. Copie o baseline para staging sem espaços
e sobreponha as mudanças:

```sh
cp -a "$PLAYOS_LINUX_718_BASE/." /var/tmp/playos-kernel-work/source/
cp -a 'Kernels/kernel linux-7.1.8/.' /var/tmp/playos-kernel-work/source/
```

Primeiro carregue `config/kernel-sources.conf` ou use uma ferramenta que o
faça. O mesmo padrão vale para Noble. FreeBSD permanece referência externa
somente leitura e atualmente não possui overlay de código.

## Limites

- `result`: comparação estática de conteúdo concluída.
- `implementation`: overlays e configuração de caminhos existem.
- `unknown`: a árvore reconstruída por composição ainda não foi recompilada ou
  inicializada após esta poda.
- O caminho FreeBSD 16 é uma árvore canary, não uma release estável fixada.
