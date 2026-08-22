# Auditoria das Alterações do Parcel Play OS — 18 de agosto de 2026

## 1\. Escopo e marco de comparação

Esta auditoria compara o workspace atual com o último commit existente:

- **Commit-base:** `60a5f63`
- **Data do commit:** 15 de agosto de 2026, 11:18:42 (America/Sao_Paulo)
- **Mensagem:** `docs`
- **Natureza da auditoria:** inspeção estática do Git, documentação, scripts,
  módulos Python/QML, protótipos C e fontes importadas.

Nenhum boot, instalação, compilação de kernel, carregamento de módulo,
benchmark ou teste destrutivo foi executado nesta auditoria.

## 2\. Resumo quantitativo

Desde o commit-base foram identificados:


|Categoria                                          |Quantidade|Variação registrada pelo Git|
|---------------------------------------------------|----------|----------------------------|
|Arquivos adicionados ao índice                     |73        |2.672 inserções             |
|Arquivos com modificações adicionais fora do índice|21        |342 inserções e 37 remoções |
|Arquivos não rastreados                            |5.222     |Não contabilizados no diff  |
|Arquivos rastreados removidos                      |0         |Nenhuma remoção             |
|Novos commits                                      |0         |`HEAD` permanece em `60a5f63`|

Alguns arquivos aparecem como `AM`: foram adicionados ao índice e depois
modificados novamente. Portanto, a versão preparada no índice não é igual à
versão atual do arquivo no workspace.

## 3\. Documentação adicionada

Foram adicionados os seguintes documentos na raiz:

1.  `ANATOMIA_DEBIAN_UBUNTU.md`
2.  `ARCH_LINUX_TECH.md`
3.  `BOOT_SPLASH_DESIGN.md`
4.  `CONVERGENCIA_MERCADO.md`
5.  `FEDORA_TECH.md`
6.  `GESTAO_HIBRIDA.md`
7.  `GESTAO_RPM_DNF.md`
8.  `HANDOFF_UBUNTU_ARCH.md`
9.  `HYBRID_GLIBC_STRATEGY.md`
10. `INTEGRACAO_TRIADE_BSD.md`
11. `KDE_GAMESCOPE_INTEGRATION.md`
12. `LABORATORIO_KERNELS.md`
13. `MACOS_TECH.md`
14. `MODO_JOGO_CAPSICUM.md`
15. `NETBSD_TECH.md`
16. `NITRO_BUILD_SYSTEM.md`
17. `NITRO_CONTAINER_ENGINE.md`
18. `NITRO_CONTROL_DESIGN.md`
19. `NITRO_SECURITY_DESIGN.md`
20. `NITRO_SWITCHER_DESIGN.md`
21. `NITRO_VERIFY.md`
22. `OPENBSD_TECH.md`
23. `OPENSUSE_TECH.md`
24. `ORBIS_FREEBSD_STEAMOS.md`
25. `ORBIS_FREEBSD_STEAMOS_INTEGRATION.md`
26. `ORBIS_OS.md`
27. `OTIMIZACAO_COMPILADOR.md`
28. `PONTE_WINDOWS_FEDORA.md`
29. `RANKING_ARQUITETURA.md`
30. `REFERENCIAS_GAMING.md`
31. `SELF_HEALING_STRATEGY.md`
32. `SOFTWARE_CENTER_DESIGN.md`
33. `SONY_PLAYSTATION_FREEBSD.md`
34. `STEAMOS_INTEGRATION.md`
35. `UBUNTU_FREEBSD_ORBIS_STEAMOS.md`
36. `UBUNTU_STEAMOS_PARCEL_UNION.md`
37. `VALVE_ARCH_OPTIMIZATIONS.md`
38. `ZFS_GAMING_ZONE.md`

Também foram adicionados:

- `nitrocore/nitrocore.md`
- `supervised_learning/ANALISE_SYS_KERN_FREEBSD.md`
- `supervised_learning/APRENDIZAGEM_FREEBSD.md`

### Avaliação documental

O projeto passou a documentar referências de Ubuntu, Debian, Arch, Fedora,
openSUSE, FreeBSD, NetBSD, OpenBSD, SteamOS, Orbis OS e macOS, além de
propostas para containers, gestão de pacotes, ZFS, NTSYNC, Gamescope, segurança
e interfaces.

Entretanto, vários documentos usam termos como “implementado”, “integrado”,
“funcional”, “validado” ou apresentam números de desempenho sem teste
correspondente. Essas declarações devem ser classificadas como **proposta**, **
protótipo não integrado** ou **hipótese a medir**, conforme o caso.

## 4\. Árvore NitroCore adicionada

### 4.1 Integração de build local

Foram adicionados:

- `nitrocore/Kconfig`
- `nitrocore/Makefile`

O `Kconfig` declara opções para scheduler, OmniLock, hardening, Jail, CFI,
NTSYNC, áudio, verificação de integridade, storage e rede XDP. O `Makefile`
associa essas opções aos respectivos objetos.

### 4.2 Protótipos C adicionados


|Arquivo                  |Finalidade declarada             |Estado confirmado                                                                 |
|-------------------------|---------------------------------|----------------------------------------------------------------------------------|
|`audio/nitro_audio.c`    |Priorizar IRQ de áudio           |Apenas logging; não altera IRQ, afinidade ou prioridade                           |
|`fs/nitro_prefetcher.c`  |Aumentar read-ahead              |Altera `mapping->ra_pages`, mas não possui integração com seleção de processos/jogos|
|`integrity/nitro_verify.c`|Verificar hashes antes de `execve`|Retorna permissão sem registrar hook de segurança                                 |
|`mm/omnilock.c`          |Fixar páginas e buffers Gamescope|Apenas logging e retorno de sucesso                                               |
|`net/nitro_net.c`        |Processamento XDP/AF_XDP         |Contém esqueleto de inspeção, mas não registra ou anexa programa XDP              |
|`sched/nitro_sched.c`    |Priorizar tarefas interativas    |Função vazia; não integra com scheduler Linux                                     |
|`security/nitro_cfi.c`   |CFI e syscall pinning            |Funções conceituais sem validação ou hook                                         |
|`security/nitro_hardened.c`|W^X e restrição de I/O           |Funções sem implementação operacional                                             |
|`security/nitro_jail.c`  |Isolamento por namespaces        |Não cria namespaces nem move processos                                            |
|`storage/nitro_storage.c`|P2P DMA NVMe/GPU                 |Apenas logging; não registra recursos P2PDMA                                      |
|`sync/nitro_ntsync.c`    |Primitivas Windows NT            |Registra estrutura de miscdevice, mas `ioctl` não implementa operações            |

### 4.3 Bloqueio de integração

Não foram encontradas referências a `nitrocore` ou `CONFIG_NITROCORE` nos `
Kconfig` e `Makefile` principais das árvores Linux vanilla e Ubuntu. Assim, a
pasta ainda não participa de um build real de kernel e não existe evidência de
produção de qualquer `.ko`.

## 5\. Scripts adicionados

Foram adicionados:

1.  `scripts/generate-uki.sh`
2.  `scripts/hybrid_build.sh`
3.  `scripts/nitro-hybrid-handoff.sh`
4.  `scripts/nitro-linker.sh`
5.  `scripts/nitro-optimize-build.sh`
6.  `scripts/nitro-pkg.sh`
7.  `scripts/nitro-switcher-apply.sh`
8.  `scripts/parcel-gamescope-session.sh`
9.  `scripts/setup-z-gaming.sh`

### Estado funcional

- `generate-uki.sh` não executa `ukify`; o comando está comentado, mas o script
  anuncia sucesso.
- `hybrid_build.sh` não copia fontes, não aplica patches, não gera `.config` e
  não compila; as operações centrais estão comentadas.
- `nitro-linker.sh` não executa o link final porque o comando `ld` está
  comentado.
- `nitro-pkg.sh` não instala pacotes; os comandos de Distrobox/DNF/host estão
  comentados.
- `nitro-switcher-apply.sh` não chama `grub-reboot`; a operação está comentada.
- `nitro-hybrid-handoff.sh` possui uma chamada real ao Bubblewrap e requer
  rootfs Arch previamente preparado.
- `parcel-gamescope-session.sh` possui chamada real ao Gamescope, mas depende de
  Gamescope, Plasma, DBus e suporte gráfico compatível.
- `setup-z-gaming.sh` contém comandos ZFS reais e destrutivos para o estado do
  pool/dataset; requer validação de pool, espaço, propriedades suportadas e
  confirmação explícita antes da execução.
- `nitro-optimize-build.sh` exporta flags agressivas, mas a detecção associa
  AVX2 a `znver3` e AVX-512 a `znver4`, o que não identifica corretamente o
  fabricante/modelo da CPU.

Todos os scripts Shell inspecionados passaram em `bash -n`. Isso confirma
somente sintaxe Shell, não funcionamento ou segurança.

## 6\. Instalador e interfaces adicionados

### Módulos Calamares

- `installer/modules/agility_zone/main.py`
- `installer/modules/agility_zone/module.desc`
- `installer/modules/network_config/View.qml`
- `installer/modules/network_config/module.desc`

O módulo `agility_zone` registra etapas para Podman/Distrobox/Arch, mas todas as
chamadas que modificariam o sistema estão comentadas. A tela `network_config`
grava opções no `globalStorage`, porém não foi encontrado backend que aplique
sysctl, congestion control ou XDP.

### Mockups QML

- `installer/branding/mockups/NitroControl.qml`
- `installer/branding/mockups/NitroSecurity.qml`
- `installer/branding/mockups/NitroSwitcher.qml`
- `installer/branding/mockups/SoftwareCenter.qml`
- `installer/branding/mockups/ThunderBrowser.qml`

Esses arquivos devem ser classificados como mockups. Não há evidência de
integração em uma configuração executável do Calamares, pacote instalável ou
aplicação independente.

### Sessão gráfica

- `config/wayland-sessions/parcel-full-session.desktop`

O arquivo aponta para o wrapper Gamescope/KDE, mas a sessão não foi instalada
nem iniciada durante a auditoria.

## 7\. Arquivos modificados depois da inclusão no índice

### Configuração

- `.gitignore`: adicionadas regras para ignorar as árvores Linux 7.1.8 e Ubuntu
  Resolute.
- `.idea/vcs.xml`: adicionados mapeamentos Git para o projeto e para a árvore
  Ubuntu.

### Documentação

- `ARQUITETURA_PERFORMANCE.md`: proposta de P2P DMA e `io_uring` passthrough.
- `GESTAO_PACOTES.md`: host imutável e Pacman/AUR por uma zona Arch.
- `KDE_GAMESCOPE_INTEGRATION.md`: proposta de OmniLock para buffers do Gamescope
  e alegação não medida de 15 GB/s.
- `LABORATORIO_KERNELS.md`: expansão da anatomia Ubuntu/Debian e estratégia de
  pasta `nitrocore`.
- `MATRIZ_QUALIDADE.md`: Oracle Linux adicionado como referência de I/O.
- `PROGRESSO.md`: dezenas de registros sobre documentos, código e estudos
  recém-adicionados.
- `RESUMO_DO_CHAT.md`: expansão das alegações sobre NitroCore, BSD, SteamOS, ZFS
  e gestão híbrida.
- `ZFS_GAMING_ZONE.md`: ligação com `scripts/setup-z-gaming.sh`.
- `supervised_learning/APRENDIZAGEM_FREEBSD.md`: expansão para oito fases de
  estudo.

### Código e interface

- `installer/branding/mockups/ThunderBrowser.qml`: indicador visual HDR e
  mensagem de brightness mapping.
- `nitrocore/Kconfig`: novas opções Jail, CFI, NTSYNC, áudio, verificação e
  storage.
- `nitrocore/Makefile`: novos objetos correspondentes.
- `nitrocore/mm/omnilock.c`: função conceitual para buffer Gamescope.
- `nitrocore/net/nitro_net.c`: inspeção inicial de pacote e saída do módulo.
- `nitrocore/sched/nitro_sched.c`: comentários alterados para referência ao ULE;
  função continua vazia.
- `scripts/nitro-optimize-build.sh`: `\-O3` substituído por `\-Ofast`, inclusão
  de `\-pipe` e variável `NITRO_FLAGS`.

### Permissões de execução

Os seguintes scripts mudaram de modo `0644` para `0755`:

- `scripts/nitro-hybrid-handoff.sh`
- `scripts/nitro-switcher-apply.sh`
- `scripts/setup-z-gaming.sh`

## 8\. Fontes importadas e não rastreadas

Existem 5.220 arquivos não rastreados sob `Kernels/`:


|Árvore            |Arquivos não rastreados|Tamanho aproximado|Conteúdo observado                                           |
|------------------|-----------------------|------------------|-------------------------------------------------------------|
|Connectiva Linux 4|4.722                  |76 MB             |Linux 2.2.5, patches, configurações, spec e fontes históricas|
|FreeBSD 15        |248                    |7,7 MB            |Recorte de `sys/kern`                                        |
|FreeBSD 16        |250                    |7,8 MB            |Recorte de `sys/kern`                                        |

As árvores abaixo também estão presentes, mas são ocultadas pelas novas regras
do `.gitignore`:

- `Kernels/kernel linux-7.1.8/`, aproximadamente 1,8 GB;
- `Kernels/ubuntu 26 resolute kernel/`, aproximadamente 1,8 GB.

### Correção sobre o FreeBSD

Os diretórios locais FreeBSD contêm somente `sys/kern`. Estão ausentes:

- `usr.sbin/bsdinstall/`;
- `release/`;
- `stand/`;
- demais partes do sistema base.

Portanto, o código oficial de `bsdinstall` e do pipeline de Live ISO está
referenciado em `LIVE_CD_FREEBSD.md`, mas ainda não foi importado para o
workspace.

## 9\. Outros arquivos não rastreados

- `chat_ubuntu26_freebsd_completo.html`
- `source-ubuntu-26-packages-manual.sh`

O script novo configura fontes APT, descobre dependências de metapacotes Ubuntu
e tenta baixar pacotes-fonte. Ele contém operações com `sudo` e modifica `
/etc/apt`; não foi executado nesta auditoria.

## 10\. Inconsistências de versão

Foram encontradas três bases concorrentes:


|Local                                      |Versão identificada            |
|-------------------------------------------|-------------------------------|
|`Kernels/kernel linux-7.1.8/Makefile`      |Linux 7.1.8                    |
|`scripts/02-build-nitrocore.sh`            |`KERNEL_VERSION="6.18.44"`     |
|Changelog da árvore chamada Ubuntu Resolute|Ubuntu Noble, Linux 6.8.0-30.30|

`ANATOMIA_DEBIAN_UBUNTU.md` também afirma que Ubuntu Resolute usa Linux 7.0.
Essa afirmação não corresponde à árvore local auditada.

Nenhum merge deve começar antes da escolha de uma única revisão-base,
registrada por URL, branch/tag, commit completo e configuração.

## 11\. Riscos principais

1.  **Maturidade superestimada:** documentação descreve protótipos como recursos
    implementados.
2.  **Build falso-positivo:** scripts imprimem sucesso mesmo quando comandos
    centrais estão comentados.
3.  **Segurança:** `thunder_setup/main.py` associa AVX-512 a `mitigations=off`,
    sem justificativa segura.
4.  **Otimização não portátil:** `\-Ofast`, `\-march=znver3/znver4` e ThinLTO
    são selecionados sem confirmar compilador, arquitetura e compatibilidade do
    kernel.
5.  **Instalador incompleto:** módulos Calamares coletam valores ou registram
    logs, mas não instalam o sistema.
6.  **Fontes sem proveniência completa:** recortes FreeBSD não possuem metadados
    Git locais, tag ou commit junto aos arquivos.
7.  **Escopo excessivo:** Live ISO, kernel, containers, múltiplos gestores de
    pacotes, BSD, ZFS, Gamescope e interfaces estão avançando simultaneamente
    sem baseline inicializável confirmado.

## 12\. Estado técnico consolidado

### Implementação real existente

- fontes Linux/Ubuntu locais;
- recortes de fontes Connectiva e FreeBSD;
- ISO protótipo do menu GRUB já produzida anteriormente;
- arquivos QML, Python, Shell, Kconfig, Makefile e C materializados no
  workspace;
- três scripts com permissão de execução adicionada;
- sintaxe Shell e Python aprovada estaticamente.

### Protótipos não integrados

- todos os módulos `nitrocore/*.c`;
- módulos Calamares novos;
- mockups QML;
- sessão Gamescope/KDE;
- gestão híbrida de pacotes;
- Nitro-Switcher;
- UKI;
- linker randomizado;
- Nitro-Verify, Nitro-Jail, CFI, NTSYNC e storage P2P.

### Apenas planejado ou documental

- fusão funcional de Linux vanilla com drivers Ubuntu;
- kernel NitroCore compilável;
- Live ISO com NitroCore;
- Live FreeBSD gráfica;
- integração de `bsdinstall`;
- auto-cura, rollback e sistema imutável;
- benchmarks e ganhos de desempenho declarados.

## 13\. Recomendação de sequência

1.  Fixar e verificar uma árvore Ubuntu Resolute correta.
2.  Reproduzir a ISO Ubuntu com kernel oficial, GNOME, KDE e Subiquity.
3.  Executar boot e instalação em VM com disco descartável.
4.  Escolher somente um módulo NitroCore mínimo e mensurável.
5.  Integrar esse módulo ao Kconfig/Makefile da árvore escolhida.
6.  Compilar com configuração conservadora antes de aplicar `\-Ofast`, LTO ou
    flags específicas de CPU.
7.  Carregar, testar, medir e documentar o módulo.
8.  Só depois expandir para os outros subsistemas.
9.  Clonar separadamente a árvore FreeBSD completa para estudar `bsdinstall` e `
    release/` com proveniência Git.

## 14\. Validações executadas

- `git status --short`;
- `git diff --cached --name-status`;
- `git diff --name-status`;
- contagem de arquivos não rastreados;
- `git diff --stat`, `\--numstat` e `\--summary`;
- inventário de arquivos Markdown e fontes;
- `bash -n` em 18 scripts Shell;
- análise AST dos três módulos Python;
- inspeção dos `Kconfig`, `Makefile`, módulos C, scripts e módulos do instalador;
- inspeção da versão nas árvores Linux;
- verificação da presença de `bsdinstall` e `release/` nos recortes FreeBSD.

## 15\. Limitações

- QML não foi carregado por Calamares ou por um runtime Qt.
- O NitroCore não foi compilado.
- Os scripts que modificam sistema, ZFS, GRUB ou pacotes não foram executados.
- A ISO não foi iniciada.
- Nenhuma instalação foi realizada.
- Nenhuma afirmação de desempenho foi confirmada.
