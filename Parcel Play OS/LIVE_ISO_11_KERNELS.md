# Mídia Live híbrida com 11 opções de kernel/sistema

## Objetivo

Construir uma única mídia Live cujo menu inicial ofereça oito kernels Linux e três sistemas BSD. Os oito kernels Linux poderão montar o rootfs Ubuntu compartilhado com GNOME, KDE Full e GDM. FreeBSD, NetBSD e OpenBSD reais precisam de userspaces e fluxos de boot próprios.

O protótipo Ubuntu Resolute permanece documentado em `LIVE_CD_RESOLUTE.md`.

## As onze opções

1. Ubuntu Oficial, padrão inicial e fallback Linux.
2. NitroCore Arch.
3. NitroCore openSUSE.
4. NitroCore Fedora.
5. FreeBSD real, como sistema independente.
6. NitroCore Debian.
7. NitroCore Gentoo.
8. NetBSD real, como sistema independente.
9. OpenBSD real, inicialmente como ambiente de instalação/recuperação.
10. NitroCore CentOS.
11. NitroCore Oracle.

## Conclusão técnica sobre os três BSDs

FreeBSD, NetBSD e OpenBSD são sistemas Unix-like completos, não flavors do kernel Linux. Seus kernels possuem ABIs, chamadas de sistema, drivers, módulos, bootloaders e userspaces próprios.

Por isso:

- não podem substituir o Linux no fluxo Casper;
- não podem iniciar diretamente o `systemd` e o rootfs Ubuntu;
- não usam os pacotes Debian `ubuntu-desktop` e `kde-full` como desktops nativos;
- não usam initramfs/Plymouth como o fluxo Linux documentado;
- precisam de kernel, ambiente inicial e rootfs próprios.

A compatibilidade Linux do FreeBSD funciona no sentido FreeBSD hospedando parte de um userland Linux. A documentação oficial exige bibliotecas e arquivos adicionais em `/compat/linux`; isso não transforma o kernel FreeBSD em kernel da ISO Ubuntu: <https://docs.freebsd.org/en/books/handbook/linuxemu/>.

Os rump kernels do NetBSD executam componentes do kernel como serviços em userspace, por exemplo filesystems e pilhas de rede. Eles não substituem o kernel Linux durante o boot: <https://www.netbsd.org/docs/rump/sptut.html>.

## Alternativas avaliadas

| Alternativa | Mesmo GNOME/KDE Ubuntu | BSD real | Complexidade | Decisão |
| :--- | :---: | :---: | :--- | :--- |
| Perfis Linux inspirados em BSD | Sim | Não | Menor | Rejeitada após esclarecimento |
| Mídia multi-OS com payloads BSD próprios | Não nas entradas BSD | Sim | Muito alta | Adotada conceitualmente |

O nome “11 kernels” passa a significar onze opções no menu inicial: oito iniciam o Parcel Play OS Linux e três iniciam ambientes BSD separados.

## Arquitetura corrigida

```text
UEFI/BIOS
   ↓
menu principal da mídia
   ├── 8 opções Linux
   │      ↓
   │   kernel + initramfs + Plymouth
   │      ↓
   │   Casper → rootfs Ubuntu compartilhado
   │      ↓
   │   GDM → GNOME/KDE
   │
   ├── FreeBSD
   │      ↓
   │   loader/kernel/rootfs FreeBSD
   │
   ├── NetBSD
   │      ↓
   │   bootloader/kernel/rootfs NetBSD
   │
   └── OpenBSD
          ↓
       bootloader ou ramdisk kernel bsd.rd
```

O manual do GRUB lista comandos para FreeBSD, NetBSD e OpenBSD, incluindo `kfreebsd`, `knetbsd`, `kopenbsd` e `kopenbsd_ramdisk`: <https://www.gnu.org/software/grub/manual/grub/html_node/Loader-commands.html>.

O suporte direto varia por firmware e plataforma. A estratégia preferencial será carregar o bootloader EFI nativo de cada BSD a partir do menu principal. OpenBSD informa oficialmente que GRUB costuma falhar em multiboot e cita rEFInd como opção que geralmente funciona; portanto, sua integração exige prova específica em UEFI: <https://www.openbsd.org/faq/faq4.html>.

## Oito opções Linux

Os kernels Ubuntu, Arch, openSUSE, Fedora, Debian, Gentoo, CentOS e Oracle compartilham:

- o mesmo rootfs Ubuntu Resolute;
- GNOME e KDE Full;
- GDM;
- Casper, SquashFS e OverlayFS;
- instalador Ubuntu/Subiquity;
- firmware disponível na mídia.

Cada um precisa de kernel, initramfs, Plymouth e diretório de módulos próprios:

```text
/usr/lib/modules/VERSAO-ubuntu/
/usr/lib/modules/VERSAO-nitro-arch/
/usr/lib/modules/VERSAO-nitro-opensuse/
/usr/lib/modules/VERSAO-nitro-fedora/
/usr/lib/modules/VERSAO-nitro-debian/
/usr/lib/modules/VERSAO-nitro-gentoo/
/usr/lib/modules/VERSAO-nitro-centos/
/usr/lib/modules/VERSAO-nitro-oracle/
```

### Plymouth Linux

| Kernel Linux | Tema | Initramfs |
| :--- | :--- | :--- |
| Ubuntu Oficial | `parcel-ubuntu` | `initrd-ubuntu` |
| NitroCore Arch | `parcel-arch` | `initrd-nitro-arch` |
| NitroCore openSUSE | `parcel-opensuse` | `initrd-nitro-opensuse` |
| NitroCore Fedora | `parcel-fedora` | `initrd-nitro-fedora` |
| NitroCore Debian | `parcel-debian` | `initrd-nitro-debian` |
| NitroCore Gentoo | `parcel-gentoo` | `initrd-nitro-gentoo` |
| NitroCore CentOS | `parcel-centos` | `initrd-nitro-centos` |
| NitroCore Oracle | `parcel-oracle` | `initrd-nitro-oracle` |

FreeBSD, NetBSD e OpenBSD receberão branding por seus mecanismos nativos, não por `plymouth-set-default-theme` ou `update-initramfs`.

## FreeBSD

O procedimento específico e a auditoria atualizada dos documentos do projeto estão em `LIVE_CD_FREEBSD.md`.

Payload mínimo:

- `loader.efi` ou outro bootloader FreeBSD nativo;
- kernel e módulos FreeBSD;
- rootfs FreeBSD;
- `/boot/loader.conf` e arquivos de boot;
- pacotes FreeBSD próprios para qualquer desktop opcional.

O processo oficial usa o loader, normalmente em `/boot/loader`, para carregar kernel e módulos: <https://docs.freebsd.org/en/books/handbook/boot/>.

FreeBSD poderá oferecer Plasma ou GNOME empacotados para FreeBSD, mas não será o mesmo rootfs Ubuntu nem terá garantia da mesma integração GDM.

## NetBSD

Payload mínimo:

- bootloader/EFI NetBSD;
- kernel NetBSD;
- módulos e sets do userland;
- imagem Live ou de instalação nativa;
- desktop NetBSD opcional preparado separadamente.

A documentação oficial usa `build.sh` com alvos `release`, `install-image` ou `iso-image` e também descreve imagens Live customizadas: <https://netbsd.org/docs/guide/en/chap-inst-media.html>.

Rump kernels podem futuramente fornecer serviços NetBSD dentro da sessão Linux, mas isso seria outra função e não uma opção de kernel no menu.

## OpenBSD

O caminho oficial mínimo é `bsd.rd`, um ramdisk kernel contendo instalador e utilitários de recuperação. A documentação oficial não o apresenta como Live desktop GNOME/KDE: <https://www.openbsd.org/faq/faq4.html>.

Payload mínimo:

- bootloader EFI OpenBSD ou chainload validado;
- `bsd.rd`;
- sets e firmware necessários à instalação;
- sistema OpenBSD completo separado se um desktop Live for desenvolvido.

Não será prometida uma sessão Live GNOME/KDE Full para OpenBSD no MVP.

## Layout conceitual da mídia

```text
/boot/grub/grub.cfg
/EFI/BOOT/...
/casper/vmlinuz-ubuntu
/casper/initrd-ubuntu
/casper/vmlinuz-nitro-arch
/casper/initrd-nitro-arch
...
/casper/vmlinuz-nitro-oracle
/casper/initrd-nitro-oracle
/casper/*.squashfs
/bsd/freebsd/...
/bsd/netbsd/...
/bsd/openbsd/...
```

Esse layout é conceitual. Os caminhos finais dependerão dos bootloaders EFI e formatos oficiais de cada BSD.

## Implementação inicial do seletor GRUB

### Artefatos criados em 2026-08-13

- configuração versionável: `config/boot/grub-11-kernels.cfg`;
- preparador idempotente: `scripts/prepare-grub-11-kernels.sh`;
- árvore modificada: `build/resolute-mvp/work/iso-tree/`;
- protótipo: `build/resolute-mvp/output/parcel-play-11-menu-prototype-amd64.iso`.

O protótipo possui 6.279.266.304 bytes e SHA-256:

```text
44a1ca2c3c239b0b87747c8372daee7d50c1a8d043644a1a5b0666516b95ec5d
```

Ele preserva o payload Ubuntu Resolute e substitui somente `boot/grub/grub.cfg` e `boot/grub/loopback.cfg`. Portanto, ainda não contém onze kernels funcionais: é o primeiro protótipo real do seletor.

### Comportamento atual

| Posição | Opção | Comportamento atual |
| :---: | :--- | :--- |
| 1 | Ubuntu Oficial | Usa `/casper/vmlinuz` e `/casper/initrd` reais |
| 2 | NitroCore Arch | Payload indisponível |
| 3 | NitroCore openSUSE | Payload indisponível |
| 4 | NitroCore Fedora | Payload indisponível |
| 5 | FreeBSD | Payload indisponível |
| 6 | NitroCore Debian | Payload indisponível |
| 7 | NitroCore Gentoo | Payload indisponível |
| 8 | NetBSD | Payload indisponível |
| 9 | OpenBSD | Payload indisponível |
| 10 | NitroCore CentOS | Payload indisponível |
| 11 | NitroCore Oracle | Payload indisponível |

Uma opção ausente mostra o caminho necessário, espera cinco segundos e retorna ao menu. Ela não inicia Ubuntu sob outro nome e não deixa o usuário em um prompt GRUB.

### Contrato de payload

Os sete Linux precisam fornecer pares próprios:

```text
/parcel/linux/arch/{vmlinuz,initrd}
/parcel/linux/opensuse/{vmlinuz,initrd}
/parcel/linux/fedora/{vmlinuz,initrd}
/parcel/linux/debian/{vmlinuz,initrd}
/parcel/linux/gentoo/{vmlinuz,initrd}
/parcel/linux/centos/{vmlinuz,initrd}
/parcel/linux/oracle/{vmlinuz,initrd}
```

Os BSDs precisam fornecer loaders EFI nativos:

```text
/EFI/parcel/freebsd/loader.efi
/EFI/parcel/netbsd/bootx64.efi
/EFI/parcel/openbsd/BOOTX64.EFI
```

Somente a existência do loader BSD não basta: kernel, módulos, rootfs/sets e demais arquivos referenciados também precisam ser integrados e testados. O MVP BSD deste menu é UEFI; o fluxo BIOS permanece pendente.

### Recuperação e loopback

Ubuntu permanece `default=0`, com timeout de 30 segundos. Um submenu contém Ubuntu com `nomodeset`, próximo volume e configurações do firmware UEFI. O mesmo seletor foi instalado como `loopback.cfg`; quando `iso_path` existir, as entradas Linux acrescentam `iso-scan/filename=${iso_path}`.

### Validações executadas

- `sh -n` aprovou o preparador;
- `grub-script-check` aprovou fonte, menu aplicado e menu reextraído;
- todas as posições numeradas de 1 a 11 foram localizadas;
- kernel e initrd Ubuntu existem;
- `cmp` confirmou que os menus incorporados são idênticos à fonte;
- a imagem preserva El Torito BIOS e UEFI, MBR protetivo, GPT, GRUB e imagem EFI anexada;
- o SHA-256 foi calculado após a escrita.

### Limites

- QEMU não está instalado, portanto nenhum boot foi observado;
- Secure Boot após remasterização não foi testado;
- os dez payloads adicionais continuam ausentes;
- GNOME + KDE Full e instalador modificado continuam bloqueados pela necessidade de sudo autenticado.

## Recuperação

- Ubuntu Oficial será a primeira opção e fallback Linux.
- Se um NitroCore Linux falhar, o usuário reinicia e escolhe Ubuntu.
- Se um BSD falhar, o usuário retorna ao menu principal.
- Os payloads BSD não podem sobrescrever o rootfs Ubuntu nem os outros BSDs.
- Cada ambiente deve ser testado em disco virtual isolado.

## Instaladores

- As opções Linux usam o instalador Ubuntu/Subiquity no MVP.
- FreeBSD usa seu instalador e ferramentas nativas.
- NetBSD usa `sysinst` ou a ferramenta da imagem escolhida.
- OpenBSD usa o instalador contido em `bsd.rd`.

A escolha no menu não autoriza um instalador a particionar ou instalar os outros sistemas. Multiboot no disco será um projeto separado, com política explícita de partições e boot.

## Como produzir Live e instalador dos três BSDs

### Decisão de escopo

O MVP dos BSDs será uma mídia de **instalação e recuperação**, não três desktops Live equivalentes ao Ubuntu. A ordem segura é:

1. iniciar cada imagem oficial separadamente em VM;
2. validar o instalador nativo e uma instalação completa;
3. extrair e integrar o payload nativo na mídia híbrida;
4. validar o chainload EFI;
5. somente depois avaliar desktop Live personalizado.

Tentar criar simultaneamente um Live desktop, um instalador modificado e uma mídia híbrida impediria identificar se uma falha pertence ao kernel, ao rootfs, ao bootloader ou ao instalador.

### Menu principal recomendado

Para um primeiro protótipo amd64, a mídia híbrida deve ser UEFI. A sequência recomendada é:

```text
rEFInd ou menu EFI principal
├── GRUB → oito opções Linux
├── loader.efi → FreeBSD
├── bootloader EFI → NetBSD
└── bootloader EFI → OpenBSD bsd.rd
```

O requisito anterior de usar somente GRUB no topo precisa ser revisto para os BSDs. O GRUB possui comandos BSD, mas o próprio OpenBSD informa que GRUB costuma falhar em multiboot. Um menu EFI capaz de chainload dos bootloaders nativos reduz o acoplamento.

O suporte BIOS legado deve ser uma fase posterior. Misturar BIOS, UEFI, oito Linux e três BSDs no primeiro protótipo multiplicaria a matriz de falhas.

### FreeBSD: Live de terminal e `bsdinstall`

#### Opção mínima recomendada

Usar uma release oficial amd64, fixando versão e checksum. Os formatos relevantes são:

- `bootonly.iso`: instalador mínimo que baixa os componentes;
- `disc1.iso`: inclui arquivos necessários à instalação;
- `dvd1.iso`: inclui instalação e alguns pacotes adicionais;
- `memstick.img`: imagem completa para USB.

Para a mídia híbrida offline, `disc1.iso` ou o conteúdo equivalente de `memstick.img` é o baseline mais apropriado. `bootonly.iso` adicionaria dependência obrigatória de rede.

O menu oficial executa `bsdinstall` e oferece três caminhos:

- Install;
- Shell;
- Live CD.

O modo Live oficial fornece terminal, usuário `root` e senha vazia; não fornece interface gráfica. Isso está documentado no Handbook: <https://docs.freebsd.org/en/books/handbook/bsdinstall/>.

#### Artefatos a preservar

```text
loader.efi
/boot/loader
/boot/kernel/kernel
/boot/kernel/*.ko
/boot/loader.conf
distribuições base/kernel e metadados do bsdinstall
```

Os caminhos reais da release escolhida devem ser obtidos da própria imagem, não presumidos pelo script.

#### Integração na mídia híbrida

1. baixar imagem e arquivos SHA256/SHA512 oficiais;
2. verificar checksum;
3. iniciar a imagem original em VM UEFI;
4. executar o modo Live de terminal;
5. instalar com `bsdinstall` num disco virtual;
6. inspecionar a ESP, El Torito, rootfs e dispositivos enumerados pelo loader original;
7. criar um protótipo UEFI que preserve o ambiente completo de boot FreeBSD;
8. adicionar `loader.efi` ao menu somente junto do payload e dos caminhos exigidos;
9. repetir a instalação offline pela mídia híbrida.

Copiar apenas `loader.efi` para a ISO Parcel não é suficiente. Ainda precisa ser demonstrado como o loader localizará `/boot`, kernel, módulos, rootfs e distribuições na mídia híbrida. Extrair a ISO para uma subpasta arbitrária ou aninhar a ISO como arquivo não constitui boot validado.

#### Desktop Live futuro

Um Live gráfico exige criar uma imagem FreeBSD pré-instalada com Xorg/Wayland, Plasma ou GNOME, display manager, usuário Live, rede e filesystem gravável temporário. Isso não é fornecido pelo modo Live oficial e constitui uma distribuição FreeBSD customizada separada.

O instalador mínimo não deve depender desse desktop. `bsdinstall` permanece o instalador nativo.

### NetBSD: imagem construída com `build.sh` e `sysinst`

#### Opção mínima recomendada

Usar a árvore de uma release NetBSD fixada e construir para `amd64`. A documentação oficial apresenta esta sequência geral:

```bash
./build.sh -U -u -j2 -m amd64 -O CAMINHO_OBJ tools
./build.sh -U -u -j2 -m amd64 -O CAMINHO_OBJ release
./build.sh -U -u -j2 -m amd64 -O CAMINHO_OBJ iso-image
```

Para imagem USB, o alvo é `install-image`. Os valores de caminho são placeholders e o número de jobs deverá respeitar a pouca memória do host.

Fonte oficial: <https://netbsd.org/docs/guide/en/chap-inst-media.html>.

O instalador nativo é `sysinst`. Os sets da release, kernel e bootloader precisam acompanhar a imagem para instalação offline.

#### Artefatos a preservar

```text
bootloader EFI NetBSD
kernel netbsd
sets da release
sysinst e ambiente de instalação
arquivos de configuração e manifesto da imagem
```

#### Integração na mídia híbrida

1. fixar release/commit NetBSD;
2. construir ou baixar a imagem oficial amd64;
3. verificar checksum;
4. testar `sysinst` na imagem original;
5. instalar num disco virtual;
6. identificar bootloader, kernel, sets e caminhos reais;
7. integrar o bootloader EFI nativo ao menu principal;
8. apontar o ambiente NetBSD aos seus próprios sets;
9. repetir o boot e instalação offline na mídia híbrida.

#### Live personalizado futuro

O NetBSD Guide documenta imagens Live customizadas. Um desktop exigirá incluir os sets gráficos correspondentes e pacotes NetBSD/pkgsrc, criar usuário Live e definir persistência/temporários. Rump kernels não são necessários para construir essa imagem e não substituem `sysinst`.

### OpenBSD: `bsd.rd` e instalador nativo

#### Opção mínima recomendada

Usar a release amd64 oficial e seus artefatos:

- `installXX.iso`: ISO de instalação com sets;
- `installXX.img`: imagem para USB com sets;
- `minirootXX.img`: ambiente mínimo que busca sets externamente;
- `bsd.rd`: ramdisk kernel contendo instalador e ferramentas de recuperação.

`XX` representa a versão e não deve ser fixado no script até que a release seja escolhida.

Para instalação offline, a referência deve ser `installXX.iso` ou `installXX.img`, não somente `minirootXX.img`. O `bsd.rd` é o kernel inicial do instalador.

Fonte oficial: <https://www.openbsd.org/faq/faq4.html>.

#### Artefatos a preservar

```text
bootloader EFI OpenBSD
bsd.rd
sets baseXX.tgz, compXX.tgz, manXX.tgz e demais selecionados
SHA256 e assinatura SHA256.sig
firmware necessário
```

Os nomes completos dependem da release e arquitetura.

#### Integração na mídia híbrida

1. baixar somente de mirror oficial;
2. verificar `SHA256.sig` com `signify` e a chave oficial da release;
3. iniciar `installXX.iso` ou `.img` original em VM;
4. executar instalação completa em disco virtual;
5. identificar bootloader EFI, `bsd.rd` e localização dos sets;
6. integrar por chainload do bootloader nativo;
7. confirmar que `bsd.rd` encontra os sets dentro da área OpenBSD;
8. repetir instalação offline pela mídia híbrida.

#### Limitação Live

`bsd.rd` é um ambiente de instalação e recuperação em RAM, não um Live desktop geral. Criar um OpenBSD gráfico Live exigiria um sistema OpenBSD completo em rootfs próprio, Xenocara/pacotes nativos, configuração de usuário e solução de filesystem temporário. Isso está fora do MVP.

### Instalador unificado: decisão negativa

Subiquity, Calamares, `bsdinstall`, `sysinst` e o instalador OpenBSD não devem controlar juntos uma única execução de particionamento.

O menu apenas escolhe o ambiente. Depois:

| Opção | Instalador |
| :--- | :--- |
| Oito Linux | Ubuntu Desktop Installer/Subiquity |
| FreeBSD | `bsdinstall` |
| NetBSD | `sysinst` |
| OpenBSD | Instalador de `bsd.rd` |

Um instalador visual Parcel comum poderia futuramente apenas coletar preferências e delegar a cada backend, mas isso seria um novo projeto de alto risco. O MVP preservará os instaladores oficiais.

### Particionamento e coexistência

No primeiro ciclo, cada instalador deve receber um disco virtual vazio exclusivo. Não testar instalação lado a lado entre os quatro sistemas.

Antes de oferecer multiboot instalado, é necessário definir:

- GPT e partição EFI compartilhada;
- tipos de partição de cada BSD;
- quais instaladores podem alterar a ESP;
- ordem e recuperação dos bootloaders;
- atualização do menu após instalação;
- política de criptografia;
- rollback e backup da tabela de partições.

### Estratégia de construção da mídia híbrida

A incorporação não deve começar copiando três ISOs arbitrariamente para uma pasta. Bootloaders BSD podem não inicializar uma ISO aninhada.

Processo proposto:

1. criar uma ESP FAT para o menu e bootloaders EFI;
2. manter a área Casper/Linux já inicializável;
3. extrair os payloads BSD para áreas separadas;
4. preservar os caminhos esperados por cada loader/instalador;
5. montar a imagem final com `xorriso` ou ferramenta equivalente;
6. testar cada entrada sem executar as demais;
7. gerar checksum e manifesto completos.

O layout final só poderá ser fixado depois de inspecionar as três imagens oficiais escolhidas.

### Critérios de aceite do MVP BSD

Para cada BSD:

- checksum/assinatura oficial validado;
- boot UEFI da imagem original aprovado;
- instalador original aprovado em VM;
- boot por menu híbrido aprovado;
- payload offline localizado;
- instalação em disco virtual vazio aprovada;
- reboot no BSD instalado aprovado;
- logs, versões, caminhos e resultado registrados em Markdown.

Um terminal Live ou ambiente de recuperação conta como Live mínimo. GNOME/Plasma não é critério do MVP BSD.

## Compatibilidade entre kernels e hipótese de união em C

### Conclusão

A linguagem C facilita a leitura, a adaptação e o porte de código, mas não torna dois kernels diretamente compatíveis. O formato das estruturas internas, APIs de drivers, gerenciamento de memória, VFS, rede, bloqueios, chamadas de sistema, módulos, compilação e licenças também precisa ser compatível.

Entre as onze opções deste projeto, há duas respostas diferentes:

1. **Maior compatibilidade prática: quaisquer dois dos oito perfis Linux.** Eles devem ser construídos a partir da mesma árvore Linux/Ubuntu Resolute, variando fragmentos de configuração e filas de patches. Nesse modelo não se fundem dois kernels prontos: consolida-se uma única fonte e geram-se oito binários.
2. **Par BSD historicamente mais próximo: NetBSD e OpenBSD.** O OpenBSD nasceu como fork do NetBSD em 1995. Essa ancestralidade facilita comparar e portar trechos em C, mas os kernels atuais não possuem ABI de módulos, KAPI ou binários intercambiáveis.

A história oficial do NetBSD registra sua origem em 4.3BSD Net/2 e 386BSD e a formação separada do FreeBSD: <https://www.netbsd.org/about/history.html>. Material oficial do OpenBSD registra o fork do NetBSD em 18 de outubro de 1995: <https://www.openbsd.org/papers/openbsd_openrheinruhr_nov2018.pdf>.

### Matriz de proximidade

| Par ou grupo | Fonte/ancestralidade | ABI/KAPI atual | Integração realista | Avaliação |
| :--- | :--- | :--- | :--- | :--- |
| Dois perfis entre os oito Linux | Mesma família e, no projeto, mesma árvore-base | Alta quando compilados sob a mesma política; módulos ainda dependem da versão/configuração | Base comum, configurações e patches por flavor | Melhor escolha prática |
| NetBSD + OpenBSD | OpenBSD derivou do NetBSD | Baixa; módulos e kernels não são intercambiáveis | Porte manual de um subsistema pequeno | BSDs mais próximos historicamente |
| FreeBSD + NetBSD | Ancestralidade BSD comum, evolução separada | Baixa | Porte manual com camada de adaptação | Possível por componente, não por fusão |
| Linux + FreeBSD | Famílias e licenças diferentes | Baixa | Linuxulator/LinuxKPI no FreeBSD para casos específicos | Ponte unilateral, não união |
| Linux + NetBSD | Famílias diferentes | Baixa | Componentes NetBSD rump em userspace | Serviço isolado, não união |

O fato de drivers migrarem entre BSDs confirma reaproveitamento de código-fonte, não compatibilidade direta. O OpenBSD documenta drivers originados ou portados de FreeBSD e NetBSD e também as adaptações necessárias: <https://www.openbsd.org/papers/pruning.html>.

### Por que não ligar dois kernels em um único executável

Um kernel de propósito geral pressupõe ser o proprietário dos recursos centrais da máquina. Unir diretamente dois kernels monolíticos criaria conflitos sobre:

- entrada de boot e inicialização das CPUs;
- tabelas de páginas e alocação de memória física;
- escalonador, processos e sinais;
- interrupções, temporizadores e energia;
- VFS, cache e drivers de armazenamento;
- rede e drivers do mesmo hardware;
- namespaces de símbolos e estruturas internas.

Renomear funções em C ou resolver símbolos duplicados não resolve esses conflitos de autoridade. Seria necessário transformar um dos kernels em subsistema, convidado virtualizado ou conjunto de serviços, o que equivale a uma nova arquitetura e não a uma simples compilação conjunta.

### Arquiteturas viáveis

#### 1. Uma base Linux com oito flavors — recomendada

```text
fonte Linux/Ubuntu Resolute fixada
   ├── patches comuns Parcel/NitroCore
   ├── configuração Ubuntu
   ├── configuração NitroCore Arch
   ├── configuração NitroCore openSUSE
   ├── configuração NitroCore Fedora
   ├── configuração NitroCore Debian
   ├── configuração NitroCore Gentoo
   ├── configuração NitroCore CentOS
   └── configuração NitroCore Oracle
```

Cada saída continua tendo `vmlinuz`, módulos e initramfs próprios. Alterações úteis são promovidas para a camada comum; alterações conflitantes permanecem no flavor correspondente. Esta é a forma rápida, testável e sustentável de “unir” os kernels Linux do projeto.

#### 2. Adaptador em C para um componente BSD

Para experimentar NetBSD e OpenBSD, deve-se escolher somente um componente sem propriedade global da máquina, definir uma interface neutra e escrever um adaptador por sistema. Uma interface conceitual poderia conter uma estrutura `parcel_kernel_service_ops` com ponteiros para inicialização, leitura, escrita e encerramento. A interface ficaria em userspace ou em uma camada claramente isolada; não prometeria carregar módulos de um BSD no outro.

Um primeiro experimento deve usar lógica pequena e testável, nunca MMU, escalonador, VFS raiz ou driver crítico. Antes do porte, é obrigatório mapear tipos, primitivas de sincronização, endianess, ciclo de vida, erros, licenças e testes.

#### 3. NetBSD rump em userspace

O NetBSD permite executar componentes de kernel como serviços rump em userspace e expor operações a clientes. Isso possibilita reutilizar, por exemplo, um filesystem ou pilha de rede sem entregar o controle do hardware ao segundo kernel: <https://www.netbsd.org/docs/rump/sptut.html> e <https://www.netbsd.org/docs/rump/sysproxy.html>.

#### 4. Dois kernels completos lado a lado

Quando for requisito executar dois kernels completos, um deve hospedar um hipervisor ou ambos devem ser convidados de um hipervisor. Cada kernel recebe CPUs, memória e dispositivos virtuais próprios. Para a Live ISO, isso seria um modo experimental posterior; não substitui o menu de boot das onze opções.

### Licenciamento

Compatibilidade técnica não autoriza automaticamente a cópia de código. O Linux usa GPL-2.0-only na licença global da árvore, com exceções e identificadores SPDX por arquivo; os BSDs usam licenças permissivas e também podem conter arquivos com condições específicas. Todo porte exige auditoria por arquivo, preservação de avisos e confirmação de que a distribuição resultante atende às duas licenças. Código BSD compatível pode ser incorporado a uma obra GPL cumprindo seus avisos; código GPL não deve ser republicado como se fosse BSD-only.

### Decisão para o Parcel Play OS

- Não será tentada a fusão binária de kernels completos.
- Os oito Linux serão tratados como flavors de uma fonte comum Resolute, e não como oito árvores independentes a serem mescladas.
- NetBSD e OpenBSD serão o par de estudo para portabilidade BSD em C, por proximidade histórica, sem alegar ABI comum.
- FreeBSD continuará sendo a referência para compatibilidade de aplicações Linux por Linuxulator, não para carregar um kernel Linux dentro do FreeBSD: <https://docs.freebsd.org/en/books/handbook/linuxemu/>.
- Qualquer protótipo compartilhado começará como biblioteca/adaptador ou serviço em userspace e terá teste isolado antes de ser considerado para kernel space.
- A mídia Live continuará iniciando somente um kernel por vez; os demais permanecem payloads selecionáveis no menu.

### Critérios para um protótipo em C

1. escolher e documentar um único componente e sua licença;
2. definir uma API neutra sem expor estruturas privadas dos kernels;
3. criar adaptadores separados, sem `#ifdef` espalhado pelo código comum;
4. executar primeiro em userspace com dados de teste e sanitizadores;
5. medir equivalência funcional, falhas, memória e concorrência;
6. somente depois avaliar um porte para kernel space;
7. manter FreeBSD, NetBSD e OpenBSD inicializáveis de forma independente na Live.

**Estado:** estudo conceitual concluído. Nenhum código de kernels foi unido, portado ou compilado nesta etapa.

## Um kernel anfitrião e dez convidados de baixo consumo

### Decisão de arquitetura

O kernel Ubuntu Resolute será o anfitrião inicial. Ele já é o fallback da Live, inicia GNOME/KDE, possui suporte Linux a KVM e pode executar convidados Linux e BSD por QEMU. Os outros dez itens não ficarão todos ligados no boot: serão catálogos de convidados iniciados sob demanda.

```text
Ubuntu Resolute anfitrião
   ├── GNOME/KDE e interface de controle
   ├── KVM + QEMU
   ├── 7 convidados Linux NitroCore
   │      └── kernel próprio + initramfs/rootfs mínimo
   ├── FreeBSD convidado
   ├── NetBSD convidado ou serviço rump
   └── OpenBSD convidado
```

O KVM expõe `/dev/kvm` e cria máquinas, vCPUs, memória e dispositivos por descritores e `ioctl`. Sua ABI é estável e é adequada para um controlador em C, embora implementar diretamente todos os dispositivos virtuais seja desnecessariamente complexo: <https://www.kernel.org/doc/html/latest/virt/kvm/api.html>.

QEMU será o monitor de máquina virtual, usando KVM para aceleração de hardware. A documentação do FreeBSD registra que QEMU suporta FreeBSD, OpenBSD e NetBSD e pode usar KVM em anfitrião Linux: <https://docs.freebsd.org/en/books/handbook/virtualization/>.

### O que significa convidado e serviço

| Modo | Executa outro kernel completo? | Isolamento | Consumo esperado | Uso no projeto |
| :--- | :---: | :--- | :--- | :--- |
| Container/chroot | Não; compartilha o kernel Ubuntu | Processos e namespaces | Muito baixo | Não comprova os outros kernels |
| Serviço rump NetBSD | Somente componentes selecionados | Processo de userspace | Muito baixo | Filesystem, rede ou driver suportado |
| VM KVM/QEMU mínima | Sim | CPU, memória e dispositivos virtuais | Baixo a médio | Opção padrão para os dez kernels |
| VM com desktop completo | Sim | Máquina completa | Alto | Fora do MVP |

O NetBSD documenta que rump kernels componentizados iniciam em milissegundos e são baratos de criar e destruir. Eles são a melhor opção quando o objetivo é consumir uma função do kernel, e não demonstrar o sistema operacional inteiro: <https://www.netbsd.org/docs/rump/sptut.html>.

### Estratégia para os sete convidados Linux

Os convidados Linux podem usar boot direto do QEMU, fornecendo `-kernel`, `-initrd` e uma linha de comando serial. Esse caminho elimina firmware e bootloader dentro da VM; é oficialmente documentado pelo QEMU: <https://www.qemu.org/docs/master/system/linuxboot.html>.

Cada convidado terá:

- uma vCPU inicialmente;
- console serial, sem GPU virtual e sem ambiente gráfico;
- kernel e initramfs do flavor correspondente;
- rootfs mínimo somente leitura;
- overlay temporário em RAM ou `qcow2` descartável;
- rede desligada por padrão ou `virtio-net` isolada quando o teste exigir;
- desligamento automático ao terminar o serviço/teste.

O rootfs completo GNOME/KDE permanece somente no anfitrião. Copiá-lo para cada convidado eliminaria a economia de RAM e armazenamento. Os sete kernels Linux poderão compartilhar uma imagem base imutável compatível, mas cada um ainda precisa de seus próprios módulos em `/usr/lib/modules/$(uname -r)`. Não se deve montar de forma gravável o mesmo filesystem em várias VMs.

### Estratégia para os três BSDs

FreeBSD, NetBSD e OpenBSD precisam de VMs QEMU com boot e userspace nativos. Para maximizar compatibilidade, o primeiro protótipo BSD usará máquina virtual convencional e dispositivos amplamente suportados; uma máquina `microvm` excessivamente reduzida pode remover firmware ou barramentos exigidos pelo BSD.

- **FreeBSD:** VM de console com imagem mínima nativa e disco overlay.
- **NetBSD:** VM de console quando for necessário o kernel completo; processo rump quando bastar um componente.
- **OpenBSD:** VM de console nativa; não deve ser convertido em serviço Linux nem receber rootfs Ubuntu.

### Orquestrador em C

Um pequeno processo `parcel-kernel-host` poderá controlar os convidados sem implementar um hipervisor. Ele deve iniciar QEMU como processo sem privilégios e usar um socket QMP para consultar estado, encerrar e coletar eventos. O acesso a `/dev/kvm` será concedido apenas ao grupo apropriado.

Interface conceitual:

```c
struct parcel_guest_spec {
    const char *name;
    const char *kernel;
    const char *initrd;
    const char *root_image;
    unsigned int memory_mib;
    unsigned int vcpus;
    enum parcel_guest_kind kind;
};

int parcel_guest_start(const struct parcel_guest_spec *spec);
int parcel_guest_status(const char *name);
int parcel_guest_stop(const char *name);
```

O programa não deve montar imagens arbitrárias como `root`, concatenar argumentos recebidos em um shell ou expor QMP sem autenticação. Perfis serão manifestos fixos e validados; limites adicionais serão aplicados por cgroups/systemd, com diretórios, dispositivos e rede explicitamente permitidos.

### Orçamento de recursos

Valores de RAM não serão declarados como requisitos confirmados antes dos testes. Para o protótipo, serão usados apenas como pontos de partida:

| Tipo | RAM inicial para teste | vCPU | Política |
| :--- | :---: | :---: | :--- |
| Linux, initramfs/serviço mínimo | 128–256 MiB | 1 | Aumentar se houver OOM ou falha de boot |
| Linux, userspace de console | 256–512 MiB | 1 | Sem desktop |
| BSD, console nativo | 256–512 MiB | 1 | Ajustar separadamente por BSD |
| Rump NetBSD | Medir por processo | — | Iniciar somente componentes necessários |

Dez VMs com 256 MiB já reservam aproximadamente 2,5 GiB somente para RAM convidada, antes de QEMU, páginas do host, GNOME/KDE e cache. Portanto:

- o padrão será **zero convidados** após iniciar a Live;
- somente um convidado será iniciado por solicitação;
- dois convidados simultâneos serão um teste opcional condicionado à memória disponível;
- executar os dez simultaneamente não faz parte do MVP;
- swap não será tratada como substituta de RAM, pois degrada fortemente a interatividade e a latência dos convidados.

Imagens base somente leitura e páginas idênticas podem economizar armazenamento e algum cache, mas não autorizam somar memória além da capacidade física. Ballooning também não garante que um BSD ou serviço devolverá rapidamente toda a memória reservada.

### Auditoria do equipamento em 2026-08-13

Foi feita somente leitura com `lscpu`, `free -h` e verificação de `/dev/kvm`:

- arquitetura `x86_64`;
- AMD Ryzen 3 7320U, 8 CPUs lógicas;
- AMD-V anunciado pelo processador;
- aproximadamente 5,1 GiB de RAM total;
- no momento da inspeção havia aproximadamente 943 MiB disponíveis e swap já estava em uso;
- `/dev/kvm` não estava presente.

AMD-V disponível não confirma KVM operacional. A Live deverá carregar `kvm` e `kvm_amd`, criar `/dev/kvm` e validar permissões antes de oferecer convidados. Com apenas 5,1 GiB, este computador reforça o modelo sequencial e inviabiliza prometer dez VMs simultâneas junto de GNOME/KDE Full.

### Fases propostas

1. validar KVM no Ubuntu anfitrião e registrar `dmesg`, módulos, `/dev/kvm` e permissões;
2. iniciar um flavor Linux por boot direto, console serial e rootfs mínimo;
3. medir tempo de boot, RSS do QEMU, memória do convidado e tempo de desligamento;
4. repetir sequencialmente para os sete flavors Linux;
5. validar FreeBSD, NetBSD e OpenBSD em VMs convencionais separadas;
6. experimentar um único serviço rump NetBSD;
7. criar o orquestrador em C somente após estabilizar comandos e manifestos;
8. integrar botões na Live sem executar convidado automaticamente;
9. testar degradação controlada quando KVM estiver ausente; TCG poderá servir para diagnóstico, mas será mais lento.

### Critérios de aceite

- o kernel indicado dentro do convidado corresponde ao manifesto selecionado;
- o convidado não usa módulos do anfitrião como se fossem próprios;
- memória e CPU respeitam limites;
- encerrar o convidado libera seus processos, sockets e overlays;
- o anfitrião GNOME/KDE permanece responsivo;
- convidados não acessam discos físicos nem rede externa por padrão;
- FreeBSD, NetBSD e OpenBSD continuam usando seus userspaces nativos;
- todas as medições e falhas são registradas em Markdown.

**Estado:** arquitetura planejada e capacidade do host parcialmente inspecionada. KVM ainda não foi habilitado ou testado, nenhuma VM foi iniciada e o orquestrador em C ainda não foi implementado.

## Testes obrigatórios

### Por kernel Linux

1. validar kernel, initramfs e Plymouth;
2. montar SquashFS/OverlayFS;
3. confirmar `/lib/modules/$(uname -r)`;
4. iniciar GDM, GNOME e Plasma;
5. testar hardware básico e instalador;
6. reiniciar no sistema instalado;
7. documentar logs e resultado.

### Por BSD

1. verificar checksum/assinatura dos artefatos oficiais;
2. iniciar em UEFI numa VM descartável;
3. confirmar bootloader, kernel e sistema corretos;
4. localizar o payload BSD próprio;
5. testar console, teclado, armazenamento e rede;
6. iniciar o instalador ou ambiente de recuperação nativo;
7. testar particionamento somente em disco virtual;
8. reiniciar no BSD instalado quando aplicável;
9. confirmar que o rootfs Ubuntu não foi usado como raiz BSD;
10. documentar logs e resultado.

## Opção atualmente mais pronta

A opção mais próxima de uma entrega é a **Live Ubuntu Resolute Desktop remasterizada, com kernel Ubuntu oficial e Ubuntu Desktop Installer/Subiquity**.

Ela está à frente das demais porque a ISO oficial já fornece em um conjunto integrado:

- boot BIOS/UEFI e Secure Boot oficial;
- Casper, SquashFS e sessão Live;
- kernel, módulos, firmware e initramfs compatíveis;
- GNOME, GDM e seleção de sessão;
- Ubuntu Desktop Installer com backend Subiquity;
- fluxo de instalação Ubuntu já alinhado ao rootfs da Live.

Para o primeiro Parcel Play OS, a alteração funcional principal é instalar `kde-full` no rootfs Live, manter GDM e validar se GNOME e Plasma também são transferidos pelo instalador. O procedimento está em `LIVE_CD_RESOLUTE.md` e a decisão do instalador está em `INSTALADOR.md`.

### Classificação por prontidão

| Posição | Live/instalador | Estado no projeto | Trabalho restante |
| :---: | :--- | :--- | :--- |
| 1 | Ubuntu Resolute Desktop + Subiquity | ISO oficial obtida/verificada e protótipo de menu gerado | Incluir KDE Full e testar boot/instalação |
| 2 | FreeBSD + `bsdinstall` | Mídia e instalador oficiais existem, mas não estão integrados | Obter/verificar payload, testar isoladamente e integrar por chainload |
| 3 | NetBSD + `sysinst` | Fluxo oficial conhecido, ainda sem payload | Construir/obter imagem, testar e integrar |
| 4 | OpenBSD `bsd.rd` | Instalador/recuperação oficial conhecido | Obter/verificar sets, testar e integrar; não é Live desktop |
| 5 | Sete NitroCore Linux | Somente arquitetura e procedimento | Construir kernels, módulos, initramfs, Plymouth e validar cada flavor |
| 6 | ISO híbrida com onze opções | Menu protótipo gerado; somente Ubuntu possui payload | Integrar dez payloads e executar matriz completa de testes |

Essa classificação mede a distância até o objetivo do Parcel Play OS com Live gráfica e instalador, não a maturidade dos projetos Ubuntu ou BSD originais.

### Limite do que já existe

“Mais pronta” não significa que a ISO Parcel final esteja pronta. Em 2026-08-13:

- uma ISO Parcel de protótipo do menu foi gerada, mas somente Ubuntu possui payload;
- a ISO Resolute foi obtida e teve checksum/assinatura validados;
- KDE Full ainda não foi incorporado ao SquashFS;
- Subiquity ainda não foi executado contra o payload modificado;
- nenhum teste de boot ou instalação em VM foi concluído.

Portanto, o próximo marco concreto deve ser exclusivamente a ISO Ubuntu Resolute com kernel oficial, GNOME + KDE Full e Subiquity. Os dez outros kernels/sistemas somente devem entrar depois que esse baseline iniciar e instalar corretamente.

### Execução iniciada em 2026-08-13

A build oficial amd64 de 2026-08-11 foi baixada integralmente para `build/resolute-mvp/download/`. O SHA-256 corresponde ao manifesto e a assinatura foi validada com a Ubuntu CD Image Automatic Signing Key (2012), fingerprint `8439 38DF 228D 22F7 B374 2BC0 D94A A3F0 EFE2 1092`.

A ISO foi extraída em `build/resolute-mvp/work/iso-tree/`. A inspeção confirmou boot híbrido BIOS/UEFI e um payload moderno `fsimage-layered`, composto principalmente por `minimal.squashfs`, `minimal.standard.squashfs` e `minimal.standard.live.squashfs`.

A remasterização do rootfs parou antes de instalar KDE porque `sudo` exige autenticação interativa, user namespaces não permitem mapear UID 0 nesta sessão e QEMU não está instalado. Uma reconstrução limitada aos menus GRUB foi executada; KDE Full e testes dinâmicos ainda não foram executados. Comandos, resultados, caminhos e bloqueios estão registrados em `BUILD_RESOLUTE_MVP.md`.

## Estado atual

- Arquitetura híbrida de onze opções: definida documentalmente.
- Oito entradas Linux: apenas Ubuntu está disponível como base do MVP.
- Sete NitroCore Linux: ainda não construídos.
- FreeBSD, NetBSD e OpenBSD: payloads ainda não integrados.
- Menu com onze opções: implementado em protótipo, com dez entradas desabilitadas por ausência de payload.
- Mídia multi-OS completa: ainda não gerada.
- ISO oficial Resolute amd64: baixada, hash e assinatura validados e árvore extraída.
- ISO Parcel GNOME + KDE Full: bloqueada antes da modificação por ausência de sudo autenticado; não gerada.
- ISO protótipo do seletor: gerada e validada estaticamente; boot ainda não testado.

Detalhes de build Linux permanecem em `kernel.md`; o MVP Ubuntu permanece em `LIVE_CD_RESOLUTE.md`.
