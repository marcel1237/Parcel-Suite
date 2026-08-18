# A Tríade BSD: O Reforço de Elite do NitroCore

Este documento detalha como o **Parcel Play OS** utiliza a especialização extrema do **FreeBSD**, **NetBSD** e **OpenBSD** para criar um núcleo Linux (NitroCore) com capacidades que desafiam as distribuições convencionais.

## 1. FreeBSD: A Excelência em Rede e Capacidades
- **Tecnologia: Capsicum**: Diferente do Seccomp do Linux, o Capsicum isola processos por capacidades de arquivos.
- **Implementação NitroCore**: Portaremos o conceito de **Capability-Mode**. Ao entrar no "Modo Jogo", o processo do jogo perde acesso a toda a árvore de diretórios, exceto os arquivos (FDs) que o NitroCore entregou explicitamente.
- **Vantagem**: Performance superior ao Seccomp tradicional, eliminando micro-engasgos em syscalls de rede.

## 2. NetBSD: Integridade e Portabilidade Radical
- **Tecnologia: Veriexec**: Um subsistema que impede a execução de qualquer binário ou carregamento de módulo que não esteja em uma "Lista de Confiança" assinada digitalmente.
- **Implementação NitroCore**: O **Nitro-Verify** usará a lógica do Veriexec para proteger o diretório `/boot` e `/lib/modules`. Mesmo com acesso root, um invasor não conseguirá carregar um driver malicioso.
- **Vantagem**: Segurança de nível industrial com baixíssimo impacto em CPU, ideal para proteger o sistema sem afetar o FPS.

## 3. OpenBSD: Firewall e Blindagem Determinística
- **Tecnologia: PF (Packet Filter)**: O firewall mais respeitado do mundo Unix.
- **Implementação NitroCore**: Utilizaremos a sintaxe e a lógica do **PF** para gerenciar o tráfego de rede via **eXpress Data Path (XDP)**.
- **Vantagem**: O tráfego de jogos é priorizado com precisão matemática, garantindo que um download em segundo plano nunca aumente o jitter (oscilação de ping) da sua partida online.

## 4. Matriz de Contribuição BSD

| Sistema | Alma Técnica | Função no Parcel Play OS |
| :--- | :--- | :--- |
| **FreeBSD** | Performance de Fluxo | **Nitro-Net**: Zero-copy e Capsicum. |
| **NetBSD** | Universalidade | **Anykernel**: Drivers em user-space. |
| **OpenBSD** | Pureza de Código | **Nitro-CFI**: Blindagem contra exploits ROP. |

---
*Filosofia: O Linux fornece a compatibilidade; a Tríade BSD fornece a perfeição técnica.*
