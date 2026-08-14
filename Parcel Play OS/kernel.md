# Documentação do Kernel NitroCore

O **NitroCore** é o núcleo customizado do Parcel Play OS, projetado para oferecer performance em hardware moderno sem abandonar compatibilidade, segurança e confiabilidade. Durante o desenvolvimento, o kernel oficial do Ubuntu Resolute será mantido como referência e fallback inicializável.

## 1. Filosofia de Desenvolvimento
O NitroCore baseia-se no conceito de **"Independência Técnica"**. O núcleo é construído diretamente a partir do código-fonte upstream, utilizando o conhecimento coletivo do **Decágono de Referência**.

## 2. Os 11 perfis de kernel
O usuário poderá escolher a personalidade do sistema no menu de boot da Live ISO. Dez entradas são perfis NitroCore planejados e a décima primeira é o kernel oficial Ubuntu:

1. **Ubuntu Oficial (padrão inicial e fallback)**: Kernel empacotado e assinado do Ubuntu Resolute, usado como baseline de compatibilidade e recuperação.
2. **NitroCore Arch**: Perfil planejado de simplicidade e proximidade com o kernel upstream.
3. **NitroCore openSUSE**: Perfil planejado de estabilidade e gestão de patches.
4. **NitroCore Fedora**: Perfil planejado de inovação e hardware recente.
5. **FreeBSD**: Sistema BSD real e independente; não utiliza o rootfs Ubuntu/Casper.
6. **NitroCore Debian**: Perfil planejado de estabilidade e compatibilidade.
7. **NitroCore Gentoo**: Perfil planejado de configuração e otimização de compilação.
8. **NetBSD**: Sistema BSD real e independente; não utiliza o rootfs Ubuntu/Casper.
9. **OpenBSD**: Sistema BSD real e independente; inicialmente por `bsd.rd` para instalação/recuperação.
10. **NitroCore CentOS**: Perfil planejado de requisitos enterprise e estabilidade operacional.
11. **NitroCore Oracle**: Perfil planejado de I/O e cargas de banco de dados.

### Estado real

- O kernel Ubuntu é o único perfil disponível para a primeira Live ISO.
- Os sete perfis NitroCore Linux ainda não possuem configurações, patches, pacotes ou imagens compiladas no repositório.
- Os três BSDs exigem payloads e userspaces nativos separados e não podem iniciar GNOME/KDE do rootfs Ubuntu.
- Nenhuma entrada NitroCore deve ser publicada no GRUB até que seu kernel e initramfs sejam construídos e testados.
- O kernel Ubuntu deve permanecer acessível como opção de recuperação mesmo depois da inclusão dos perfis NitroCore.

## 3. Identidade de boot das 11 opções

Os oito kernels Linux deverão possuir uma identidade visual Plymouth própria. FreeBSD, NetBSD e OpenBSD não usam o initramfs/Plymouth Linux e deverão receber branding pelos mecanismos nativos de boot.

Nas oito opções Linux, o GRUB controla a seleção e o Plymouth controla a splash carregada do initramfs. Cada opção Linux precisa ser entregue como uma unidade verificável:

```text
entrada GRUB → kernel → initramfs → tema Plymouth
```

Os oito pares Linux montam um único rootfs Live compartilhado com GNOME e KDE Full. Os três BSDs iniciam userspaces próprios e não montam o SquashFS Ubuntu como sistema raiz.

### Mapeamento obrigatório

| Kernel | Tema | Kernel na Live ISO | Initramfs na Live ISO |
| :--- | :--- | :--- | :--- |
| Ubuntu Oficial | `parcel-ubuntu` | `vmlinuz-ubuntu` | `initrd-ubuntu` |
| NitroCore Arch | `parcel-arch` | `vmlinuz-nitro-arch` | `initrd-nitro-arch` |
| NitroCore openSUSE | `parcel-opensuse` | `vmlinuz-nitro-opensuse` | `initrd-nitro-opensuse` |
| NitroCore Fedora | `parcel-fedora` | `vmlinuz-nitro-fedora` | `initrd-nitro-fedora` |
| FreeBSD | Branding nativo | Payload FreeBSD | Boot nativo FreeBSD |
| NitroCore Debian | `parcel-debian` | `vmlinuz-nitro-debian` | `initrd-nitro-debian` |
| NitroCore Gentoo | `parcel-gentoo` | `vmlinuz-nitro-gentoo` | `initrd-nitro-gentoo` |
| NetBSD | Branding nativo | Payload NetBSD | Boot nativo NetBSD |
| OpenBSD | Branding nativo | `bsd.rd`/payload OpenBSD | Boot nativo OpenBSD |
| NitroCore CentOS | `parcel-centos` | `vmlinuz-nitro-centos` | `initrd-nitro-centos` |
| NitroCore Oracle | `parcel-oracle` | `vmlinuz-nitro-oracle` | `initrd-nitro-oracle` |

### Estrutura de cada tema

Cada tema deve ser instalado em um diretório próprio cujo nome coincida com o arquivo `.plymouth`:

```text
/usr/share/plymouth/themes/parcel-ubuntu/parcel-ubuntu.plymouth
/usr/share/plymouth/themes/parcel-arch/parcel-arch.plymouth
...
/usr/share/plymouth/themes/parcel-oracle/parcel-oracle.plymouth
```

O diretório também pode conter scripts, PNGs, animações, fontes e imagens auxiliares requeridas pelo plugin escolhido. Todos esses recursos precisam ser copiados para o initramfs correspondente.

### Comandos básicos e diferença do Resolute

Em distribuições que fornecem `plymouth-set-default-theme`, os temas disponíveis podem ser listados com:

```bash
plymouth-set-default-theme --list
```

Um único tema pode ser selecionado e ter o initramfs reconstruído automaticamente com:

```bash
plymouth-set-default-theme --rebuild-initrd NOME_DO_TEMA
```

ou, na forma curta:

```bash
plymouth-set-default-theme -R NOME_DO_TEMA
```

Esse comando é apropriado para uma máquina com um tema global. Ele **não deve ser executado cegamente onze vezes** para produzir a Live ISO: a seleção é global, e a última execução pode fazer vários initramfs receberem o mesmo tema.

Na verificação do host Ubuntu 26.04 Resolute em 2026-08-13, `plymouth-set-default-theme` **não estava disponível**. O tema ativo era gerenciado por `update-alternatives`, e `update-initramfs` reportava Dracut 110. Nesse ambiente, listar e selecionar temas utiliza:

```bash
update-alternatives --list default.plymouth
update-alternatives --set default.plymouth \
  /usr/share/plymouth/themes/NOME_DO_TEMA/NOME_DO_TEMA.plymouth
update-initramfs -u -k VERSAO_DO_KERNEL
```

Antes de selecionar um tema Parcel, ele precisa estar registrado como alternativa. Exemplo conceitual:

```bash
update-alternatives --install \
  /usr/share/plymouth/themes/default.plymouth \
  default.plymouth \
  /usr/share/plymouth/themes/parcel-ubuntu/parcel-ubuntu.plymouth \
  200
```

A existência e a sintaxe dos utilitários devem ser detectadas pelo script de build. O fluxo não deve presumir que todos os sistemas Ubuntu/Debian oferecem o mesmo comando auxiliar.

### Geração individual

O processo de build deverá, para cada linha da tabela:

1. confirmar que o kernel correspondente existe;
2. instalar e selecionar somente o tema correspondente;
3. regenerar o initramfs para a versão específica com `update-initramfs -u -k VERSAO`;
4. copiar imediatamente o arquivo produzido para o nome exclusivo em `casper/`;
5. verificar que o tema correto está dentro do arquivo;
6. somente então criar ou habilitar a entrada GRUB.

Modelo a ser automatizado pelo futuro script de build:

```bash
update-alternatives --set default.plymouth \
  /usr/share/plymouth/themes/parcel-arch/parcel-arch.plymouth
update-initramfs -u -k VERSAO_NITRO_ARCH
cp /boot/initrd.img-VERSAO_NITRO_ARCH /CAMINHO_DA_ISO/casper/initrd-nitro-arch
lsinitramfs /CAMINHO_DA_ISO/casper/initrd-nitro-arch | grep 'themes/parcel-arch/'
```

Os valores em maiúsculas são placeholders e não devem ser executados literalmente. A sequência será aplicada aos oito kernels Linux usando seus nomes e versões reais. Os três BSDs seguem procedimentos nativos descritos em `LIVE_ISO_11_KERNELS.md`.

Se imagens de um tema forem editadas manualmente, o initramfs daquele kernel deverá ser regenerado e validado novamente. Alterar apenas `/usr/share/plymouth/themes/` depois que o initramfs foi criado não atualiza a splash já incorporada.

### Critério de aceite

Nenhum kernel Linux será considerado pronto para a Live ISO sem:

- tema instalado e listado pelo Plymouth;
- initramfs exclusivo;
- confirmação do tema por `lsinitramfs`;
- entrada GRUB apontando para o par correto;
- boot completo em máquina virtual;
- captura da splash correta;
- teste de `Esc` para exibir mensagens;
- teste de prompt de criptografia quando aplicável;
- resultado documentado em Markdown.

### Verificações locais realizadas

- Plymouth instalado: `24.004.60+git20250831.4a3c171d-0ubuntu8`.
- `update-initramfs`: Dracut `110-11`.
- `lsinitramfs` e `lsinitrd`: disponíveis.
- `plymouth-set-default-theme`: ausente no host verificado.
- Alternativa Plymouth ativa durante a inspeção: tema `kubuntu-logo`.
- Nenhuma alternativa, configuração Plymouth ou imagem initramfs foi modificada durante a análise.

## 4. Auditoria de prontidão para Live ISO

### Resultado em 2026-08-13

Os procedimentos básicos **ainda não estão completos** para gerar uma mídia com as onze opções. A arquitetura Linux de nomes, Plymouth e GRUB está documentada, mas os BSDs exigem uma arquitetura multi-OS e ainda não existe pipeline executável.

| Área | Ubuntu Oficial | Sete NitroCore Linux + três BSDs | Situação geral |
| :--- | :--- | :--- | :--- |
| Fonte identificada | Sim, repositório Resolute | Base ainda não fixada corretamente no projeto | Parcial |
| Versão/commit fixado | Não registrado para a ISO | Não | Bloqueado |
| Configuração/payload | Fornecida pelo pacote Ubuntu da ISO | Sete NitroCore Linux e três payloads BSD ausentes | Bloqueado |
| ABI e nome exclusivos | Ubuntu fornece seu ABI | Não definidos | Bloqueado |
| Compilação real | Disponível como pacote oficial | Script atual somente imprime mensagens | Bloqueado |
| Pacotes de imagem e módulos | Disponíveis no arquivo Ubuntu | Não produzidos | Bloqueado |
| Módulos em `/lib/modules` | Presentes na ISO oficial | Ausentes | Bloqueado |
| Firmware | Presente na ISO oficial | Compatibilidade ainda não testada | Parcial |
| Initramfs com Casper | Presente na ISO oficial | Não gerado | Bloqueado |
| Temas Plymouth Parcel | Não criado | Não criados | Bloqueado |
| Entradas GRUB finais | Entrada oficial existe na ISO-base | Não criadas | Bloqueado |
| Secure Boot/assinatura | Preservado apenas usando artefatos oficiais | Estratégia de chaves ausente | Bloqueado |
| Boot em VM | Ainda não executado pelo projeto | Não | Bloqueado |
| Instalação no destino | Ainda não executada pelo projeto | Não | Bloqueado |

Conclusão: somente o kernel Ubuntu da ISO oficial pode ser usado no primeiro protótipo. Os sete NitroCore Linux estão em especificação e os três BSDs ainda não possuem payloads nativos integrados.

### Correção do modelo de fontes

Para manter compatibilidade com o userspace Resolute, a abordagem mínima recomendada é:

- preservar o kernel Ubuntu oficial sem alterações como primeira opção e fallback Linux;
- usar uma revisão fixada da árvore Ubuntu Resolute como base de empacotamento dos sete perfis NitroCore Linux;
- aplicar configurações e patches documentados por perfil;
- usar nomes de flavor e ABI exclusivos para impedir colisões entre pacotes e diretórios de módulos.

Arch, openSUSE, Fedora, Debian, Gentoo, CentOS e Oracle são referências de configuração dos sete NitroCore Linux. FreeBSD, NetBSD e OpenBSD serão sistemas reais separados e não serão inicializados com o userspace Ubuntu/Casper.

### Identidade técnica obrigatória

Cada build precisa possuir uma versão que não colida com as demais. Modelo conceitual:

```text
VERSAO-ABI-nitro-arch
VERSAO-ABI-nitro-opensuse
VERSAO-ABI-nitro-fedora
VERSAO-ABI-nitro-debian
VERSAO-ABI-nitro-gentoo
VERSAO-ABI-nitro-centos
VERSAO-ABI-nitro-oracle
```

Os BSDs não seguem esse esquema Linux de ABI/pacotes `.deb`; cada um mantém a versão e o formato de distribuição nativos.

Essa identidade deve coincidir entre:

- `uname -r`;
- `/boot/vmlinuz-*`;
- `/boot/initrd.img-*`;
- `/lib/modules/$(uname -r)`;
- nomes dos pacotes `.deb`;
- entrada GRUB;
- tema Plymouth esperado;
- logs e manifesto da ISO.

## 5. Procedimento básico comum aos oito kernels Linux

### Etapa 1 — Fixar a entrada

Registrar antes do build:

- URL da fonte;
- branch;
- commit completo;
- versão Ubuntu;
- arquitetura, inicialmente `amd64`;
- toolchain e versões;
- hash da configuração;
- patches e ordem de aplicação.

Builds baseados apenas em “branch mais recente” não são reproduzíveis.

### Etapa 2 — Criar configuração válida

O kernel da Live ISO precisa suportar, embutido ou por módulos disponíveis no initramfs:

- initramfs e `devtmpfs`;
- loop devices;
- SquashFS e o algoritmo de compressão usado pela ISO;
- OverlayFS;
- ISO 9660 e mídia USB;
- NVMe, AHCI/SATA e armazenamento USB;
- USB HID, teclado e console;
- DRM/KMS necessário ao Plymouth;
- rede usada pelo modo Live;
- EFI, GPT e os sistemas de arquivos oferecidos pelo instalador;
- device mapper e criptografia quando LUKS for oferecido.

Cada configuração deve passar por `olddefconfig`, validação de políticas Ubuntu e comparação documentada contra o baseline.

### Etapa 3 — Construir pacotes instaláveis

Para a árvore Ubuntu Resolute, o fluxo de referência é o empacotamento Ubuntu:

```bash
fakeroot debian/rules clean
fakeroot debian/rules binary
```

A documentação oficial informa que o build gera, entre outros, pacotes de headers, imagem e módulos: <https://canonical-kernel-docs.readthedocs-hosted.com/how-to/develop-customise/build-kernel/>.

Para uma árvore upstream experimental, `make bindeb-pkg` pode gerar pacotes Debian, mas esses pacotes não substituem automaticamente todas as integrações do empacotamento Ubuntu. Não se deve misturar os dois métodos dentro do mesmo perfil sem decisão documentada.

Artefatos mínimos por perfil NitroCore:

- pacote de imagem;
- pacote de módulos;
- headers para DKMS;
- arquivo de configuração;
- `System.map`;
- metadados de build e checksums.

### Etapa 4 — Instalar no rootfs da Live ISO

Copiar somente `vmlinuz` e initramfs para `casper/` é insuficiente. Os pacotes devem ser instalados no rootfs que será comprimido, garantindo:

```text
/lib/modules/VERSAO_COMPLETA/
/usr/lib/modules/VERSAO_COMPLETA/
/boot/vmlinuz-VERSAO_COMPLETA
/boot/initrd.img-VERSAO_COMPLETA
```

Dependendo da política `usrmerge`, `/lib/modules` pode apontar para `/usr/lib/modules`. O resultado real deve ser verificado, não presumido.

Depois da instalação dos pacotes:

```bash
depmod -a VERSAO_COMPLETA
```

DKMS, drivers adicionais e firmware devem ser construídos ou validados para cada ABI. Um módulo compilado para um perfil não deve ser reutilizado cegamente em outro.

O mesmo rootfs deverá conter simultaneamente os diretórios de módulos dos oito kernels Linux. Depois que o kernel escolhido montar o SquashFS, `/lib/modules/$(uname -r)` precisa resolver para o diretório daquele perfil. Os BSDs usam rootfs próprios.

### Etapa 5 — Gerar initramfs com Casper e Plymouth

Para cada kernel:

1. garantir que o gerador inclua o suporte necessário para montar a Live ISO;
2. incorporar módulos de armazenamento, SquashFS, OverlayFS, DRM/KMS e firmware necessário ao early boot;
3. incorporar o tema Plymouth correspondente;
4. gerar para a versão exata;
5. verificar o arquivo com `lsinitramfs` ou `lsinitrd`;
6. copiar para o nome exclusivo em `casper/`.

A presença de uma imagem Plymouth não comprova que o initramfs consegue localizar e montar o filesystem Live. O boot `boot=casper` precisa ser testado em cada perfil.

### Etapa 6 — Criar entrada GRUB

A entrada só pode ser ativada depois que estes arquivos existirem:

```text
/casper/vmlinuz-PERFIL
/casper/initrd-PERFIL
```

Parâmetros mínimos conceituais:

```text
boot=casper quiet splash parcel.kernel=PERFIL
```

Os parâmetros reais da ISO oficial devem ser preservados. Opções como caminho de camadas, integridade, idioma e acessibilidade não podem ser removidas ao criar as entradas Parcel.

### Etapa 7 — Manifestos e instalador

Os onze pacotes de kernel e módulos precisam constar no filesystem e nos manifestos relevantes da ISO. O instalador deve ser testado para confirmar se:

- mantém todos os oito kernels Linux no sistema instalado; ou
- instala somente o Linux escolhido mais o Ubuntu fallback.

Essa política ainda não foi decidida. Para o MVP, instalar somente o Ubuntu oficial é o comportamento aprovado.

### Etapa 8 — Assinatura e Secure Boot

O kernel Ubuntu oficial preserva a cadeia de confiança somente enquanto seus artefatos assinados e o boot oficial forem mantidos. Kernels NitroCore locais não serão aceitos automaticamente pelo Secure Boot.

Antes de anunciar suporte, o projeto precisa definir:

- chave de assinatura;
- proteção e rotação da chave privada;
- assinatura dos kernels e módulos;
- integração com shim/MOK ou infraestrutura equivalente;
- procedimento de revogação;
- teste em firmware com Secure Boot habilitado.

Até isso existir, os NitroCore devem ser classificados como builds de desenvolvimento que podem exigir Secure Boot desabilitado. Isso não se aplica ao fallback Ubuntu oficial.

### Etapa 9 — Testar cada kernel

Matriz mínima por perfil:

1. checksum dos pacotes e arquivos da ISO;
2. boot UEFI sem Secure Boot;
3. splash Plymouth correta;
4. montagem do SquashFS e OverlayFS;
5. entrada na sessão Live;
6. armazenamento NVMe, SATA e USB em VMs/dispositivos disponíveis;
7. rede, áudio, vídeo e entrada;
8. abertura do instalador;
9. instalação em disco virtual descartável;
10. reboot no sistema instalado;
11. confirmação de `uname -r` e `/lib/modules/$(uname -r)`;
12. fallback pelo kernel Ubuntu;
13. teste posterior de Secure Boot quando houver assinatura.

Cada resultado deve ser registrado como aprovado, reprovado ou não testado. “Compilou” não equivale a “pronto para Live ISO”.

## 6. Recursos de build

A documentação oficial da Canonical recomenda pelo menos 8 GB de RAM e 30 GB livres para construir um kernel Ubuntu. O host auditado possuía aproximadamente 5,1 GiB de RAM e 4 GiB de swap, abaixo da recomendação de RAM, embora tivesse cerca de 161 GB livres.

Para onze builds:

- compilar sequencialmente;
- limitar paralelismo para evitar falta de memória;
- limpar artefatos intermediários entre perfis somente depois de guardar pacotes e logs;
- monitorar espaço, temperatura e erros de OOM;
- não construir simultaneamente onze árvores nesse host.

O espaço atual pode não ser suficiente para manter onze árvores completas com símbolos de depuração. A retenção deve privilegiar fontes compartilhadas, configurações, patches, pacotes finais e logs.

## 7. Tecnologias Integradas (Thunder SDK)
O NitroCore é uma plataforma acelerada, segura e escalável:
- **NitroCore Scheduler**: Escalonamento inteligente para jogos e produtividade.
- **OmniLock Memory Matrix**: Gestão de RAM sem latência (HugePages/Maple Tree).
- **Dark Volt Handshake**: Inicialização acelerada e segura.
- **Enterprise Hardening**: Auditoria de integridade inspirada no CentOS/OpenBSD.

## 8. Estrutura de Build
O processo de construção segue o modelo de 8 etapas:
1.  **Clonagem**: Código original do GitHub do Linus Torvalds.
2.  **Auditoria**: Comparação documentada com as referências técnicas e com o baseline Ubuntu.
3.  **Injeção**: Aplicação das otimizações Thunder, Security Hardening e Enterprise IO.
4.  **Compilação**: Toolchain moderna (GCC 15+ / Clang 18+).

## 9. Transparência
Todo o código do NitroCore é auditável. Os patches aplicados sobre a base Vanilla são documentados no arquivo `TRANSPARENCIA_KERNEL.md`.

---
*Versão documental: 1.3.0 — 11 perfis, incluindo fallback Ubuntu*
*Responsável: Marcel / Parcel Play OS Team*
