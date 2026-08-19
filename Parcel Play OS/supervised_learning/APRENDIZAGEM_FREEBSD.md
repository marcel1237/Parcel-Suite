# Aprendizagem Supervisionada: Núcleo FreeBSD (v15 & v16)

> **Estado: nota legada, não canônica.** Este texto mistura fatos, hipóteses e
> metas antigas. Consulte [INDEX.md](INDEX.md), os catálogos e `knowledge/` antes
> de responder ou implementar. Afirmações sobre Sony, desempenho e FreeBSD 16
> não foram verificadas pela base atual.

Este documento registra o processo contínuo de análise e extração de inteligência do código-fonte do FreeBSD para benefício do **Parcel Play OS**.

## 1. Referência Mestra: Sony PlayStation (Orbis OS)
A Sony utilizou o FreeBSD como base para o PS4 e PS5 devido ao controle total (licença permissiva) e excelência em I/O e rede.

### Lições Aprendidas com a Sony:
- **Hipóteses históricas**: números de syscalls, detalhes internos do I/O do PS5
  e uso de XOM precisam de fontes primárias antes de serem reutilizados.
- **Meta, não resultado**: qualquer aplicação no NitroCore exige especificação,
  baseline, implementação e teste próprios.

## 2. Status da Aprendizagem Supervisionada

### [Fase 1] - Arquitetura de Rede (`sys/net`)
- **Análise: `bpf_zerocopy.c`**:
    - **Mecanismo**: O FreeBSD utiliza buffers compartilhados entre o kernel e o user-space para evitar a operação de `copyout`.
    - **Lição**: O uso de `vm_page` e mapeamento direto de memória é o segredo por trás do "Zero-Copy". Implementaremos uma lógica similar no `nitro_net.c` usando **AF_XDP**.

### [Fase 2] - Gestão de Memória e I/O (`sys/kern` & `sys/vm`)
- **Análise: `vm_page_wire` (vm_page.c)**:
    - **Mecanismo**: O FreeBSD usa o conceito de "wiring" para travar páginas na memória física.
    - **Lição**: Quando uma página é marcada como "wired", ela é removida das filas do "page daemon". Isso garante que o tempo de acesso seja constante.
    - **Aplicação no OmniLock**: Implementaremos uma lógica similar de "desenfileiramento" para as HugePages no NitroCore.

### [Fase 3] - Sistemas de Arquivos e I/O (`sys/fs` & `sys/contrib/openzfs`)
- **Análise: ZFS ARC (`arc.c`)**:
    - **Mecanismo**: O ZFS utiliza o ARC para gerenciar cache de RAM de forma adaptativa.
    - **Lição**: Podemos forçar o NitroCore a tratar ativos de jogos como blocos de cache não-evitáveis.

### [Fase 4] - Segurança e Isolamento (`sys/kern/kern_jail.c`)
- **Análise: `prison0` e Estrutura de Jails**:
    - **Mecanismo**: O FreeBSD define a `prison0` como o estado "real" do sistema. Todas as outras jails são derivadas desta raiz, restringindo visibilidade de PIDs e rede.
    - **Lição**: O NitroCore implementará o **Nitro-Jail** definindo uma "Raiz de Confiança" (Nitro-Root) e derivando namespaces filhos onde os processos são "desenfileirados" da visibilidade global.

### [Fase 5] - Drivers e Camada de Abstração (`sys/dev`)
- **Foco**: Estudar o suporte a hardware específico do PlayStation (Sony).
- **Análise: `dev/sound`**:
    - **Mecanismo**: O FreeBSD possui uma arquitetura de drivers de som modular.
    - **Aplicação**: Extrairemos a lógica de priorização de buffer de áudio para o nosso `nitro_audio.c`, garantindo que o tempo de resposta do som no Parcel Play OS seja idêntico ao de um console de mesa.

### [Fase 6] - Escalonamento de Processos (`sys/kern/sched_ule.c`)
- **Foco**: Otimizar a interatividade em sistemas multi-core.
- **Análise: ULE Scheduler**:
    - **Mecanismo**: O ULE utiliza filas de execução independentes por CPU e bloqueio de grão fino. Ele mantém a afinidade do processador usando carimbos de tempo (`ts_rltick`).
    - **Lição**: A separação das filas reduz a contenção entre os núcleos, permitindo que a interface do usuário (KDE/Gnome) permaneça responsiva mesmo quando o sistema está sob carga pesada (ex: compilando o kernel).
    - **Aplicação no NitroCore**: O `nitro_sched.c` evoluirá para suportar **Independent Run-Queues**, garantindo que o "Nitro-Boost" da interface não seja prejudicado por processos de background em outros núcleos.

### [Fase 7] - Cache e Buffer de Dados (`sys/contrib/openzfs/module/zfs/dbuf.c`)
- **Foco**: Acelerar o acesso a metadados de arquivos.
- **Análise: ZFS `dbuf.c`**:
    - **Mecanismo**: O ZFS gerencia um cache de "dbufs" (data buffers) com limites de memória baixa e alta (`lowater`/`hiwater`). Ele mantém estatísticas detalhadas de "hits" e "misses" para cada nível de cache.
    - **Lição**: A estabilidade de performance do ZFS vem de não deixar o cache crescer de forma ilimitada, disparando a "evicção" de dados frios antes que a memória acabe.
    - **Aplicação no NitroCore**: O **OmniLock** herdará esta lógica de limites dinâmicos. Quando o jogo começar a exigir mais RAM, o NitroCore limpará automaticamente buffers de disco de menor prioridade (do sistema host) para manter os dados do jogo em cache quente, assim como o ZFS faz ao atingir a `hiwater` de memória.

### [Fase 8] - O Coração do Sistema (`sys/kern`)
- **Foco**: Analisar a infraestrutura básica: Boot, Devices e Locking.
- **Destaque**: Análise concluída de `init_main.c` (Boot orquestrado), `subr_bus.c` (Abstração Newbus) e `kern_mutex.c` (Sincronização Adaptativa).
- **Detalhes históricos**: Veja [ANALISE_SYS_KERN_FREEBSD.md](ANALISE_SYS_KERN_FREEBSD.md).

---
*Este documento é preservado como histórico e deve ser migrado para entradas
rastreáveis antes de orientar implementação.*
