# Aprendizagem Supervisionada: Núcleo FreeBSD (v15 & v16)

Este documento registra o processo contínuo de análise e extração de inteligência do código-fonte do FreeBSD para benefício do **Parcel Play OS**.

## 1. Referência Mestra: Sony PlayStation (Orbis OS)
A Sony utilizou o FreeBSD como base para o PS4 e PS5 devido ao controle total (licença permissiva) e excelência em I/O e rede.

### Lições Aprendidas com a Sony:
- **Customização de Syscalls**: A Sony adicionou ~85 syscalls customizadas para lidar com acesso direto à GPU.
- **I/O de Ultra-Velocidade**: No PS5, o stack de I/O foi reescrito para ignorar gargalos do VFS tradicional, permitindo que a GPU converse quase diretamente com o NVMe.
- **Segurança via Hypervisor**: O uso de um Hypervisor customizado para garantir proteções de memória (XOM - Execute Only Memory) é um objetivo para o **NitroCore Hardened**.

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

---
*Este processo é contínuo e nunca deve ser interrompido.*
