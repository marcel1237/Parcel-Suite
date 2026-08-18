# PlayOS unificado: Ubuntu Resolute + FreeBSD 15

**Data:** 18 de agosto de 2026  
**Estado:** análise arquitetural e plano de prova de conceito  
**Decisão preliminar:** Ubuntu host com FreeBSD integrado como máquina de
serviços KVM/libvirt.

## 1. O que “um único OS” significará

PlayOS será um único produto, uma única instalação e uma única experiência de
desktop. Internamente haverá dois kernels:

- Linux 7.0 do Ubuntu Resolute controla hardware, desktop e aplicações;
- FreeBSD 15.1 executa simultaneamente em uma VM isolada e fornece serviços BSD.

Isso é uma união no nível do produto e dos serviços, não uma fusão de código de
kernel. Linux e FreeBSD possuem ABIs internas, modelos de drivers, loaders,
licenças e estruturas de processo incompatíveis. Tentar ligar objetos dos dois
kernels ou montar o mesmo root filesystem como raiz de ambos produziria um
sistema inseguro e impossível de manter.

## 2. Alternativas avaliadas

| Arquitetura | Simultânea | Gaming | Recursos BSD | Complexidade | Veredito |
|---|---:|---:|---:|---:|---|
| fundir kernels/fontes | não aplicável | imprevisível | imprevisível | extrema | rejeitada |
| trocar kernel no mesmo Ubuntu rootfs | não | quebra ABI/userspace | parcial | extrema | rejeitada |
| dual boot na mesma mídia | não | bom por sistema | completo ao reiniciar | média | recuperação, não união |
| FreeBSD host + Ubuntu em bhyve | sim | GPU/desktop mais difíceis | completo | alta | perfil futuro |
| Ubuntu host + FreeBSD em KVM | sim | melhor caminho | serviços BSD reais | controlável | recomendado |

O host Ubuntu é escolhido porque o PlayOS é orientado a desktop e jogos. Ele
mantém drivers, Steam/Proton, Waydroid, PipeWire, Wayland e Secure Boot no fluxo
mais suportado. KVM oferece virtualização assistida por hardware, e o Ubuntu
documenta QEMU/libvirt como seu fluxo oficial. O FreeBSD documenta operação em
ambientes virtualizados e possui drivers VirtIO.

## 3. Arquitetura proposta

```text
UEFI / Secure Boot
        │
Ubuntu Resolute Linux 7.0
        │
        ├── KDE/GNOME + Wayland + PipeWire
        ├── Steam/Proton/Waydroid/Flatpak
        ├── Play Software Center
        ├── Play Orchestrator (`playd`)
        │       │
        │       └── libvirt/KVM ──► FreeBSD 15.1 minimal
        │                            ├── ZFS em discos dedicados
        │                            ├── Jails/VNET/RCTL
        │                            ├── Capsicum/MAC
        │                            ├── serviços de rede/storage
        │                            └── Play BSD Agent
        │
        └── bridge VirtIO privada + API autenticada
```

### Regra de responsabilidade

| Recurso | Responsável |
|---|---|
| GPU, Wi-Fi, áudio, Bluetooth, energia e suspend | Ubuntu host |
| desktop e login | Ubuntu host |
| jogos e aplicativos locais | Ubuntu host |
| hipervisor e ciclo de vida da VM | libvirt/KVM no Ubuntu |
| ZFS BSD, Jails, VNET e serviços BSD | FreeBSD guest |
| catálogo e UX comum | PlayOS userspace |
| roteamento de tarefas | Play Orchestrator |

## 4. Como os dois lados se comunicam

### Rede de controle

Criar uma rede libvirt privada, sem exposição externa por padrão:

```text
playbr0: 192.168.127.1/30
Ubuntu:  192.168.127.1
FreeBSD: 192.168.127.2
```

A primeira versão usará VirtIO NIC e API HTTPS/mTLS ou SSH com chave dedicada.
Não dependerá de um recurso experimental de memória compartilhada. Firewall no
host e PF no guest permitirão somente os serviços declarados.

### Dados

Não montar simultaneamente um mesmo filesystem gravável nos dois kernels.
Opções seguras:

1. NFSv4 sobre a rede VirtIO privada para arquivos compartilhados;
2. SMB quando a interoperabilidade com Windows for necessária;
3. volume virtual dedicado, anexado a apenas um sistema por vez;
4. API de objetos para artefatos e backups.

Virtio-fs pode ser investigado depois, mas não será requisito do MVP até haver
suporte comprovado no guest FreeBSD selecionado.

### Identidade

- o usuário faz login somente no Ubuntu;
- `playd` usa credencial de máquina, não replica senha do usuário;
- IDs de usuário e permissões são mapeados explicitamente nos exports;
- segredos ficam no keyring do host e são entregues por sessão curta;
- root do FreeBSD nunca equivale automaticamente a root do Ubuntu.

## 5. Serviços FreeBSD úteis dentro do PlayOS

### Bons candidatos iniciais

- laboratório de Jails/VNET;
- storage ZFS em disco virtual ou dispositivo dedicado;
- snapshots, replicação e servidor de backup;
- serviços de rede isolados;
- build/teste de software FreeBSD;
- DTrace e comparação de desempenho;
- appliance de firewall em topologia de laboratório;
- testes dos patches Linux → FreeBSD.

### Candidatos ruins

- renderização principal da GPU;
- áudio do desktop;
- scheduler dos processos Linux;
- execução transparente de módulos FreeBSD no Linux;
- aceleração direta de jogos do host;
- controle de arquivos do host sem protocolo explícito.

Uma VM FreeBSD não transfere ULE, Jails ou a pilha de rede para processos Linux.
Ela fornece serviços reais executados pelo FreeBSD. Otimizações do host Linux
continuam exigindo implementações Linux próprias.

## 6. Experiência do usuário

O usuário verá:

- um instalador PlayOS;
- uma conta;
- um desktop;
- uma central de atualização;
- uma página “FreeBSD Core” com estado, recursos e serviços;
- botões para iniciar/parar laboratórios ou storage BSD;
- indicação clara quando uma tarefa executa no FreeBSD.

Estados previstos:

```text
FreeBSD Core: desligado | iniciando | saudável | degradado | manutenção
```

O boot do desktop não deve depender do guest. Se FreeBSD falhar, jogos e
desktop continuam funcionando e a interface oferece reparo ou restauração.

## 7. Instalação única

O instalador Ubuntu/Subiquity continua responsável pelo disco e pelo host. Um
pacote PlayOS instala depois:

- QEMU/KVM e libvirt;
- imagem FreeBSD assinada e versionada;
- definição libvirt;
- rede privada;
- `playd` no host;
- agente rc.d no FreeBSD;
- políticas, manifests e health checks.

Não executar `bsdinstall` diretamente no disco físico durante esse fluxo. A
imagem guest deve ser produzida antes, pelo sistema oficial de release do
FreeBSD, e distribuída como artefato imutável/verificável.

### Perfil mínimo sugerido

- 2 vCPUs quando ativo;
- 1 GiB de RAM inicial, ajustável;
- disco de sistema pequeno e somente para FreeBSD;
- segundo disco opcional para ZFS/dados;
- ballooning somente após teste;
- autostart opcional, não obrigatório no perfil Gaming mínimo.

O host atual possui apenas 5,1 GiB de RAM, com 2,3 GiB disponíveis durante a
auditoria. Ele é adequado apenas para uma prova de conceito FreeBSD mínima; não
é adequado para executar simultaneamente desktop pesado, jogo e VM grande.

## 8. Atualização e recuperação

Host e guest têm ciclos separados:

1. atualizar Ubuntu sem alterar a imagem FreeBSD;
2. baixar nova imagem FreeBSD em paralelo;
3. validar assinatura e manifesto;
4. iniciar health check temporário;
5. trocar a versão ativa somente após sucesso;
6. preservar a imagem anterior para rollback.

Dados devem ficar fora da imagem do sistema guest. Migrações precisam ser
versionadas e reversíveis. O kernel Ubuntu oficial e a imagem FreeBSD anterior
permanecem como recuperação.

## 9. Segurança

- Secure Boot protege a cadeia do host; a imagem guest recebe assinatura e hash;
- libvirt executa a VM com privilégios mínimos;
- rede de controle não faz bridge externa por padrão;
- API exige autenticação mútua e autorização por operação;
- FreeBSD usa PF, Jails, RCTL, Capsicum/MAC conforme o serviço;
- exports de arquivos usam allowlist;
- nenhum socket administrativo fica acessível a aplicações comuns;
- logs registram backend, usuário, versão e resultado.

O FreeBSD guest não deve ser tratado como barreira absoluta contra um host
Ubuntu comprometido: o host controla memória, CPU e dispositivos da VM.

## 10. Prova de conceito em sete etapas

### P0 — pré-requisitos

- obter imagem oficial FreeBSD 15.1 amd64 e checksums;
- instalar QEMU/KVM/libvirt no Ubuntu;
- confirmar `/dev/kvm` e AMD-V/VT-x;
- fixar versões e guardar manifests.

### P1 — boot isolado

- importar a imagem FreeBSD;
- usar UEFI, VirtIO block e VirtIO network;
- obter console e desligamento limpo;
- medir boot, RAM e CPU ociosa.

### P2 — canal de controle

- criar bridge privada;
- instalar agente mínimo;
- implementar `ping`, `version`, `health` e `shutdown`;
- negar tráfego não declarado.

### P3 — serviço real

- criar um dataset ZFS dentro de disco exclusivo do guest;
- exportar diretório de teste por NFSv4;
- validar leitura, escrita, UID/GID, snapshot e restauração;
- nunca usar dados únicos nessa fase.

### P4 — integração desktop

- painel de status;
- start/stop e logs;
- timeout e modo degradado;
- notificações sem bloquear login.

### P5 — atualização A/B

- duas imagens guest;
- health check antes da troca;
- rollback automático;
- preservação independente dos dados.

### P6 — medição

- boot com e sem guest;
- RAM/CPU ociosa;
- throughput e latência NFS;
- suspend/resume do host;
- 100 ciclos start/stop;
- falhas de energia simuladas em VM descartável.

## 11. Critérios de aceitação

- PlayOS inicia e funciona com FreeBSD Core ausente ou corrompido;
- guest inicia e encerra sem intervenção em 100 ciclos;
- zero filesystem gravável montado simultaneamente por dois kernels;
- API rejeita credencial inválida;
- atualização A/B e rollback funcionam;
- suspend/resume não corrompe o guest;
- overhead ocioso fica dentro do orçamento definido;
- serviços FreeBSD mostram benefício ou capacidade não coberta pelo host;
- usuário sempre sabe onde a tarefa está executando.

## 12. Estado do ambiente atual

Confirmado no host:

- Ubuntu Resolute com kernel `7.0.0-29-generic`;
- arquitetura x86_64;
- CPU AMD Ryzen 3 7320U;
- AMD-V anunciado pelo processador;
- aproximadamente 94 GiB livres;
- QEMU, `virsh` e `virt-install` não encontrados;
- `/dev/kvm` não confirmado;
- apenas 5,1 GiB de RAM total.

Logo, a análise é viável, mas a prova de conceito está bloqueada até instalar o
stack de virtualização e confirmar KVM. Nenhuma instalação foi executada nesta
etapa.

## 13. Veredito

A melhor forma de unir Ubuntu Resolute e FreeBSD 15 em um único PlayOS é uma
arquitetura host/serviço: Ubuntu permanece no controle do desktop e hardware;
FreeBSD sobe como núcleo de serviços isolado e gerenciado pelo sistema. Para o
usuário é um produto único, enquanto a separação técnica mantém cada kernel em
um ambiente que ele consegue suportar e atualizar corretamente.

Dual boot pode permanecer como recuperação ou modo FreeBSD completo. Fusão de
kernels, módulos cruzados e rootfs compartilhado devem permanecer proibidos.

## Fontes oficiais

- [Ubuntu: libvirt e KVM](https://documentation.ubuntu.com/server/how-to/virtualisation/libvirt/)
- [Ubuntu 26.04: stack de virtualização](https://documentation.ubuntu.com/release-notes/26.04/summary-for-lts-users/)
- [Documentação KVM do kernel Linux](https://docs.kernel.org/virt/kvm/)
- [FreeBSD: virtualização](https://docs.freebsd.org/en/books/handbook/virtualization/)
- [FreeBSD 15.1-RELEASE](https://www.freebsd.org/releases/15.1R/)
- [FreeBSD: Jails](https://docs.freebsd.org/en/books/handbook/jails/)
- [FreeBSD: ZFS](https://docs.freebsd.org/en/books/handbook/zfs/)
