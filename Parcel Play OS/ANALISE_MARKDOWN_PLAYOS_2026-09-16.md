# Análise Estruturada dos Arquivos Markdown — PlayOS
**Data**: 2026-09-16  
**Escopo**: Todos os `.md` em `supervised_learning/knowledge/` e documentos críticos de projeto  
**Formato**: Hierarquia de evidência, estado e confiança

---

## 📊 Cobertura Documentada

- **17 arquivos** em `supervised_learning/knowledge/`
- **691 linhas** de documentação técnica estruturada
- **8 tópicos raiz**: FreeBSD, Linux, PlayOS, mapeamento, segurança, I/O, glossário, governança

---

## 1️⃣ BASE SUPERVISIONADA: ARQUITETURA E GOVERNANÇA

### `AGENTS.md` (Diretriz Principal) — `fact`, confiança `high`
**Propósito**: Entrada obrigatória para qualquer IA trabalhando no PlayOS.

**Regras críticas**:
- ✅ Leia `AGENTS.md` → `README.md` → `INDEX.md` → catálogos → código
- ✅ Hierarquia de evidência obrigatória: código-fonte > build/teste > docs upstream > análise local > inferência > proposta
- ✅ Vocabulário de estado: `fact`, `inference`, `decision`, `proposal`, `implementation`, `result`, `unknown`
- ✅ **Rejeição de cópia direta**: ULE, Jails, VFS, mbufs, locks, Newbus **não são portes Linux**
- ✅ Regra FreeBSD–Linux: comparar mecanismos, não transplantar ABI

**Baselines obrigatórios**:
- FreeBSD: `15.1-RELEASE-p2` (commit `aadd58dddcbc78f4d5594827b46b5633552b15ce`)
- Ubuntu local "Resolute": **Linux 6.8.4** (não 7.0)
- Linux vanilla: 7.1.8
- `Kernels/` = overlays apenas, nunca build completo

**Proibições explícitas**:
- ❌ Confundir Resolute (6.8.4 local) com Resolute oficial (7.0)
- ❌ Inventar benchmarks, compatibilidade ou estado de implementação
- ❌ Chamar build de "produção" antes de: boot QEMU/hw + regressão + pacote + hardware
- ❌ Atribuir propriedades internas Sony sem fonte verificável
- ❌ Afirmar compatibilidade de GPU, áudio, anti-cheat sem teste

---

### `supervised_learning/governance/EVIDENCE_POLICY.md` — `decision`, `high`

**Hierarquia enforçável**:
1. Código-fonte com versão/commit/linhas
2. Build/teste reproduzível
3. Documentação upstream primária
4. Análise local citando (1-3)
5. Inferência rotulada explicitamente
6. Proposta sem validação

**Confiança registrada**:
- `high`: fonte primária ou execução reproduzível
- `medium`: múltiplas evidências consistentes
- `low`: hipótese ou fonte incompleta
- `unknown`: não pesquisado ainda

**Resposta obrigatória**: sempre incluir IDs de fontes e declarar limites quando "não determinado".

---

## 2️⃣ CONHECIMENTO BSD PRIORITÁRIO

### `KB-FBSD-IDENTITY` — FreeBSD 15.1: Identidade e Capacidades
**Tipo**: `fact`, confiança `high`, verificado em 2026-08-19

**Baseline confirmado**:
- Tag: `release/15.1.0-p2`
- Commit: `aadd58dddcbc78f4d5594827b46b5633552b15ce`
- Tamanho inventariado: ~2,2 GiB, 108.960 arquivos, 33.186 em `sys/`

**Capacidades confirma das no código**:
- ✅ Schedulers: ULE, 4BSD, SMP, NUMA
- ✅ Isolamento: Jails/VIMAGE, RACCT/RCTL
- ✅ Segurança: Capsicum, MAC Framework, auditoria, credenciais BSD
- ✅ Concorrência: epoch/SMR, UMA, mutexes adaptativos, primitives SMP
- ✅ Rede: sendfile, kTLS, TCP/IP, IPsec, PF, IPFW, Netgraph
- ✅ Armazenamento: OpenZFS, UFS/FFS, GEOM, CAM, NVMe, iSCSI, NFS
- ✅ Virtualização: bhyve/vmm, VirtIO, Xen, Hyper-V, Linuxulator
- ✅ Boot/instalação: loader, bsdinstall, infraestrutura de testes

**Limite crítico**: Presença no código ≠ validação em hardware. Separar "estruturalmente confirmado" de "confirmado por execução".

---

### `KB-FBSD-SYSKERN` — FreeBSD `sys/kern`: Mapa Técnico
**Tipo**: `fact`, confiança `high`, 248 arquivos

**Matriz de decisões**:
| Meta | FreeBSD | Linux | Ação PlayOS |
|---|---|---|---|
| Boot | SYSINIT/`mi_startup` | initcalls/initramfs/systemd | medir boottrace |
| Isolamento | Jails/VNET | namespaces+cgroup | contrato userspace |
| Privilege | Capsicum/MAC | capabilities/seccomp/LSM/Landlock | combinar nativos |
| Recursos | RACCT/RCTL | cgroup v2/PSI | mapear política |
| Scheduler | ULE | CFS/EEVDF/sched_ext | benchmark; não copiar |
| Zero-copy | sendfile/kTLS/BPF | sendfile/splice/kTLS/AF_XDP | throughput/CPU/latência |
| Memória | UMA/page queues | SLUB/memcg | estudar algoritmo |
| Concorrência | mutex/epoch/SMR | mutex/RCU/SRCU | usar Linux nativo |
| Dispositivos | Newbus/KOBJ | device model/bus | rejeitar wrapper ABI |
| VFS | vnode/namei | inode/dentry | rejeitar porte |
| Rede | mbuf/VNET | sk_buff/netns | rejeitar porte |
| Tracing | DTrace/SDT/KTR | ftrace/perf/eBPF | alinhar eventos |

**Regra aprovada**: extrair princípios e contratos observáveis, **não copiar o subsistema**.

---

### `KB-FBSD-SECURITY` — Segurança e Isolamento BSD
**Tipo**: `fact`, confiança `high`

**Mecanismos BSD**:
- `struct prison`: hierarquia de jails com `prison0` como raiz/host
- VNET: pilhas de rede virtualizadas por jail
- RACCT/RCTL: accounting e limites de recurso
- Capsicum: capabilities em file descriptors, capability mode
- MAC Framework: políticas de controle de acesso plugáveis
- audit: trilha de eventos de segurança
- securelevel + flags de arquivo: políticas operacionais complementares

**Comparação Linux** (NÃO equivalências diretas):
- Jail ≠ namespace (é mais complexo: isolamento + hierarquia + VNET + RACCT)
- Capsicum ≠ Landlock (diferentes semântica e escopo)
- RCTL ≠ cgroup v2 (políticas distintas)

**Contrato comum PlayOS**:
- FreeBSD: Jail/VNET/RCTL/Capsicum/MAC
- Linux: namespaces/cgroup/seccomp/LSM/Landlock
- Critérios mínimos: isolamento PID/rede/mount, limites, filesystem policy, redução de privilégios, logs, testes de fuga

---

### `KB-FBSD-IO` — I/O, Rede, Armazenamento e Virtualização
**Tipo**: `fact`, confiança `high`

**Rede**: sendfile, kTLS, TCP/IP, IPv6, IPsec, SCTP, BPF, Netgraph, PF, IPFW
- AF_XDP/io_uring/kTLS Linux = mecanismos Linux próprios, não portes FreeBSD

**Armazenamento**: OpenZFS, UFS/FFS, GEOM, CAM, NVMe, AHCI, iSCSI, NFS
- ARC/dbuf controles ≠ page cache Linux (semântica distinta)
- Política "manter ativos quentes" precisa pressão memória + limites + fairness + benchmark

**Virtualização**:
- bhyve/vmm, VirtIO, Xen, Hyper-V, Linuxulator presentes
- Roteamento camadas: pacote FreeBSD → Linuxulator em jail → Wine → VM bhyve → streaming
- ⚠️ Linuxulator compartilha kernel BSD, não executa recursos que exijam kernel Linux real

**Estado**: Estruturalmente localizado; GPU, áudio, suspend/resume, passthrough, apps reais ainda exigem boot/teste.

---

## 3️⃣ CONHECIMENTO LINUX E INTEGRAÇÕES

### `KB-LINUX-BUILDS` — Evidências dos Builds Linux
**Tipo**: `result`, confiança `high`

#### Ubuntu Noble 6.8.4 PlayOS
- ✅ Release: `6.8.4-playos-freebsd-lab1+`
- ✅ bzImage concluído
- ✅ 6.467 módulos `.ko` em staging
- ✅ BTF no kernel e módulos
- ✅ kTLS como módulo
- ✅ AppArmor + Landlock habilitados
- ✅ fault injection desativado (produção)
- ✅ initramfs genérico 286 MiB
- ✅ hashes verificados
- ❌ **Sem boot QEMU/hardware**
- ❌ Rust desativado (versão local 1.93.1 ≠ exigido 1.75.0)

#### Linux vanilla 7.1.8 PlayOS
- ✅ Release: `7.1.8-playos-freebsd-lab1`
- ✅ kernel + 14 módulos em staging
- ✅ NTSYNC + kTLS
- ✅ BTF (pahole 1.31, toolchain local)
- ✅ `CONFIG_SCHED_CLASS_EXT=y` habilitado
- ✅ initramfs gerado
- ❌ **Sem boot QEMU/hardware**

**Interpretação crítica**: compilabilidade ≠ correção runtime. QEMU não instalável (sudo interativo). **Nenhum é release de produção**.

#### NTSYNC Backport Noble
- ✅ Driver NTSYNC do 7.1.8 integrado a Noble 6.8.4
- ✅ `ntsync.ko` compilou com BTF
- ✅ Kselftest userspace compilou
- ❌ Selftest não pode executar (kernel host sem `/dev/ntsync`)
- ✅ Módulo reversível via `CONFIG_NTSYNC=m`
- **Estado**: compilável + integrado, **não validado runtime**.

#### PlayOS Kernel 1 (6.8.4)
- ✅ NTSYNC + `mseal` integrados
- ✅ Identidade: `6.8.4-playos-kernel1+`
- ✅ bzImage: 14.914.048 bytes com BTF
- ✅ SHA-256: `03f2675bcc4e5bdbccf9e2cbeeeb8b01d4b998a22e769a0996ac1a61e55752ca`
- ✅ Módulo NTSYNC reconstruído com BTF
- ⚠️ `modules` alvo global incompleto (fixdep serial em progresso)
- ❌ Faltam: initramfs, assinatura, boot, testes runtime

---

### `KB-LINUX-NTSYNC-NOBLE` — Backport NTSYNC
**Tipo**: `implementation`, confiança `high`, estado `implemented-no-runtime`

**O que foi incorporado**:
- Driver NTSYNC, UAPI, documentação, kselftest do 7.1.8
- APIs de alocação/publicação adaptadas para equivalentes 6.8
- Modular via `CONFIG_NTSYNC=m` (rollback fácil)

**Evidência disponível**:
- ✅ BTF com pahole 1.31
- ✅ Selftest compilou
- ❌ `/dev/ntsync` não existe no kernel host

**Estado correto**: compilável + integrado, **não pronto para produção** (faltam boot, regressão, validação userspace).

**Limite**: `sched_ext` existe no 7.1.8 mas **não será copiado** para 6.8 (risco ABI > benefício).

---

### `KB-PLAYOS-KERNEL-718` — PlayOS Kernel 7.1.8 com Perfil Noble
**Tipo**: `implementation`, confiança `high`, estado `build-in-progress`

**Decisão de baseline**:
- Backports no Noble = continuam Linux 6.8.4
- PlayOS Kernel 2 = Linux vanilla 7.1.8 + política Ubuntu Noble Generic + patches PlayOS
- PlayOS Kernel 1 = permanece fallback 6.8.4

**Patchset**:
- Localização: `patch-Noble-PlayOS-Kernel-7.1.8/`
- ✅ Passou `git apply --check` em 7.1.8 limpo
- ✅ Produziu `7.1.8-playos-kernel2`
- ✅ Mantém: AppArmor, Landlock, seccomp, namespaces, cgroup/BPF, DRM, kTLS, NTSYNC
- ✅ BTF habilita sched_ext
- ❌ Rust fora
- ❌ fault injection fora do perfil de produção

**Comparação Resolute**:
- Ubuntu 26.04 Resolute = Linux 7.0
- PlayOS 7.1.8 > 7.0 em versão
- ⚠️ "mais novo" ≠ "melhor" (faltam boot, regressão, segurança, empacotamento, hardware)

**Limites**:
- Não herda ABI módulos 6.8
- Sem suporte Canonical
- Chaves Canonical removidas (Secure Boot exigirá chave PlayOS)
- Gates independentes: build ✅ → initramfs → pacote Debian → boot → runtime

---

## 4️⃣ MAPEAMENTO FREEBSD–LINUX

### `KB-FBSD-LINUX-MAP` — Matriz Operacional
**Tipo**: `decision`, confiança `high`

**Fluxo de decisão PlayOS**:
1. Definir comportamento desejado e métrica
2. Procurar equivalente nativo no alvo
3. Criar baseline sem patch
4. Implementar menor mudança possível
5. Testar correção, regressão, segurança, desempenho
6. Rejeitar se não superar mecanismo existente

**Direção Linux→FreeBSD** (Reversa):
- PSI, io_uring, NTSYNC, BPF moderno, sanitizers podem inspirar wrappers/experimentos BSD
- ❌ Não copiar código GPL de forma que comprometa política BSD
- LinuxKPI tem escopo específico, **não é conversor universal**

---

## 5️⃣ PLAYOS: DECISÕES E ESTADO REAL

### `KB-PLAYOS-STATUS` — Arquitetura e Direção
**Tipo**: `decision`, confiança `high`

**Direção vigente**:
PlayOS **não será kernel que mistura FreeBSD e Linux diretamente**.

**Opções tecnicamente sustentáveis**:
1. Família/edições com kernels separados
2. Host Linux (desktop/jogos) + FreeBSD Core em KVM isolado
3. Contratos userspace comuns com backends nativos
4. Patchsets experimentais pequenos que traduzem ideias, sem transplantar ABI

**Identidades que não podem ser confundidas**:
- `Kernels/ubuntu 26 resolute kernel` = Noble Linux 6.8.4 ✅
- Ubuntu Resolute oficial = Linux 7.0 (verificado)
- `Kernels/kernel linux-7.1.8` = vanilla 7.1.8 ✅
- FreeBSD completo = 15.1-p2 (fora do raiz gravável)

**Estado das implementações**:
- ✅ patchset Noble: compilado Generic, sem boot
- ✅ patchset Linux 7.1.8: compilado, sem boot
- 📋 patchset Linux→FreeBSD: propostas + validação estática (não kernel funcional)
- 🧪 NitroCore: protótipos experimentais (não subsistema produção)
- 📋 FreeBSD compatibility: arquitetura/política (testes reais pendentes)
- 📋 Live CD: análise e plano (não mídia final validada)

**Regra crítica**: "criado" ≠ "proposto" ≠ "compilado" ≠ "inicializável" ≠ "pronto para produção".

---

## 6️⃣ GLOSSÁRIO E FAMÍLIA BSD

### `KB-BSD-GLOSSARY` — Glossário BSD/Linux/PlayOS
**Tipo**: `fact`, estado `current`

**Entradas críticas**:
- **Jail**: isolamento + hierarquia + VNET + RACCT (não apenas "namespace BSD")
- **Namespace Linux**: isolamento de PID/rede/mount/user/ipc (não cópia de Jail)
- **Capsicum**: capabilities em FD + capability mode (não Landlock direto)
- **Landlock**: LSM empilhável para restrições filesystem (não Capsicum direto)
- **RCTL**: políticas RACCT (não cgroup v2 com outro nome)
- **mbuf**: estrutura interna BSD, **não intercambiável com sk_buff**
- **vnode**: abstração BSD, **não intercambiável com inode+dentry**
- **UMA**: alocador BSD, **não intercambiável com SLUB**
- **bhyve**: hipervisor BSD (não KVM com mesma interface)
- **Linuxulator**: emulação em kernel BSD (não kernel Linux real)
- **AF_XDP**: socket especial Linux (não porte de bpf_zerocopy.c)
- **ARC/dbuf**: controles ZFS (não devem controlar page cache Linux)

**Regra**: Compare metas, semântica, invariantes e resultados; **não apenas nomes**.

---

## 7️⃣ PLAYOS: ARQUITETURA DE PRODUTO

### `KB-PLAYOS-DECISIONS` — Decisões de Design (Síntese)
**38 decisões registradas com alta confiança**:

#### Decisões Rejeitadas
- ❌ DEC-001: Cópia direta FreeBSD sys/kern para Linux
- ❌ DEC-003: ULE, Jails, VFS, mbufs, locks, Newbus como portes diretos
- ❌ DEC-020: Xorg e compositor Wayland no kernel

#### Decisões Vigentes (Current)
- ✅ DEC-002: Integrações usam equivalentes Linux ou reimplementação por APIs nativas
- ✅ DEC-005: Ubuntu local "Resolute" = Noble Linux 6.8.4
- ✅ DEC-008: Build ≠ produção antes de boot + regressão + pacote + hardware
- ✅ DEC-011: NTSYNC do 7.1.8 entra em Noble como módulo reversível
- ✅ DEC-016: PlayOS Kernel 2 usa 7.1.8, preserva 6.8.4 como fallback
- ✅ DEC-021–028: Graphics Platform = kernel + X11 + Wayland + XFCE/GNOME/KDE (modular, sem Xorg no kernel)
- ✅ DEC-034: Primeira Live Debian = Trixie XFCE + kernel Noble (sem instalador)
- ✅ DEC-038: PlayOS Native Userspace = Slackware-like + Live KNOPPIX + kernel Noble

#### Decisões Planejadas
- 📋 DEC-004: FreeBSD integral como sistema separado ou guest KVM
- 📋 DEC-009: FreeBSD recebe ideias Linux via wrappers + experimentos

#### Decisões Adiadas
- ⏸️ DEC-012: `sched_ext` não será copiado do 7.1.8 para Noble
- ⏸️ DEC-014: DRM Panic e fwctl fora do perfil Generic

---

## 8️⃣ IMPLEMENTAÇÕES REGISTRADAS (Estado Real)

### Builds Completados
| Artefato | Status | Validação |
|---|---|---|
| Noble Patchset | Implemented | build-generic-no-boot |
| Noble Kernel | Built | sha256-initramfs-modules |
| Linux 7.1.8 Patchset | Implemented | build-no-boot |
| NTSYNC-Noble Backport | Implemented | module-btf-no-runtime |
| PlayOS Kernel 1 (6.8.4) | Implemented | bzimage-btf-no-boot |
| PlayOS Kernel 2 (7.1.8) | Partial | series-config-build-in-progress |

### Live ISOs Construídas
| ISO | Status | Validação |
|---|---|---|
| Noble Graphics Core Calamares | Built Static | iso-sha256-bios-uefi-manifest |
| Noble XFCE Calamares | Built Static | iso-sha256-bios-uefi-structure |
| Noble GNOME Calamares | Built Static | iso-sha256-bios-uefi-structure |
| Debian Trixie XFCE + Noble kernel | Built + Validated | bios-uefi-boot-userspace-xfce-visual-hw-pending |
| Debian Trixie GNOME + Noble kernel | Built + Validated | iso-sha256-bios-uefi-static |
| Debian Trixie KDE Full + Noble kernel | Built + Validated | iso-sha256-bios-uefi-manifest |

### Userspace e Experimental
| Projeto | Status | Validação |
|---|---|---|
| GNOME 50 Upstream | Partial | 719-element-graph-resolved-build-pending |
| Native Userspace (Slackware-like) | Partial | stage0-stage1-uefi-pass-stage2-graphics-pending |
| KDE KNOPPIX-style (Noble) | Partial | profile-shell-validated-build-blocked-30g-runtime-pending |

---

## 9️⃣ LIMITAÇÕES CRÍTICAS (Gates Não Alcançados)

### Boot Runtime
- ❌ Nenhum PlayOS Kernel testado em QEMU
- ❌ Nenhum PlayOS Kernel testado em hardware
- ❌ QEMU não instalável (sudo interativo)

### Segurança e Assinatura
- ❌ Chaves Canonical removidas (nenhuma chave PlayOS Secure Boot)
- ❌ Módulos sem assinatura

### Qualidade
- ❌ Regressão kselftest vs Noble Generic puro
- ❌ Benchmarks vs baselines
- ❌ Testes de hardware (GPU, áudio, suspend/resume)

### Empacotamento
- ❌ Nenhum pacote `.deb` final
- ❌ DKMS não integrado
- ❌ GRUB não integrado

### Compatibilidade
- ❌ Nenhum teste de compatibilidade de aplicações
- ❌ Wine, Proton em sandbox ainda não validados
- ❌ Linuxulator em Jail ainda não testado

---

## 🔟 ESTRUTURA DE CONHECIMENTO

### Tópicos Mapeados (52 entradas no catalog/topics.tsv)
1. Primeira abertura e validação (TOP-BUILD-RECREATE)
2. Baselines e overlays (TOP-KERNEL-OVERLAYS)
3. FreeBSD: identidade, subsistemas, segurança, I/O (TOP-FBSD-*)
4. BSD família (TOP-BSD-FAMILY, TOP-BSD-GLOSSARY)
5. Mapeamento FreeBSD–Linux (TOP-MAPPING)
6. PlayOS: arquitetura, decisões, kernel, userspace (TOP-PLAYOS-*)
7. Builds Linux: Noble, 7.1.8, NTSYNC (TOP-LINUX-BUILDS, TOP-LINUX-NTSYNC)
8. Live CDs e instaladores (TOP-LIVECD, TOP-LIVE-*)
9. Graphics Platform: kernel, stack, desktop, componentes (TOP-GRAPHICS-*, TOP-PLAYOS-MULTI-DESKTOP)
10. Compatibilidade FreeBSD (TOP-COMPAT)

### Catálogos Críticos
- **sources.tsv**: 25+ fontes canônicas com URLs/paths
- **implementations.tsv**: 30+ artefatos com status e validação
- **decisions.tsv**: 38 decisões com confiança e estado
- **document_inventory.tsv**: 65+ documentos inventariados

### Datasets de Treinamento e Validação
- `datasets/train.jsonl`: 20 exemplos instrutivos
- `datasets/validation.jsonl`: 8 perguntas separadas para validação
- `datasets/adversarial.jsonl`: 8 solicitações que exigem recusa/correção
- `evaluations/questions.jsonl`: 8 testes de avaliação

---

## 🔗 FLUXO DE CONSULTA IMPLEMENTADO

```mermaid
IA recebe tarefa
  ↓
Lê AGENTS.md (diretriz)
  ↓
Consulta INDEX.md (mapa)
  ↓
Busca em catalog/topics.tsv (roteamento)
  ↓
Lê entradas KB em supervised_learning/knowledge/
  ↓
Confirma fontes em catalog/sources.tsv
  ↓
Verifica estado em catalog/implementations.tsv + decisions.tsv
  ↓
Só abre código se necessário
  ↓
Responde com fact/inference/decision/proposal/implementation + fontes
```

---

## 🎯 RECOMENDAÇÕES PARA CONTINUIDADE

### Imediato (Gates bloqueadores)
1. **Boot QEMU**: testar Noble 6.8.4 e 7.1.8 com QEMU
2. **Assinatura Secure Boot**: gerar chave PlayOS, assinar kernels
3. **Regressão**: kselftest vs baselines
4. **Pacote Debian**: gerar `.deb` final

### Curto prazo
1. Validar graphics stack em hardware (X11, Wayland, XFCE, GNOME, KDE)
2. Testar Live ISOs em QEMU + hardware real
3. Validar compatibilidade Wine/Proton
4. Completar userspace nativo (Slackware-like)

### Médio prazo
1. Integração FreeBSD 15.1 como guest KVM (não kernel fusionado)
2. Comparação de benchmark: FreeBSD vs PlayOS Kernel vs Noble vanilla
3. Validação de Jails em FreeBSD guest
4. Documentação de API userspace PlayOS

### Longo prazo
1. Release oficial 1.0
2. Suporte de hardware expandido
3. Contribuição upstream (se apropriado)

---

## 📋 RESUMO EXECUTIVO

### Projeto PlayOS em 2026-09-16
- **Fase**: Integração kernel/userspace, kernels compilados, sem boot confirmado
- **Maturidade**: 3/10 para produção (faltam gates críticos)
- **Risco**: Confundir compilável com pronto; prometer compatibilidade sem teste
- **Força**: Documentação estruturada, hierarquia de evidência, rejeição de portes diretos
- **Próximo passo**: Boot em QEMU dos kernels PlayOS Noble/7.1.8

**Estado crítico a comunicar**:
- ✅ Documentação clara de baselines, decisões, implementações
- ✅ Governança rigorosa (fact vs proposal vs implementation)
- ✅ Rejeição explícita de cópias diretas de subsistemas
- ❌ Nenhum kernel PlayOS testado em runtime
- ❌ Nenhuma validação de compatibilidade de aplicações
- ❌ Segurança e assinatura ainda em aberto
