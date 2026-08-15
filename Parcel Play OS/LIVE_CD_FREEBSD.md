# Verificação para um Live CD do FreeBSD

**Data da auditoria:** 15 de agosto de 2026

## 1. Objetivo

Definir um caminho verificável para criar ou integrar um ambiente Live FreeBSD no Parcel Play OS, após analisar todos os arquivos Markdown do projeto e confrontar suas afirmações com a documentação oficial atual.

Esta análise separa três produtos:

1. **Live oficial de terminal:** já existe na mídia oficial FreeBSD.
2. **Live gráfico personalizado:** precisa ser construído como distribuição FreeBSD própria.
3. **Entrada na ISO híbrida Parcel:** exige integrar boot e payload FreeBSD sem usar o rootfs Ubuntu.

Nenhuma ISO FreeBSD foi baixada, alterada ou iniciada nesta etapa. Nenhum disco foi particionado.

## 2. Conclusão executiva

A recomendação é começar pelo **FreeBSD 15.1-RELEASE amd64 `disc1.iso`**, sem modificações, e validar checksum, boot BIOS/UEFI, Live de terminal, rede, armazenamento virtual, instalação offline com `bsdinstall` e reboot no sistema instalado.

Somente depois deve ser iniciada uma imagem gráfica personalizada ou a integração multi-OS. O `disc1.iso` atual possui aproximadamente 1,35 GB e não cabe em CD-R de 700 MB. Apesar do nome histórico, deve ser tratado como **Live ISO para DVD, USB ou VM**.

## 3. Estado oficial atual

### 3.1 Release e imagens

Na data desta auditoria, a release de produção mais recente é o FreeBSD 15.1-RELEASE, publicado em 16 de junho de 2026.

| Imagem amd64 | Tamanho oficial | Uso |
| --- | ---: | --- |
| `bootonly.iso` | 546.666.496 bytes | Instalador mínimo; depende de rede |
| `disc1.iso` | 1.352.255.488 bytes | Instalação offline e Live de terminal |
| `dvd1.iso` | 4.605.024.256 bytes | Instalação mais pacotes binários populares |
| `memstick.img` | 1.552.601.600 bytes | Imagem completa para USB |
| `mini-memstick.img` | 678.842.880 bytes | USB mínimo; depende de rede |

Fontes:

- <https://www.freebsd.org/releases/>
- <https://download.freebsd.org/releases/amd64/amd64/ISO-IMAGES/15.1/>

Para o primeiro Live e instalador offline, `disc1.iso` é o baseline recomendado. Para pendrive físico, `memstick.img` é o formato apropriado. O `dvd1.iso` inclui alguns pacotes, mas não se deve presumir que contenha exatamente todo o Plasma ou GNOME desejado.

### 3.2 Modo Live oficial

O menu do `bsdinstall` oferece Install, Shell e Live CD. O Live:

- inicia FreeBSD real;
- fornece prompt de comandos;
- usa usuário `root` com senha vazia;
- executa diretamente da mídia;
- **não possui interface gráfica**.

Fonte: <https://docs.freebsd.org/en/books/handbook/bsdinstall/#using-live-cd>.

## 4. Auditoria dos 23 arquivos Markdown

| Documento | Relação com o Live FreeBSD | Resultado |
| --- | --- | --- |
| `ANALISE_PROJETO_2026-08-15.md` | Estado geral | Correto: payload BSD ausente |
| `ARQUITETURA_BOOT.md` | Menu híbrido | Princípio correto; chainload não testado |
| `ARQUITETURA_PERFORMANCE.md` | Otimizações Linux/Qt | Não se aplica automaticamente ao FreeBSD |
| `BUILD_RESOLUTE_MVP.md` | ISO Ubuntu | Útil apenas ao ramo Linux |
| `COMPARACAO_OPENBSD_FREEBSD.md` | Contexto FreeBSD | Coerente; não era procedimento de Live |
| `COMPATIBILIDADE_UNIVERSAL.md` | Camadas Linux | Proton/Waydroid não podem ser prometidos no FreeBSD |
| `DARK_VOLT.md` | Login EGLFS | Não implementado nem portado para FreeBSD |
| `DETALHAMENTO_TECNICO.md` | Build e Live | Desatualizado: mistura RPM, Calamares e Ubuntu |
| `ESTRATEGIA_INSTALADOR.md` | Subiquity | Não se aplica; `bsdinstall` deve permanecer separado |
| `GESTAO_PACOTES.md` | APT/Snap/Flatpak | FreeBSD usa `pkg` e Ports |
| `INSTALADOR.md` | Instaladores Linux | Não deve controlar instalação FreeBSD |
| `LIVE_CD_RESOLUTE.md` | Live Ubuntu | Deve permanecer isolado do FreeBSD |
| `LIVE_ISO_11_KERNELS.md` | Especificação multi-OS | Principal referência; loader ainda é hipótese |
| `MATRIZ_INSTALACAO.md` | Metapacotes Ubuntu | `kde-full` e `ubuntu-desktop` não servem ao FreeBSD |
| `MATRIZ_QUALIDADE.md` | Inspiração FreeBSD | Alegações não validadas; XDP/eBPF são mecanismos Linux |
| `Modos de login.md` | Sessões gráficas | Só vale para o ramo Ubuntu atual |
| `PLAN_ESTRATEGICO.md` | Visão | FreeBSD é referência, não base já integrada |
| `PORTABILIDADE_NETBSD.md` | Rump kernels | Não se aplica à mídia FreeBSD |
| `PROGRESSO.md` | Histórico | Entradas recentes refletem o estado real |
| `RESUMO_DO_CHAT.md` | Decisões antigas | Desatualizado: dez kernels, Debian padrão, kexec e instalador híbrido |
| `THUNDER_BROWSER.md` | Browser EGLFS | Conceitual; nenhuma build FreeBSD |
| `TRANSPARENCIA_KERNEL.md` | Fonte FreeBSD | Correto: árvore oficial clonável |
| `kernel.md` | Contrato multi-OS | Correto ao separar FreeBSD de Plymouth/Casper |

### 4.1 Convergência correta

Os documentos recentes concordam que:

1. FreeBSD é sistema completo, não flavor NitroCore.
2. Não monta o SquashFS Ubuntu/Casper como raiz.
3. Não usa Plymouth, initramfs Ubuntu ou Subiquity.
4. O instalador deve ser `bsdinstall`.
5. Um desktop precisa de pacotes e configuração FreeBSD próprios.

### 4.2 Contradições a desconsiderar

- `RESUMO_DO_CHAT.md` registra decisões substituídas.
- `DETALHAMENTO_TECNICO.md` mistura RPM/DNF, Calamares e Ubuntu/APT.
- `MATRIZ_QUALIDADE.md` chama conceitos de implementados/validados.
- Documentos de performance afirmam integrações ausentes do repositório.
- “Todos os kernels usam GNOME/KDE” não vale para as entradas BSD.

Precedência recomendada para esse trabalho:

1. `LIVE_CD_FREEBSD.md`;
2. `LIVE_ISO_11_KERNELS.md`;
3. `ARQUITETURA_BOOT.md`;
4. `kernel.md`;
5. `PROGRESSO.md`.

## 5. Ambiente local

### Disponível

- `xorriso`, `7z` e `sha256sum`;
- aproximadamente 129 GiB livres durante a inspeção.

### Ausente

- `qemu-system-x86_64`;
- `bsdtar` e `signify` no `PATH`;
- imagem FreeBSD oficial;
- payload FreeBSD na árvore da ISO Parcel;
- script de build e configuração de desktop FreeBSD.

É possível baixar e validar SHA-256, mas não aprovar boot ou instalação. A integração não deve começar antes do teste isolado.

## 6. Estratégia em três fases

### Fase A — Live oficial isolado

1. Baixar `FreeBSD-15.1-RELEASE-amd64-disc1.iso`.
2. Baixar o manifesto SHA-256 da mesma pasta.
3. Validar a linha exata da imagem.
4. Registrar tamanho, hash, URL e data.
5. Instalar QEMU/OVMF ou usar máquina separada.
6. Iniciar a ISO original em BIOS e UEFI.
7. Entrar no Live CD e registrar versão, `dmesg`, discos e interfaces.
8. Executar `bsdinstall` em disco virtual vazio.
9. Reiniciar sem a ISO e confirmar o sistema instalado.

Critério: Live terminal e instalação offline aprovados.

### Fase B — Live gráfico independente

O build deve ocorrer preferencialmente dentro do FreeBSD 15.1, usando:

```text
https://git.FreeBSD.org/src.git
/usr/src/release/release.sh
/usr/src/release/release.conf.sample
```

A documentação oficial apresenta:

```bash
/bin/sh /usr/src/release/release.sh
```

e `release.sh -c` com arquivo de configuração. Isso exige ambiente FreeBSD, privilégios e espaço para construir world, kernel e mídias; não é comando para executar diretamente no host Ubuntu.

Fonte: <https://docs.freebsd.org/en/articles/freebsd-releng/#building-freebsd-installation-media>.

Componentes mínimos:

- kernel/world fixados em revisão;
- firmware;
- Xorg ou Wayland validado;
- um único desktop inicial, Plasma ou GNOME;
- display manager;
- usuário Live sem privilégio irrestrito;
- raiz somente leitura com escrita temporária ou imagem descartável;
- estratégia para `/tmp`, `/var`, home e caches;
- rede, DNS, shutdown e reboot;
- `bsdinstall` preservado;
- manifesto e licenças de pacotes.

Não reutilizar diretamente:

- `kde-full`, `ubuntu-desktop`, APT, Snap ou Waydroid;
- Casper, SquashFS/OverlayFS Ubuntu, initramfs ou Plymouth;
- Subiquity;
- scripts Thunder que forçam EGLFS/Vulkan;
- parâmetros do kernel Linux.

Critério: ISO FreeBSD isolada inicia desktop e instala em disco virtual vazio.

### Fase C — Integração Parcel

Copiar apenas `loader.efi` é insuficiente. O loader precisa localizar:

- `/boot/loader` e seus módulos;
- `/boot/kernel/kernel` e módulos `.ko`;
- configuração;
- rootfs Live;
- arquivos de distribuição e metadados do `bsdinstall`.

Também não está provado que extrair `disc1.iso` para uma subpasta preserve dispositivos e caminhos esperados.

Provas de conceito possíveis:

1. chainload UEFI com payload completo extraído;
2. partição/imagem FreeBSD dedicada;
3. múltiplas imagens El Torito;
4. menu EFI superior delegando para GRUB e FreeBSD.

Aninhar uma ISO como arquivo não significa que UEFI conseguirá iniciá-la.

Ordem:

1. inspecionar partições, El Torito e conteúdo original;
2. identificar ESP e `loader.efi`;
3. observar dispositivos enumerados pelo loader;
4. localizar rootfs, kernel, módulos e distribuições;
5. criar protótipo somente UEFI;
6. testar FreeBSD isoladamente nessa mídia;
7. instalar offline em disco virtual;
8. reativar as demais entradas;
9. tratar BIOS legado depois.

Critério: uma mídia inicia Ubuntu e FreeBSD independentemente, cada um com seu payload.

## 7. Estrutura proposta

```text
build/freebsd-live/
├── download/
├── inspect/
├── vm/
│   └── logs/
├── work/
└── output/

config/freebsd/
├── release.conf
├── loader.conf
├── rc.conf
└── packages.list

scripts/freebsd/
├── 01-fetch-verify.sh
├── 02-inspect-media.sh
├── 03-test-official-vm.sh
├── 04-build-live.sh
└── 05-test-live-vm.sh
```

Artefatos grandes permanecem sob `build/`, ignorado pelo Git. Scripts futuros não podem declarar sucesso com etapas comentadas.

## 8. Matriz mínima

| Teste | Estado |
| --- | --- |
| URL/release oficial | Verificado documentalmente |
| SHA-256 local | Não executado; ISO ausente |
| Boot BIOS/UEFI original | Não testado |
| Login Live | Confirmado na documentação; não testado |
| Disco e rede virtuais | Não testado |
| `bsdinstall` offline | Não testado |
| Reboot instalado | Não testado |
| Xorg/Wayland e desktop | Não implementado |
| Chainload híbrido | Não implementado |
| Secure Boot Parcel | Não definido |

## 9. Riscos

- loader não localizar rootfs após alteração do layout;
- reconstrução quebrar BIOS/UEFI;
- `bsdinstall` não encontrar distribuições;
- mistura de caminhos Ubuntu/FreeBSD;
- driver gráfico, Wi-Fi, áudio ou firmware ausente;
- desktop e integração multi-OS desenvolvidos simultaneamente;
- particionamento acidental de disco físico;
- conta Live root sem senha exposta por rede;
- mídia customizada não herdar confiança da mídia oficial.

Serviços de rede devem ficar desativados por padrão no Live, e os primeiros testes devem usar somente discos virtuais vazios.

## 10. Decisões recomendadas

1. Fixar FreeBSD 15.1-RELEASE amd64.
2. Usar `disc1.iso` como baseline offline.
3. Tratar Live CD como Live ISO/DVD/USB/VM.
4. Aprovar `bsdinstall` antes do desktop.
5. Construir o gráfico em ambiente FreeBSD.
6. Escolher somente um desktop inicial.
7. Não copiar `loader.efi` isoladamente.
8. Fazer primeira integração apenas UEFI.
9. Manter `bsdinstall` separado de Subiquity/Calamares.
10. Usar discos virtuais descartáveis.

## 11. Próximo marco

> Baixar e validar `FreeBSD-15.1-RELEASE-amd64-disc1.iso`, instalar QEMU/OVMF, iniciar a mídia oficial em UEFI, entrar no Live terminal e concluir uma instalação offline em disco virtual descartável.

Esse marco não cria ainda uma imagem Parcel, mas remove as principais incertezas sobre boot, loader, hardware virtual, `bsdinstall` e layout oficial.

## 12. Avaliação de Calamares e Anaconda

### 12.1 Critério correto de avaliação

Um instalador não é utilizável apenas porque sua interface abre. Para substituir `bsdinstall`, ele precisa concluir com segurança:

1. descoberta dos discos FreeBSD (`/dev/ada*`, `/dev/nvme*`, `/dev/da*`);
2. GPT e partições FreeBSD;
3. criação de UFS2 ou pool/root ZFS;
4. montagem do destino;
5. implantação de base, kernel, firmware e pacotes;
6. criação de usuário, senha, grupos e configuração de rede;
7. geração de `fstab`, `rc.conf`, `loader.conf` e arquivos ZFS;
8. instalação de `loader.efi` na ESP e boot BIOS quando suportado;
9. rollback ou falha segura;
10. reboot no sistema instalado.

O teste precisa ocorrer em disco virtual descartável. Não se deve testar um backend de particionamento experimental em disco físico.

### 12.2 Calamares no FreeBSD

#### O que está disponível

O FreeBSD Ports contém `sysutils/calamares`, atualmente na versão 3.3.14 para FreeBSD 15 amd64. Portanto, o frontend Qt/KDE pode ser instalado com:

```sh
pkg install calamares
```

Isso demonstra portabilidade da aplicação e de parte dos módulos, não um instalador FreeBSD pronto.

Fontes:

- <https://cgit.freebsd.org/ports/tree/sysutils/calamares>
- <https://www.freshports.org/sysutils/calamares/>

#### Bloqueio principal

O Calamares utiliza KPMCore para particionamento. O port FreeBSD de KPMCore registra que **não há backend FreeBSD funcional** e que é compilado um backend dummy. Assim, a tela pode existir sem conseguir realizar particionamento real e seguro.

Além disso, a descrição do pacote Calamares para FreeBSD informa que ele pode ser adaptado para derivados FreeBSD, mas exige configuração extensa que não acompanha o port.

Fonte do backend: <https://www.freshports.org/sysutils/kpmcore/>.

#### Módulos incompatíveis ou insuficientes

Os módulos Calamares normalmente usados por distribuições Linux pressupõem ferramentas e formatos Linux:

- `partition`: sem backend FreeBSD funcional;
- `unpackfs`: poderia copiar um rootfs preparado, mas não substitui particionamento e boot;
- `bootloader`: normalmente integra GRUB/systemd-boot, não o fluxo completo do FreeBSD loader;
- `packages`: perfis Linux não equivalem a `pkg`/Ports sem configuração própria;
- `users`: precisa respeitar ferramentas, grupos e arquivos FreeBSD;
- `fstab`: precisa conhecer UFS/ZFS e nomes de dispositivos FreeBSD;
- módulos Python existentes no projeto chamam APT, `update-grub` e parâmetros Linux.

#### Formas tecnicamente possíveis

**Opção A — Calamares apenas como frontend:**

- coleta idioma, teclado, timezone, usuário e escolha UFS/ZFS;
- não executa particionamento diretamente;
- chama um backend Parcel-FreeBSD próprio;
- o backend reutiliza ferramentas e bibliotecas do FreeBSD ou delega fases controladas ao `bsdinstall`.

**Opção B — desenvolver suporte FreeBSD upstream:**

- implementar backend KPMCore real para GEOM/GPart;
- acrescentar criação e importação ZFS/UFS;
- implementar bootloader FreeBSD;
- adaptar módulos de usuário, rede, pacotes e filesystem;
- contribuir e manter patches no upstream relevante.

A opção B é praticamente um projeto de instalador novo e não deve bloquear o primeiro Live.

#### Veredito Calamares

| Uso | Veredito |
| --- | --- |
| Executar a interface no Live FreeBSD | **Viável para prova de conceito** |
| Instalar usando configuração padrão Linux | **Inviável** |
| Particionar FreeBSD com o port atual | **Bloqueado pelo backend dummy** |
| Frontend Parcel sobre backend próprio/`bsdinstall` | **Possível, alto esforço** |
| Substituir `bsdinstall` no MVP | **Não recomendado** |

### 12.3 Anaconda no FreeBSD

O Anaconda é o instalador usado por Fedora, Red Hat Enterprise Linux e distribuições relacionadas. Sua arquitetura atual depende do ecossistema Linux/RPM:

- ambiente inicial controlado por dracut;
- fontes de instalação com `.treeinfo`, repositórios e metadados Fedora/RHEL;
- payloads RPM/DNF, OSTree ou bootc;
- Kickstart;
- Blivet e ferramentas Linux para storage;
- LVM, device-mapper, multipath e convenções Linux;
- bootloader e configuração do sistema-alvo Linux;
- serviços D-Bus e integrações específicas do ambiente Fedora/RHEL.

Fontes oficiais:

- <https://anaconda-installer.readthedocs.io/en/latest/user-guide/intro.html>
- <https://anaconda-installer.readthedocs.io/en/latest/user-guide/boot-options.html>
- <https://anaconda-installer.readthedocs.io/en/latest/developer/configuration-files.html>

Não foi encontrado port oficial do Anaconda na coleção FreeBSD, nem suporte oficial a FreeBSD na documentação do projeto. Portar somente a interface não resolveria storage, payload, usuários, bootloader ou configuração do sistema.

#### Veredito Anaconda

| Uso | Veredito |
| --- | --- |
| Executar nativamente no Live FreeBSD | **Não demonstrado** |
| Instalar payload FreeBSD | **Não suportado** |
| Adaptar via perfil/configuração | **Insuficiente; dependências são estruturais** |
| Criar fork para FreeBSD | **Esforço extremo e manutenção permanente** |
| Usar no MVP | **Rejeitado** |

### 12.4 Comparação final dos instaladores

| Critério | `bsdinstall` | Calamares | Anaconda |
| --- | --- | --- | --- |
| Roda oficialmente no FreeBSD | Sim | Port disponível | Não demonstrado |
| Conhece discos/partições FreeBSD | Sim | Backend funcional ausente | Não |
| UFS/ZFS | Nativo | Exigiria implementação | Não é seu modelo |
| Instala base/kernel FreeBSD | Sim | Exigiria backend | Não |
| Instala FreeBSD loader | Sim | Exigiria módulo | Não |
| Interface gráfica | Não | Sim | Sim/web |
| Pronto para MVP | Sim | Não | Não |
| Esforço Parcel | Baixo | Alto | Extremo |

### 12.5 Decisão recomendada

1. **MVP:** manter `bsdinstall` como único instalador autoritativo.
2. **Live gráfico:** oferecer botão “Instalar FreeBSD” que abre `bsdinstall` em terminal legível.
3. **Experimento posterior:** instalar Calamares no Live apenas para validar inicialização, tradução, teclado e branding.
4. **Não permitir escrita em disco pelo Calamares** enquanto o backend continuar dummy.
5. **Não investir em Anaconda** para FreeBSD.
6. Se uma experiência gráfica for requisito, criar primeiro um frontend Parcel estreito que gere uma configuração validada e delegue operações ao backend FreeBSD, mantendo logs e confirmações destrutivas.

O Calamares é a única das duas ferramentas que merece uma prova de conceito no FreeBSD, mas como interface experimental — não como instalador funcional no estado atual.

## 13. Fontes oficiais

- [Releases](https://www.freebsd.org/releases/)
- [Imagens 15.1 amd64](https://download.freebsd.org/releases/amd64/amd64/ISO-IMAGES/15.1/)
- [Instalação e Live CD](https://docs.freebsd.org/en/books/handbook/bsdinstall/)
- [Boot](https://docs.freebsd.org/en/books/handbook/boot/)
- [Engenharia de releases](https://docs.freebsd.org/en/articles/freebsd-releng/)
- [Makefile de mídias](https://cgit.freebsd.org/src/tree/release/Makefile)
- [Árvore-fonte](https://git.FreeBSD.org/src.git)
- [Plataformas](https://www.freebsd.org/platforms/)
- [Ports e pacotes](https://docs.freebsd.org/en/books/handbook/ports/)
- [Ambientes gráficos](https://docs.freebsd.org/en/books/handbook/desktop/)
- [Calamares no FreeBSD Ports](https://cgit.freebsd.org/ports/tree/sysutils/calamares)
- [Calamares](https://calamares.io/about/)
- [Anaconda](https://anaconda-installer.readthedocs.io/en/latest/)

## 14. Localização do código-fonte oficial

O código do `bsdinstall` e da mídia Live está disponível na mesma árvore `freebsd-src`. O “Live CD” não é um segundo programa isolado: é um sistema FreeBSD preparado pelo subsistema de release, com `bsdinstall`, scripts de inicialização, kernel/world e conjuntos de distribuição.

### 14.1 Clone recomendado

Para estudar exatamente a linha do FreeBSD 15.1, deve-se fixar o branch/tag correspondente à release, em vez de usar `main` sem revisão:

```bash
git clone https://git.FreeBSD.org/src.git freebsd-src
git -C freebsd-src switch --detach release/15.1.0
git -C freebsd-src rev-parse HEAD
```

O nome da tag deve ser confirmado com `git tag -l 'release/15.1*'` após o clone. O commit completo precisa ser registrado antes de qualquer modificação.

### 14.2 Código do `bsdinstall`

Diretório principal:

```text
usr.sbin/bsdinstall/
├── bsdinstall
├── bsdinstall.8
├── distfetch/
├── distextract/
├── partedit/
└── scripts/
```

Responsabilidades:

- `bsdinstall`: orquestrador principal em shell;
- `partedit/`: editor de partições, implementado em C;
- `distfetch/`: obtenção das distribuições;
- `distextract/`: extração do base/kernel no destino;
- `scripts/`: hostname, rede, usuários, timezone, serviços, hardening, UFS/ZFS e finalização;
- `bsdinstall.8`: contrato, variáveis e documentação do instalador.

Navegação direta: <https://cgit.freebsd.org/src/tree/usr.sbin/bsdinstall>.

### 14.3 Código do ambiente Live e da ISO

Diretório principal:

```text
release/
├── Makefile
├── release.sh
├── release.conf.sample
├── rc.local
├── amd64/
│   ├── mkisoimages.sh
│   └── make-memstick.sh
└── scripts/
```

Responsabilidades:

- `release/Makefile`: instala world/kernel no staging, copia distribuições para `/usr/freebsd-dist` e gera `disc1.iso`, `bootonly.iso`, `dvd1.iso` e imagens USB;
- `release/rc.local`: ponto de entrada da mídia para iniciar o fluxo de instalação/Live;
- `release/amd64/mkisoimages.sh`: mastering da ISO amd64 híbrida;
- `release/amd64/make-memstick.sh`: geração de imagem USB;
- `release/release.sh`: criação reprodutível da release em ambiente controlado;
- `release/scripts/`: manifestos, pacotes offline e auxiliares.

Navegação direta:

- <https://cgit.freebsd.org/src/tree/release/>
- <https://cgit.freebsd.org/src/tree/release/Makefile>
- <https://cgit.freebsd.org/src/tree/release/rc.local>
- <https://cgit.freebsd.org/src/tree/release/amd64/>

### 14.4 Consequência para o Parcel

Há três pontos naturais de customização:

1. **Interface e fluxo:** alterar ou envolver `bsdinstall` e seus scripts.
2. **Conteúdo do Live:** adicionar pacotes, configuração, usuário e desktop ao staging produzido por `release/Makefile`.
3. **Formato da mídia:** adaptar `mkisoimages.sh`, ESP, loader e manifestos.

A rota de menor risco é preservar `partedit`, `distextract` e os scripts nativos, aplicando primeiro branding e um launcher gráfico externo. Isso permite melhorar a experiência sem reimplementar as operações destrutivas do instalador.
