# Análise Profunda: FreeBSD sys/kern (O Coração do Sistema)

> **Estado: nota legada, não canônica.** As descrições de mecanismos são pontos
> de partida; as aplicações NitroCore são propostas não validadas. Para decisões
> atuais use [INDEX.md](INDEX.md) e
> [knowledge/freebsd/sys-kern-map.md](knowledge/freebsd/sys-kern-map.md).

Este documento detalha a análise técnica dos arquivos em `sys/kern` do FreeBSD 15, focando em como portar essas tecnologias para o **Parcel Play OS**.

## 1. Inicialização e Sysinit (`init_main.c`)
O FreeBSD utiliza o mecanismo `mi_startup` para orquestrar o boot.
- **DNA Técnico**: Uso de uma lista encadeada estática (`sysinit_list`) ordenada por prioridade (`subsystem` e `order`).
- **Proposta histórica**: Estudar boot ordenado e medir initcalls. A meta de
  login abaixo de dois segundos não possui validação registrada.

## 2. Abstração de Hardware: Newbus (`subr_bus.c`)
O framework Newbus separa a topologia do hardware da lógica do driver.
- **DNA Técnico**: Uso de instâncias `device_t` e classes de dispositivo `devclass`. Utiliza o sistema **KOBJ** para permitir herança e polimorfismo em nível de kernel.
- **Proposta rejeitada como porte genérico**: Newbus/KOBJ e o driver model Linux
  não compartilham ABI. Padrões arquiteturais podem ser estudados, mas drivers
  devem usar o modelo nativo do kernel alvo.

## 3. Sincronização Adaptativa (`kern_mutex.c`)
O FreeBSD escala muito bem em sistemas multi-core devido aos seus mutexes adaptativos.
- **DNA Técnico**: Se um núcleo tenta adquirir um mutex ocupado, ele verifica se o dono está rodando em outro CPU. Se estiver, ele faz "spin" (espera ativa); se não estiver, ele dorme. Isso reduz mudanças de contexto inúteis.
- **Proposta condicionada**: Não injetar mutexes BSD no Linux. Comparar workloads
  e usar primitives Linux com lockdep, PI e modelo de memória preservados.

## 4. O Sistema de "Prisões" (`kern_jail.c`)
Analisamos a estrutura fundamental das Jails.
- **DNA Técnico**: O kernel define a `prison0` como o sistema real. As jails filhas herdam restrições, mas possuem sua própria visão de rede e processos.
- **Aplicação NitroCore**: O **Nitro-Jail** será uma implementação de namespaces do Linux que utiliza a lógica de "Hierarquia de Visibilidade" do FreeBSD, garantindo que aplicativos não possam "subir" na árvore de processos do host.

---
*Este registro faz parte da Aprendizagem Supervisionada Contínua.*
