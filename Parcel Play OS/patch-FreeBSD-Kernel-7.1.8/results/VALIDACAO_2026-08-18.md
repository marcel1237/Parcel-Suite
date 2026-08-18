# Validação inicial — Linux vanilla 7.1.8

## Fonte analisada

- caminho: `Kernels/kernel linux-7.1.8/`;
- versão declarada: 7.1.8;
- nome: `Baby Opossum Posse`;
- aproximadamente 93.616 arquivos e 1,8 GiB;
- metadados Git próprios: ausentes;
- `.config`: ausente;
- caminho compatível com Kbuild: não, contém espaços.

Não foi possível confirmar origem, tag ou commit da árvore local. Ela foi usada
somente para análise e compatibilidade estática.

## Reanálise FreeBSD

Foram revisitados os 248 arquivos de `FreeBSD 15/sys/kern`, com foco em
boottrace, falhas, ULE, sendfile, kTLS, Jail, VFS cache, PID, filtros, relógio e
estatísticas. As dependências FreeBSD (`mbuf`, UMA, vnode, VNET, sysctl,
SYSINIT, locks e epoch) confirmam que não há arquivo candidato a cópia direta.

## Recursos confirmados no Linux 7.1.8

- `sched_ext` e seus selftests;
- NTSYNC oficial;
- bootconfig/ftrace;
- fault injection;
- sendfile/splice;
- kTLS;
- BPF;
- namespaces/cgroups/seccomp/Landlock.

## Validações executadas

| Validação | Resultado |
|---|---|
| scripts em `bash -n` | PASS |
| estrutura e série | PASS |
| três patches em `git apply --check --no-index` | PASS |
| whitespace estrito | PASS |
| aplicação em cópia temporária | PASS |
| compilação do selftest com warnings como erro | PASS |
| integridade de dados por sendfile | PASS |
| inventário de recursos | PASS |
| build da ferramenta bootconfig | PASS |
| testes oficiais bootconfig | 75 PASS, 0 FAIL |
| parsing do perfil Parcel | PASS |

O inventário foi executado no kernel do host, não em um kernel 7.1.8
compilado. O host expôs `sched_ext` desabilitado; NTSYNC e kTLS não estavam
carregados; fault injection foi corretamente marcado como lab-only ausente.

## Não executado

- build completo do Linux 7.1.8;
- boot em VM ou hardware;
- selftests `sched_ext` sobre o kernel-alvo;
- fault injection real;
- NTSYNC funcional;
- kTLS em rede/NIC;
- benchmark ULE versus política `sched_ext`;
- assinatura, instalação ou empacotamento.

## Veredito

A série inicial é aplicável à estrutura local e está pronta para revisão contra
uma fonte oficial verificável. Patches funcionais invasivos permanecem
bloqueados até build, boot e benchmarks do baseline.
