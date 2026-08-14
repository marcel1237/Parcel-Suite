# Registro de Progresso: Parcel Play OS

Este arquivo documenta as ações realizadas durante o desenvolvimento do projeto.

## Regra de Documentação
- **Obrigatório**: Toda análise, decisão técnica, comando executado, alteração de código, teste e resultado relacionado ao Parcel Play OS deve ser registrado em um arquivo Markdown (`.md`).
- **Rastreabilidade**: Os registros devem distinguir explicitamente entre funcionalidade planejada, protótipo, implementação real, teste executado e resultado confirmado.
- **Segurança**: Funcionalidades não devem ser descritas como implementadas quando existirem somente como comentários, placeholders ou documentação conceitual.

## [2026-08-13] - Compatibilidade e Possível União de Kernels em C
- **Ação**: Análise conceitual e documental da compatibilidade entre as onze opções da mídia; nenhum kernel foi unido, alterado ou compilado.
- **Conclusão Linux**: Os oito perfis Linux são o grupo tecnicamente mais compatível. A solução recomendada é uma única árvore Linux/Ubuntu Resolute com patches comuns e configurações por flavor, produzindo kernel, módulos e initramfs separados.
- **Conclusão BSD**: NetBSD e OpenBSD são o par BSD historicamente mais próximo porque o OpenBSD derivou do NetBSD em 1995, mas suas ABIs, APIs internas e módulos atuais não são intercambiáveis.
- **Limite da Linguagem C**: Compartilhar C permite portar código-fonte, mas não resolve diferenças em memória, escalonamento, interrupções, VFS, drivers, build, ABI ou licenciamento.
- **Decisão**: Não realizar fusão binária de kernels monolíticos. Para compartilhar tecnologia, usar porte de componentes com adaptadores, NetBSD rump em userspace ou virtualização quando dois kernels completos precisarem executar lado a lado.
- **Live ISO**: O menu continuará iniciando somente um kernel/sistema por vez. A análise não altera a arquitetura multi-OS já definida.
- **Licenças**: Todo reaproveitamento será auditado por arquivo; avisos BSD e obrigações GPL/SPDX devem ser preservados.
- **Documento Técnico**: Matriz de proximidade, riscos, arquiteturas viáveis e critérios de protótipo em C adicionados a `LIVE_ISO_11_KERNELS.md`.

## [2026-08-13] - Ubuntu Anfitrião com Dez Kernels Convidados
- **Ação**: Estudo de uma arquitetura na qual o kernel Ubuntu Resolute mantém GNOME/KDE e executa as outras dez opções sob demanda; nenhuma VM foi iniciada e nenhum pacote foi instalado.
- **Decisão**: Usar KVM/QEMU para kernels completos e NetBSD rump somente quando um componente puder funcionar como serviço em userspace. Containers foram descartados para comprovação dos kernels porque compartilham o kernel anfitrião.
- **Economia**: Manter zero convidados no boot, iniciar normalmente somente um por vez, usar uma vCPU, console serial, rootfs mínimo somente leitura e overlay descartável. Desktops permanecem exclusivamente no anfitrião.
- **Linux**: Os sete flavors NitroCore poderão usar boot direto por kernel/initramfs e uma imagem base mínima compatível, preservando módulos próprios de cada versão.
- **BSD**: FreeBSD, NetBSD e OpenBSD usarão VMs e userspaces nativos; NetBSD poderá adicionalmente fornecer serviços rump.
- **C**: Planejado um orquestrador pequeno para processos QEMU/QMP, manifestos fixos e limites de recursos; não será criado um hipervisor novo nem serão montados argumentos por shell.
- **Auditoria Local**: `lscpu` confirmou x86_64, Ryzen 3 7320U, 8 CPUs lógicas e AMD-V. `free -h` mostrou 5,1 GiB totais, cerca de 943 MiB disponíveis durante a inspeção e swap em uso. `/dev/kvm` não estava presente.
- **Limite**: Dez VMs simultâneas estão fora do MVP e não são adequadas ao equipamento inspecionado; os valores de 128–512 MiB são apenas pontos iniciais a validar por convidado.
- **Documento Técnico**: Arquitetura, orçamento, segurança, fases e critérios de aceite adicionados a `LIVE_ISO_11_KERNELS.md`.

## [2026-08-13] - Identificação da Live e Instalador Mais Prontos
- **Ação**: Comparação do estado documentado das onze opções, dos instaladores nativos e da ISO híbrida; nenhum build ou teste foi executado.
- **Resultado**: A opção mais pronta para o objetivo do projeto é a ISO Ubuntu Resolute Desktop remasterizada, usando o kernel Ubuntu oficial e preservando o Ubuntu Desktop Installer/Subiquity.
- **Motivo**: A base oficial já integra boot BIOS/UEFI, Secure Boot, Casper, SquashFS, GNOME/GDM, kernel, firmware e instalador. A mudança mínima é acrescentar `kde-full` e validar a instalação do sistema modificado.
- **Limite**: A solução está mais pronta apenas em termos de base e procedimento. Nenhuma ISO Parcel foi produzida, KDE Full não foi incorporado e Subiquity ainda não foi testado com o novo payload.
- **Prioridade**: Concluir e testar esse baseline antes de integrar os sete NitroCore Linux e os três BSDs.
- **Documento Técnico**: Classificação de prontidão e próximo marco registrados em `LIVE_ISO_11_KERNELS.md`.

## [2026-08-13] - Execução do Baseline Resolute
- **Ação**: Início efetivo do baseline Ubuntu Resolute Desktop; foram criadas somente áreas novas sob `build/resolute-mvp/`, preservando os arquivos e alterações preexistentes.
- **Download**: Obtida a ISO oficial amd64 do build de 2026-08-11, com aproximadamente 5,84 GiB, além de `SHA256SUMS` e `SHA256SUMS.gpg`.
- **Integridade**: `sha256sum -c` retornou `resolute-desktop-amd64.iso: OK`.
- **Assinatura**: A assinatura retornou `Good signature` com a Ubuntu CD Image Automatic Signing Key (2012), fingerprint `8439 38DF 228D 22F7 B374 2BC0 D94A A3F0 EFE2 1092`, importada em keyring isolado do build.
- **Extração**: A árvore completa foi extraída em `build/resolute-mvp/work/iso-tree/`; o original possui boot híbrido BIOS/UEFI, MBR/GPT e GRUB.
- **Descoberta**: O payload usa `fsimage-layered`. Desktop completo combina `minimal.squashfs`, `minimal.standard.squashfs` e uma camada Live; editar somente a camada Live não instalaria KDE no disco.
- **Bloqueio Administrativo**: `sudo -n true` confirmou exigência de autenticação interativa. `fakeroot` não substitui chroot/mounts privilegiados e o user namespace falhou ao mapear UID 0. Nenhum pacote foi copiado de forma incompleta.
- **Bloqueio de Teste**: QEMU não está instalado e, na auditoria, `/dev/kvm` estava ausente.
- **Estado**: A ISO Parcel ainda não foi gerada; KDE Full, recomposição das camadas, rebuild e testes permanecem pendentes.
- **Higiene do Git**: Criado `.gitignore` com `/build/` para evitar versionar a ISO oficial e a cópia extraída, mantendo os artefatos locais disponíveis para continuação.
- **Documento Técnico**: Log completo, caminhos, resultados e continuação segura registrados em `BUILD_RESOLUTE_MVP.md`.

## [2026-08-13] - Primeiro Protótipo do Seletor GRUB de Onze Opções
- **Ação**: Criada configuração GRUB versionável, preparador idempotente, contrato de payload e ISO real de protótipo.
- **Menu**: Onze posições numeradas. Ubuntu é padrão e única com payload real; sete NitroCore e três BSDs informam indisponibilidade sem simular boot.
- **Linux**: Cada NitroCore exige `vmlinuz` e `initrd` próprios em `/parcel/linux/FLAVOR/`.
- **BSD**: Cada BSD possui caminho de loader sob `/EFI/parcel/`; o protótipo BSD é UEFI-only e nenhum loader foi adicionado.
- **Recuperação**: Adicionado submenu com Ubuntu `nomodeset`, próximo volume e configurações UEFI.
- **Loopback**: O mesmo seletor acrescenta `iso-scan/filename` quando `iso_path` existir.
- **ISO**: Gerado `build/resolute-mvp/output/parcel-play-11-menu-prototype-amd64.iso`, 6.279.266.304 bytes, SHA-256 `44a1ca2c3c239b0b87747c8372daee7d50c1a8d043644a1a5b0666516b95ec5d`.
- **Boot Preservado**: Confirmados El Torito BIOS/UEFI, MBR protetivo, GPT, GRUB e imagem EFI anexada.
- **Validação**: Aprovados `sh -n`, `grub-script-check`, onze posições, kernel/initrd Ubuntu e comparação dos menus reextraídos.
- **Limite**: QEMU não está instalado; nenhum boot foi observado. Os dez payloads, KDE Full, instalador modificado e Secure Boot continuam sem teste.
- **Documentação**: Implementação e estado adicionados a `LIVE_ISO_11_KERNELS.md` e `BUILD_RESOLUTE_MVP.md`.

## [2026-08-13] - Auditoria do Repositório de Kernel Resolute
- **Ação**: Inspeção somente leitura do clone localizado em `/home/marcel/Parcel Suite/resolute`; nenhum arquivo do kernel foi alterado e nenhuma compilação foi iniciada.
- **Confirmado**: O remoto configurado é `https://git.launchpad.net/~ubuntu-kernel/ubuntu/+source/linux/+git/resolute`.
- **Confirmado**: O clone está no branch `master`, no commit `74134bfb6`, e foi criado como clone superficial (`shallow`).
- **Problema**: Apesar do nome do repositório, o conteúdo atualmente obtido corresponde ao Ubuntu Noble: o `debian.master/changelog` inicia em `linux (6.8.0-30.30) noble`.
- **Problema**: Somente `origin/master` foi trazido para o clone local; o branch de desenvolvimento Resolute `master-next` ainda não foi buscado nem selecionado.
- **Bloqueio de Build**: O caminho `/home/marcel/Parcel Suite/resolute` contém espaços. O Makefile do Linux rejeita diretórios-fonte com espaços ou dois-pontos, portanto essa localização não é compilável.
- **Estado**: A árvore Git estava limpa durante a auditoria, ocupava aproximadamente `1,8 GB` e ainda não continha sabor, configuração ou patches NitroCore.
- **Próximo Passo Proposto**: Buscar `origin/master-next`, mudar para esse branch, mover a árvore para um caminho sem espaços (por exemplo, `/home/marcel/parcel-kernel/resolute`) e validar branch, changelog e `make kernelversion` antes de qualquer otimização.

## [2026-08-13] - Estudo da Live ISO Resolute com GNOME e KDE Full
- **Ação**: Verificação do caminho mais rápido e simples para criar uma imagem Live amd64 do Resolute com GNOME e KDE Full; nenhuma ISO foi criada e nenhum pacote foi instalado nesta etapa.
- **Decisão**: Para o primeiro protótipo, remasterizar a ISO Desktop oficial do Resolute, que já contém GNOME, GDM, `casper`, boot BIOS/UEFI e instalador, adicionando somente o metapacote `kde-full`.
- **Decisão**: Manter o GDM como display manager padrão para disponibilizar GNOME e Plasma no mesmo seletor de sessão.
- **Planejado**: Migrar posteriormente para `livecd-rootfs`, permitindo builds automatizados e reproduzíveis.
- **Confirmado**: O host utiliza Ubuntu 26.04 LTS amd64; `kde-full` está disponível no Resolute e as ferramentas `xorriso` e `squashfs-tools` já estão instaladas.
- **Limitação**: A imagem oficial observada já possui aproximadamente `6,1 GB`; com KDE Full, o resultado deve ser tratado como Live USB e não como CD físico.
- **Documento Técnico**: Procedimento, fontes, riscos, alternativas e critérios de teste registrados em `LIVE_CD_RESOLUTE.md`.

## [2026-08-13] - Seleção do Instalador Mínimo da Live ISO
- **Ação**: Comparação de Subiquity, Calamares, Anaconda e archinstall para instalar a Live ISO Resolute com GNOME e KDE Full; nenhuma instalação em disco foi executada.
- **Decisão**: Preservar no MVP o Ubuntu Desktop Installer existente na ISO oficial, utilizando seu backend Subiquity.
- **Motivo**: É a alternativa nativa do Resolute e exige menos integração para particionamento, payload offline, usuário e bootloader.
- **Calamares**: Mantido como experimento futuro independente; o pacote está disponível no Resolute, mas os protótipos atuais não possuem `settings.conf`, configuração de payload ou fluxo completo de instalação.
- **Anaconda**: Descartado para o MVP por sua integração principal com RPM/DNF e árvore de instalação Fedora/RHEL.
- **archinstall**: Descartado como backend porque é uma biblioteca para instalar Arch Linux; mantido apenas como referência de logs e configuração declarativa.
- **Correção Documental**: Removida de `ESTRATEGIA_INSTALADOR.md` a afirmação de que uma fusão Calamares/Subiquity estava consolidada.
- **Documento Técnico**: Requisitos mínimos, matriz comparativa, testes e fases registrados em `INSTALADOR.md`.

## [2026-08-13] - Plymouth e Inclusão do Kernel Ubuntu
- **Ação**: Verificação do mecanismo Plymouth no Ubuntu Resolute e da seleção de splash depois do GRUB; nenhuma imagem foi criada e nenhum initramfs foi alterado.
- **Confirmado**: O tema Plymouth é incorporado ao initramfs e precisa estar disponível antes da montagem do sistema raiz.
- **Decisão**: Cada entrada futura do GRUB usará um par kernel/initramfs próprio, permitindo incorporar uma splash específica e evitando depender de um parâmetro de tema não documentado.
- **Alteração Documental**: O kernel oficial Ubuntu foi adicionado a `kernel.md` como décimo primeiro perfil, baseline, opção padrão inicial e fallback de recuperação.
- **Correção Documental**: `ARQUITETURA_BOOT.md` passou a descrever onze entradas planejadas, initramfs separados e estado ainda não validado.
- **Escopo MVP**: A primeira Live ISO terá apenas o kernel Ubuntu e o tema `parcel-ubuntu`; entradas NitroCore não serão simuladas antes da existência dos respectivos binários.
- **Documento Técnico**: Mapeamento de boot e identidade visual consolidado em `LIVE_ISO_11_KERNELS.md`.
- **Requisito Corrigido Posteriormente**: Plymouth e initramfs próprios aplicam-se às oito opções Linux; os três BSDs usam mecanismos nativos.
- **Correção Técnica**: Registrado em `kernel.md` que `plymouth-set-default-theme -R` configura um tema global e não deve ser repetido sem controle para gerar onze initramfs; cada versão será regenerada, copiada e validada individualmente.
- **Critério de Aceite**: Um kernel somente será marcado como pronto após validação do tema com `lsinitramfs` e teste visual completo em máquina virtual.
- **Variação Confirmada no Resolute**: O host não fornece `plymouth-set-default-theme`; a seleção existente usa `update-alternatives`, enquanto `update-initramfs` é fornecido pelo Dracut 110.
- **Documentação Corrigida**: `kernel.md` agora apresenta os dois fluxos e exige detecção da ferramenta disponível, evitando copiar comandos de outra distribuição sem validação.

## [2026-08-13] - Auditoria dos Procedimentos para 11 Kernels na Live ISO
- **Ação**: Auditoria somente leitura da documentação, scripts e artefatos disponíveis para verificar a prontidão dos onze kernels; nenhum kernel foi compilado e nenhuma ISO foi alterada.
- **Resultado**: Os procedimentos ainda não estão prontos para execução completa. Plymouth e o vínculo GRUB/kernel/initramfs estão documentados, mas faltam configurações, ABI, pacotes, módulos no rootfs, integração Casper, firmware, assinatura e testes.
- **Ubuntu Oficial**: Único kernel utilizável no primeiro protótipo, ainda sujeito a teste após a remasterização.
- **NitroCore**: Dez perfis permanecem bloqueados por ausência de configurações, patches versionados, pacotes de imagem/módulos e initramfs reais.
- **Correção Técnica**: Registrado que copiar apenas `vmlinuz` e initramfs para `casper/` é insuficiente; o SquashFS precisa conter `/lib/modules/VERSAO` e os pacotes correspondentes.
- **Modelo de Fonte**: Recomendado usar uma revisão fixada do empacotamento Ubuntu Resolute como base comum dos sete NitroCore Linux, mantendo Ubuntu como fallback; os três BSDs usam fontes e payloads nativos.
- **Secure Boot**: Classificado como bloqueado para NitroCore até existir gestão de chaves, assinatura de kernel/módulos e integração shim/MOK testada.
- **Recursos**: O host possui menos RAM que os 8 GB recomendados pela Canonical; builds devem ser sequenciais e com paralelismo limitado.
- **Documento Técnico**: Matriz de prontidão e procedimento comum de nove etapas adicionados a `kernel.md`.

## [2026-08-13] - Definição da Live ISO Única com Seletor de 11 Kernels
- **Requisito Confirmado**: O projeto terá uma única mídia cujo menu seleciona uma de onze opções antes da inicialização.
- **Fluxo Corrigido Posteriormente**: Oito opções Linux usam kernel/initramfs/Plymouth e rootfs Ubuntu; três BSDs usam boot e userspaces próprios.
- **Correção Técnica**: O ambiente gráfico não é normalmente desempacotado por completo a cada boot; as camadas SquashFS são montadas como somente leitura e combinadas com OverlayFS gravável em RAM.
- **Contrato Comum Linux**: Somente os oito kernels Linux montam as mesmas camadas e encontram `/lib/modules/$(uname -r)` no rootfs Ubuntu.
- **Fallback**: Ubuntu Oficial permanecerá como primeira opção e recuperação caso um NitroCore não consiga iniciar a Live.
- **Política Pendente**: A escolha do kernel para a sessão Live não define automaticamente quais kernels serão instalados no disco; essa política será decidida e testada separadamente.
- **Documentação Atualizada**: Fluxo, layout da mídia, responsabilidades, recuperação e critérios registrados em `LIVE_ISO_11_KERNELS.md`, `ARQUITETURA_BOOT.md` e `kernel.md`.
- **Organização Documental**: A arquitetura multi-kernel foi removida de `LIVE_CD_RESOLUTE.md` e consolidada em `LIVE_ISO_11_KERNELS.md`; o documento Resolute voltou a tratar somente do MVP com kernel Ubuntu.

## [2026-08-13] - Verificação de FreeBSD, NetBSD e OpenBSD Reais
- **Ação**: Pesquisa técnica sobre a inclusão dos três BSDs como sistemas reais na mesma mídia; nenhum artefato BSD foi baixado ou executado.
- **Conclusão**: Kernels BSD não podem substituir diretamente o Linux no fluxo Casper nem iniciar o rootfs Ubuntu com `ubuntu-desktop` e `kde-full`, devido a ABI, syscalls, drivers, boot e userspace diferentes.
- **Arquitetura Corrigida**: A mídia passa a ser multi-OS: oito opções Linux compartilham o rootfs Ubuntu; FreeBSD, NetBSD e OpenBSD usam payloads e bootloaders próprios.
- **FreeBSD**: Exige loader, kernel, módulos e rootfs FreeBSD; Linuxulator funciona no sentido FreeBSD hospedando parte de um userland Linux.
- **NetBSD**: Exige kernel, sets e imagem nativa; rump kernels são serviços em userspace e não substituem o kernel Linux no GRUB.
- **OpenBSD**: O mínimo oficial é o ramdisk kernel `bsd.rd` para instalação/recuperação; não existe promessa de Live GNOME/KDE no MVP.
- **Plymouth**: Restrito às oito entradas Linux. Os BSDs usarão branding e telas de boot nativos.
- **Risco**: Suporte direto do GRUB varia por firmware; bootloaders EFI nativos devem ser priorizados e testados, especialmente porque a documentação OpenBSD alerta sobre falhas frequentes com GRUB.
- **Documentação Atualizada**: Decisão, alternativas, payloads mínimos, fluxo e testes registrados em `LIVE_ISO_11_KERNELS.md` e `kernel.md`.

## [2026-08-13] - Live e Instaladores Nativos dos Três BSDs
- **Ação**: Pesquisa dos procedimentos oficiais para mídia Live/instalação de FreeBSD, NetBSD e OpenBSD; nenhum download, build ou particionamento foi realizado.
- **Decisão MVP**: Integrar primeiro ambientes oficiais de instalação/recuperação, sem exigir desktop gráfico BSD.
- **FreeBSD**: Usar como baseline `disc1.iso` ou `memstick.img`, validar Live de terminal e instalação offline com `bsdinstall`; o modo Live oficial não possui GUI.
- **NetBSD**: Usar imagem oficial ou build amd64 por `build.sh` com `release` e `iso-image`/`install-image`; instalar por `sysinst`.
- **OpenBSD**: Usar `installXX.iso`/`.img` e `bsd.rd`; validar sets e assinaturas com `signify`; o ramdisk é instalador/recuperação, não Live desktop.
- **Menu de Boot**: Recomendado protótipo UEFI com menu EFI principal e chainload dos bootloaders BSD nativos; GRUB permanece no ramo Linux.
- **Instaladores**: Não haverá backend único no MVP. Subiquity, `bsdinstall`, `sysinst` e instalador OpenBSD permanecem isolados.
- **Segurança**: Primeiros testes de instalação usarão discos virtuais vazios e exclusivos, sem multiboot instalado.
- **Documento Técnico**: Procedimentos por sistema, artefatos, fases, limitações e critérios de aceite adicionados a `LIVE_ISO_11_KERNELS.md`.

## [2026-08-13] - Análise e Estruturação Inicial
- **Ação**: Análise do diretório do projeto e identificação do propósito (Criação de um OS).
- **Ação**: Pesquisa no sistema de arquivos do usuário para localizar tecnologias complementares (Thunder SDK, Parcel Suite).
- **Ação**: Auditoria do Thunder SDK identificando pontos críticos de segurança e performance.
- **Ação**: Análise profunda do código-fonte do **Connectiva Linux 4** como referência histórica e estrutural.
- **Ação**: Mapeamento das 8 etapas de construção de um OS baseadas no modelo da Connectiva.
- **Ação**: Consolidação do plano estratégico e migração de documentos para a raiz do projeto.
- **Ação**: Criação do `RESUMO_DO_CHAT.md` para síntese das discussões.
- **Ação**: Expansão do `DETALHAMENTO_TECNICO.md` para cobrir todas as 8 etapas de construção do OS.
- **Ação**: Criação da `ARQUITETURA_PERFORMANCE.md` detalhando NitroCore, OmniLock e Dark Volt.
- **Ação**: Definição do **Ubuntu 26** como distribuição base do sistema.
- **Ação**: Criação do `GESTAO_PACOTES.md` detalhando o **Parcel Software Center** (APT, Snap, Flatpak).
- **Ação**: Atualização de todos os documentos estratégicos para refletir a compatibilidade total e a base Ubuntu 26.
- **Ação**: Implementação da estratégia de **"Divórcio do Kernel"**: Uso do Kernel Vanilla transparente em vez do kernel do Ubuntu.
- **Ação**: Criação do `TRANSPARENCIA_KERNEL.md` para documentar referências de Arch, openSUSE e BSD.
- **Ação**: Pesquisa extensiva e catalogação de links de kernels de diversas distribuições (Ubuntu, Debian, Fedora, NixOS, Void, etc.).
- **Ação**: Verificação de links e correção da documentação: O link do kernel Ubuntu no GitHub foi identificado como não funcional e substituído pelos links oficiais do **Launchpad**.
- **Ação**: Inclusão dos repositórios oficiais do kernel **Fedora** (GitLab ARK e Dist-Git) na documentação de transparência.
- **Ação**: Consolidação do `TRANSPARENCIA_KERNEL.md` com links 100% verificados e funcionais.
- **Ação**: Definição dos **9 Pilares de Referência** para o kernel NitroCore: Slackware, Debian, FreeBSD, NetBSD, openSUSE, Arch Linux, Fedora, Gentoo e Clear Linux.
- **Ação**: Identificação do status do **Clear Linux** (arquivado pela Intel) e adoção do **CachyOS** como referência moderna de performance.
- **Ação**: Inclusão do **NetBSD** como referência de portabilidade universal mantida desde 1993.
- **Ação**: Reconfiguração dos pilares para o **Octógono de Referência**: Remoção de Slackware e Clear Linux; inclusão do **OpenBSD** para reforçar a segurança extrema.
- **Ação**: Consolidação da documentação na raiz para refletir o novo grupo de 8 sistemas de elite.
- **Ação**: Pesquisa e localização dos kernels enterprise: **CentOS Stream** (GitLab) e **Oracle Linux UEK** (GitHub).
- **Ação**: Verificação técnica do kernel do **Slackware**: Confirmado o uso do kernel **6.18.44 Vanilla** (versão Current) sem patches externos.
- **Ação**: Criação da `MATRIZ_QUALIDADE.md` detalhando as heranças técnicas do Octógono (OpenBSD, FreeBSD, etc.).
- **Ação**: Criação da `COMPATIBILIDADE_UNIVERSAL.md` com a estratégia para unificar Windows, Android e Linux.
- **Ação**: Início da execução técnica com a criação da pasta `scripts/`.
- **Ação**: Implementação dos primeiros scripts de build: `build_os.sh`, `01-bootstrap-toolchain.sh`, `02-build-nitrocore.sh` e `03-setup-fhs.sh`.
- **Ação**: Criação e enriquecimento dos documentos `INSTALADOR.md`, `MATRIZ_QUALIDADE.md` e `COMPATIBILIDADE_UNIVERSAL.md` com detalhes técnicos de arquitetura e design.
- **Ação**: Implementação do tema **Dark Kubuntu** (Breeze Dark) para o instalador.
- **Ação**: Criação do protótipo de interface em QML (`show.qml`) e do módulo Python `thunder_setup`.
- **Ação**: Implementação do módulo `universal_compat` para automação da instalação de Snaps, Flatpaks, Waydroid e Wine/Proton.
- **Ação**: Desenvolvimento da interface gráfica **Decágono Selector** em QML/Kirigami, categorizando os 10 kernels em Performance, Enterprise e Segurança.
- **Ação**: Implementação da tela **Session Selector** (Gnome Basic vs KDE Full) com design imersivo em Kirigami.
- **Ação**: Criação da `MATRIZ_INSTALACAO.md` definindo os metapackages `ubuntu-desktop` e `kde-full` para Ubuntu 26.
- **Ação**: Integração da lógica de instalação de desktop no módulo Python `universal_compat`.
- **Ação**: Atualização da Etapa 7 no `DETALHAMENTO_TECNICO.md` para refletir a instalação dinâmica de interfaces.
- **Ação**: Integração das escolhas de sessão e kernel com o `globalStorage` do Calamares.
- **Ação**: Ativação da tecnologia **Dark Volt**: Criação do `DARK_VOLT.md` e dos protótipos de serviço e configuração em `scripts/`.
- **Restrição**: Tecnologia **Dark Volt** colocada em estado de "Hold" (Em espera). Não será integrada ao boot sem aprovação explícita.
- **Ação**: Implementação do script `kde-thunder-optim.sh` para aceleração profunda da Sessão Full (KDE) via Vulkan e UDMABUF.
- **Ação**: Atualização da `ARQUITETURA_PERFORMANCE.md` para incluir a aceleração de interface Qt 6.
- **Ação**: Implementação da arquitetura **Anykernel (NetBSD style)** via Rump Kernels para portabilidade universal.
- **Ação**: Desenvolvimento do conceito do **Thunder Browser** nativo para o ambiente EGLFS.
- **Ação**: Criação de scripts de otimização de performance para o motor Chromium.
- **Ação**: Integração do seletor com o `globalStorage` do Calamares para salvar o sabor NitroCore escolhido.
- **Ação**: Criação da `ESTRATEGIA_INSTALADOR.md` detalhando a fusão Calamares (Frontend) + Subiquity (Backend).
- **Ação**: Definição do **Decágono de Referência**: Adição de CentOS Stream e Oracle Linux UEK como pilares de infraestrutura e performance enterprise.
- **Ação**: Atualização de todos os documentos para os **10 Sabores do NitroCore** e seletor de instalação expandido.
- **Ação**: Criação da `ARQUITETURA_BOOT.md` detalhando o menu GRUB do Live CD com os 10 kernels e a transição via `kexec`.
- **Ação**: Configuração do sabor **Debian** como a opção padrão (default) no menu de boot do Live CD.
- **Ação**: Início da **Fase de Compilação Real**: O usuário clonou o código-fonte do kernel Ubuntu em `~/Parcel Suite/resolute` e iniciou a instalação das dependências de build.

## Status Atual
- **Fase**: Construção do Protótipo do Kernel (NitroCore).
- **Próximo Objetivo**: Configurar o `.config` do kernel com as otimizações do Decágono e realizar a compilação.
