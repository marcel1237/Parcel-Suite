# Auditoria Completa de Arquitetura e Direção — Parcel Play OS

**Data:** 18 de agosto de 2026

**Escopo:** estado atual, propostas novas, alterações recentes, coerência
arquitetural, segurança, build, instalador, kernels, Live ISO e viabilidade de
produto.

**Método:** inspeção estática local, validações disponíveis no host e confronto
com documentação técnica primária.

## 1\. Veredito executivo

O Parcel Play OS possui uma direção de produto aproveitável, mas a
implementação recente está se afastando do caminho mínimo capaz de produzir um
sistema inicializável, instalável e mensurável.

### Direção correta

- Ubuntu Resolute como baseline e fallback;
- uma Live ISO reproduzível antes de alterações profundas no kernel;
- GNOME ou KDE como desktop convencional;
- Gamescope como sessão gaming opcional;
- Subiquity como instalador inicial;
- Flatpak e containers para aplicações externas ao host;
- FreeBSD, NetBSD e OpenBSD como referências e payloads separados;
- UKI, Secure Boot, rollback e sistema imutável como fases posteriores, cada um
  com arquitetura própria;
- otimizações somente depois de benchmark repetível.

### Direção que precisa ser corrigida

- copiar partes de uma árvore Ubuntu para uma árvore Linux vanilla de versão
  diferente;
- tratar dez referências de sistemas operacionais como dez “sabores” funcionais
  de kernel;
- reimplementar NTSYNC quando já existe implementação oficial no Linux;
- afirmar que placeholders C implementam Jail, CFI, Veriexec, scheduler ou
  DirectStorage;
- representar namespaces Linux como equivalentes a FreeBSD Jails ou Capsicum;
- representar embaralhamento de objetos por `shuf` como equivalente ao KARL do
  OpenBSD;
- tornar APT, Pacman, DNF e OBS gestores simultâneos do host;
- declarar Ubuntu Desktop convencional como imutável sem mecanismo de
  imagem/rollback;
- usar `mitigations=off`, `\-Ofast` e microarquitetura AMD inferida apenas por
  AVX2/AVX-512;
- avançar em browser próprio, auto-cura, P2P DMA e interfaces extensas antes do
  MVP.

### Recomendação principal

Suspender a expansão do “Decágono” como implementação. Mantê-lo apenas como
catálogo de referências. Concentrar o desenvolvimento em uma única linha:

> Ubuntu Resolute oficial → Live ISO reproduzível → GNOME/KDE → Subiquity →
> teste em VM → sessão Gamescope opcional → primeiro patch NitroCore pequeno e
> mensurável.

## 2\. Classificação global de maturidade


|Área                           |Estado real                                    |Direção                                      |Decisão                                 |
|-------------------------------|-----------------------------------------------|---------------------------------------------|----------------------------------------|
|ISO Ubuntu com menu customizado|Protótipo produzido; boot não observado        |Correta como experimento                     |Manter                                  |
|Ubuntu + GNOME/KDE             |Planejado; KDE não incorporado ao payload      |Correta com aumento de escopo controlado     |Manter                                  |
|Subiquity                      |Presente na ISO-base; não testado após remaster|Correta para MVP                             |Manter                                  |
|Calamares                      |Mockups e módulos incompletos                  |Útil apenas depois do MVP                    |Adiar                                   |
|Anaconda                       |Sem integração com a base escolhida            |Direção errada                               |Remover do roadmap atual                |
|NitroCore                      |Esqueletos C fora das árvores Linux            |Pesquisa inicial, não kernel                 |Reformular                              |
|Dez sabores NitroCore          |Nomes e propostas sem builds                   |Complexidade sem benefício comprovado        |Reduzir a perfis documentais            |
|Três BSDs na mesma ISO         |Sem payloads e sem boot testado                |Laboratório futuro                           |Adiar                                   |
|NTSYNC próprio                 |`ioctl` vazio                                  |Duplicação de subsistema upstream            |Substituir pelo NTSYNC oficial          |
|Gamescope                      |Wrapper não testado; pacote ausente            |Bom para modo gaming                         |Manter como sessão opcional             |
|KDE inteiro dentro do Gamescope|Não testado                                    |Arriscado como desktop padrão                |Adiar/reformular                        |
|Sistema imutável               |Nenhuma implementação                          |Objetivo válido, arquitetura ausente         |Escolher tecnologia antes de anunciar   |
|APT + AUR + DNF                |Wrappers comentados                            |Válido somente em containers                 |Restringir ao isolamento                |
|ZFS Gaming Zone                |Script real, dependências ausentes             |Experimento opcional                         |Não usar como padrão                    |
|P2P DMA NVMe–GPU               |Logging apenas                                 |Hardware/driver específico                   |Adiar indefinidamente                   |
|Nitro-Verify                   |Permite tudo                                   |Boa meta com solução Linux nativa            |Usar IMA/fs-verity, não reescrever agora|
|Nitro-Jail/Capsicum            |Placeholder                                    |Equivalência conceitual incorreta            |Usar namespaces/Landlock/seccomp        |
|Nitro-CFI/pinsyscalls          |Placeholder                                    |Exige integração profunda de kernel/toolchain|Remover do MVP                          |
|Nitro-Linker/KARL              |Link final comentado                           |Não equivale ao KARL                         |Remover alegação de segurança           |
|Dark Volt EGLFS                |Serviço aponta para binário inexistente        |Alto risco no boot/login                     |Manter em hold                          |
|Thunder Browser                |Script não inicia binário                      |Produto paralelo de alto custo               |Remover do roadmap inicial              |
|Self-healing                   |Somente documento                              |Bom objetivo, depende da base                |Adiar até definir armazenamento/update  |

## 3\. Auditoria do baseline e da Live ISO

### 3.1 Ubuntu Resolute

Usar Ubuntu Desktop como baseline continua sendo a decisão mais adequada para
chegar a uma imagem utilizável. A base fornece kernel, firmware, Casper,
desktop, boot e instalador integrados.

Problema atual: a árvore chamada `Kernels/ubuntu 26 resolute kernel` apresenta
no changelog local `noble` e Linux `6.8.0-30.30`. Ela não deve ser usada como
fonte Resolute até branch e commit serem corrigidos e confirmados.

### 3.2 Linux vanilla 7.1.8

A árvore declara versão 7.1.8, mas não possui `.config`, headers gerados ou
integração NitroCore. Ela é uma referência, não uma base pronta.

Misturar essa árvore com diretórios `ubuntu/` e `debian/` de outra versão não é
um método válido de merge. Código de driver, Kconfig, ABI, patches e
empacotamento dependem da revisão exata. A estratégia correta é escolher:

1.  árvore Ubuntu correta e aplicar patches NitroCore pequenos sobre ela; ou
2.  árvore upstream e criar empacotamento próprio, aceitando perder integrações
    Ubuntu.

Para o MVP, deve ser escolhida a opção 1.

### 3.3 Onze entradas de boot

O menu com onze posições é aceitável como demonstração visual, porque as
entradas sem payload informam indisponibilidade. Não deve ser apresentado como
Live ISO de onze kernels.

Para produto, onze opções de kernel aumentam exponencialmente testes de:

- initramfs;
- firmware;
- módulos externos;
- Secure Boot;
- regressões gráficas;
- recuperação;
- instalação e atualização.

Recomendação: produto inicial com um kernel Ubuntu oficial e, depois, no máximo
um kernel NitroCore experimental. Os BSDs devem ser imagens ou VMs
independentes até que exista integração UEFI comprovada.

## 4\. Auditoria do NitroCore

### 4.1 Estado de build

`nitrocore/Kconfig` e `nitrocore/Makefile` existem, mas não estão incluídos por
nenhuma árvore Linux. Não há `.config`, árvore preparada, objeto, módulo ou log
de compilação.

O nome “implementação” deve ser substituído por “stub”, “esqueleto” ou
“protótipo não integrado”.

### 4.2 Scheduler

`nitro_sched.c` não altera prioridade, runqueue, deadline ou política. Criar um
scheduler próprio é uma das tarefas de maior risco do kernel: falhas podem
causar starvation, inversão de prioridade, regressões energéticas e travamentos.

Direção recomendada:

- medir EEVDF do kernel-base;
- testar políticas `sched_ext` existentes em ambiente isolado;
- avaliar BORE/LAVD como patches ou programas externos rastreáveis;
- não declarar herança de ULE sem portar algoritmos e provar equivalência.

### 4.3 NTSYNC

O Linux já fornece um driver NTSYNC oficial com API documentada para semáforos,
mutexes, eventos e esperas usadas por emuladores NT: 
<https://docs.kernel.org/userspace-api/ntsync.html>.

`nitro_ntsync.c` registra o nome `ntsync`, mas retorna sucesso para qualquer `
ioctl`, o que não implementa semântica NT e pode induzir userspace a interpretar
comportamento incorreto.

Decisão: remover o driver próprio do plano e habilitar/testar a implementação
oficial compatível com Wine/Proton.

### 4.4 Integridade e segurança

`nitro_verify.c`, `nitro_cfi.c` e `nitro_hardened.c` não registram hooks e não
aplicam políticas.

Direção recomendada no Linux:

- IMA/EVM ou fs-verity para integridade;
- AppArmor ou SELinux para MAC;
- seccomp para filtragem de syscalls;
- Landlock para restrição de filesystem por processo;
- namespaces/cgroups para isolamento;
- KCFI quando suportado pelo toolchain e configuração oficial.

O `pinsyscalls(2)` do OpenBSD é configurado por `ld.so` para registrar regiões
precisas de chamadas de sistema na libc; não é reproduzido por uma função
isolada que recebe dois endereços. Referência: 
<https://man.openbsd.org/pinsyscalls.2>.

### 4.5 Jail e Capsicum

FreeBSD Jails são virtualização no nível do sistema operacional; Capsicum
transforma descritores em capacidades e é usado para compartimentalizar
aplicações. São mecanismos diferentes, conforme o Handbook do FreeBSD: 
<https://docs.freebsd.org/en/books/handbook/jails/> e 
<https://docs.freebsd.org/en/books/handbook/security/#capsicum>.

Namespaces Linux não são uma implementação de Capsicum. Um “Capsicum style” no
Linux precisaria ser descrito apenas como inspiração e composto por APIs Linux
reais.

Decisão: renomear Nitro-Jail como perfil de sandbox Linux e projetá-lo em
userspace antes de qualquer helper no kernel.

### 4.6 Rede XDP

`nitro_net.c` não registra um programa BPF/XDP nem AF_XDP socket. Além disso, o
caminho apresentado mistura estruturas de programa BPF com módulo convencional.

Direção recomendada: primeiro protótipo em eBPF userspace, carregado com
libbpf, com interface, fila e modo XDP explicitamente escolhidos. Gaming comum
não deve desviar tráfego pelo XDP sem caso de uso e benchmark, pois isso pode
contornar partes importantes da pilha, firewall e observabilidade.

### 4.7 P2P DMA e “Direct Storage”

P2PDMA depende de topologia PCIe, ACS, root ports, drivers provedores e
consumidores e regras de segurança. A documentação do kernel registra que
transações entre domínios podem ser bloqueadas: 
<https://docs.kernel.org/driver-api/pci/p2pdma.html>.

O protótipo não cria provider, recurso, mapa DMA, consumidor ou caminho
NVMe–GPU. Portanto, não implementa DirectStorage.

Decisão: manter apenas como pesquisa de longo prazo. Não incluir no marketing,
instalador ou kernel inicial.

### 4.8 Áudio e prefetch

O módulo de áudio apenas registra uma mensagem. Afinidade e prioridade de IRQ
não podem ser escolhidas universalmente sem conhecer driver, topologia,
isolamento de CPU e impacto no restante do sistema.

Alterar `mapping->ra_pages` diretamente também exige política, concorrência,
restauração do valor e medição por workload. Para o MVP, usar PipeWire,
prioridades configuradas pelo sistema e parâmetros convencionais antes de criar
código de kernel.

## 5\. Build e otimizações

### 5.1 Scripts de build

`build_os.sh` executa apenas a criação de uma árvore FHS. Bootstrap e kernel
estão comentados. `hybrid_build.sh`, `generate-uki.sh` e `nitro-linker.sh`
também anunciam sucesso sem executar sua operação principal.

Regra recomendada: scripts devem falhar com mensagem “não implementado”
enquanto não produzirem e verificarem o artefato. Um script nunca deve informar
sucesso somente por chegar ao final.

### 5.2 Flags de compilação

Problemas em `nitro-optimize-build.sh`:

- AVX2 não significa AMD Zen 3;
- AVX-512 não significa AMD Zen 4;
- `\-march=native` não é apropriado para imagem distribuível;
- `\-Ofast` pode alterar semântica e não deve ser aplicado indiscriminadamente
  ao kernel;
- `\-flto=thin` é estratégia associada ao ThinLTO/Clang, enquanto o projeto
  também anuncia GCC sem fixar toolchain;
- `NITRO_FLAGS=-DCONFIG_...` não habilita opções Kconfig;
- `\-fno-plt` não comprova ganho ou segurança no kernel.

Direção correta:

- baseline genérico x86-64 compatível;
- configuração oficial Ubuntu;
- builds reprodutíveis;
- variantes de microarquitetura somente para pacotes controlados e após
  benchmark;
- um compilador e versão fixados por build manifest.

### 5.3 KARL e randomização

Embaralhar nomes de arquivos `.o` e executar `ld -r` não reproduz sozinho o KARL
do OpenBSD, não integra relink seguro ao boot e não mede entropia ou
compatibilidade. O link está comentado de qualquer forma.

Decisão: retirar a alegação de segurança. Se houver pesquisa futura, tratá-la
como randomização experimental da ordem de link do Linux.

## 6\. Instalador

### 6.1 Subiquity

Continua sendo a escolha correta para o MVP Ubuntu. Primeiro deve ser
demonstrado que a ISO remasterizada:

- inicia em UEFI;
- oferece GNOME e KDE;
- instala offline;
- inicia o sistema instalado;
- mantém kernel, firmware e bootloader coerentes.

### 6.2 Calamares

Não existe `installer/settings.conf`. Os módulos não aparecem em uma sequência
executável e as operações de instalação estão comentadas. Os QML são mockups.

Calamares pode voltar depois do MVP como frontend próprio, mas misturar
Calamares e Subiquity exige um contrato explícito e aumenta o custo de
manutenção. A primeira versão deve usar apenas Subiquity.

### 6.3 Seletores

Problemas existentes:

- NetBSD grava `seguranca` em vez de `netbsd`;
- o seletor de kernel não oferece Ubuntu;
- filtros e feedback estão incompletos;
- escolhas não controlam payload real;
- `libcalamares.utils.debug` em QML precisa de validação no runtime;
- `network_config` salva valores, mas não os aplica.

Essas telas não devem entrar na ISO enquanto forem somente cosméticas.

### 6.4 Segurança

`thunder_setup/main.py` adiciona `mitigations=off` quando encontra AVX-512. Não
existe relação técnica que justifique desativar mitigação por essa instrução de
CPU.

Decisão: bloquear essa opção. Qualquer modo inseguro futuro deve exigir seleção
manual avançada, aviso explícito e nunca ser padrão.

## 7\. Desktop, Gamescope e Dark Volt

### 7.1 Gamescope

Gamescope é adequado para uma sessão dedicada a jogos. A documentação oficial
descreve modos embedded e nested e redução de cópias, não “latência zero”: 
<https://github.com/ValveSoftware/gamescope>.

Rodar o Plasma inteiro dentro do Gamescope pode ser experimentado, mas não deve
substituir inicialmente uma sessão Plasma convencional. HDR e VRR dependem de
GPU, driver, display, backend e modo de execução.

### 7.2 Defeito no arquivo de sessão

`desktop-file-validate` reprova `
config/wayland-sessions/parcel-full-session.desktop` porque `DesktopNames` não é
uma chave padrão válida sem prefixo de extensão. Além disso, o executável `
/usr/bin/parcel-gamescope-session` não foi instalado e Gamescope não está
disponível no host.

### 7.3 Otimizações KDE

Forçar Vulkan, desabilitar integração GLib, ocultar logs e forçar modificadores
DRM globalmente pode reduzir compatibilidade. As alegações de 60%, 15 GB/s e
latência zero não possuem benchmark.

As variáveis devem virar opções detectadas com fallback, nunca padrão universal.

### 7.4 Dark Volt

O serviço aponta para `/usr/bin/thunder-login-eglfs`, que não existe. Ele roda
como root, antes do display manager, permite prioridade realtime e acesso DRM,
com proteções relaxadas. `kms-config.json` força `/dev/dri/card0`, que não é
estável em sistemas multi-GPU.

Decisão: manter em hold. Não instalar ou habilitar o serviço.

### 7.5 Thunder Browser

Não há binário de navegador. O script força EGLFS, ignora blocklist de GPU e
coloca cache em `/tmp`. Criar e manter um navegador Chromium seguro é um projeto
muito maior que a distribuição.

Decisão: usar Firefox/Chromium empacotado e remover Thunder Browser do caminho
crítico.

## 8\. Gestão de pacotes e imutabilidade

### 8.1 Host

Ubuntu Desktop tradicional com APT não se torna imutável por documentação. Não
há OSTree, image-based update, composefs, EROFS, Snapper, Btrfs transactional
root ou mecanismo equivalente no código.

É necessário escolher uma das duas identidades:

1.  **MVP convencional:** Ubuntu APT mutável, simples e compatível;
2.  **Produto posterior imutável:** arquitetura de imagem e rollback projetada de
    forma explícita.

Recomendação: opção 1 para o MVP.

### 8.2 APT, Pacman e DNF

APT deve ser o único gestor do host Ubuntu. Pacman/AUR e DNF/COPR podem existir
dentro de containers Distrobox/Podman, com diretórios e permissões limitados.

Não se deve:

- misturar bibliotecas Arch no `/usr` do host;
- anunciar compatibilidade universal de pacotes;
- instalar AUR automaticamente como root;
- considerar container equivalente a pacote nativo;
- compartilhar todo `$HOME` por padrão sem perfil de segurança.

O wrapper atual `nitro-pkg.sh` apenas imprime sucesso; Distrobox e Podman nem
estão instalados no host auditado.

### 8.3 Software Center

O mockup é uma boa direção de UX, mas o backend deve começar com APT/Flatpak.
AUR, COPR e outros catálogos só devem ser exibidos quando o container
correspondente estiver configurado, e sempre com origem visível.

## 9\. Armazenamento, ZFS e auto-cura

### 9.1 ZFS Gaming Zone

O script presume que o pool `z-nitro` já existe e cria apenas o dataset. Não
seleciona disco, não cria pool e não protege contra nomes/estado inesperados.

Propriedades como `recordsize=1M` podem beneficiar arquivos grandes, mas devem
ser medidas contra jogos reais. `casesensitivity=insensitive` e normalização
possuem consequências semânticas. ZFS não deve ser requisito para o MVP Ubuntu.

L2ARC persistente existe e sobrevive a reboot, mas é restaurado
assincronamente, custa RAM e beneficia principalmente working sets de leitura
aleatória estática; não significa que todo jogo estará instantaneamente em
cache: 
<https://openzfs.github.io/openzfs-docs/Basic%20Concepts/Pool%20Structure/Caching.html>
.

Decisão: oferecer somente como experimento avançado posterior, nunca criar
automaticamente no instalador inicial.

### 9.2 Conflito de arquitetura

Os documentos propõem ao mesmo tempo:

- host Ubuntu convencional;
- root imutável;
- Btrfs + Snapper;
- ZFS Gaming Zone;
- rollback automático;
- atualizações APT.

Essas peças podem coexistir em alguns desenhos, mas não formam uma arquitetura
automaticamente. O projeto deve escolher root filesystem, modelo de update e
mecanismo de rollback antes de implementar auto-cura.

## 10\. BSD, Connectiva, macOS e Orbis

### 10.1 FreeBSD

É a melhor referência BSD para ZFS, jails, Capsicum, rede e construção de um
sistema completo. Deve permanecer separado do kernel Linux.

Os diretórios locais FreeBSD possuem somente `sys/kern`; não contêm `bsdinstall`
nem `release/`. Para Live FreeBSD, é necessária a árvore completa com tag e
commit.

### 10.2 OpenBSD

É uma referência válida para princípios de segurança, redução de superfície e
APIs como `pledge`, `unveil` e `pinsyscalls`. Esses mecanismos não devem ser
descritos como já portados.

### 10.3 NetBSD

Rump kernels podem servir a experimentos específicos em userspace. Não
transformam o Linux em “Anykernel” e não fornecem portabilidade universal de
drivers.

### 10.4 Connectiva Linux 4

É útil para pesquisa histórica de empacotamento e compatibilidade brasileira.
Linux 2.2.5 não deve fornecer patches diretos ao kernel moderno sem análise
individual de licença, API e relevância.

### 10.5 Orbis/PlayStation e macOS

São referências conceituais, não fontes de implementação disponíveis ao
projeto. Alegações sobre syscalls, hypervisor, áudio, GNM/AGC ou I/O
proprietário não autorizam inferir código ou desempenho reproduzível.

Devem permanecer em documentos de inspiração, separados dos requisitos técnicos
verificáveis.

## 11\. Governança, licenças e reprodutibilidade

O projeto não possui na raiz:

- `README.md`;
- `LICENSE` ou `COPYING` próprio;
- guia de contribuição;
- CI;
- testes automatizados;
- manifesto de fontes e commits;
- política de versões.

Antes de distribuir uma ISO ou binários, devem existir:

1.  licença do código próprio;
2.  inventário SPDX/licenças de terceiros;
3.  manifestos de fontes e hashes;
4.  instruções de build reproduzível;
5.  SBOM ou inventário equivalente;
6.  política de assinatura e atualização;
7.  rastreamento de CVEs da base e componentes.

As árvores grandes não devem ser versionadas dentro do repositório principal.
Devem ser obtidas por script usando URLs oficiais, tags/commits e hashes
fixados.

## 12\. Resultados dos testes estáticos


|Teste                                 |Resultado     |Interpretação                                         |
|--------------------------------------|--------------|------------------------------------------------------|
|`bash -n` em 18 scripts               |Aprovado      |Sintaxe apenas                                        |
|AST dos três módulos Python           |Aprovado      |Sintaxe apenas; Calamares não importado/executado     |
|`python -m json.tool` em `kms-config.json`|Aprovado      |JSON válido                                           |
|`grub-script-check`                   |Aprovado      |Sintaxe GRUB válida                                   |
|`desktop-file-validate`               |Reprovado     |Chave `DesktopNames` inválida no arquivo de sessão    |
|`systemd-analyze verify`              |Inconclusivo  |Sandbox impediu verificação completa                  |
|`git diff --check`                    |Aprovado      |Sem erros de whitespace no diff                       |
|Build NitroCore                       |Não executável|Árvores sem `.config`, preparação e integração NitroCore|
|QML                                   |Não executado |Runtime QML/Calamares ausente                         |
|Gamescope                             |Não executado |Pacote ausente                                        |
|ZFS                                   |Não executado |Ferramentas ausentes; operação afetaria armazenamento |

## 13\. Propostas: manter, reformular, adiar ou remover

### Manter agora

- Ubuntu Resolute como base;
- kernel Ubuntu oficial como fallback;
- Live ISO reproduzível;
- GNOME e KDE, desde que testados;
- Subiquity;
- GRUB simples;
- Flatpak;
- documentação de transparência;
- QEMU como primeiro ambiente de teste.

### Reformular

- NitroCore como uma fila pequena de patches, não “união de kernels”;
- Decágono como referências, não sabores entregues;
- Gamescope como sessão gaming opcional;
- Nitro-Jail como sandbox Linux em userspace;
- Nitro-Verify sobre IMA/fs-verity;
- Pacman/DNF somente em containers;
- Software Center começando com APT + Flatpak;
- ZFS como recurso avançado opcional;
- BSDs como imagens/VMs separadas.

### Adiar

- Calamares customizado;
- imutabilidade;
- UKI e Secure Boot próprios;
- rollback/auto-cura;
- BSDs na mesma ISO;
- scheduler próprio;
- CFI próprio;
- XDP gamer;
- P2P DMA NVMe–GPU;
- ZFS no instalador;
- múltiplas variantes de CPU.

### Remover do roadmap inicial

- Anaconda no FreeBSD/Ubuntu MVP;
- Thunder Browser próprio;
- Dark Volt no early boot;
- NTSYNC reimplementado;
- `mitigations=off` automático;
- promessa de latência zero;
- promessa de 20–200% de FPS;
- promessa de 15 GB/s por OmniLock;
- promessa de “100% compatível/seguro/reproduzível” sem teste;
- descrição do Nitro-Linker como KARL implementado;
- instalação direta de AUR/COPR no host.

## 14\. Roadmap recomendado

### Marco 0 — Higiene do projeto

- criar README, licença e matriz de estados;
- corrigir documentação que chama stubs de implementação;
- fixar URLs, branches e commits;
- escolher Ubuntu convencional mutável para o MVP;
- retirar flags inseguras e mensagens de falso sucesso.

### Marco 1 — ISO mínima

- reconstruir ISO Resolute de forma reproduzível;
- manter kernel oficial;
- incluir GNOME/KDE com um display manager definido;
- validar GRUB, UEFI e checksum;
- iniciar em QEMU.

### Marco 2 — Instalação

- usar somente Subiquity;
- instalar offline em disco virtual descartável;
- reiniciar no sistema instalado;
- testar usuário, rede, áudio, GPU virtual, atualização e recuperação.

### Marco 3 — Gaming

- instalar Steam, Mesa/Vulkan e Gamescope por pacotes;
- manter Plasma convencional;
- adicionar sessão Gamescope opcional;
- medir frame pacing, latência e estabilidade.

### Marco 4 — Primeiro NitroCore

- copiar a árvore NitroCore para a árvore Ubuntu correta;
- integrar um único recurso pequeno no Kconfig/Makefile;
- compilar com configuração conservadora;
- testar em VM e hardware;
- manter kernel Ubuntu para recuperação;
- publicar benchmark e regressões.

### Marco 5 — Containers e armazenamento

- adicionar Flatpak primeiro;
- provar Distrobox/Podman com Arch isolado;
- só depois criar frontend unificado;
- experimentar ZFS em volume/disco separado, sem ser requisito do sistema.

### Marco 6 — BSD

- clonar `freebsd-src` completo com revisão fixada;
- construir/testar ISO FreeBSD separada;
- testar `bsdinstall` em VM;
- comparar FreeBSD e OpenBSD com métricas;
- avaliar chainload somente depois dos testes isolados.

## 15\. Critério de decisão para novas ideias

Uma proposta nova só deve entrar no roadmap quando responder:

1.  Qual problema de usuário resolve?
2.  O Linux/Ubuntu já possui mecanismo oficial equivalente?
3.  Qual é a interface técnica exata?
4.  Existe protótipo executável, não somente arquivo ou logging?
5.  Qual benchmark e baseline serão usados?
6.  Qual é o risco de segurança e recuperação?
7.  Como será atualizado e mantido?
8.  Qual componente do MVP será removido ou atrasado para abrir espaço?

Se essas respostas não existirem, a ideia deve permanecer em `research/` e não
ser descrita como funcionalidade do sistema.

## 16\. Conclusão

O projeto deve continuar, mas com redução agressiva de escopo. A melhor parte
da visão é combinar uma base Ubuntu confiável com boa experiência desktop e
gaming, transparência de kernel e experimentos mensuráveis. A pior parte é
transformar referências de muitos sistemas em promessas de subsistemas próprios
antes de haver um produto mínimo.

O caminho correto não é “unir tudo”. É selecionar mecanismos existentes,
integrá-los de forma reproduzível e provar cada ganho. FreeBSD, OpenBSD,
NetBSD, SteamOS, Arch, Fedora, openSUSE, macOS e Orbis podem orientar decisões;
eles não devem ser apresentados como componentes já incorporados ao NitroCore.

**Decisão final:** preservar a visão, interromper a expansão horizontal e
executar verticalmente o baseline Ubuntu até boot e instalação confirmados.
Somente depois iniciar um NitroCore pequeno, compilável, reversível e medido.

