# NitroCore: O Contêiner de Performance do Parcel Play OS

A pasta `nitrocore/` é o coração das otimizações proprietárias do nosso kernel, seguindo o modelo arquitetural da pasta `ubuntu/` encontrada no kernel da Canonical.

## 1. O que será colocado aqui (Especificamente)

Diferente do Ubuntu, que foca em drivers de fabricantes (ODM), o **NitroCore** foca em **aceleração e resposta bruta**. Especificamente, colocaremos:

### A. Thunder Schedulers (`nitrocore/sched/`)
- Implementação de algoritmos de escalonamento inspirados no **XanMod (BORE)** e **Zen**, mas otimizados para o ambiente **Dark Volt**.
- Foco: Redução da latência de input em jogos e aumento da prioridade para a Sessão Full (KDE).

### B. Matriz de Memória OmniLock (`nitrocore/mm/`)
- Código C responsável pelo gerenciamento agressivo de **HugePages** (2MB/1GB).
- Lógica de travamento de páginas críticas na RAM física para eliminar o acesso ao disco (swap-avoidance) em processos marcados como "Nitro-Acelerados".

### C. Bypass de Segurança Proativo (`nitrocore/security/`)
- Implementação de filtros **Seccomp** e **Landlock** pré-configurados (OpenBSD Style) para isolar o navegador Thunder e os contêineres Waydroid.
- Lógica para desativar mitigações de CPU (como Spectre/Meltdown) **apenas** quando o usuário ativar o "Modo Gamer", via flags controladas em tempo real.

### D. Interceptores de Rede Nitro (`nitrocore/net/`)
- Rotinas de aceleração baseadas em **XDP (eXpress Data Path)** e **eBPF** (FreeBSD style) para processamento de pacotes com bypass parcial do stack tradicional do Linux.

## 2. Por que esta estrutura?

Seguindo o padrão identificado no Ubuntu 26, a pasta `nitrocore/` conterá seu próprio `Kconfig` e `Makefile`. Isso permite que nossas otimizações sejam:
1.  **Modulares**: Podemos ligar/desligar o NitroCore sem quebrar a base Debian/Ubuntu.
2.  **Rastreáveis**: Fica fácil auditar o que é "Linux Puro" e o que é "Otimização Parcel".

---
*Filosofia: Se o Ubuntu usa a pasta `ubuntu/` para compatibilidade, o Parcel Play OS usa a `nitrocore/` para dominância tecnológica.*
