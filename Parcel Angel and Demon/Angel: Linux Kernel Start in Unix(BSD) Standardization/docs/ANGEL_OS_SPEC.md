# Especificação de Arquitetura — Angel OS

**Versão**: `1.0.0-draft`  
**Slogan**: *"The Linux unix-like"*  
**Data**: `2026-09-26`  

---

## 1. Introdução e Filosofia de Design

O **Angel OS** foi concebido com o propósito de redefinir a experiência de um sistema operacional Unix-like moderno. Ele combina a filosofia de simplicidade e rigor de padronização histórica dos sistemas BSD/Slackware com o motor de execução e compatibilidade de hardware do Kernel Linux.

### Princípios Fundamentais:
1. **Padronização POSIX / Unix-like Fiel**: Hierarquia FHS limpa e previsível.
2. **Arquitetura Dupla de Kernels**:
   - **Seraphin**: Kernel completo para desktop de alto desempenho, workstation e jogos.
   - **Querubin**: Kernel embarcado / mini-kernel para boot acelerado, recuperação e tarefas minimalistas.
3. **Independência de Distribuição**: Construção modular que pode utilizar backends Linux (Slackware, Ubuntu, Debian, RHEL) para pacotes mantendo a identidade Angel OS.

---

## 2. Subsistemas de Kernel

### A. Seraphin (Angel Linux Kernel)
- **Caminho**: `/Seraphin: Angel Linux Kernel/`
- **Configuração**: Kernel otimizado com suporte a baixa latência (PREEMPT_RT / Full Preemption), mitigação seletiva sob demanda ("Modo Gamer") e escalonador priorizado para GUI.
- **Perfis de Compilação**:
  - `seraphin-desktop`: Kernel completo com suporte a drivers gráficos proprietários e abertos (NVIDIA, AMD, Intel).
  - `seraphin-server`: Perfil focado em estabilidade I/O e carga pesada.

### B. Querubin (Linux Mini-Kernel)
- **Caminho**: `/Querubin: Linux mini-kernel/`
- **Configuração**: Kernel ultracompartilhado e enxuto (< 10 MB).
- **Aplicações**:
  - Inicialização de emergência / ambiente de recuperação.
  - Boot de Login ultrarrápido (estilo Dark Volt EGLFS / DRM) em sub-2 segundos.
  - Sistemas embarcados ou contêineres ultra-isolados.

---

## 3. Boot e Identidade Visual

- **Gerenciador de Boot**: GRUB2 customizado com tema **Angel OS**.
- **Splash Screen**: Plymouth com temas **Angel Seraphin** e **Angel Querubin**.
- **Gerenciador de Sessão**: Suporte nativo a Wayland (KDE Plasma / Hyprland / XFCE) e inicialização acelerada via DRM/EGLFS.

---

## 4. Estrutura de Arquivos e Diretórios

```text
/
├── config/
│   ├── boot/
│   │   └── grub-angelos.cfg
│   └── angel-os.conf
├── scripts/
│   ├── bootstrap_env.sh
│   └── build_angel_os.sh
├── docs/
│   ├── README.md
│   ├── ANGEL_OS_SPEC.md
│   └── ANALISE_SISTEMA_PLAYOS.md
├── Seraphin: Angel Linux Kernel/
├── Querubin: Linux mini-kernel/
└── assets/
```

---

## 5. Roteiro de Desenvolvimento (Roadmap)

1. **Fase 1 (Estruturação e Identidade)**:
   - Definição da hierarquia de diretórios e scripts de automação.
   - Configuração das definições do GRUB2 e perfis do Angel OS.
2. **Fase 2 (Integração de Kernels)**:
   - Configuração das árvores de kernel Seraphin e Querubin.
   - Testes de compilação e empacotamento de initramfs.
3. **Fase 3 (Geração da ISO / Live System)**:
   - Criação de scripts de montagem de SquashFS e geração de imagem híbrida ISO/USB.
4. **Fase 4 (Validação em QEMU/Hardware)**:
   - Testes de boot, desempenho e compatibilidade.
