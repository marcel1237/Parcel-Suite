# Recomendações de Próximos Passos — PlayOS
**Data**: 2026-09-16  
**Tipo**: `decision`, `medium` confiança  
**Base**: Análise estruturada de documentação + implementações registradas

---

## 🎯 Prioridade Estratégica (Ordem de Impacto)

### BLOQUEADOR 1: Boot QEMU dos Kernels PlayOS
**Status**: ❌ Crítico  
**Razão**: Compilabilidade ≠ correção runtime. Nenhuma validação possível sem boot.  
**Ação**:
1. Instalar QEMU em máquina separada (não via sudo) ou via container Docker
2. Testar Noble 6.8.4 (PlayOS Kernel 1) com:
   - Initramfs incluso
   - Boot com systemd
   - kselftest: sendfile, AppArmor, Landlock, cgroup, namespaces
3. Testar Linux 7.1.8 (PlayOS Kernel 2) com mesmas validações
4. Registrar resultados em `supervised_learning/` com `KB-LINUX-BOOTS-QEMU`

**Entregas**:
- ✅ BR-001: Boot log QEMU Noble
- ✅ BR-002: Boot log QEMU 7.1.8
- ✅ BR-003: Kselftest results ambos kernels
- ✅ BR-004: Regressão vs baselines (Noble Generic puro, 7.1.8 vanilla)

**Estimativa**: 3-5 dias

---

### BLOQUEADOR 2: Assinatura Secure Boot e GRUB
**Status**: ❌ Crítico  
**Razão**: Nenhum kernel PlayOS pronto para produção sem assinatura.  
**Ação**:
1. Gerar chave privada PlayOS (no local seguro ou hardware token)
2. Gerar certificado auto-assinado para Secure Boot
3. Assinar bzImage de ambos kernels com `sbsign`
4. Integrar GRUB com entrada PlayOS dual-boot (Noble fallback)
5. Testar boot UEFI Secure Boot em QEMU + hardware (se disponível)

**Entregas**:
- ✅ SB-001: Chave privada PlayOS (armazenada seguramente)
- ✅ SB-002: Certificado e procedimento de assinatura documentado
- ✅ SB-003: Kernels assinados
- ✅ SB-004: GRUB configurado, entrada PlayOS dual-boot
- ✅ SB-005: Boot UEFI testado em QEMU

**Estimativa**: 2-3 dias

---

### BLOQUEADOR 3: Pacotes Debian Finais
**Status**: ❌ Crítico  
**Razão**: Instalação, updates, mantenibilidade impossíveis sem `.deb`.  
**Ação**:
1. Criar `linux-image-6.8.4-playos-freebsd-lab1_*.deb`
2. Criar `linux-image-7.1.8-playos-kernel2_*.deb`
3. Incluir modules + headers + DTBs
4. Incluir DKMS templates para módulos custom
5. Gerar `linux-headers-*.deb` correspondentes
6. Testar instalação em Debian/Ubuntu Trixie (dpkg + apt)

**Entregas**:
- ✅ DEB-001: Pacote linux-image Noble assinado
- ✅ DEB-002: Pacote linux-image 7.1.8 assinado
- ✅ DEB-003: Pacotes linux-headers para ambos
- ✅ DEB-004: DKMS templates
- ✅ DEB-005: Teste instalação em Trixie

**Estimativa**: 3-4 dias

---

## 🔧 Qualidade de Curto Prazo (Semana 2)

### Regressão Completa
**Status**: 📋 Planejado  
**Ação**:
1. Executar kselftest completo em:
   - Noble 6.8.4 puro (baseline)
   - PlayOS Kernel 1 (6.8.4-playos)
   - PlayOS Kernel 2 (7.1.8-playos)
2. Comparar resultados: diferenças = regredir ou justificar
3. Executar lmbench (latência, throughput) se tempo permitir
4. Registrar em `supervised_learning/catalog/evaluations/`

**Entregas**:
- ✅ REG-001: Kselftest baseline Noble
- ✅ REG-002: Kselftest PlayOS 6.8.4 vs baseline
- ✅ REG-003: Kselftest PlayOS 7.1.8 vs vanilla 7.1.8
- ✅ REG-004: Relatório diferenças + justificativas

---

### Validação Gráfica Base (X11 + Wayland + XFCE)
**Status**: 📋 Paralelo ao boot  
**Ação**:
1. Boot Live ISO Debian Trixie XFCE + kernel Noble em QEMU
2. Validar X11:
   - Desktop renderiza (XFCE widgets visíveis)
   - Mouse/keyboard respondem
   - Window manager funciona
3. Validar Wayland:
   - Compositor inicia
   - App de teste (weston-simple-egl) renderiza
4. Testar switch X11↔Wayland sem reboot
5. Registrar em `supervised_learning/knowledge/playos/graphics-validation.md`

**Entregas**:
- ✅ GRA-001: Boot X11 XFCE em QEMU
- ✅ GRA-002: Boot Wayland em QEMU
- ✅ GRA-003: Switch sem reboot
- ✅ GRA-004: Screenshots/video (se possível)

---

## 📊 Validações de Médio Prazo (Semanas 3-4)

### Compatibilidade de Aplicações Básicas
**Status**: 📋 Planejado  
**Ação**:
1. Teste de 10 apps representativas:
   - Firefox (web)
   - VLC (media)
   - Libre Office (productivity)
   - GIMP (gráficos)
   - VS Code (desenvolvimento)
   - Blender (3D)
   - Audacity (áudio)
   - Transmission (torrent)
   - MPV (player minimalista)
   - X-Terminal (linha comando)
2. Critério: app inicia, executa tarefa básica, não trava
3. Registrar em matriz compatibilidade

---

### Testes de Hardware (se disponível)
**Status**: 📋 Planejado  
**Ação**:
1. Boot em máquina física (se seguro):
   - Detecta CPU, RAM, disco corretamente
   - rede (Ethernet ou WiFi) funciona
   - Disco (SATA/NVMe) lê/escreve
   - Áudio inicia (não precisa som real)
2. Suspend/resume básico
3. Hibernate (se suportado)

---

## 🏗️ Arquitetura e Integração (Mês 2)

### Validação Userspace PlayOS Nativo
**Status**: 🔨 Parcial (stage 0-1 complete)  
**Ação**:
1. Completar stage 2 (gráficos + base de desktop)
2. Validar Slackware-like package management
3. Integrar XFCE, GNOME, KDE sobre userspace nativo
4. Testar boot e operação básica

**Gates**:
- ✅ Stage 1 puro: boot, rede, shell
- ✅ Stage 2 gráficos: X11, Wayland, drivers
- ✅ Stage 3 desktops: 3 variantes montadas

---

### Integração FreeBSD em KVM
**Status**: 📋 Planejado  
**Decisão**: FreeBSD como guest isolado, não kernel fusionado  
**Ação**:
1. Definir bridge de rede PlayOS Host → FreeBSD Guest
2. Criar VM bhyve ou QEMU com FreeBSD 15.1
3. Validar comunicação rede entre host/guest
4. Teste piloto: Jail no FreeBSD guest

---

### Comparação de Comportamento BSD vs Linux
**Status**: 📋 Planejado  
**Ação**:
1. Selecionar 5 pares (Jail/namespace, RCTL/cgroup, etc.)
2. Implementar teste diferencial em ambos
3. Comparar resultados: sem benchmark de performance, apenas comportamento
4. Documentar em `supervised_learning/knowledge/mappings/`

---

## 🛡️ Segurança e Compliance

### Auditoria de Código Patchset
**Status**: 📋 Pendente  
**Ação**:
1. Code review: todos patches PlayOS Noble + 7.1.8
2. Verificar:
   - Nenhuma cópia direta de `sys/kern` FreeBSD
   - Licenças corretas (GPL v2+ para Linux)
   - Sem hardcodes, backdoors, debug leaks
   - Espaçamento/estilo consistente
3. Solicitar revisão comunitária (LKML ou mailing list relevante, se apropriado)

---

### Validação de Segurança Básica
**Status**: 📋 Planejado  
**Ação**:
1. Testar AppArmor confinement:
   - Profile compila
   - Aplicação confinada não pode ler /root
2. Testar Landlock:
   - Regra filesystem: app não acessa /etc
   - Regra implementa corretamente
3. Testar seccomp:
   - Syscall block testável via strace
4. Testar capabilities:
   - App sem CAP_NET_ADMIN não binda porta <1024

---

## 📚 Documentação e Catálogos

### Atualizar Catálogos Supervisionados
**Status**: 📋 Contínuo  
**Ação**:
1. Após cada gate alcançado:
   - Atualizar `catalog/implementations.tsv` (status e validação)
   - Atualizar `catalog/decisions.tsv` (confirmar ou revisar)
2. Criar novas entradas `KB-*` para descobertas:
   - `KB-LINUX-BOOTS-QEMU` (boot results)
   - `KB-GRAPHICS-VALIDATION-X11-WAYLAND` (visual tests)
   - `KB-COMPAT-APPS-BASIC` (app compatibility matrix)
3. Rodar validador: `python3 supervised_learning/tools/validate_knowledge.py`

---

### Atualizar Portal HTML
**Status**: 📋 Após catálogos  
**Ação**:
1. Regenerar `documentation-portal/generated-data.js` com novos dados
2. Validar links: `python3 documentation-portal/tools/validate_portal.py`
3. Verificar visual em navegador (compatibilidade X11/Wayland)

---

## 🎪 Comunicação e Transparência

### Registrar Progresso em PROGRESSO.md
**Status**: 📋 Contínuo  
**Ação**:
1. Entrada para cada gate alcançado:
   ```
   ## [2026-09-XX] - Boot QEMU PlayOS Kernel Noble 6.8.4 validado
   - **Resultado**: ✅ kernel boot, systemd iniciado, kselftest 4/6 pass
   - **Limitações**: AppArmor enforcido bloqueou teste de security module
   - **Próximo**: regressão completa vs Noble Generic 6.8.4 puro
   - **Relatório**: supervised_learning/evaluations/boot-qemu-noble-2026-09-XX.md
   ```
2. Preservar entradas antigas; nunca sobrescrever silenciosamente

---

## ⏱️ Cronograma Proposto

```
SEMANA 1 (2026-09-16 ~ 2026-09-22)
├─ BR-001 ~ BR-004: Boot QEMU ambos kernels + kselftest       [PRI 1]
├─ SB-001 ~ SB-005: Assinatura Secure Boot + GRUB             [PRI 2]
└─ DEB-001 ~ DEB-005: Pacotes .deb finais                     [PRI 3]

SEMANA 2 (2026-09-23 ~ 2026-09-29)
├─ REG-001 ~ REG-004: Regressão kselftest completa            [PRI 4]
├─ GRA-001 ~ GRA-004: Validação X11 + Wayland em QEMU         [PARA]
└─ Audit code patchsets (segurança)                           [PRI 5]

SEMANA 3-4 (2026-09-30 ~ 2026-10-13)
├─ 10 apps compatibilidade testadas                           [PRI 6]
├─ Testes hardware (se máquina disponível)                   [OPC]
├─ Validação userspace nativo stage 2-3                      [OPC]
└─ FreeBSD KVM guest integração inicial                       [OPC]

CONTINUO
├─ Atualizar catálogos supervisionados após cada gate
├─ Regenerar portal HTML
├─ Registrar progresso em PROGRESSO.md
└─ Code review interna e externa (se apropriado)
```

---

## 🚀 Sucesso = Definição de Pronto

PlayOS é considerado **pronto para teste público** quando:

✅ Boot QEMU validado (ambos kernels)  
✅ Assinatura Secure Boot implementada  
✅ Pacotes Debian instaláveis  
✅ Regressão kselftest sem regredir  
✅ Gráficos (X11 + Wayland) funcionais em QEMU  
✅ 10+ apps básicas com compatibilidade declarada  
✅ Zero backdoors, hardcodes, GPL violations em audit  
✅ Documentação atualizada em catálogos  
✅ Live ISO de cada variante (XFCE, GNOME, KDE) testada  

**Estimativa atual**: 4-6 semanas até readiness.

---

## ⚠️ Riscos e Contingências

| Risco | Probabilidade | Mitigação |
|---|---|---|
| QEMU não executa em ambiente local | média | Usar máquina separada/container/CI |
| Regressão kselftest prejudica confiança | alta | Correção rápida ou revisão de patchset |
| Assinatura Secure Boot complexa | média | Usar ferramentas existentes (sbsign, efitools) |
| Compatibilidade de apps piora com 7.1.8 | média | Fallback para 6.8.4, investigação incremental |
| Hardware não disponível | média | Validar em QEMU primeiro; hardware como segunda validação |

---

## 📖 Leitura Recomendada para Próximas Sessões

1. **Immediately**: `ANALISE_MARKDOWN_PLAYOS_2026-09-16.md` (salvo em session-state/files)
2. **Before acting**: Reconfirmar baselines em `AGENTS.md` e `supervised_learning/INDEX.md`
3. **For details**:
   - `supervised_learning/knowledge/linux/build-evidence.md` (estado atual builds)
   - `supervised_learning/knowledge/playos/decisions-status.md` (direção vigente)
   - `patch-FreeBSD-Noble/results/BUILD_GENERIC_PROD_6.8.4_2026-08-18.md` (último build report)

---

**Próxima ação**: Instalar QEMU, iniciar BR-001 (boot PlayOS Kernel Noble em QEMU).
