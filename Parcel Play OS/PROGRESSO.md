# Registro de Progresso: Parcel Play OS

Este arquivo documenta as ações realizadas durante o desenvolvimento do projeto.

## [2026-08-19] - Portal documental automatizado pelos catálogos
- **Geração**: `generate_portal.py` transforma o inventário e metadados supervisionados em `generated-data.js` determinístico.
- **Cobertura**: O portal deixou de conter somente 22 cartões manuais e passou a incluir todo documento inventariado.
- **Métricas**: Fontes, documentos, entradas de conhecimento, tópicos e QA agora são calculados, não digitados no HTML.
- **Validação**: `validate_portal.py` verifica payload, IDs, contagens, assets e todos os links documentais.
- **Comando Único**: `make -C documentation-portal validate` regenera o portal, valida a base e verifica caminhos.
- **Governança**: Portal registrado como implementação; HTML continua camada visual, enquanto Markdown/TSV/JSONL permanecem fontes de verdade.

## [2026-08-19] - Diretriz única de entrada para Inteligências Artificiais
- **Entrada Automática**: Criado `AGENTS.md` na raiz para orientar agentes antes de qualquer análise ampla do repositório.
- **Fluxo Simplificado**: A IA lê a diretriz, consulta README/INDEX, roteia o assunto pelos catálogos e só abre código necessário à tarefa.
- **Conteúdo**: Baselines, prioridade BSD, evidência, estados, portabilidade FreeBSD–Linux, protocolos por pedido, documentação, portal, validação, segurança e antialucinação.
- **Atalho do Usuário**: Uma nova sessão pode começar com “Leia AGENTS.md e continue o PlayOS”.
- **Integração**: README, índice e inventário da base supervisionada apontam para a nova diretriz.

## [2026-08-19] - Documentação BSD ampliada e portal HTML iniciado
- **Novos Markdown**: Referência de subsistemas FreeBSD, glossário BSD/Linux/PlayOS e roadmap de conhecimento BSD adicionados à base.
- **Cobertura**: A base agora possui 10 entradas técnicas, 13 tópicos e 68 documentos inventariados, mantendo 25 fontes e 44 exemplos QA.
- **Portal**: Criado `documentation-portal/` com HTML, CSS e JavaScript locais, identidade PlayOS, 22 cartões documentais, busca e seis filtros.
- **Estado Real**: O portal diferencia Noble compilado, Linux 7.1.8 compilado, proposta Linux→FreeBSD e fonte Resolute ausente.
- **Validação**: HTML e 15 links/assets passaram na checagem local; base supervisionada e `git diff --check` permanecem aprovados.
- **Limite**: Preview HTTP foi impedido pelo sandbox e Node.js não está disponível; teste visual em navegador permanece para a próxima etapa.
- **Relatório**: `supervised_learning/HTML_PORTAL_STATUS.md` e `documentation-portal/README.md`.

## [2026-08-19] - Base supervisionada BSD/PlayOS implementada
- **Transformação**: `supervised_learning/` passou de duas notas para uma base operacional com índice, governança, esquemas, catálogos, conhecimento, datasets, avaliações e ferramentas.
- **Prioridade BSD**: Criadas entradas centrais para FreeBSD 15.1, `sys/kern`, segurança/Jails, rede/I/O/ZFS/bhyve, família BSD e tradução FreeBSD–Linux.
- **Fontes**: 25 fontes canônicas e 65 documentos relacionados foram catalogados com estado, papel e prioridade.
- **Estado Real**: 10 decisões e 7 implementações/propostas agora distinguem compilado, estático, planejado, bloqueado e experimental.
- **Dataset**: 44 exemplos QA — 20 treino, 8 validação, 8 adversariais e 8 avaliação — com fontes e comportamento esperado.
- **Antialucinação**: Incluídas correções obrigatórias para Noble/Resolute, porte direto de `sys/kern`, Linuxulator, compatibilidade de hardware e builds sem boot.
- **Ferramentas**: `validate_knowledge.py`, `query_knowledge.py` e Makefile adicionados; validação e três consultas de fumaça passaram.
- **Legado**: As duas notas antigas foram marcadas como não canônicas, tiveram link absoluto corrigido e propostas perigosas reclassificadas.
- **Relatório**: `supervised_learning/RELATORIO_IMPLEMENTACAO_2026-08-19.md`.

## [2026-08-19] - Auditoria da base de aprendizado supervisionado
- **Veredito**: Confirmado que `supervised_learning/` ainda não permite consulta técnica autônoma confiável por IA; prontidão estimada em 2/10.
- **Dimensão**: Apenas dois Markdown, 88 linhas e 1.114 palavras; nenhum índice, esquema, dataset QA, metadado, teste de recuperação ou catálogo de fontes.
- **Validação**: Arquivos e símbolos FreeBSD citados foram confirmados na fonte 15.1-p2, mas a pasta não preserva commits, linhas ou evidências reproduzíveis.
- **Risco**: Fatos, inferências e propostas estão misturados; promessas de desempenho e portabilidade aparecem sem benchmark, análise de ABI ou teste.
- **Cobertura**: Cerca de 65 documentos relevantes permanecem fora da coleção e não são descobertos por uma IA limitada à pasta.
- **Direção**: Recomendadas camadas separadas de conhecimento, catálogo, dataset JSONL e avaliações, com IDs, proveniência, confiança e recusa quando não houver evidência.
- **Relatório**: `supervised_learning/AUDITORIA_BASE_IA_2026-08-19.md`.

## [2026-08-18] - Ubuntu Noble Generic com patches PlayOS concluído
- **Configuração Real**: Exportada `amd64-generic` de `debian.master/config/annotations` e aplicado apenas o fragmento PlayOS de produção; kTLS permanece módulo e fault injection permanece desativado.
- **Build Completo**: `bzImage`, módulos, BTF, assinatura temporária, `modules_install` e `depmod` concluíram com código zero para `6.8.4-playos-freebsd-lab1+`.
- **Cobertura**: 6.467 módulos `.ko` instalados em staging isolado de 7,1 GiB; o módulo kTLS foi confirmado com BTF e assinatura.
- **Initramfs**: Dracut produziu imagem genérica de 286 MiB e `lsinitrd` encontrou 1.247 entradas da nova release, incluindo kTLS.
- **Selftests**: Os quatro grupos passaram novamente pelo worktree sem espaços; execução ocorreu no kernel host e ainda deve ser repetida após o boot do novo kernel.
- **Correção Nova**: Adicionado o patch 0107 para preservar `const` em `tools/lib/bpf/libbpf.c` e permitir o build Generic sob GCC 15.
- **Rust**: Mantido desativado porque Noble 6.8 exige rustc 1.75.0/bindgen 0.65.1 e a toolchain Resolute local 1.93.1/0.72.1 não passa no gate oficial.
- **Artefatos**: Kernel, configuração, System.map, initramfs e SHA-256 em `build/playos-noble-generic/output/`.
- **Limites**: Ainda faltam boot QEMU/hardware, selftests dentro do novo kernel, pacote Debian, chave Secure Boot definitiva e regressão contra Noble Generic puro.
- **Relatório**: `patch-FreeBSD-Noble/results/BUILD_GENERIC_PROD_6.8.4_2026-08-18.md`.

## [2026-08-18] - Linux 7.1.8 alterado e compilado como PlayOS FreeBSD Lab
- **Fonte Principal**: `Kernels/kernel linux-7.1.8` recebeu identidade `-playos-freebsd-lab1`, documentação, bootconfig e quatro selftests; a árvore continua sem metadados Git verificáveis.
- **Área de Build**: Criada `/home/marcel/kernel-work/playos-7.1.8/{source,out,stage}` para contornar os espaços do caminho principal, mantendo o mesmo modelo usado no Noble.
- **Build**: `bzImage` concluído como `7.1.8-playos-freebsd-lab1`; 14 módulos instalados apenas no staging, incluindo NTSYNC e kTLS.
- **Initramfs**: Dracut gerou imagem genérica de 48.058.317 bytes sem instalar o kernel ou alterar o host.
- **Testes**: sendfile, Landlock ABI 8, inventário, cgroup v2, namespaces, seccomp, PSI e AppArmor passaram no kernel host.
- **Scheduler/BTF**: Uma toolchain local com `pahole` 1.31 e `libdwarves1` foi extraída sem instalação global; o segundo build passou com `CONFIG_DEBUG_INFO_BTF=y`, `CONFIG_SCHED_CLASS_EXT=y` e BTF nos 14 módulos.
- **Limite**: Boot em VM, pacote Debian, assinatura e GRUB ainda pendentes; QEMU não pôde ser instalado porque sudo exige autenticação interativa.
- **Artefatos**: Kernel, configuração, System.map, initramfs e hashes em `build/playos-7.1.8/output/`.
- **Relatório**: `patch-FreeBSD-Kernel-7.1.8/results/BUILD_PLAYOS_7.1.8_2026-08-18.md`.

## [2026-08-18] - Primeiro Build do Kernel PlayOS FreeBSD Lab
- **Resultado**: Compilado com sucesso `6.8.4-playos-freebsd-lab1-g74134bfb6b72-dirty`; `bzImage` x86 bootável com 14.050.304 bytes.
- **Worktree**: Build concluído em `/home/marcel/kernel-work/playos-noble`, após `/tmp` ficar sem espaço no link final.
- **Configuração**: `x86_64_defconfig` + fragmentos PlayOS de produção/lab; namespaces, cgroup, seccomp, Landlock, AppArmor, kTLS, PSI, bootconfig, tracing, BPF e fault injection confirmados.
- **Selftests**: Quatro testes kselftest passaram: sendfile, Landlock ABI 8, inventário e isolamento com cgroup v2/namespaces/seccomp/PSI/AppArmor.
- **Correções de Build**: Adicionados patches mínimos para linkage LSM/AppArmor, warning r8169, array cpufreq e padrão GNU11 no EFI stub/kernel comprimido sob GCC 15.
- **Artefatos**: `bzImage`, `.config`, `System.map` e hashes copiados para `build/playos-noble/output/`.
- **Módulos**: `make modules` e `modules_install` concluídos; nove módulos foram instalados somente no staging isolado em `/home/marcel/kernel-work/playos-noble/stage`, sem alterar o host.
- **Initramfs**: Dracut 110 gerou uma imagem genérica de 46 MiB; `lsinitrd` confirmou microcode, systemd-initrd, suporte de VM/rootfs e módulos da nova release. Hash registrado em `SHA256SUMS`.
- **Limites**: Ainda sem pacote Debian, assinatura, GRUB, boot ou testes executados no novo kernel. QEMU/virt-install não estão disponíveis no host. O sufixo `dirty` confirma estado não commitado/laboratorial.
- **Relatório**: Detalhes em `patch-FreeBSD-Noble/results/BUILD_6.8.4_PLAYOS_FREEBSD_LAB1_2026-08-18.md`.

## [2026-08-18] - Meta Corrigida: Ubuntu Noble Enriquecido com FreeBSD 15.1
- **Alvo**: Confirmado Ubuntu Noble Linux 6.8.4 no commit `74134bfb6b720ca18a73931662cbcc8170ef1bed`; o nome local Resolute está incorreto e deixa de definir a meta deste patchset.
- **Fonte**: Confirmado FreeBSD `release/15.1.0-p2`, commit `aadd58dddcbc78f4d5594827b46b5633552b15ce`, remote oficial e checkout limpo em `/home/marcel/Parcel Suite/Operating Systems/freebsd-15.1.0-p2`.
- **Novo Patchset**: Criado `patch-FreeBSD-Noble/` com manifesto, roadmap, matriz de 16 integrações e configurações separadas de produção/laboratório.
- **Produção**: Usará mecanismos Linux equivalentes para namespaces/Jails, cgroup/RCTL, seccomp/Landlock/Capsicum, kTLS/sendfile e tracing/boottrace.
- **Laboratório**: Fault injection separado; sanitizers em variantes próprias. `sched_ext` está ausente no Linux 6.8 e não será fingido nem substituído por cópia do ULE.
- **Regra**: Código FreeBSD completo permanece somente leitura. Patches Linux serão pequenos, nativos, testados e justificáveis; sem cópia direta de `sys/kern`.

## [2026-08-18] - Início do Kernel PlayOS FreeBSD Study sobre Ubuntu Local
- **Branch**: Criada `codex/playos-freebsd-syskern-6.8-lab` dentro da árvore `Kernels/ubuntu 26 resolute kernel`, preservando `master` no commit `74134bfb6b720ca18a73931662cbcc8170ef1bed`.
- **Aplicação**: Três patches existentes foram aplicados ao índice: documentação de tradução, bootconfig opt-in e selftests. Um quarto patch adicionou `localversion-playos` com sufixo `-playos-freebsd-lab1`.
- **Escopo**: Sete arquivos e 215 inserções; nenhum scheduler, VFS, syscall, lock, mbuf ou subsistema FreeBSD foi copiado para Linux.
- **Testes**: `git diff --cached --check` e kit passaram; teste sendfile compilou com warnings como erro e preservou dados via AF_UNIX; inventário retornou cinco PASS e um SKIP de fault injection.
- **Bloqueio**: Kselftest/Kbuild não funcionam na hierarquia atual com espaços. Build integral requer worktree física em caminho limpo.
- **Identidade**: O novo kernel é laboratório sobre Noble Linux 6.8.4, não Ubuntu Resolute 7.0. Mudanças permanecem staged e não commitadas para revisão.
- **Relatório**: Resultado registrado em `patch-FreeBSD-Ubuntu/results/APLICACAO_INICIAL_6.8_2026-08-18.md`.

## [2026-08-18] - Análise de Integração do FreeBSD `sys/kern` no Ubuntu
- **Inventário**: Auditados 248 arquivos no primeiro nível de `Kernels/FreeBSD 15/sys/kern`; 210 incluem `sys/param.h`, 206 `sys/systm.h`, 187 `sys/kernel.h` e 155 `sys/proc.h`.
- **Conclusão**: `sys/kern` não é biblioteca e não pode ser adicionado ao Kbuild. Estruturas como proc/thread, vnode, mbuf, UMA, VNET, SYSINIT, epoch e locks não possuem ABI compatível com Linux.
- **Estratégia**: Três camadas: mecanismos Linux existentes sem patch; patches Linux mínimos para lacunas comprovadas; FreeBSD Core KVM para semântica BSD integral.
- **Mapeamento**: Criado `patch-FreeBSD-Ubuntu/proposals/sys-kern-mapping.tsv` com 16 famílias, alvo Linux, ação e prioridade.
- **Bloqueios**: ULE, Jails, sendfile, kTLS, VFS, locks e mbufs não devem ser copiados. Scheduler pode ser estudado por política `sched_ext`; isolamento deve usar contrato userspace com backends nativos.
- **Baseline**: A cópia Ubuntu local continua Noble 6.8.4; qualquer aplicação final depende de árvore oficial Resolute Linux 7.0, build, boot e testes.
- **Documento**: Relatório completo registrado em `INTEGRACAO_SYS_KERN_FREEBSD_NO_UBUNTU_2026-08-18.md`.

## [2026-08-18] - Nova Direção: PlayOS Unificado Ubuntu + FreeBSD
- **Mudança**: Substituída a proposta de duas edições por análise de um produto único executando Ubuntu e FreeBSD simultaneamente.
- **Arquitetura Recomendada**: Ubuntu Resolute Linux 7.0 controla hardware, desktop e jogos; FreeBSD 15.1 funciona como máquina de serviços KVM/libvirt integrada por rede VirtIO privada e API autenticada.
- **Unificação**: Um instalador, conta, desktop, central de controle e atualização; dois kernels permanecem tecnicamente isolados e com ciclos próprios.
- **Dados**: Compartilhamento inicial por NFSv4/SMB sobre rede privada; proibido montar filesystem gravável simultaneamente nos dois kernels.
- **Resiliência**: Desktop não depende do guest, imagens FreeBSD usam atualização A/B e rollback, e falha do FreeBSD Core resulta em modo degradado.
- **Host Auditado**: Ubuntu `7.0.0-29-generic`, Ryzen 3 7320U com AMD-V, 94 GiB livres e 5,1 GiB RAM; QEMU/libvirt e `/dev/kvm` ainda não disponíveis/confirmados.
- **Documento**: Arquitetura, comunicação, instalação, segurança, PoC e critérios registrados em `PLAYOS_UNIFICADO_UBUNTU_FREEBSD_2026-08-18.md`.

## [2026-08-18] - Definição da Arquitetura do PlayOS
- **Nome**: Definido PlayOS como marca futura da família de sistemas; renomeação física permanece pendente e não será feita por substituição global.
- **Decisão Principal**: PlayOS Gaming/Desktop usará Ubuntu Resolute Linux 7.0; PlayOS BSD/Server usará FreeBSD 15.1 em imagem e userspace próprios.
- **Kernel**: Rejeitado kernel híbrido ou kernel novo no MVP. Kernels oficiais permanecem produção/fallback; NitroCore e os três patchsets continuam laboratório.
- **Integração**: UI, catálogo, sandbox, telemetria, atualização e modelo do instalador serão comuns por contratos userspace, com backend específico Linux ou FreeBSD.
- **Compatibilidade**: Linux prioriza DEB/Flatpak/containers/Proton/Waydroid; FreeBSD prioriza pkg/Ports/Linuxulator/Wine/bhyve.
- **Entrega**: A ISO Linux será concluída antes da edição FreeBSD; eventual mídia conjunta fará chainload de payloads independentes.
- **Documento**: Análise, matriz, arquitetura, política de patches, branding, roadmap e critérios de release registrados em `PLAYOS_ARQUITETURA_LINUX_FREEBSD_2026-08-18.md`.

## [2026-08-18] - Arquitetura de Compatibilidade Máxima para FreeBSD
- **Solução**: Criado `freebsd-compatibility/` com roteamento em camadas: FreeBSD nativo, Linuxulator em Linux jail, Wine, bhyve e streaming como último fallback.
- **Princípio**: Linux jail compartilha o kernel FreeBSD; cargas dependentes de kernel Linux, NTSYNC, Waydroid, drivers ou anti-cheat devem usar VM, não receber falsa classificação nativa.
- **Entregas**: README arquitetural, matriz por classe de carga, plano em seis fases, política TSV legível por máquina e auditoria somente leitura do host.
- **Segurança**: GENERIC e rollback permanecem obrigatórios; o kit não instala pacotes, não carrega módulos e não altera o sistema.
- **Validação Pendente**: Desktop, GPU, áudio, Wine, Steam, passthrough, suspend/resume e aplicações reais exigem boot do FreeBSD em VM e hardware.

## [2026-08-18] - Correção da versão oficial do kernel Resolute
- **Confirmação Oficial**: Ubuntu 26.04 LTS Resolute Raccoon foi lançado com Linux 7.0, conforme anúncio da Equipe de Kernel da Canonical e changelog do pacote `linux` no Launchpad.
- **Correção Local**: `Kernels/ubuntu 26 resolute kernel/` continua identificada como Noble 6.8.4 (`6.8.0-30.30`), apesar do nome e do remote Resolute; não é o baseline oficial.
- **Impacto**: A validação de `patch-FreeBSD-Ubuntu/` contra 6.8 foi reclassificada explicitamente como compatibilidade sintática, não validação Resolute.
- **Proteção**: O validador agora exige simultaneamente changelog `resolute` e `VERSION.PATCHLEVEL = 7.0` para aplicação normal.
- **Documento**: Evidências, comparação e critérios do novo baseline registrados em `VERIFICACAO_KERNEL_UBUNTU_RESOLUTE_2026-08-18.md`.

## [2026-08-18] - Resumo Consolidado do Dia
- **Consolidação**: Todo o trabalho do dia foi reunido em `RESUMO_DIA_2026-08-18.md`, com ranking de importância de 1 a 10, maturidade e pendências.
- **Nota Máxima**: Receberam 10/10 a descoberta da identidade incorreta da árvore Resolute, a política de portabilidade sem cópia direta e o patchset FreeBSD para Ubuntu.
- **Entregas**: Registradas auditorias, cinco estudos, três patchsets, inventário FreeBSD completo, estratégia Live/instalador e transparência de fontes.
- **Estado Real**: Documentação, patches iniciais e validações estáticas/temporárias concluídos; build, boot, VM, ISO, instalação e hardware permanecem pendentes.
- **Próximo Marco**: Preparar fontes oficiais em caminhos sem espaços, disponibilizar QEMU/KVM, construir baselines sem patches e então aplicar as séries.

## [2026-08-18] - Inventário Completo do FreeBSD 15.1-p2
- **Escopo**: Inventariada a árvore completa externa do FreeBSD, incluindo kernel, módulos, arquiteturas, userland, boot, instalador, release, segurança, rede, storage, virtualização e testes.
- **Identidade**: Confirmados FreeBSD 15.1-RELEASE-p2, tag `release/15.1.0-p2`, commit `aadd58dddcbc78f4d5594827b46b5633552b15ce`, remote oficial e árvore limpa.
- **Dimensão**: Aproximadamente 2,2 GiB, 108.960 arquivos totais, 33.186 em `sys/`, 470 diretórios de módulos e 2.386 arquivos de testes.
- **Kernel**: Confirmados ULE/4BSD, SMP/NUMA, VIMAGE, RACCT/RCTL, Capsicum, MAC, audit, epoch/SMR, UMA, OpenCrypto, sendfile/kTLS e extensa cobertura de drivers.
- **Storage**: Confirmados OpenZFS, UFS/FFS, GEOM, NVMe, CAM/SCSI, AHCI, iSCSI, NFS e diversos filesystems. OpenZFS inclui aproximadamente 2.355 arquivos de teste.
- **Rede**: Confirmados IPv4/IPv6, PF, IPFW, IPFilter, Netgraph, netlink, BPF, IPsec, TCP offload/blackbox/Fast Open, SCTP, Wi-Fi e VNET.
- **Virtualização**: Confirmados bhyve/vmm, virtio, Hyper-V, Xen, Linuxulator e compatibilidade FreeBSD32/ABIs antigas.
- **Diagnóstico**: Confirmados DTrace, HWPMC, KTR, TSLOG, boottrace, failpoints, WITNESS, INVARIANTS, KASAN, KCSAN, KMSAN, KCOV, KTest e ATF/Kyua.
- **Instalador/Live**: Confirmados código completo do bsdinstall, particionamento, ZFS boot, rede/Wi-Fi, hardening, pkgbase, criação de ISO/memstick e imagens Azure/EC2/GCE/OCI/OpenStack/Vagrant/Firecracker.
- **Lacunas Diretas**: Não identificados equivalentes diretos completos para sched_ext, NTSYNC, PSI, io_uring, Landlock, seccomp-BPF, cgroup v2, IMA/fs-verity e kernel Rust; vários objetivos possuem soluções BSD diferentes.
- **Validação**: Análise estática. Não houve buildworld, buildkernel, boot, ISO, ATF/Kyua ou teste de hardware; fonte externa permaneceu limpa.
- **Documento Técnico**: Inventário detalhado registrado em `patch-linux7.1.8-FreeBSD/INVENTARIO_FREEBSD_15.1_P2.md`.

## [2026-08-18] - Patchset Invertido Linux 7.1.8 para FreeBSD 15.1-p2
- **Diretório Criado**: Trabalho concentrado em `patch-linux7.1.8-FreeBSD/`, sem modificar a fonte externa FreeBSD.
- **Fonte FreeBSD**: Confirmada árvore completa FreeBSD 15.1-RELEASE-p2, tag `release/15.1.0-p2`, commit `aadd58dddcbc78f4d5594827b46b5633552b15ce` e remote oficial. Checkout limpo, raso e destacado.
- **Comparação**: Linux 7.1.8 confrontado com epoch/SMR, ULE, RACCT/RCTL, Jails/VNET, Capsicum/MAC, sendfile/kTLS, failpoints, sanitizers, DTrace/HWPMC, TSLOG, WITNESS e LinuxKPI do FreeBSD.
- **Licença**: Proibida cópia de código GPL do kernel Linux. Patches são implementação/documentação independente BSD-2-Clause.
- **Série Inicial**: Três patches criados: manual de tradução, configuração amd64 `PARCEL-LAB` e testes ATF de baseline.
- **PARCEL-LAB**: Herda GENERIC-DEBUG e acrescenta TSLOG, COVERAGE e KCOV. É somente laboratório; KASAN/KCSAN/KMSAN permanecem variantes separadas.
- **Testes ATF**: Preparadas verificações não destrutivas de scheduler, Capsicum/VIMAGE, boottrace/failpoints e sendfile/kTLS.
- **Oportunidades**: PSI nativo, NTSYNC clean-room, scheduler experimental com fallback, evolução de AIO e integridade MAC/veriexec foram documentados como propostas, não implementação.
- **Validação**: Scripts, whitespace e `git apply --check` passaram. A série aplicou em cópia temporária e o ATF shell passou em análise sintática.
- **Bloqueios**: Host Linux sem bmake, config FreeBSD, mandoc, Kyua ou ATF; não houve buildworld, buildkernel, boot ou execução dos testes.
- **Documento Técnico**: Análise detalhada e resultados em `patch-linux7.1.8-FreeBSD/`.

## [2026-08-18] - Patchset FreeBSD para Linux Vanilla 7.1.8
- **Diretório Criado**: Preparação concentrada em `patch-FreeBSD-Kernel-7.1.8/`, sem modificar a árvore vanilla.
- **Reanálise FreeBSD**: Revisitados os 248 arquivos de `FreeBSD 15/sys/kern`, especialmente boottrace, fault injection, ULE, sendfile, kTLS, Jail, VFS cache, PID, filtros, relógio e estatísticas. Dependências FreeBSD confirmam que não há arquivo completo seguro para cópia direta.
- **Árvore Vanilla**: Confirmada versão declarada 7.1.8, cerca de 93.616 arquivos e 1,8 GiB. A cópia não possui Git próprio, origem/tag/commit verificáveis ou `.config`, e está em caminho rejeitado pelo Kbuild por conter espaços.
- **Diferença Positiva**: Ao contrário da árvore Ubuntu 6.8 auditada, o vanilla 7.1.8 contém `sched_ext`, selftests `sched_ext`, NTSYNC oficial, bootconfig, fault injection, sendfile/splice, kTLS, BPF e Landlock.
- **Série Inicial**: Criados três patches para documentação da tradução, boottrace opt-in e selftests de sendfile/capacidades.
- **Config Lab**: Preparado fragmento separado com `sched_ext`, NTSYNC módulo, kTLS e fault injection. Sanitizers continuam em builds separados e o fragmento não faz parte da aplicação automática.
- **Automação**: Scripts identificam o alvo, exigem 7.1.8, validam fonte Git oficial no modo de aplicação, checam whitespace, aplicam ao índice e revertem a série.
- **Validação**: Série passou em `git apply --check --no-index --whitespace=error-all`; em cópia temporária, selftest compilou e passou.
- **Bootconfig**: Ferramenta oficial compilou, seus 75 testes passaram e o perfil Parcel foi analisado corretamente.
- **Limites**: Inventário funcional rodou no kernel do host, não em 7.1.8 compilado. Não houve build completo, boot, fault injection, NTSYNC, kTLS em NIC ou benchmark `sched_ext`.
- **Documento Técnico**: Manifesto e validação registrados dentro de `patch-FreeBSD-Kernel-7.1.8/`.

## [2026-08-18] - Preparação do Patchset FreeBSD para Ubuntu Resolute
- **Diretório Criado**: Toda a preparação foi concentrada em `patch-FreeBSD-Ubuntu/`, sem modificar a árvore do kernel.
- **Série Ativa**: Criados três patches ordenados: documentação da tradução FreeBSD/Linux, amostra opt-in de bootconfig para initcalls e selftests Parcel de sendfile/capacidades.
- **Automação**: Adicionados scripts para identificar e validar o alvo, checar a série, aplicar explicitamente e reverter antes de commits.
- **Proteções**: A aplicação recusa árvore suja, clone raso, changelog não Resolute e caminho com espaços/dois-pontos. A compatibilidade com a árvore Noble local exige modo explicitamente não Resolute e não permite aplicação automática.
- **Fault Injection**: Preparado `config/parcel-lab.config`, mantido fora da série para impedir ativação no kernel generic. KASAN, KCSAN e KCOV permanecem builds separados.
- **Propostas Bloqueadas**: Scheduler ULE, alterações kTLS/VFS, algoritmos no kernel e equivalentes de Jail permanecem fora da série até baseline correto, consumidor e evidência.
- **Validação Estática**: Scripts passaram em `bash -n`; os três patches passaram em `git apply --check --whitespace=error-all` contra a árvore local 6.8.
- **Validação Funcional**: Em cópia temporária, a série foi aplicada, o selftest sendfile compilou com `-Wall -Wextra -Werror` e passou; o inventário de recursos passou.
- **Bootconfig**: A ferramenta oficial compilou, seus 55 testes passaram e o perfil Parcel foi analisado corretamente.
- **Limites**: Não houve build/boot de kernel, aplicação em Resolute verdadeiro, fault injection, pacote Debian, Secure Boot ou teste em QEMU/hardware.
- **Rastreabilidade**: Manifesto, hashes SHA-256 e relatório de validação estão em `patch-FreeBSD-Ubuntu/`.

## [2026-08-18] - Relatório de Aplicação FreeBSD no Ubuntu Resolute
- **Escopo**: A árvore `Kernels/ubuntu 26 resolute kernel/` foi confrontada com os estudos do `Kernels/FreeBSD 15/sys/kern/` e com os resultados A–E.
- **Identidade Crítica**: Embora o remote aponte para o repositório oficial Resolute, a cópia local está no commit raso `74134bfb6b720ca18a73931662cbcc8170ef1bed`, declara Linux 6.8.4 e contém changelog Noble 6.8.0-30.30 de abril de 2024. Ela não deve ser tratada como baseline Resolute atual.
- **Build**: A árvore está limpa, mas sem `.config`, `debian/build` ou `debian/control` gerado. `make -s kernelversion` confirmou que Kbuild rejeita o caminho atual por conter espaços; o clone/worktree de build deve ficar em caminho integral sem espaços ou dois-pontos. Nenhum kernel foi compilado ou instalado.
- **Aplicação Recomendada**: Usar bootconfig/ftrace para boottrace; flavour de laboratório para fault injection; scheduler padrão como baseline; `sched_ext` somente em árvore compatível; sendfile/kTLS Linux existentes; namespaces, cgroup v2, seccomp, Landlock e AppArmor para conceitos de Jail/Capsicum.
- **Configuração**: Confirmados BPF, ftrace, kprobes, bootconfig, debugfs, UBSan, TLS, namespaces, cgroups, seccomp, Landlock, IMA e fs-verity na política Ubuntu. O framework geral `CONFIG_FAULT_INJECTION` está desabilitado no generic, apesar de `CONFIG_FUNCTION_ERROR_INJECTION=y`.
- **Scheduler**: A cópia Linux 6.8 não contém `sched_ext`; não há justificativa experimental para portar ULE ou substituir o scheduler Linux.
- **Portabilidade**: Rejeitada a cópia direta de arquivos FreeBSD. Conceitos devem ser traduzidos para APIs Linux e algoritmos pequenos precisam de consumidor real, implementação independente e KUnit.
- **Arquitetura**: Recomendados kernel Ubuntu oficial como fallback, flavour Parcel generic para produção e flavour Parcel lab separado para diagnóstico destrutivo.
- **Segurança**: Fault injection, KASAN, KCSAN e KCOV devem ser usados somente em builds/VMs dedicados, nunca ativados indiscriminadamente na imagem gamer.
- **Alterações**: Nenhum arquivo da árvore do kernel foi modificado. A etapa produziu apenas análise e documentação.
- **Documento Técnico**: Plano completo, pontos de integração, fases de build, matriz de testes, gates e rollback registrados em `APLICACAO_FREEBSD15_NO_UBUNTU_RESOLUTE_2026-08-18.md`.

## [2026-08-18] - Execução dos Cinco Estudos FreeBSD `sys/kern`
- **Suíte Criada**: Implementada estrutura reproduzível em `studies/freebsd15_sys_kern/` para boottrace, fault injection, scheduler, rede/arquivos e algoritmos isolados.
- **Segurança**: Nenhum teste alterou kernel, sysctl, tracefs, debugfs, módulos, GRUB, scheduler global ou discos. Fault injection real foi bloqueada fora de VM descartável.
- **Build**: Três binários C compilados com `-Wall -Wextra -Werror`; testes de algoritmos passaram.
- **Algoritmos**: Implementações userspace independentes de PID, min/max e regressão incremental passaram em testes normais e ASan/UBSan com leak detection desativada.
- **Scheduler**: Cinco repetições de 20.000 iterações compararam `SCHED_OTHER` e `SCHED_BATCH`. As médias ficaram próximas e outliers variaram; não foi encontrada justificativa para substituir EEVDF ou portar ULE.
- **I/O**: Em `socketpair` local com arquivo temporário de 64 MiB, `read/write` obteve média de 2.225,51 MiB/s e `sendfile` 4.922,52 MiB/s, razão de 2,212×. O teste não representa rede física, kTLS, FreeBSD ou DirectStorage.
- **Boottrace**: Coletor executado, mas system bus e tracefs estavam inacessíveis/somente leitura no sandbox; nenhum tempo de boot foi confirmado.
- **Fault Injection**: Detectados `CONFIG_UBSAN=y` e `CONFIG_FUNCTION_ERROR_INJECTION=y`, porém debugfs estava somente leitura e os nós de injeção não estavam disponíveis.
- **Bloqueios**: QEMU, KVM, FreeBSD executável, `fio`, `iperf3`, Gamescope e estatísticas kTLS estavam ausentes.
- **Resultados Brutos**: Preservados em `studies/freebsd15_sys_kern/results/`, incluindo cinco repetições.
- **Documento Técnico**: Método, números, interpretação, limites e infraestrutura restante registrados em `RESULTADOS_ESTUDOS_FREEBSD15_SYS_KERN_2026-08-18.md`.

## [2026-08-18] - Auditoria FreeBSD 15 `sys/kern` para Ubuntu Resolute
- **Escopo**: Inventário e classificação dos 248 arquivos presentes em `Kernels/FreeBSD 15/sys/kern`, cobrindo build, processos, scheduler, locks, tempo, Jails, segurança, tracing, memória, DMA, devices, VFS, rede, IPC, TTY e infraestrutura genérica.
- **Limite da Fonte**: Confirmado que o diretório é somente um recorte de aproximadamente 7,7 MB; faltam headers `sys/sys`, VM, rede, segurança, arquitetura, configuração, árvore de build superior, COPYRIGHT e metadados Git.
- **Conclusão de Portabilidade**: Nenhum arquivo completo é recomendado para cópia direta ao Linux. As APIs internas FreeBSD (`proc`, `vnode`, UMA, mbuf, Jail, Capsicum, VNET, SYSINIT e locks) são incompatíveis com as APIs Linux.
- **Equivalentes Linux**: Confirmada na árvore Ubuntu a presença de RCU, lockdep, fault injection, boot tracing, workqueues, SLUB, XArray, Maple Tree, kTLS, cgroups, namespaces, Landlock, IMA, fs-verity, KCOV, KASAN, KCSAN e UBSAN.
- **Melhor Uso**: Utilizar FreeBSD para definir benchmarks, testes de falha, políticas e hipóteses; mapear conceitos para APIs Linux existentes; extrair somente algoritmos pequenos primeiro em userspace.
- **Candidatos de Estudo**: `kern_boottrace.c`, `kern_fail.c`, `sched_ule.c`, `kern_sendfile.c`, `uipc_ktls.c`, `vfs_cache.c`, `subr_pidctrl.c`, `subr_clockcalib.c`, `subr_filter.c` e `subr_stats.c`.
- **Licenças**: Identificados 130 arquivos BSD-2-Clause, 63 BSD-3-Clause, 9 BSD-4-Clause, 2 Beerware, 2 expressões combinadas e 42 arquivos sem SPDX explícito. Qualquer porte exige auditoria individual, preservação de avisos e compatibilidade GPL-2.0.
- **Scheduler**: Recomendado estudar heurísticas ULE via `sched_ext`, sem substituir o scheduler Linux ou copiar locks/runqueues FreeBSD.
- **Isolamento**: Jails/Capsicum devem orientar o threat model; implementação deve usar namespaces, cgroup v2, seccomp, Landlock e LSM Linux.
- **Rede/VFS**: Sendfile, kTLS e namecache devem ser comparados por benchmark; não portar mbuf, sockets ou vnode/VFS.
- **Experimentos**: Definidos experimentos de boottrace, fault injection, scheduler, rede/arquivos e algoritmos isolados, sempre com baseline, VM, testes e kernel Ubuntu fallback.
- **Documento Técnico**: Inventário completo, famílias, equivalentes Linux, ranking, licenças, experimentos e processo de porte registrados em `PORTABILIDADE_FREEBSD15_SYS_KERN_PARA_UBUNTU.md`.

## [2026-08-18] - Auditoria Completa de Arquitetura e Direção
- **Ação**: Auditoria integral das propostas recentes, código NitroCore, scripts, instalador, QML, Live ISO, gestão de pacotes, imutabilidade, ZFS, Gamescope, BSDs, segurança e governança.
- **Veredito**: A visão Ubuntu + desktop + gaming permanece válida, mas a expansão simultânea para kernel próprio, dez sabores, três BSDs, vários gestores de pacotes, browser, auto-cura e storage P2P está desviando recursos do MVP.
- **Direção Mantida**: Ubuntu Resolute como baseline, kernel oficial como fallback, GNOME/KDE, Subiquity, Live reproduzível, Gamescope opcional, Flatpak e testes em VM.
- **Direção Reformulada**: NitroCore deve ser uma fila pequena de patches sobre uma árvore Ubuntu fixada; Decágono permanece catálogo de referências; AUR/DNF somente em containers; BSDs permanecem sistemas/payloads separados.
- **Direção Rejeitada no MVP**: Anaconda, Thunder Browser próprio, Dark Volt no early boot, NTSYNC reimplementado, `mitigations=off`, mistura de árvores Linux de versões distintas e alegações de KARL/DirectStorage/Capsicum já implementados.
- **Validação Estática**: Dezoito scripts passaram em `bash -n`; três módulos Python passaram em AST; JSON e GRUB passaram; `git diff --check` passou.
- **Defeito Confirmado**: `desktop-file-validate` reprovou `config/wayland-sessions/parcel-full-session.desktop` pela chave `DesktopNames` não padronizada.
- **Build NitroCore**: Não executável no estado atual; ambas as árvores Linux estão sem `.config` e preparação, e nenhuma inclui `nitrocore/` no build principal.
- **Dependências Ausentes**: Gamescope, Calamares, QML runtime, Podman, Distrobox, ZFS e `ukify` não estavam disponíveis no host auditado.
- **Segurança**: Bloqueado o uso automático de `mitigations=off`; recomendadas APIs Linux existentes como IMA/fs-verity, AppArmor/SELinux, seccomp, Landlock, namespaces e KCFI.
- **NTSYNC**: Recomendado abandonar o stub próprio e usar a implementação oficial do kernel Linux.
- **P2PDMA**: Classificado como pesquisa de longo prazo dependente de topologia e drivers, não como DirectStorage implementado.
- **Roadmap**: Definidos marcos sequenciais para higiene, ISO, instalação, gaming, primeiro patch NitroCore, containers/armazenamento e BSD.
- **Documento Técnico**: Vereditos por componente, evidências, riscos e critérios de entrada no roadmap registrados em `AUDITORIA_COMPLETA_DIRECAO_2026-08-18.md`.

## [2026-08-18] - Nova Auditoria e Inventário das Alterações
- **Marco de Comparação**: Estado atual comparado ao commit `60a5f63` de 15 de agosto de 2026; nenhum commit posterior foi encontrado.
- **Inventário Git**: Identificados 73 arquivos adicionados ao índice, 21 arquivos com modificações adicionais fora do índice, 5.222 arquivos não rastreados e nenhuma remoção rastreada.
- **Documentação**: Catalogados 41 novos documentos entre a raiz, `nitrocore/` e `supervised_learning/`, cobrindo referências técnicas, arquitetura, segurança, gaming, pacotes, BSD e interfaces.
- **NitroCore**: Localizados `Kconfig`, `Makefile` e onze protótipos C. Confirmado que a árvore ainda não está integrada aos `Kconfig`/`Makefile` principais das fontes Linux e não há módulo `.ko` produzido ou testado.
- **Scripts**: Dezoito scripts passaram em `bash -n`. A validação confirma apenas sintaxe; vários scripts mantêm comandos centrais comentados e imprimem sucesso sem gerar o artefato declarado.
- **Python**: Os três módulos Python do instalador passaram na análise sintática. Suas operações relevantes permanecem comentadas e nenhum fluxo Calamares foi executado.
- **Fontes Importadas**: Catalogados 4.722 arquivos Connectiva Linux 4, 248 arquivos FreeBSD 15 e 250 arquivos FreeBSD 16 não rastreados, além das árvores Linux 7.1.8 e Ubuntu ocultadas pelo `.gitignore`.
- **Correção FreeBSD**: Os diretórios FreeBSD locais contêm somente recortes de `sys/kern`; `usr.sbin/bsdinstall/` e `release/` continuam ausentes do workspace.
- **Inconsistência de Versão**: A árvore vanilla declara Linux 7.1.8, o script antigo declara 6.18.44 e a árvore chamada Resolute contém changelog Noble 6.8.0-30.30.
- **Risco de Segurança**: Mantida a advertência contra ativar `mitigations=off` com base na presença de AVX-512. Também foram identificadas flags de compilação e seleção `znver3/znver4` sem detecção suficiente do processador.
- **Classificação de Maturidade**: Código NitroCore, módulos Calamares, QML, gestão híbrida, NTSYNC, CFI, Jail, UKI e storage P2P classificados como protótipos não integrados, não como funcionalidades concluídas.
- **Testes Não Executados**: Não houve compilação de kernel, boot, instalação, carregamento de módulo, benchmark, execução QML ou alteração de ZFS/GRUB.
- **Documento Técnico**: Inventário nominal, matriz de maturidade, riscos, validações e sequência recomendada registrados em `ANALISE_ALTERACOES_2026-08-18.md`.

## Regra de Documentação
- **Obrigatório**: Toda análise, decisão técnica, comando executado, alteração de código, teste e resultado relacionado ao Parcel Play OS deve ser registrado em um arquivo Markdown (`.md`).
- **Rastreabilidade**: Os registros devem distinguir explicitamente entre funcionalidade planejada, protótipo, implementação real, teste executado e resultado confirmado.
- **Segurança**: Funcionalidades não devem ser descritas como implementadas quando existirem somente como comentários, placeholders ou documentação conceitual.

## [2026-08-15] - Auditoria Geral do Estado do Projeto
- **Ação**: Inspeção da estrutura, documentação, scripts de build, configuração GRUB, módulos Calamares/QML/Python e artefatos locais do Parcel Play OS.
- **Natureza**: Análise estática; nenhuma funcionalidade do sistema operacional foi implementada ou alterada.
- **Validações**: Todos os scripts `.sh` passaram em `bash -n`; os módulos Python passaram em compilação sintática; `kms-config.json` é válido; `grub-11-kernels.cfg` passou em `grub-script-check`.
- **Limites dos Testes**: ShellCheck não estava disponível. QML não foi executado. Não houve boot, instalação, compilação de kernel ou benchmark. QEMU/KVM permanecem indisponíveis.
- **Estado Confirmado**: O projeto é uma especificação arquitetural com protótipo de ISO/menu. Apenas o Ubuntu oficial possui payload real; NitroCore, Thunder SDK, instalador Parcel e BSDs não estão implementados de ponta a ponta.
- **Build**: `build_os.sh` executa somente a criação da árvore FHS; bootstrap e kernel estão comentados, e seus scripts são simulações.
- **Instalador**: O MVP recente escolhe Ubuntu Desktop Installer/Subiquity, mas o código experimental presente é Calamares e suas operações relevantes estão comentadas.
- **Defeito Identificado**: O seletor QML grava `seguranca` para NetBSD, não inclui Ubuntu, não implementa filtro/feedback e redefine Debian ao carregar.
- **Risco de Segurança**: A proposta de ativar `mitigations=off` quando AVX-512 é detectado não possui justificativa técnica segura e não deve ser automatizada. `intel_pstate=passive` também não deve ser aplicado indiscriminadamente.
- **Portabilidade**: Vulkan, EGLFS e `/dev/dri/card0` são forçados sem detecção ou fallback; essas configurações podem falhar em hardware não previsto.
- **Documentação**: Foram identificadas contradições entre documentos antigos que declaram recursos ativos/integrados e registros recentes que corretamente os classificam como planejados.
- **Recomendação**: Priorizar uma ISO Ubuntu Resolute reproduzível, com GNOME, KDE e Subiquity testados, antes de compilar NitroCore ou integrar BSDs.
- **Documento Técnico**: Diagnóstico completo, matriz de maturidade, riscos e sequência recomendada registrados em `ANALISE_PROJETO_2026-08-15.md`.

## [2026-08-15] - Correção dos Links Diretos de Kernels
- **Problema**: `TRANSPARENCIA_KERNEL.md` listava principalmente páginas de navegação e não fornecia, de modo consistente, URLs clonáveis, branches ou a natureza de cada repositório.
- **Ação**: Catálogo reestruturado com links diretos oficiais, comandos `git clone`, branch recomendado quando aplicável e documentação primária.
- **Distinção Técnica**: Cada fonte passou a ser classificada como árvore completa, árvore downstream, empacotamento, patchset ou árvore de sistema BSD.
- **Ubuntu Resolute**: Documentados o repositório Launchpad direto, os branches `master` e `master-next`, o clone do branch de integração e verificações obrigatórias antes do build.
- **Correção Conceitual**: O repositório Gentoo `linux-patches` foi identificado corretamente como patchset, não como kernel completo. FreeBSD, NetBSD e OpenBSD foram identificados como árvores completas do sistema base.
- **Rastreabilidade**: A política agora exige URL, branch/tag, commit completo, tipo da fonte e data da auditoria para qualquer revisão usada pelo Parcel Play OS.
- **Documento Atualizado**: `TRANSPARENCIA_KERNEL.md`.

## [2026-08-15] - Comparação Inicial entre OpenBSD e FreeBSD
- **Ação**: Iniciada comparação técnica documental entre OpenBSD e FreeBSD usando documentação primária dos dois projetos.
- **Escopo**: Objetivos, arquitetura do kernel, segurança, rede, armazenamento, virtualização, hardware, pacotes, licenciamento e implicações para o Parcel Play OS.
- **OpenBSD**: Identificado como referência principal para segurança preventiva, auditabilidade, `pledge`, `unveil`, PF e redução de superfície.
- **FreeBSD**: Identificado como referência principal para OpenZFS, GEOM, jails, VNET, bhyve, Capsicum, Linuxulator e escalabilidade operacional.
- **Limite**: Nenhum código foi unido, portado, compilado ou executado. Os kernels, módulos, APIs internas e userspaces não são intercambiáveis.
- **Decisão Inicial**: Manter OpenBSD e FreeBSD como sistemas independentes e comparar mecanismos isolados antes de considerar qualquer porte.
- **Próximo Experimento Proposto**: Duas VMs amd64 mínimas e equivalentes, com OpenBSD 7.9 e FreeBSD 15.1-RELEASE, para medir boot, memória, instalação, atualização, rede e complexidade de sandbox.
- **Documento Técnico**: Análise, matriz comparativa e roteiro experimental registrados em `COMPARACAO_OPENBSD_FREEBSD.md`.

## [2026-08-15] - Auditoria para Live CD FreeBSD
- **Ação**: Analisados os 23 arquivos Markdown do projeto e confrontadas as decisões sobre FreeBSD com a documentação oficial atual.
- **Baseline Escolhido**: FreeBSD 15.1-RELEASE amd64 `disc1.iso`, que oferece Live de terminal e instalação offline por `bsdinstall`.
- **Tamanho**: A imagem oficial possui 1.352.255.488 bytes e não cabe em CD-R convencional; deve ser tratada como Live ISO para DVD, USB ou VM.
- **Limite Oficial**: O Live fornecido pelo FreeBSD é somente terminal, com usuário `root` e senha vazia; não contém GNOME ou Plasma.
- **Live Gráfico**: Classificado como distribuição FreeBSD customizada separada, a ser construída em ambiente FreeBSD com a infraestrutura oficial de release.
- **Correção de Boot**: Registrado que copiar apenas `loader.efi` não integra o FreeBSD. Loader, `/boot`, kernel, módulos, rootfs e distribuições precisam permanecer localizáveis.
- **Ambiente Local**: `xorriso`, `7z` e `sha256sum` estão disponíveis; QEMU, `bsdtar`, `signify` e a ISO FreeBSD estão ausentes. Aproximadamente 129 GiB estavam livres.
- **Testes**: Nenhum download, boot, particionamento ou instalação foi executado nesta etapa.
- **Próximo Marco**: Baixar/verificar a ISO oficial, instalar QEMU/OVMF, testar Live UEFI e concluir instalação offline em disco virtual vazio.
- **Documento Técnico**: Auditoria completa, matriz dos 23 documentos, fases, riscos e critérios registrados em `LIVE_CD_FREEBSD.md`.

## [2026-08-15] - Avaliação de Calamares e Anaconda no FreeBSD
- **Calamares Disponível**: Confirmado `sysutils/calamares` 3.3.14 nos Ports/pacotes do FreeBSD 15 amd64; a aplicação Qt pode ser instalada e usada em prova de conceito visual.
- **Bloqueio Calamares**: O KPMCore no FreeBSD não possui backend funcional de particionamento e compila um backend dummy. A configuração necessária para instalar uma distribuição FreeBSD também não acompanha o port.
- **Consequência**: A presença do pacote não autoriza escrita em disco. Particionamento, UFS/ZFS, implantação do base/kernel, configuração e FreeBSD loader exigiriam backend próprio.
- **Anaconda**: Rejeitado para o FreeBSD por dependências estruturais de Linux, dracut, Blivet, RPM/DNF, Kickstart, `.treeinfo` e bootloaders Linux; não foi identificado suporte ou port oficial FreeBSD.
- **Decisão MVP**: `bsdinstall` permanece o único instalador autoritativo.
- **Experimento Futuro**: Calamares poderá ser testado somente como frontend/branding, sem operações destrutivas, ou como interface sobre backend Parcel-FreeBSD próprio.
- **Documento Atualizado**: Matriz, módulos incompatíveis, opções arquiteturais e vereditos registrados em `LIVE_CD_FREEBSD.md`; `INSTALADOR.md` passou a apontar para a análise FreeBSD.

## [2026-08-15] - Localização do Código do bsdinstall e Live FreeBSD
- **Código Aberto**: Confirmado que instalador e infraestrutura Live fazem parte da árvore oficial `freebsd-src`.
- **bsdinstall**: Fontes localizadas em `usr.sbin/bsdinstall/`, incluindo orquestrador shell, `partedit`, `distfetch`, `distextract`, scripts de configuração e manual.
- **Live/ISO**: Fontes localizadas em `release/`, incluindo `Makefile`, `release.sh`, `rc.local`, scripts amd64 para ISO/USB e ferramentas de manifesto/pacotes.
- **Conclusão**: O Live CD não é um aplicativo isolado; é um sistema FreeBSD preparado pelo pipeline de release e iniciado com o fluxo do `bsdinstall`.
- **Estratégia Parcel**: Preservar inicialmente os backends nativos destrutivos e adicionar branding/launcher gráfico por cima, em vez de reimplementar partições e implantação.
- **Rastreabilidade**: Exigir tag/branch e commit completo do `freebsd-src` antes de modificar qualquer arquivo.
- **Documento Atualizado**: Mapa dos diretórios, responsabilidades e pontos de customização adicionado a `LIVE_CD_FREEBSD.md`.

## [2026-08-13] - Compatibilidade e Possível União de Kernels em C
- **Ação**: Análise conceitual e documental da compatibilidade entre as onze opções da mídia; nenhum kernel foi unido, alterado ou compilado.
- **Conclusão Linux**: Os oito perfis Linux são o grupo tecnicamente mais compatível. A solução recomendada é uma única árvore Linux/Ubuntu Resolute com patches comuns e configurações por flavor, produzindo kernel, módulos e initramfs separados.
- **Conclusão BSD**: NetBSD e OpenBSD são o par BSD historicamente mais próximo porque o OpenBSD derivou do NetBSD em 1995, mas suas ABIs, APIs internas e módulos atuais não são intercambiáveis.
- **Limite da Linguagem C**: Compartilhar C permite portar código-fonte, mas não resolve diferenças em memória, escalonamento, interrupções, VFS, drivers, build, ABI ou licenciamento.
- **Decisão**: Não realizar fusão binária de kernels monolíticos. Para compartilhar tecnologia, usar porte de componentes com adaptadores, NetBSD rump em userspace ou virtualização quando dois kernels completos precisarem executar lado a lado.
- **Live ISO**: O menu continuará iniciando somente um kernel/sistema por vez. A análise não altera a arquitetura multi-OS já definida.
- **Licenças**: Todo reaproveitamento será auditado por arquivo; avisos BSD e obrigações GPL/SPDX devem ser preservados.
- **Documento Técnico**: Matriz de proximidade, riscos, arquiteturas viáveis e critérios de protótipo em C adicionados a `LIVE_ISO_11_KERNELS.md`.

## [2026-08-13] - Ubuntu Anfitrião com Dez Kernels Convidados
- **Ação**: Estudo de uma arquitetura na qual o kernel Ubuntu Resolute mantém GNOME/KDE e executa as outras dez opções sob demanda; nenhuma VM foi iniciada e nenhum pacote foi instalado.
- **Decisão**: Usar KVM/QEMU para kernels completos e NetBSD rump somente quando um componente puder funcionar como serviço em userspace. Containers foram descartados para comprovação dos kernels porque compartilham o kernel anfitrião.
- **Economia**: Manter zero convidados no boot, iniciar normalmente somente um por vez, usar uma vCPU, console serial, rootfs mínimo somente leitura e overlay descartável. Desktops permanecem exclusivamente no anfitrião.
- **Linux**: Os sete flavors NitroCore poderão usar boot direto por kernel/initramfs e uma imagem base mínima compatível, preservando módulos próprios de cada versão.
- **BSD**: FreeBSD, NetBSD e OpenBSD usarão VMs e userspaces nativos; NetBSD poderá adicionalmente fornecer serviços rump.
- **C**: Planejado um orquestrador pequeno para processos QEMU/QMP, manifestos fixos e limites de recursos; não será criado um hipervisor novo nem serão montados argumentos por shell.
- **Auditoria Local**: `lscpu` confirmou x86_64, Ryzen 3 7320U, 8 CPUs lógicas e AMD-V. `free -h` mostrou 5,1 GiB totais, cerca de 943 MiB disponíveis durante a inspeção e swap em uso. `/dev/kvm` não estava presente.
- **Limite**: Dez VMs simultâneas estão fora do MVP e não são adequadas ao equipamento inspecionado; os valores de 128–512 MiB são apenas pontos iniciais a validar por convidado.
- **Documento Técnico**: Arquitetura, orçamento, segurança, fases e critérios de aceite adicionados a `LIVE_ISO_11_KERNELS.md`.

## [2026-08-13] - Identificação da Live e Instalador Mais Prontos
- **Ação**: Comparação do estado documentado das onze opções, dos instaladores nativos e da ISO híbrida; nenhum build ou teste foi executado.
- **Resultado**: A opção mais pronta para o objetivo do projeto é a ISO Ubuntu Resolute Desktop remasterizada, usando o kernel Ubuntu oficial e preservando o Ubuntu Desktop Installer/Subiquity.
- **Motivo**: A base oficial já integra boot BIOS/UEFI, Secure Boot, Casper, SquashFS, GNOME/GDM, kernel, firmware e instalador. A mudança mínima é acrescentar `kde-full` e validar a instalação do sistema modificado.
- **Limite**: A solução está mais pronta apenas em termos de base e procedimento. Nenhuma ISO Parcel foi produzida, KDE Full não foi incorporado e Subiquity ainda não foi testado com o novo payload.
- **Prioridade**: Concluir e testar esse baseline antes de integrar os sete NitroCore Linux e os três BSDs.
- **Documento Técnico**: Classificação de prontidão e próximo marco registrados em `LIVE_ISO_11_KERNELS.md`.

## [2026-08-13] - Execução do Baseline Resolute
- **Ação**: Início efetivo do baseline Ubuntu Resolute Desktop; foram criadas somente áreas novas sob `build/resolute-mvp/`, preservando os arquivos e alterações preexistentes.
- **Download**: Obtida a ISO oficial amd64 do build de 2026-08-11, com aproximadamente 5,84 GiB, além de `SHA256SUMS` e `SHA256SUMS.gpg`.
- **Integridade**: `sha256sum -c` retornou `resolute-desktop-amd64.iso: OK`.
- **Assinatura**: A assinatura retornou `Good signature` com a Ubuntu CD Image Automatic Signing Key (2012), fingerprint `8439 38DF 228D 22F7 B374 2BC0 D94A A3F0 EFE2 1092`, importada em keyring isolado do build.
- **Extração**: A árvore completa foi extraída em `build/resolute-mvp/work/iso-tree/`; o original possui boot híbrido BIOS/UEFI, MBR/GPT e GRUB.
- **Descoberta**: O payload usa `fsimage-layered`. Desktop completo combina `minimal.squashfs`, `minimal.standard.squashfs` e uma camada Live; editar somente a camada Live não instalaria KDE no disco.
- **Bloqueio Administrativo**: `sudo -n true` confirmou exigência de autenticação interativa. `fakeroot` não substitui chroot/mounts privilegiados e o user namespace falhou ao mapear UID 0. Nenhum pacote foi copiado de forma incompleta.
- **Bloqueio de Teste**: QEMU não está instalado e, na auditoria, `/dev/kvm` estava ausente.
- **Estado**: A ISO Parcel ainda não foi gerada; KDE Full, recomposição das camadas, rebuild e testes permanecem pendentes.
- **Higiene do Git**: Criado `.gitignore` com `/build/` para evitar versionar a ISO oficial e a cópia extraída, mantendo os artefatos locais disponíveis para continuação.
- **Documento Técnico**: Log completo, caminhos, resultados e continuação segura registrados em `BUILD_RESOLUTE_MVP.md`.

## [2026-08-13] - Primeiro Protótipo do Seletor GRUB de Onze Opções
- **Ação**: Criada configuração GRUB versionável, preparador idempotente, contrato de payload e ISO real de protótipo.
- **Menu**: Onze posições numeradas. Ubuntu é padrão e única com payload real; sete NitroCore e três BSDs informam indisponibilidade sem simular boot.
- **Linux**: Cada NitroCore exige `vmlinuz` e `initrd` próprios em `/parcel/linux/FLAVOR/`.
- **BSD**: Cada BSD possui caminho de loader sob `/EFI/parcel/`; o protótipo BSD é UEFI-only e nenhum loader foi adicionado.
- **Recuperação**: Adicionado submenu com Ubuntu `nomodeset`, próximo volume e configurações UEFI.
- **Loopback**: O mesmo seletor acrescenta `iso-scan/filename` quando `iso_path` existir.
- **ISO**: Gerado `build/resolute-mvp/output/parcel-play-11-menu-prototype-amd64.iso`, 6.279.266.304 bytes, SHA-256 `44a1ca2c3c239b0b87747c8372daee7d50c1a8d043644a1a5b0666516b95ec5d`.
- **Boot Preservado**: Confirmados El Torito BIOS/UEFI, MBR protetivo, GPT, GRUB e imagem EFI anexada.
- **Validação**: Aprovados `sh -n`, `grub-script-check`, onze posições, kernel/initrd Ubuntu e comparação dos menus reextraídos.
- **Limite**: QEMU não está instalado; nenhum boot foi observado. Os dez payloads, KDE Full, instalador modificado e Secure Boot continuam sem teste.
- **Documentação**: Implementação e estado adicionados a `LIVE_ISO_11_KERNELS.md` e `BUILD_RESOLUTE_MVP.md`.

## [2026-08-13] - Auditoria do Repositório de Kernel Resolute
- **Ação**: Inspeção somente leitura do clone localizado em `/home/marcel/Parcel Suite/resolute`; nenhum arquivo do kernel foi alterado e nenhuma compilação foi iniciada.
- **Confirmado**: O remoto configurado é `https://git.launchpad.net/~ubuntu-kernel/ubuntu/+source/linux/+git/resolute`.
- **Confirmado**: O clone está no branch `master`, no commit `74134bfb6`, e foi criado como clone superficial (`shallow`).
- **Problema**: Apesar do nome do repositório, o conteúdo atualmente obtido corresponde ao Ubuntu Noble: o `debian.master/changelog` inicia em `linux (6.8.0-30.30) noble`.
- **Problema**: Somente `origin/master` foi trazido para o clone local; o branch de desenvolvimento Resolute `master-next` ainda não foi buscado nem selecionado.
- **Bloqueio de Build**: O caminho `/home/marcel/Parcel Suite/resolute` contém espaços. O Makefile do Linux rejeita diretórios-fonte com espaços ou dois-pontos, portanto essa localização não é compilável.
- **Estado**: A árvore Git estava limpa durante a auditoria, ocupava aproximadamente `1,8 GB` e ainda não continha sabor, configuração ou patches NitroCore.
- **Próximo Passo Proposto**: Buscar `origin/master-next`, mudar para esse branch, mover a árvore para um caminho sem espaços (por exemplo, `/home/marcel/parcel-kernel/resolute`) e validar branch, changelog e `make kernelversion` antes de qualquer otimização.

## [2026-08-13] - Estudo da Live ISO Resolute com GNOME e KDE Full
- **Ação**: Verificação do caminho mais rápido e simples para criar uma imagem Live amd64 do Resolute com GNOME e KDE Full; nenhuma ISO foi criada e nenhum pacote foi instalado nesta etapa.
- **Decisão**: Para o primeiro protótipo, remasterizar a ISO Desktop oficial do Resolute, que já contém GNOME, GDM, `casper`, boot BIOS/UEFI e instalador, adicionando somente o metapacote `kde-full`.
- **Decisão**: Manter o GDM como display manager padrão para disponibilizar GNOME e Plasma no mesmo seletor de sessão.
- **Planejado**: Migrar posteriormente para `livecd-rootfs`, permitindo builds automatizados e reproduzíveis.
- **Confirmado**: O host utiliza Ubuntu 26.04 LTS amd64; `kde-full` está disponível no Resolute e as ferramentas `xorriso` e `squashfs-tools` já estão instaladas.
- **Limitação**: A imagem oficial observada já possui aproximadamente `6,1 GB`; com KDE Full, o resultado deve ser tratado como Live USB e não como CD físico.
- **Documento Técnico**: Procedimento, fontes, riscos, alternativas e critérios de teste registrados em `LIVE_CD_RESOLUTE.md`.

## [2026-08-13] - Seleção do Instalador Mínimo da Live ISO
- **Ação**: Comparação de Subiquity, Calamares, Anaconda e archinstall para instalar a Live ISO Resolute com GNOME e KDE Full; nenhuma instalação em disco foi executada.
- **Decisão**: Preservar no MVP o Ubuntu Desktop Installer existente na ISO oficial, utilizando seu backend Subiquity.
- **Motivo**: É a alternativa nativa do Resolute e exige menos integração para particionamento, payload offline, usuário e bootloader.
- **Calamares**: Mantido como experimento futuro independente; o pacote está disponível no Resolute, mas os protótipos atuais não possuem `settings.conf`, configuração de payload ou fluxo completo de instalação.
- **Anaconda**: Descartado para o MVP por sua integração principal com RPM/DNF e árvore de instalação Fedora/RHEL.
- **archinstall**: Descartado como backend porque é uma biblioteca para instalar Arch Linux; mantido apenas como referência de logs e configuração declarativa.
- **Correção Documental**: Removida de `ESTRATEGIA_INSTALADOR.md` a afirmação de que uma fusão Calamares/Subiquity estava consolidada.
- **Documento Técnico**: Requisitos mínimos, matriz comparativa, testes e fases registrados em `INSTALADOR.md`.

## [2026-08-13] - Plymouth e Inclusão do Kernel Ubuntu
- **Ação**: Verificação do mecanismo Plymouth no Ubuntu Resolute e da seleção de splash depois do GRUB; nenhuma imagem foi criada e nenhum initramfs foi alterado.
- **Confirmado**: O tema Plymouth é incorporado ao initramfs e precisa estar disponível antes da montagem do sistema raiz.
- **Decisão**: Cada entrada futura do GRUB usará um par kernel/initramfs próprio, permitindo incorporar uma splash específica e evitando depender de um parâmetro de tema não documentado.
- **Alteração Documental**: O kernel oficial Ubuntu foi adicionado a `kernel.md` como décimo primeiro perfil, baseline, opção padrão inicial e fallback de recuperação.
- **Correção Documental**: `ARQUITETURA_BOOT.md` passou a descrever onze entradas planejadas, initramfs separados e estado ainda não validado.
- **Escopo MVP**: A primeira Live ISO terá apenas o kernel Ubuntu e o tema `parcel-ubuntu`; entradas NitroCore não serão simuladas antes da existência dos respectivos binários.
- **Documento Técnico**: Mapeamento de boot e identidade visual consolidado em `LIVE_ISO_11_KERNELS.md`.
- **Requisito Corrigido Posteriormente**: Plymouth e initramfs próprios aplicam-se às oito opções Linux; os três BSDs usam mecanismos nativos.
- **Correção Técnica**: Registrado em `kernel.md` que `plymouth-set-default-theme -R` configura um tema global e não deve ser repetido sem controle para gerar onze initramfs; cada versão será regenerada, copiada e validada individualmente.
- **Critério de Aceite**: Um kernel somente será marcado como pronto após validação do tema com `lsinitramfs` e teste visual completo em máquina virtual.
- **Variação Confirmada no Resolute**: O host não fornece `plymouth-set-default-theme`; a seleção existente usa `update-alternatives`, enquanto `update-initramfs` é fornecido pelo Dracut 110.
- **Documentação Corrigida**: `kernel.md` agora apresenta os dois fluxos e exige detecção da ferramenta disponível, evitando copiar comandos de outra distribuição sem validação.

## [2026-08-13] - Auditoria dos Procedimentos para 11 Kernels na Live ISO
- **Ação**: Auditoria somente leitura da documentação, scripts e artefatos disponíveis para verificar a prontidão dos onze kernels; nenhum kernel foi compilado e nenhuma ISO foi alterada.
- **Resultado**: Os procedimentos ainda não estão prontos para execução completa. Plymouth e o vínculo GRUB/kernel/initramfs estão documentados, mas faltam configurações, ABI, pacotes, módulos no rootfs, integração Casper, firmware, assinatura e testes.
- **Ubuntu Oficial**: Único kernel utilizável no primeiro protótipo, ainda sujeito a teste após a remasterização.
- **NitroCore**: Dez perfis permanecem bloqueados por ausência de configurações, patches versionados, pacotes de imagem/módulos e initramfs reais.
- **Correção Técnica**: Registrado que copiar apenas `vmlinuz` e initramfs para `casper/` é insuficiente; o SquashFS precisa conter `/lib/modules/VERSAO` e os pacotes correspondentes.
- **Modelo de Fonte**: Recomendado usar uma revisão fixada do empacotamento Ubuntu Resolute como base comum dos sete NitroCore Linux, mantendo Ubuntu como fallback; os três BSDs usam fontes e payloads nativos.
- **Secure Boot**: Classificado como bloqueado para NitroCore até existir gestão de chaves, assinatura de kernel/módulos e integração shim/MOK testada.
- **Recursos**: O host possui menos RAM que os 8 GB recomendados pela Canonical; builds devem ser sequenciais e com paralelismo limitado.
- **Documento Técnico**: Matriz de prontidão e procedimento comum de nove etapas adicionados a `kernel.md`.

## [2026-08-13] - Definição da Live ISO Única com Seletor de 11 Kernels
- **Requisito Confirmado**: O projeto terá uma única mídia cujo menu seleciona uma de onze opções antes da inicialização.
- **Fluxo Corrigido Posteriormente**: Oito opções Linux usam kernel/initramfs/Plymouth e rootfs Ubuntu; três BSDs usam boot e userspaces próprios.
- **Correção Técnica**: O ambiente gráfico não é normalmente desempacotado por completo a cada boot; as camadas SquashFS são montadas como somente leitura e combinadas com OverlayFS gravável em RAM.
- **Contrato Comum Linux**: Somente os oito kernels Linux montam as mesmas camadas e encontram `/lib/modules/$(uname -r)` no rootfs Ubuntu.
- **Fallback**: Ubuntu Oficial permanecerá como primeira opção e recuperação caso um NitroCore não consiga iniciar a Live.
- **Política Pendente**: A escolha do kernel para a sessão Live não define automaticamente quais kernels serão instalados no disco; essa política será decidida e testada separadamente.
- **Documentação Atualizada**: Fluxo, layout da mídia, responsabilidades, recuperação e critérios registrados em `LIVE_ISO_11_KERNELS.md`, `ARQUITETURA_BOOT.md` e `kernel.md`.
- **Organização Documental**: A arquitetura multi-kernel foi removida de `LIVE_CD_RESOLUTE.md` e consolidada em `LIVE_ISO_11_KERNELS.md`; o documento Resolute voltou a tratar somente do MVP com kernel Ubuntu.

## [2026-08-13] - Verificação de FreeBSD, NetBSD e OpenBSD Reais
- **Ação**: Pesquisa técnica sobre a inclusão dos três BSDs como sistemas reais na mesma mídia; nenhum artefato BSD foi baixado ou executado.
- **Conclusão**: Kernels BSD não podem substituir diretamente o Linux no fluxo Casper nem iniciar o rootfs Ubuntu com `ubuntu-desktop` e `kde-full`, devido a ABI, syscalls, drivers, boot e userspace diferentes.
- **Arquitetura Corrigida**: A mídia passa a ser multi-OS: oito opções Linux compartilham o rootfs Ubuntu; FreeBSD, NetBSD e OpenBSD usam payloads e bootloaders próprios.
- **FreeBSD**: Exige loader, kernel, módulos e rootfs FreeBSD; Linuxulator funciona no sentido FreeBSD hospedando parte de um userland Linux.
- **NetBSD**: Exige kernel, sets e imagem nativa; rump kernels são serviços em userspace e não substituem o kernel Linux no GRUB.
- **OpenBSD**: O mínimo oficial é o ramdisk kernel `bsd.rd` para instalação/recuperação; não existe promessa de Live GNOME/KDE no MVP.
- **Plymouth**: Restrito às oito entradas Linux. Os BSDs usarão branding e telas de boot nativos.
- **Risco**: Suporte direto do GRUB varia por firmware; bootloaders EFI nativos devem ser priorizados e testados, especialmente porque a documentação OpenBSD alerta sobre falhas frequentes com GRUB.
- **Documentação Atualizada**: Decisão, alternativas, payloads mínimos, fluxo e testes registrados em `LIVE_ISO_11_KERNELS.md` e `kernel.md`.

## [2026-08-13] - Live e Instaladores Nativos dos Três BSDs
- **Ação**: Pesquisa dos procedimentos oficiais para mídia Live/instalação de FreeBSD, NetBSD e OpenBSD; nenhum download, build ou particionamento foi realizado.
- **Decisão MVP**: Integrar primeiro ambientes oficiais de instalação/recuperação, sem exigir desktop gráfico BSD.
- **FreeBSD**: Usar como baseline `disc1.iso` ou `memstick.img`, validar Live de terminal e instalação offline com `bsdinstall`; o modo Live oficial não possui GUI.
- **NetBSD**: Usar imagem oficial ou build amd64 por `build.sh` com `release` e `iso-image`/`install-image`; instalar por `sysinst`.
- **OpenBSD**: Usar `installXX.iso`/`.img` e `bsd.rd`; validar sets e assinaturas com `signify`; o ramdisk é instalador/recuperação, não Live desktop.
- **Menu de Boot**: Recomendado protótipo UEFI com menu EFI principal e chainload dos bootloaders BSD nativos; GRUB permanece no ramo Linux.
- **Instaladores**: Não haverá backend único no MVP. Subiquity, `bsdinstall`, `sysinst` e instalador OpenBSD permanecem isolados.
- **Segurança**: Primeiros testes de instalação usarão discos virtuais vazios e exclusivos, sem multiboot instalado.
- **Documento Técnico**: Procedimentos por sistema, artefatos, fases, limitações e critérios de aceite adicionados a `LIVE_ISO_11_KERNELS.md`.

## [2026-08-13] - Análise e Estruturação Inicial
- **Ação**: Análise do diretório do projeto e identificação do propósito (Criação de um OS).
- **Ação**: Pesquisa no sistema de arquivos do usuário para localizar tecnologias complementares (Thunder SDK, Parcel Suite).
- **Ação**: Auditoria do Thunder SDK identificando pontos críticos de segurança e performance.
- **Ação**: Análise profunda do código-fonte do **Connectiva Linux 4** como referência histórica e estrutural.
- **Ação**: Mapeamento das 8 etapas de construção de um OS baseadas no modelo da Connectiva.
- **Ação**: Consolidação do plano estratégico e migração de documentos para a raiz do projeto.
- **Ação**: Criação do `RESUMO_DO_CHAT.md` para síntese das discussões.
- **Ação**: Expansão do `DETALHAMENTO_TECNICO.md` para cobrir todas as 8 etapas de construção do OS.
- **Ação**: Criação da `ARQUITETURA_PERFORMANCE.md` detalhando NitroCore, OmniLock e Dark Volt.
- **Ação**: Definição do **Ubuntu 26** como distribuição base do sistema.
- **Ação**: Criação do `GESTAO_PACOTES.md` detalhando o **Parcel Software Center** (APT, Snap, Flatpak).
- **Ação**: Atualização de todos os documentos estratégicos para refletir a compatibilidade total e a base Ubuntu 26.
- **Ação**: Implementação da estratégia de **"Divórcio do Kernel"**: Uso do Kernel Vanilla transparente em vez do kernel do Ubuntu.
- **Ação**: Criação do `TRANSPARENCIA_KERNEL.md` para documentar referências de Arch, openSUSE e BSD.
- **Ação**: Pesquisa extensiva e catalogação de links de kernels de diversas distribuições (Ubuntu, Debian, Fedora, NixOS, Void, etc.).
- **Ação**: Verificação de links e correção da documentação: O link do kernel Ubuntu no GitHub foi identificado como não funcional e substituído pelos links oficiais do **Launchpad**.
- **Ação**: Inclusão dos repositórios oficiais do kernel **Fedora** (GitLab ARK e Dist-Git) na documentação de transparência.
- **Ação**: Consolidação do `TRANSPARENCIA_KERNEL.md` com links 100% verificados e funcionais.
- **Ação**: Definição dos **9 Pilares de Referência** para o kernel NitroCore: Slackware, Debian, FreeBSD, NetBSD, openSUSE, Arch Linux, Fedora, Gentoo e Clear Linux.
- **Ação**: Identificação do status do **Clear Linux** (arquivado pela Intel) e adoção do **CachyOS** como referência moderna de performance.
- **Ação**: Inclusão do **NetBSD** como referência de portabilidade universal mantida desde 1993.
- **Ação**: Reconfiguração dos pilares para o **Octógono de Referência**: Remoção de Slackware e Clear Linux; inclusão do **OpenBSD** para reforçar a segurança extrema.
- **Ação**: Consolidação da documentação na raiz para refletir o novo grupo de 8 sistemas de elite.
- **Ação**: Pesquisa e localização dos kernels enterprise: **CentOS Stream** (GitLab) e **Oracle Linux UEK** (GitHub).
- **Ação**: Verificação técnica do kernel do **Slackware**: Confirmado o uso do kernel **6.18.44 Vanilla** (versão Current) sem patches externos.
- **Ação**: Criação da `MATRIZ_QUALIDADE.md` detalhando as heranças técnicas do Octógono (OpenBSD, FreeBSD, etc.).
- **Ação**: Criação da `COMPATIBILIDADE_UNIVERSAL.md` com a estratégia para unificar Windows, Android e Linux.
- **Ação**: Início da execução técnica com a criação da pasta `scripts/`.
- **Ação**: Implementação dos primeiros scripts de build: `build_os.sh`, `01-bootstrap-toolchain.sh`, `02-build-nitrocore.sh` e `03-setup-fhs.sh`.
- **Ação**: Criação e enriquecimento dos documentos `INSTALADOR.md`, `MATRIZ_QUALIDADE.md` e `COMPATIBILIDADE_UNIVERSAL.md` com detalhes técnicos de arquitetura e design.
- **Ação**: Implementação do tema **Dark Kubuntu** (Breeze Dark) para o instalador.
- **Ação**: Criação do protótipo de interface em QML (`show.qml`) e do módulo Python `thunder_setup`.
- **Ação**: Implementação do módulo `universal_compat` para automação da instalação de Snaps, Flatpaks, Waydroid e Wine/Proton.
- **Ação**: Desenvolvimento da interface gráfica **Decágono Selector** em QML/Kirigami, categorizando os 10 kernels em Performance, Enterprise e Segurança.
- **Ação**: Implementação da tela **Session Selector** (Gnome Basic vs KDE Full) com design imersivo em Kirigami.
- **Ação**: Criação da `MATRIZ_INSTALACAO.md` definindo os metapackages `ubuntu-desktop` e `kde-full` para Ubuntu 26.
- **Ação**: Integração da lógica de instalação de desktop no módulo Python `universal_compat`.
- **Ação**: Atualização da Etapa 7 no `DETALHAMENTO_TECNICO.md` para refletir a instalação dinâmica de interfaces.
- **Ação**: Integração das escolhas de sessão e kernel com o `globalStorage` do Calamares.
- **Ação**: Ativação da tecnologia **Dark Volt**: Criação do `DARK_VOLT.md` e dos protótipos de serviço e configuração em `scripts/`.
- **Restrição**: Tecnologia **Dark Volt** colocada em estado de "Hold" (Em espera). Não será integrada ao boot sem aprovação explícita.
- **Ação**: Implementação do script `kde-thunder-optim.sh` para aceleração profunda da Sessão Full (KDE) via Vulkan e UDMABUF.
- **Ação**: Atualização da `ARQUITETURA_PERFORMANCE.md` para incluir a aceleração de interface Qt 6.
- **Ação**: Implementação da arquitetura **Anykernel (NetBSD style)** via Rump Kernels para portabilidade universal.
- **Ação**: Desenvolvimento do conceito do **Thunder Browser** nativo para o ambiente EGLFS.
- **Ação**: Criação de scripts de otimização de performance para o motor Chromium.
- **Ação**: Integração do seletor com o `globalStorage` do Calamares para salvar o sabor NitroCore escolhido.
- **Ação**: Criação da `ESTRATEGIA_INSTALADOR.md` detalhando a fusão Calamares (Frontend) + Subiquity (Backend).
- **Ação**: Definição do **Decágono de Referência**: Adição de CentOS Stream e Oracle Linux UEK como pilares de infraestrutura e performance enterprise.
- **Ação**: Atualização de todos os documentos para os **10 Sabores do NitroCore** e seletor de instalação expandido.
- **Ação**: Criação da `ARQUITETURA_BOOT.md` detalhando o menu GRUB do Live CD com os 10 kernels e a transição via `kexec`.
- **Ação**: Configuração do sabor **Debian** como a opção padrão (default) no menu de boot do Live CD.
- **Ação**: Início da **Fase de Compilação Real**: O usuário clonou o código-fonte do kernel Ubuntu em `~/Parcel Suite/resolute`.
- **Ação**: Auditoria profunda da pasta `Kernels/` dentro do projeto, identificando fontes do **Linux 7.1.8**, **Ubuntu 26**, **Connectiva 4**, **FreeBSD 15** e **16**.
- **Ação**: Consolidação do "Laboratório de Kernels" como a base para a criação do NitroCore Híbrido.
- **Ação**: Criação do arquivo `LABORATORIO_KERNELS.md` detalhando as descobertas sobre Kconfigs e o legado da Connectiva.
- **Ação**: Identificação precisa da anatomia do kernel Ubuntu: Confirmado que ele é uma base Debian com a pasta `ubuntu/` como diferencial de drivers e patches.
- **Ação**: Criação do arquivo `ANATOMIA_DEBIAN_UBUNTU.md` detalhando as diferenças de filosofia e conteúdo entre o Debian 13 e o Ubuntu 26.
- **Ação**: Criação da pasta `nitrocore/` com o documento `nitrocore.md` definindo os 4 pilares técnicos.
- **Ação**: Definição da estratégia "Future-Proof" (Ubuntu 27+) e inclusão de **Arch/SteamOS** e **Fedora** como referências de performance gamer e workstation.
- **Ação**: Criação do arquivo `REFERENCIAS_GAMING.md` detalhando tecnologias como BORE (Arch), EPP Boost (SteamOS) e NTSYNC (Fedora).
- **Ação**: Implementação dos primeiros protótipos em C: `nitro_sched.c` (Escalonador de Resposta) e `omnilock.c` (Gestão de Memória).
- **Ação**: Pesquisa profunda sobre a arquitetura do **SteamOS 3.5/3.8** e criação do documento `STEAMOS_INTEGRATION.md` com as lições da Valve.
- **Ação**: Implementação do protótipo de segurança `nitro_hardened.c` (W^X Protection) e dos arquivos de build `Kconfig` e `Makefile` para a pasta `nitrocore/`.
- **Ação**: Criação do documento `KDE_GAMESCOPE_INTEGRATION.md` detalhando como o KDE Plasma 6 rodará sob o Gamescope para latência zero.
- **Ação**: Início da **Aprendizagem Supervisionada** do código FreeBSD (v15/16), criando o documento mestre `APRENDIZAGEM_FREEBSD.md` com referências à arquitetura Sony PlayStation (Orbis OS).
- **Ação**: Implementação do protótipo de rede `nitro_net.c` inspirado na eficiência de rede do FreeBSD.
- **Ação**: Criação da "Trindade da Performance" no documento `ORBIS_FREEBSD_STEAMOS.md`.
- **Ação**: Integração técnica do **Gamescope** com o **OmniLock**, permitindo o travamento de texturas na RAM física.
- **Ação**: Análise do ZFS ARC e VFS Read-ahead do FreeBSD para otimização de carregamento de jogos.
- **Ação**: Configuração do `.gitignore` para excluir os diretórios gigantes de fontes de kernel.
- **Ação**: Criação do documento `SONY_PLAYSTATION_FREEBSD.md` detalhando como a Sony adaptou o FreeBSD para os consoles PS4 e PS5.
- **Ação**: Início da análise técnica de `bpf_zerocopy.c` (FreeBSD 15) no âmbito da aprendizagem supervisionada.
- **Ação**: Análise profunda de `vm_page.c` (FreeBSD 15), identificando a lógica de "wiring" de páginas para o aprimoramento do OmniLock.
- **Ação**: Implementação técnica do protótipo `nitro_net.c` utilizando lógica de **AF_XDP** para processamento de pacotes com zero-copy.
- **Ação**: Análise técnica de `kern_jail.c` (FreeBSD 15) para a criação do motor de isolamento **Nitro-Jail**.
- **Ação**: Criação do módulo de instalador `agility_zone` para automação da infraestrutura Arch/Pacman via Distrobox.
- **Ação**: Desenvolvimento do script `nitro-optimize-build.sh` para detecção automática de microarquitetura x86-64-v3/v4.
- **Ação**: Criação da **ZFS Gaming Zone**, integrando a tecnologia do FreeBSD e Oracle para carregamento ultra-rápido de jogos e cache persistente.
- **Ação**: Implementação do **Nitro Build System**, detalhando o uso de Clang 19, ThinLTO e AutoFDO para performance de vanguarda.
- **Ação**: Refinamento do script de otimização com as flags `-Ofast` e `-fno-plt` (Sony Style).
- **Ação**: Implementação do **Nitro-Linker** (`nitro-linker.sh`), emulando a segurança **KARL** do OpenBSD através da randomização da ordem de linkagem de objetos.
- **Ação**: Criação da sessão **Parcel-Gamescope** (`parcel-gamescope-session.sh` e `.desktop`), permitindo que o KDE rode nativamente dentro do micro-compositor da Valve.
- **Ação**: Criação dos dossiês técnicos finais do Decágono: `NETBSD_TECH.md` (Portabilidade/Anykernel) e `OPENBSD_TECH.md` (Segurança Proativa).
- **Ação**: Design e criação do mockup QML do **Nitro-Control Center**, a central de comando unificada inspirada no YaST do openSUSE.
- **Ação**: Consolidação da documentação completa para todos os 10 sistemas de referência do Parcel Play OS.
- **Ação**: Criação do documento mestre de união `UBUNTU_STEAMOS_PARCEL_UNION.md`.
- **Ação**: Design do Boot Splash (Plymouth) no documento `BOOT_SPLASH_DESIGN.md`, integrando a identidade visual Breeze Dark.
- **Ação**: Implementação do script `generate-uki.sh` para criação de Unified Kernel Images, aumentando a segurança do boot.
- **Ação**: Início da Fase 5 da Aprendizagem Supervisionada do FreeBSD, focando na camada de drivers de áudio (`sys/dev`).
- **Ação**: Criação do documento `ORBIS_FREEBSD_STEAMOS_INTEGRATION.md` unificando as lições de isolamento (Sony) e imutabilidade (Valve).
- **Ação**: Análise do código de Jails do FreeBSD (`kern_jail.c`) para a criação da camada de isolamento **Nitro-Jail**.
- **Ação**: Implementação do código C do **Nitro-Prefetcher** (`nitro_prefetcher.c`) focado em aceleração de I/O para jogos.
- **Ação**: Criação da **Gestão Híbrida (APT + Pacman)**: Desenvolvimento do conceito de Zona de Estabilidade (Ubuntu) e Zona de Agilidade (Arch via Distrobox).
- **Ação**: Implementação do código C do **Nitro-Jail** (`nitro_jail.c`), integrando isolamento por Namespaces inspirado no PlayStation (FreeBSD Jails).
- **Ação**: Criação da estratégia de isolamento de Glibc e dependências híbridas no arquivo `HYBRID_GLIBC_STRATEGY.md`.
- **Ação**: Implementação técnica do protótipo **NTSYNC** (`nitro_ntsync.c`) para aceleração de jogos Windows (inspirado no Fedora 44).
- **Ação**: Desenvolvimento do plano de suporte universal para **DNF (Fedora)** e **openSUSE** no arquivo `GESTAO_RPM_DNF.md`.
- **Ação**: Implementação do script `nitro-hybrid-handoff.sh` utilizando lógica de Bubblewrap para isolamento de bibliotecas entre Ubuntu e Arch.
- **Ação**: Criação do script de automação `setup-z-gaming.sh` para configuração da **ZFS Gaming Zone** otimizada para 2026.
- **Ação**: Pesquisa e documentação das otimizações da Valve no Arch Linux (`VALVE_ARCH_OPTIMIZATIONS.md`).
- **Ação**: Design da interface do **Parcel Software Center** unificando 4 fontes de pacotes (`SOFTWARE_CENTER_DESIGN.md`).
- **Ação**: Implementação técnica do protótipo de áudio de baixa latência `nitro_audio.c` inspirado no FreeBSD/Sony.
- **Ação**: Criação do Mockup QML oficial para o **Parcel Software Center**, unificando visualmente AUR, APT, COPR e Flathub.
- **Ação**: Desenvolvimento do código C para o **Nitro-Warp Storage** (`nitro_storage.c`), implementando a tecnologia Direct Storage (P2PDMA) inspirada no PlayStation 5.
- **Ação**: Criação do dossiê técnico `ORBIS_OS.md` detalhando a arquitetura de syscalls, gráficos (GNM/AGC) e I/O de ultra-velocidade do PlayStation 4 e 5.
- **Ação**: Criação do dossiê técnico `FEDORA_TECH.md` detalhando as inovações do Fedora 44 (NTSYNC, EEVDF, DNF5) e como elas alimentam o NitroCore.
- **Ação**: Criação do dossiê técnico `ARCH_LINUX_TECH.md` detalhando os diferenciais do Arch (Zen Kernel, BORE, Pacman 7.0, AUR) e sua integração ao NitroCore.
- **Ação**: Consolidação do "Quarteto de Elite" no documento `UBUNTU_FREEBSD_ORBIS_STEAMOS.md`.
- **Ação**: Início da **Aprendizagem Supervisionada** do código FreeBSD (v15/16), criando o documento mestre `APRENDIZAGEM_FREEBSD.md`.
- **Ação**: Implementação dos protocolos NitroCore no Kernel: `nitro_sched.c`, `omnilock.c`, `nitro_hardened.c`, `nitro_net.c`, `nitro_prefetcher.c`, `nitro_ntsync.c`, `nitro_audio.c` e `nitro_storage.c`.
- **Ação**: Atualização da `MATRIZ_QUALIDADE.md` e `ARQUITETURA_PERFORMANCE.md` para incluir a aceleração de I/O.
- **Ação**: Atualização do `Kconfig` e `Makefile` do NitroCore para incluir as novas proteções e motores.
- **Ação**: Desenvolvimento do mockup QML do **Thunder Browser** nativo com suporte a **HDR Brightness Mapping**.
- **Ação**: Implementação técnica do protótipo **Nitro-CFI** (`nitro_cfi.c`), integrando segurança de integridade de fluxo estilo OpenBSD.
- **Ação**: Desenvolvimento do **Modo Jogo** (`MODO_JOGO_CAPSICUM.md`) utilizando isolamento por capacidades inspirado no FreeBSD Capsicum.
- **Ação**: Implementação do motor de integridade **Nitro-Verify** (`nitro_verify.c`) e sua documentação (`NITRO_VERIFY.md`), emulando o NetBSD Veriexec.
- **Ação**: Início da Fase 7 da Aprendizagem Supervisionada do FreeBSD, analisando o gerenciamento de buffers do ZFS (`dbuf.c`).
- **Ação**: Design e criação do mockup QML da **Central de Segurança Nitro**, integrando Jails, Verificação e CFI.
- **Ação**: Início da **Análise Completa de `sys/kern`** (FreeBSD 15), identificando as tecnologias de Boot (sysinit), Hardware (Newbus) e Sincronização (Adaptive Mutexes).
- **Ação**: Criação do documento especializado `ANALISE_SYS_KERN_FREEBSD.md` para portabilidade dessas tecnologias para o NitroCore.
- **Ação**: Atualização da `ZFS_GAMING_ZONE.md` com a inteligência de limites dinâmicos de cache.
- **Ação**: Análise de mercado e convergência tecnológica, criando o documento `CONVERGENCIA_MERCADO.md` comparando o Parcel Play OS com Bazzite, Vanilla OS, blendOS e CachyOS.
- **Ação**: Início da Fase 6 da Aprendizagem Supervisionada do FreeBSD, analisando o escalonador **ULE**.
- **Ação**: Criação do dossiê `INTEGRACAO_TRIADE_BSD.md`, detalhando o uso de **Capsicum** (FreeBSD), **Veriexec** (NetBSD) e **PF** (OpenBSD) no NitroCore.
- **Ação**: Criação da tela de **Configuração de Rede Nitro-Net** no instalador, permitindo habilitar Zero-Copy e algoritmos de vanguarda (BBR).
- **Ação**: Criação do dossiê técnico `MACOS_TECH.md` detalhando a arquitetura híbrida Mach + FreeBSD.
- **Ação**: Design do widget **Nitro-Switcher** para o KDE Plasma, integrando com o `grub-reboot` para troca de kernels.
- **Ação**: Implementação do **Nitro-Container Engine (Nitro-APX)**, unificando a gestão de pacotes de múltiplas distros.
- **Ação**: Criação do script unificado `nitro-pkg.sh` para automação de instalações híbridas.
- **Ação**: Implementação completa do widget **Nitro-Switcher** (QML) e seu backend (`nitro-switcher-apply.sh`) para troca dinâmica de sabores do Decágono.
- **Ação**: Auditoria final de consistência em todos os documentos estratégicos do Parcel Play OS.
- **Ação**: Criação do documento `RANKING_ARQUITETURA.md`, estabelecendo o enquadramento do sistema e o rank de influência dos 10 pilares.
- **Ação**: Implementação técnica da **Ponte Windows-Fedora** (`PONTE_WINDOWS_FEDORA.md`), detalhando o uso automático do NTSYNC para performance nativa.
- **Ação**: Desenvolvimento do **Plano de Handoff Ubuntu-Arch** (`HANDOFF_UBUNTU_ARCH.md`), unindo a estabilidade imutável com a agilidade do AUR via Namespaces.
- **Ação**: Configuração rigorosa do `.gitignore` para excluir os diretórios de fontes de kernel em todas as localizações.
- **Ação**: Desenvolvimento do protótipo `scripts/hybrid_build.sh` para orquestrar o merge entre o Linux 7.1.8 e o Ubuntu 26.

## Status Atual
- **Fase**: Análise de DNA e Engenharia de Kernel Híbrido.
- **Próximo Objetivo**: Realizar o merge conceitual entre a base purista 7.1.8 e os drivers do Ubuntu 26.

## 2026-08-19 — Vitamina Linux 7.1.8 no Ubuntu Noble

- **Implementado**: backport do NTSYNC 7.1.8 para a fonte Noble 6.8.4, incluindo UAPI, documentação e kselftest.
- **Adaptado**: alocação de objetos e publicação de descritores para APIs existentes no Linux 6.8.
- **Configurado**: `CONFIG_NTSYNC=m`, mantendo rollback por módulo.
- **Validado**: `ntsync.ko` compilado com BTF usando pahole 1.31; selftest userspace compilado.
- **Pendente**: build completo, assinatura, boot, `/dev/ntsync`, 11 selftests e regressão Wine/Proton.
- **Adiado conscientemente**: `sched_ext`, por acoplamento profundo com scheduler, BPF, tracing e UAPI.
- **PlayOS Kernel 1**: identidade alterada para `6.8.4-playos-kernel1+` e `bzImage` concluído com BTF.
- **mseal**: syscall e proteções de memória integradas; objetos, link e selftest userspace compilados.
- **NTSYNC**: módulo reconstruído com BTF para a identidade PlayOS Kernel.
- **Auditoria 7.1.8**: DRM Panic e fwctl adiados; subsistemas já existentes no Noble não serão duplicados; sched_ext e Rust exigem projetos separados.
- **Gate aberto**: reconstrução global de módulos ainda precisa eliminar artefatos antigos e terminar limpa; depois seguem assinatura, initramfs, boot e runtime.
- **Preservação**: a árvore Linux 7.1.8 não será removida antes dos gates de reprodução e validação.

## 2026-08-20 — Forward-port Noble para PlayOS Kernel 7.1.8

- **Decisão**: manter PlayOS Kernel 1/Noble 6.8.4 como fallback e criar PlayOS Kernel 2 sobre Linux 7.1.8.
- **Patchset**: criada `patch-Noble-PlayOS-Kernel-7.1.8/` com série reproduzível, configuração, scripts, manifesto e análise.
- **Identidade**: fonte 7.1.8 atualizada para `7.1.8-playos-kernel2`.
- **Configuração**: annotations Ubuntu Noble `amd64/generic` reconciliadas pelo Kconfig 7.1.8; AppArmor, Landlock, NTSYNC, BTF e sched_ext confirmados.
- **Produção**: Rust, fault injection e chaves privadas Canonical excluídos; Secure Boot exigirá chave PlayOS.
- **Selftests host**: sendfile, Landlock ABI 8, cgroup v2, namespaces, seccomp, PSI e AppArmor passaram; NTSYNC e kTLS não carregados foram skips.
- **Evidência externa**: Resolute usa Linux 7.0; em 20/08/2026 kernel.org já lista 7.1.9 stable e 7.2 mainline.
- **Build**: compilação completa `bzImage modules` do perfil Generic em staging isolado iniciada; boot continua pendente.
# 2026-08-21 — Entrada `start` e reconstrução de `build`

- `fact`: `build/` e as fontes Linux locais estavam ignoradas pelo Git; um
  clone novo não recuperava esses dados.
- `implementation`: criado `./start` para primeira abertura, inventário,
  layout idempotente, validação documental e checksums, sem instalação no host.
- `implementation`: criado `build/RECRIAR_BUILD.md` e aberta exceção específica
  no `.gitignore` para manter somente esse manual versionado dentro de `build/`.
- `unknown`: Noble 6.8.4 ainda não possui uma série portátil única capaz de
  reconstruir todas as mudanças a partir de checkout limpo.
- próximo gate: exportar e testar a série Noble limpa; depois repetir Kernel 2
  e bootar os artefatos em QEMU/OVMF.
# 2026-08-22 — Kernels convertidos em overlays versionáveis

- `fact`: comparação por checksum encontrou 9 divergências no Linux 7.1.8, 40
  no Noble 6.8.4 e nenhuma nas cópias FreeBSD 15, FreeBSD 16 e Conectiva 4.
- `implementation`: removidas 182.534 entradas idênticas; preservados os 49
  arquivos divergentes em `Kernels/`.
- `implementation`: caminhos externos somente leitura foram centralizados em
  `config/kernel-sources.conf`; auditoria/poda reproduzível foi adicionada em
  `scripts/prune-kernel-overlays.sh`.
- `decision`: `Kernels/` deixa de ser ignorada e passa a versionar somente
  overlays, enquanto fontes completas permanecem fora do projeto.
- `unknown`: composição pós-poda ainda não recebeu build e boot novos.
- próximo gate: reconstruir staging a partir de baseline + overlay, comparar o
  diff resultante, compilar e inicializar em QEMU/OVMF.

## [2026-08-22] - Substituição de Identidade Ubuntu para PlayOS
- **Ação**: Criação da estratégia de branding total para a mídia e sistema básico.
- **Implementação**: Script `scripts/build-playos-iso.sh` pronto para gerar a nova ISO com Volume ID `PlayOS-26.04-amd64`.
- **Implementação**: Configuração GRUB `config/boot/grub-playos.cfg` com menu 100% PlayOS.
- **Implementação**: Script de branding interno `scripts/apply-internal-branding.sh` para execução em chroot.
- **Documentação**: Criada entrada de conhecimento `supervised_learning/knowledge/playos/iso-branding.md`.
- **Estado**: Branding externo concluído na árvore ISO; branding interno aguardando privilégios para repacotamento SquashFS.

## [2026-08-22] - Integração de Branding no Instalador Visual
- **Ação**: Atualização da identidade visual nos instaladores Calamares e Subiquity.
- **Implementação**: Slideshow Calamares (`show.qml`) atualizado para focar na marca PlayOS.
- **Implementação**: Configuração de fontes do Subiquity (`install-sources.yaml`) modificada para exibir "PlayOS Desktop".
- **Implementação**: Criado template de branding para Subiquity em `config/installer/subiquity-branding.yaml`.
- **Documentação**: Criado dossiê `INTEGRACAO_INSTALADOR_BRANDING.md`.

## [2026-08-22] - Planejamento de Assets e Limpeza de Branding
- **Ação**: Identificação de caminhos de ativos visuais (ícones, wallpapers) para substituição futura no RootFS.
- **Implementação**: Criado dossiê `supervised_learning/knowledge/playos/asset-identity.md`.
- **Implementação**: Atualizados mockups de UI (`SoftwareCenter.qml` e `View.qml`) para utilizar `playos-logo` em vez de ícones do Ubuntu.
- **Implementação**: Revisados documentos estratégicos (`COMPATIBILIDADE_UNIVERSAL.md`, `LIVE_CD_RESOLUTE.md`) para priorizar o nome PlayOS como identidade do sistema.

## [2026-08-22] - Implementação da Autotransformação (Pós-Instalação)
- **Ação**: Criação de um fluxo automatizado para aplicar o branding PlayOS no sistema final após a instalação.
- **Implementação**: Script `scripts/inject-visual-assets.sh` para troca de logos e ícones no sistema alvo.
- **Implementação**: Script orquestrador `scripts/nitro-post-install.sh` que roda no final da instalação (`late-commands`).
- **Implementação**: Arquivo de configuração `config/installer/post-install-hooks.yaml` para integração com o instalador Subiquity.
- **Documentação**: Novo dossiê estratégico `supervised_learning/knowledge/playos/auto-metamorphosis.md`.
- **Estado**: Estratégia "Metamorfose" implementada e pronta para teste na ISO.

## [2026-08-22] - Identidade Completa do Live CD
- **Ação**: Implementação de ferramentas para garantir que o ambiente Live (antes da instalação) exiba a marca PlayOS.
- **Implementação**: Script `scripts/rebuild-live-rootfs.sh` para reconstrução do SquashFS com branding interno.
- **Implementação**: Atualização dos metadados de Release em `dists/resolute/Release` (Origin, Label e Suite alterados para PlayOS).
- **Estado**: O Live CD agora está pronto para transição total. A execução do script de reconstrução exige `sudo`.

## [2026-08-22] - Suporte a Wallpaper e Logos Customizados
- **Ação**: Automatização da substituição do papel de parede e logos do Ubuntu pelo PlayOS na sessão Live.
- **Implementação**: Script `scripts/apply-internal-branding.sh` atualizado para configurar o GNOME para usar `/usr/share/backgrounds/playos/default-dark.jpg`.
- **Implementação**: Script `scripts/rebuild-live-rootfs.sh` atualizado para injetar automaticamente arquivos do diretório `assets/` para o RootFS.
- **Estado**: Pronto para injeção de ativos. O usuário deve colocar `wallpaper.jpg` e `logo.svg` na pasta `assets/` do projeto.

## [2026-08-22] - Script Mestre de Construção (Orquestrador)
- **Ação**: Criação de um script único para automatizar todo o processo de branding e geração de ISO.
- **Implementação**: Script `scripts/master-build-playos.sh` que une a reconstrução do RootFS à geração da ISO.
- **Diferencial**: O script realiza checagem de dependências e avisa sobre a ausência de ativos em `assets/`.
- **Estado**: Processo de build totalmente automatizado em um comando único.

## [2026-08-22] - Expansão de Branding Visual e Documentação Master
- **Ação**: Refinamento da substituição de marca para atingir Splash de Boot (Plymouth) e Wallpaper padrão.
- **Implementação**: Script `scripts/inject-visual-assets.sh` atualizado para v1.1.0, com busca agressiva de arquivos de imagem do Ubuntu.
- **Documentação**: Criado o guia completo `build/manuals/ISO_CREATION_GUIDE.md`.
- **Estado**: O sistema agora é capaz de apagar rastros visuais do Ubuntu no RootFS durante a reconstrução.

## [2026-08-22] - Customização do Terminal Neon e Versão v1.1.0 do Build
- **Ação**: Implementação do prompt de comando customizado com cores neon.
- **Implementação**: Script `scripts/apply-internal-branding.sh` atualizado para v1.2.0.
- **Detalhe Visual**: O terminal exibirá `nitro@playos:~$ ` com cores verde (nitro) e ciano (playos).
- **Implementação**: Script mestre `master-build-playos.sh` atualizado para v1.1.0, unificando todas as novas proteções e visual.
- **Estado**: Identidade de terminal integrada ao fluxo de reconstrução do RootFS.

## [2026-08-22] - Banner MOTD em ASCII e Identidade de Login
- **Ação**: Criação de um banner de boas-vindas em ASCII Art para o terminal.
- **Implementação**: Script `scripts/apply-internal-branding.sh` atualizado para v1.3.0.
- **Detalhe Visual**: O banner "PlayOS" em cores neon verde e ciano aparecerá em todo login de terminal.
- **Refinamento**: Desativação do texto de ajuda padrão do Ubuntu (`10-help-text`) para uma experiência mais limpa.
- **Versão**: Build Master elevada para v1.2.0.

## [2026-08-22] - Consolidação Monolítica: PlayOS Ultimate Builder
- **Ação**: União de todos os scripts de branding, transformação de RootFS e geração de ISO em um único utilitário.
- **Implementação**: Script `scripts/ultimate-playos-builder.sh` (v1.0.0).
- **Recursos Integrados**:
    - Extração e Repacotamento de SquashFS (ZSTD).
    - Metamorfose interna via `chroot` (os-release, hostname, MOTD).
    - Injeção agressiva de ativos visuais (Wallpaper Warty, ícones Yaru/Hicolor).
    - Terminal Neon automático (`nitro@playos`).
    - Geração de ISO com Replay de Boot (BIOS/UEFI compatível com original).
- **Estado**: Ferramenta de build definitiva concluída.

## [2026-08-22] - Documentação Mestre da ISO Concluída
- **Ação**: Consolidação de todo o conhecimento de build no guia `build/manuals/PLAYOS_ISO_MASTER_GUIDE.md`.
- **Conteúdo**: Instruções de branding, fluxo técnico do Builder e guia de solução de problemas.
- **Estado**: Documentação de engenharia de mídia concluída em 100%.

## [2026-08-26] - Estudo Live ISO mínima Resolute + XFCE 4.20

- **Ação**: Comparação do modelo Knoppix com os mecanismos Live disponíveis no Ubuntu Resolute.
- **Documento**: `LIVE_CD_RESOLUTE_XFCE_MINIMAL_KNOPPIX.md`.
- **Proposta**: Primeiro protótipo sem instalador com `live-build`, `live-boot`, SquashFS, OverlayFS, kernel `linux-generic` e `xubuntu-desktop-minimal`.
- **Limite**: Nenhuma ISO foi compilada ou inicializada; tamanho, RAM, Secure Boot e compatibilidade permanecem não determinados.
- **Próximo gate**: Gerar primeiro o console Live mínimo e só então adicionar XFCE/LightDM.

## [2026-08-26] - Identificação da fonte local da Live XFCE

- **Fonte**: `/home/marcel/Parcel-Suite/Linux Kernels/ubuntu 26 resolute kernel`.
- **Fato**: `Makefile` declara Linux 6.8.4 e o changelog Ubuntu Noble `6.8.0-30.30`; não é a fonte oficial Resolute 7.0.
- **Capacidade**: SquashFS, loop, EFI e formatos de initramfs são built-in; OverlayFS e ISO9660 são módulos.
- **Estado**: não há `.deb`, `bzImage`, `vmlinux` ou módulos compilados na árvore.
- **Documento**: `AUDITORIA_KERNEL_LOCAL_LIVE_RESOLUTE_XFCE_2026-08-26.md`.
- **Próximo gate**: empacotar imagem, módulos e headers em staging e criar o initramfs coerente com a ABI.

## [2026-08-26] - Comparação Fedora/Knoppix para Live XFCE simples

- **Documento**: `COMPARACAO_FEDORA_KNOPPIX_LIVE_XFCE_KERNEL_LOCAL_2026-08-26.md`.
- **Fedora**: Kickstart é uma boa referência declarativa, mas Lorax/Anaconda/RPM não simplificam um rootfs Ubuntu e estão ausentes no host.
- **Knoppix**: adotado como referência para raiz comprimida e overlay, sem portar cloop/aufs.
- **Decisão proposta**: `live-build` + `live-boot`, pacotes `.deb` locais do kernel e `xubuntu-desktop-minimal`.
- **Correção**: usar `--binary-images` e `--linux-packages none`; o estudo anterior usava singular e permitiria seleção automática incorreta do kernel.
- **Estado**: procedimento documentado, ainda sem build ou boot.

## [2026-08-26] - Arquitetura PlayOS Graphics Kernel Stack

- **Pedido analisado**: novo modelo de kernel PlayOS com X11 e Wayland incluídos.
- **Limite técnico**: Xorg e compositor Wayland são userspace e não serão ligados ao `vmlinux` nem executados no kernelspace.
- **Decisão**: distribuir `linux-playos-graphics` e `playos-graphics-stack` como um produto integrado e atualizável.
- **Sessões**: XFCE/Xorg/xfwm4 como padrão; XFCE/Labwc/Wayland + Xwayland como experimental.
- **Evidência**: o kernel local já habilita DRM/KMS, dma-buf, evdev, framebuffer e drivers Intel/AMD/nouveau como módulos.
- **Documento**: `ARQUITETURA_PLAYOS_GRAPHICS_KERNEL_STACK_2026-08-26.md`.
- **Estado real**: arquitetura documentada; metapacotes, sessões, kernel flavor, build e runtime ainda não implementados.

## [2026-08-26] - Manual completo do PlayOS Graphics Kernel Stack

- **Documento**: `MANUAL_PLAYOS_GRAPHICS_KERNEL_STACK_X11_WAYLAND.md`.
- **Cobertura geral**: fronteiras kernel/userspace, DRM/KMS, input, Mesa, Xorg, Wayland, Xwayland, XFCE e empacotamento.
- **Cobertura de uso**: seleção de sessão, identificação, fallback, recuperação e comandos de diagnóstico.
- **Cobertura específica**: Intel, AMD, nouveau, NVIDIA proprietário, software rendering, jogos, VMs, headless, captura e portals.
- **Operação**: Live ISO, atualização independente, rollback, versionamento, segurança e Secure Boot.
- **Qualidade**: gates por camada, critérios de aceitação, árvore de decisão e níveis G0–G8.
- **Estado atual**: G0, documentação apenas; nenhum pacote ou runtime gráfico PlayOS foi produzido por este trabalho.

## [2026-08-26] - Medição de tamanho Noble + X11 + Wayland + XFCE

- **Método**: resolução APT amd64 em estado vazio com índices assinados Noble, updates e security.
- **Standard**: 1.163 pacotes, 1.424,4 MiB de `.deb` e 3.104,1 MiB instalados.
- **Lean**: 570 pacotes, 1.057,4 MiB de `.deb` e 1.822,8 MiB instalados.
- **Estimativa da ISO standard**: 1,6–2,1 GiB após SquashFS e overhead de boot; ainda não é resultado de build.
- **Limite**: a medição usa `linux-generic 6.8.0-138.138` como proxy; o kernel local 6.8.0-30 ainda não possui `.deb` mensurável.
- **Documento**: `MEDICAO_TAMANHO_ISO_NOBLE_X11_WAYLAND_XFCE_2026-08-26.md`.

## [2026-08-26] - Produto único PlayOS Graphics Platform

- **Documento**: `PROJETO_SOFTWARE_UNICO_PLAYOS_GRAPHICS_PLATFORM.md`.
- **Decisão**: oferecer Noble/kernel PlayOS, X11, Wayland/Labwc/Xwayland e XFCE por uma entrada `playos-graphics-platform`.
- **Arquitetura**: um pacote-fonte gera metapacotes e ferramentas; componentes upstream continuam separados e atualizáveis.
- **Experiência**: um comando APT, CLI, manifesto, diagnóstico e duas sessões.
- **Estado**: especificação documentada; pacote, build, boot, ISO e hardware pendentes.
- **Complemento**: documentada a conexão simples entre base Noble, kernel PlayOS, caminho X11/Wayland e desktop XFCE, incluindo os fluxos das duas sessões.

## [2026-08-26] - Inicialização do PlayOS Graphics Platform

- **Documento**: `INICIALIZACAO_PLAYOS_GRAPHICS_PLATFORM.md`.
- **Fluxo**: UEFI → GRUB → kernel/initramfs → systemd → LightDM → X11 ou Wayland → XFCE.
- **Live**: documentada a etapa adicional SquashFS + OverlayFS antes do userspace definitivo.
- **Recuperação**: kernel anterior, console sem interface gráfica e sessão X11 como fallback do Wayland.
- **Validação**: definidos gates B0–B10, do alinhamento de ABI ao teste em hardware.
- **Estado**: procedimento proposto; nenhum boot novo foi executado por esta documentação.

## [2026-08-26] - Auditoria do catálogo de software freedesktop.org

- **Documento**: `ANALISE_SOFTWARE_FREEDESKTOP_PLAYOS_GRAPHICS_PLATFORM_2026-08-26.md`.
- **Escopo**: todos os projetos apresentados nas seções ativas, movidas e inativas da página solicitada.
- **Classificação**: `CORE`, `PROFILE`, `RECOMMENDED`, `OPTIONAL`, `DEVTEST`, `EXCLUDE` e `TRANSITIVE`.
- **Conclusão**: a página é inventário incompleto e histórico, não lista de dependências nem certificação.
- **Arquitetura adicional**: identificados PipeWire, WirePlumber, Xwayland, Labwc, portals, LightDM e XFCE, necessários ao produto mas insuficientemente representados pelo catálogo.
- **Estado**: matriz conceitual documentada; resolução exata de pacotes e versões Noble continua pendente.

## [2026-08-26] - Manual dos componentes-base do desktop PlayOS

- **Documento**: `MANUAL_COMPONENTES_BASE_PLAYOS_DESKTOP.md`.
- **Cobertura**: systemd/logind, D-Bus, polkit, NetworkManager, UPower, udisks2, XDG, DRM/KMS, Mesa, input, fontes, X11, Wayland, LightDM, XFCE e áudio.
- **Integração**: documentados fluxos de boot, sessão, hardware, IPC, autorização, mídia e Live ISO.
- **Operação**: registrados pacotes candidatos, serviços, arquivos, comandos de diagnóstico, falhas e critérios de aceite.
- **Segurança**: definidos limites de privilégio, sessão, polkit, dispositivos, X11/Xwayland e captura PipeWire/portal.
- **Estado**: manual de arquitetura concluído; resolução APT, empacotamento e testes C0–C12 permanecem pendentes.

## [2026-08-26] - Ampliação do PlayOS para XFCE, GNOME e KDE Plasma

- **Documento**: `ARQUITETURA_MULTI_DESKTOP_PLAYOS_XFCE_GNOME_KDE.md`.
- **Decisão**: XFCE deixa de ser o único desktop; GNOME e KDE Plasma entram no produto planejado.
- **Base comum**: kernel, systemd/logind, D-Bus, polkit, rede, energia, discos, XDG, DRM/Mesa, input, fontes e PipeWire.
- **Compositores**: XFCE usa `xfwm4` em X11 e Labwc no laboratório Wayland; GNOME usa Mutter; Plasma usa KWin.
- **Login**: LightDM, GDM e SDDM foram analisados, mas somente um poderá estar ativo por imagem.
- **Conflitos tratados**: portals, agentes polkit, daemons de configuração, notificações, keyrings e aplicações duplicadas.
- **Estado**: arquitetura e matriz de testes M0–M11 documentadas; pacotes, tamanhos, display manager final, ISO e runtime pendentes.

## [2026-08-26] - Kernel gráfico PlayOS sem desktops

- **Documento**: `KERNEL_GRAFICO_PLAYOS_SEM_DESKTOPS.md`.
- **Decisão**: XFCE, GNOME e KDE Plasma são retirados do conceito e do pacote do kernel gráfico.
- **Conteúdo do kernel**: DRM/KMS, drivers de GPU, dma-buf, sincronização, input, console, firmware loader e infraestrutura de hardware.
- **Fora do kernel**: Mesa/libdrm, Xorg, Wayland, Xwayland, compositores, display managers, desktops e PipeWire.
- **Empacotamento**: kernel e módulos próprios; `playos-graphics-core` userspace separado; desktops opcionais dependem da base, nunca o contrário.
- **Validação**: definidos gates KG0–KG11 e uma Live ISO técnica que inicializa até console sem desktop.
- **Estado**: arquitetura documentada; configuração, build, pacotes, VM, ISO e hardware permanecem pendentes.

## [2026-08-26] - Graphics Core completo sem GNOME, KDE ou XFCE

- **Documento**: `PLAYOS_GRAPHICS_CORE_COMPLETO_SEM_DESKTOPS.md`.
- **Restauração**: systemd/logind, D-Bus, polkit, rede, energia, discos, XDG, Mesa, input, fontes, Xorg, Wayland, Xwayland, Labwc, LightDM, ALSA, PipeWire e WirePlumber voltam ao produto.
- **Exclusão**: GNOME, KDE Plasma e XFCE, com seus shells, compositores e display managers específicos, não entram na composição.
- **Fronteira**: somente DRM/KMS, drivers e mecanismos de hardware ficam no kernel; demais itens são reunidos pelo metapacote userspace `playos-graphics-core`.
- **Sessões**: X11 técnica e Wayland/Labwc básica, sem ambiente de desktop.
- **ISO**: definida edição Graphics Core para validar toda a pilha antes de instalar um desktop opcional.
- **Estado**: arquitetura GC0 documentada; resolução APT, pacotes, boot, sessões, ISO e hardware permanecem pendentes.

## [2026-08-26] - Vulkan no PlayOS Graphics Core

- **Documento**: `VULKAN_NO_PLAYOS_GRAPHICS_CORE.md`.
- **Integração**: loader Vulkan, ICDs Mesa e WSI para X11/XCB e Wayland/Labwc passam a integrar o Graphics Core.
- **Drivers**: ANV, RADV, NVK quando disponível, lavapipe e perfis de virtualização serão resolvidos contra a versão real do Mesa.
- **Pacotes**: separados runtime, ferramentas, desenvolvimento/validation layers e futuro perfil multiarch 32-bit.
- **Diagnóstico**: definidos comandos `playos-graphicsctl vulkan`, manifesto de dispositivo, WSI, driver e hardware/software.
- **Validação**: gates VK0–VK12 cobrem loader, ICDs, GPUs, X11, Wayland, Xwayland, suspensão, ISO e 32-bit.
- **Estado**: Vulkan documentado e aprovado na arquitetura; instalação, testes e runtime permanecem pendentes.

## [2026-08-27] - XFCE substitui Openbox somente na Live Noble

- **Documento**: `LIVE_ISO_NOBLE_XFCE_SOBRE_GRAPHICS_CORE_2026-08-27.md`.
- **Decisão**: o Graphics Core continua sem GNOME, KDE Plasma ou XFCE; a edição Live passa a consumir esse núcleo com XFCE.
- **Baseline confirmada**: Ubuntu Noble fornece XFCE 4.18; XFCE 4.20 não foi alegado nem incorporado.
- **Implementação**: removidos pacote, sessão, script e autostart Openbox; adicionados XFCE, goodies, terminal, power manager e integração Thunar.
- **Login**: LightDM seleciona `xfce` como sessão padrão; Labwc permanece como sessão Wayland técnica separada.
- **Instalador**: Calamares continua independente do desktop e será acessível pelo menu XDG do XFCE.
- **Validação**: disponibilidade e versões APT confirmadas; referências ativas a Openbox removidas do perfil, salvo auditoria de pacote proibido.
- **Limite**: o SquashFS anterior está obsoleto; rebuild, ISO, boot e instalação em VM permanecem pendentes.

## [2026-08-27] - Calamares versus Anaconda

- **Documento**: `COMPARACAO_CALAMARES_ANACONDA_PLAYOS_2026-08-27.md`.
- **Decisão**: Calamares permanece candidato único da Live Noble XFCE.
- **Motivo**: integração existente com SquashFS, pacote Noble e custo muito menor que adaptar Anaconda de RPM/DNF para DEB/APT.
- **Anaconda**: referência futura para Kickstart, LVM, RAID, iSCSI, multipath e uma eventual edição baseada em Fedora/RHEL.
- **Limite**: recomendação arquitetural; nenhuma instalação PlayOS completa foi comprovada ainda.

## [2026-08-27] - Calamares versus Ubuntu Desktop Provision

- **Documento**: `COMPARACAO_CALAMARES_DESKTOP_PROVISION_PLAYOS_2026-08-27.md`.
- **MVP**: Calamares permanece por já consumir diretamente o SquashFS da Live e carregar o perfil PlayOS.
- **Estratégia Ubuntu**: Desktop Provision será avaliado em variante separada com Casper, livecd-rootfs, Subiquity, Curtin e fontes declaradas.
- **Primeiro boot**: `ubuntu_init`/`provd` é vantagem do Desktop Provision para OEM e provisionamento pós-instalação.
- **Restrição**: não incluir dois motores na mesma ISO e não copiar hooks GNOME da imagem Core Desktop para o perfil XFCE.

## [2026-08-28] - Build da primeira ISO Noble XFCE Calamares iniciado

- **Perfil**: `live-build/playos-graphics-core-noble/`.
- **Composição**: Graphics Core neutro, XFCE 4.18 na Live, LightDM, Labwc técnico e Calamares.
- **Preparação**: build antigo limpo e preservado com outro nome; perfil final sincronizado sem resíduos Openbox.
- **Execução**: `lb build` ativo na VM `playos-noble-graphics-vm`, unidade `playos-xfce-calamares-build.service`.
- **Recursos**: 16 GiB livres no início da execução.
- **Estado**: bootstrap em andamento; ainda não há ISO nem resultado de boot.

## [2026-08-28] - Plano e inventário de fontes da primeira ISO

- **Documento**: `PLANO_IMPLEMENTACAO_PRIMEIRA_ISO_NOBLE_XFCE_CALAMARES.md`.
- **Pacotes diretos**: 74 nomes, todos obtidos online dos repositórios Ubuntu Noble.
- **Kernel e firmware**: online; kernel generic oficial, módulos e initramfs coerentes, sem kernel local PlayOS nesta primeira ISO.
- **Conteúdo local**: configurações Calamares/LightDM, sessão Labwc, launcher, branding, identidade e dois hooks.
- **Dependências**: resolvidas online pelo APT com recommends; versões finais serão congeladas no manifesto do chroot.
- **Reprodutibilidade**: nominal, ainda não bit a bit, porque os mirrors não estão fixados em snapshot.
- **Plano**: preparação, bootstrap, auditoria, SquashFS, GRUB/ISO, inspeção, boot UEFI/BIOS e instalação em VM documentados.

## [2026-08-28] - Primeira ISO Noble XFCE Calamares gerada

- **Artefato**: `build/playos-graphics-core-noble/output/playos-noble-xfce-calamares-amd64.iso`.
- **Tamanho**: 1.755.160.576 bytes.
- **SHA-256**: `4ce6c108ad9d455e80ad859ae61e9890f9aa8a5f14d7408d7e8bed8bf994c1b2`.
- **Payload**: Noble 6.8.0-138, XFCE 4.18, LightDM, Calamares 3.3.5, Labwc, X11/Xwayland, Mesa/Vulkan e PipeWire/WirePlumber.
- **Exclusões**: GNOME Shell, Ubuntu Desktop, KDE Plasma e Openbox ausentes do manifesto.
- **Boot estático**: El Torito BIOS, imagem UEFI, MBR GRUB2 híbrido e GPT protetora confirmados.
- **Correção**: a finalização defeituosa do `live-build 3.0~a57` foi substituída por `grub-mkrescue`/xorriso e registrada em script reutilizável.
- **Estado**: ISO gerada e auditada estaticamente; boot, desktop, instalador e hardware ainda não foram testados em runtime.
- **Próximo gate**: boot BIOS e UEFI em VM e instalação Calamares em disco virtual descartável.

## [2026-08-28] - Calamares híbrido com Subiquity como backend

- **Ação**: Implementação da ponte Calamares + Subiquity para resolver a falha do instalador standard.
- **Arquitetura**: Calamares atua como frontend (Show) para coleta de dados e decisões; Subiquity/Curtin atua como backend (Exec) para o deploy.
- **Novos Módulos**:
    - `subiquity_bridge`: Traduz `globalStorage` (usuário, particionamento, sessão) para `autoinstall.yaml`.
    - `subiquity_exec`: Invoca o `subiquity --autoinstall` com o arquivo gerado.
- **Configuração**: `settings.conf` atualizado para remover módulos `unpackfs` e `bootloader` do Calamares, delegando-os ao Subiquity.
- **Pacotes**: Adicionados `subiquity-server`, `curtin`, `casper` e `python3-yaml` ao perfil `live-build`.
- **Hooks**: Tuning de performance e ativação de serviços integrados via `late-commands` do Subiquity.
- **Estado**: Código implementado e integrado ao perfil; build da ISO híbrida pronto para reprodução.

## [2026-08-29] - Runbook da primeira ISO Calamares + XFCE

- **Ação**: criado `RECRIAR_PRIMEIRA_ISO_CALAMARES_XFCE.md` para orientar qualquer IA na reconstrução da primeira ISO.
- **Evidência**: o artefato original foi auditado diretamente; tamanho, SHA-256, manifesto, versões e configuração Calamares embutida foram confirmados.
- **Divergência registrada**: o perfil atual contém a experiência posterior Calamares + Subiquity, ausente da primeira ISO; o runbook ensina a trabalhar em cópia transitória e restaurar a sequência nativa sem sobrescrever trabalho posterior.
- **Estado**: documentação implementada; build e runtime não foram repetidos nesta tarefa.
- **Risco conhecido**: o usuário informou que o Calamares não funcionou; sem log de runtime, a causa exata permanece `unknown`.
- **Próximo gate**: coletar log do Calamares em boot UEFI/BIOS numa VM descartável ou prosseguir com a variante Desktop Provision em perfil separado.

## [2026-08-29] - Correção dos impedimentos da recriação Calamares + XFCE

- **Auditoria**: o relatório externo foi confrontado com a ISO canônica, seu GRUB, manifesto e perfil.
- **Causa**: a tentativa misturou `livecd-rootfs`/Casper/germinate com o pipeline histórico `live-build`/`live-boot`.
- **Evidência**: a ISO usa `/live`, `boot=live`, contém `live-boot`, `live-config` e `live-tools`, não contém Casper e não depende de marcador `/ubuntu`.
- **Implementação**: criado `prepare-first-calamares-profile.sh`, que restaura o `settings.conf` histórico e remove componentes híbridos somente da cópia de build.
- **Documentação**: criado `SOLUCAO_IMPEDIMENTOS_RECRIACAO_ISO_CALAMARES_XFCE.md` e corrigido o runbook principal.
- **Limite**: a composição ainda precisa ser recompilada; a falha funcional do Calamares permanece separada e exige logs de runtime.

## [2026-08-30] - Auditoria da tentativa pure live-build

- **Pipeline**: a nova tentativa adotou corretamente `live-build` + `live-boot`.
- **Estado real**: o processo não estava mais ativo; o log terminou em `Terminated` durante o pacote 421.
- **Artefatos**: não foram produzidos ISO, SquashFS, manifesto ou árvore binária final.
- **Manifesto correto**: `lb_binary_manifest` gera `/live/filesystem.packages` no modo `live-boot`; `filesystem.manifest` é exclusivo da convenção Casper.
- **Calamares**: o módulo Noble `unpackfs` existe e não exige Casper, mas a instalação continua sem validação runtime.
- **GRUB**: o finalizador detecta `binary/` ou `chroot/binary/` quando executado na raiz do perfil; ele não se aplica ao build interrompido atual.
- **Próximo gate**: limpar o chroot e repetir o build, preservando PID, código de saída e log completo.

## [2026-08-30] - Diretriz autocontida para execução pelo Gemini

- **Arquivo**: criado `INSTRUCOES_GEMINI_RECRIAR_ISO_CALAMARES_XFCE.md`.
- **Escopo**: missão completa para preparar, compilar, monitorar, finalizar e auditar a candidata histórica Calamares + XFCE.
- **Proteções**: proibição explícita de `livecd-rootfs`, Casper, germinate e manifesto injetado; staging separado e preservação da ISO histórica.
- **Observabilidade**: PID, código de saída, log, recursos e relatório final tornaram-se obrigatórios.
- **Estado**: documentação e automação disponíveis; execução pelo Gemini pendente.
- 2026-08-30: ISO Noble XFCE Calamares recriada com sucesso via Pure Pipeline (live-build). Localizada em candidate-gemini.
