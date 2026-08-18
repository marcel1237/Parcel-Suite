# Referências de Performance: Gaming & Workstation (SteamOS, Arch, Fedora)

Para atingir o objetivo de ser o kernel definitivo para "dar play" em tudo (jogos, 3D, produtividade), o **NitroCore** utiliza o estado da arte das distribuições líderes em performance de 2026.

## 1. Referência: Arch Linux (O "Pai" do SteamOS)
O Arch Linux é a base do **SteamOS (Valve)** devido ao seu controle total sobre os pacotes e proximidade com o hardware.
- **Herança no NitroCore**: Adoção do conceito do **Zen Kernel**.
- **Tecnologia Chave**: **BORE Scheduler (Burst-Oriented Response Enhancer)**. Diferente de escalonadores de servidor, o BORE prioriza tarefas "curtas e explosivas" como o input do mouse em jogos e atualizações de janelas 3D.
- **Objetivo**: Eliminar o atraso de resposta (input lag) no ambiente de trabalho e em jogos.

## 2. Referência: SteamOS (O Mestre do Hardware AMD)
O SteamOS da Valve é otimizado especificamente para extrair cada FPS do hardware.
- **Herança no NitroCore**: Implementação de otimizações via **sched-ext** (Linux BPF schedulers).
- **Tecnologia Chave**: **EPP Boost (AMD P-State)**. Esta tecnologia evita que o CPU reduza a frequência durante pausas curtas entre quadros de um jogo, mantendo a performance estável.
- **Objetivo**: Estabilidade de frame-pacing (fim dos engasgos/micro-stuttering).

## 3. Referência: Fedora Workstation (O Pioneiro do NTSYNC)
O Fedora é a vanguarda tecnológica da Red Hat e lidera a integração de tecnologias de compatibilidade Windows.
- **Herança no NitroCore**: Integração de drivers modernos e foco em Wayland estável.
- **Tecnologia Chave**: **NTSYNC (Native NT Synchronization)**. Implementa primitivas de sincronização do Windows NT diretamente no kernel Linux.
- **Objetivo**: Fazer com que jogos e apps Windows rodem via Proton com a mesma velocidade (ou superior) do que no Windows original.

## 4. Estratégia "Future-Proof" (Ubuntu 27+)
Embora estejamos usando o Ubuntu 26 como base de teste atual, o **NitroCore** é projetado para ser agnóstico. 
- A pasta `nitrocore/` é um contêiner de DNA que será movido para os kernels do **Ubuntu 27, 28, 29** e além, garantindo que o Parcel Play OS nunca fique para trás.

---
*Status: Benchmarks do Arch e Fedora integrados ao DNA do NitroCore.*
