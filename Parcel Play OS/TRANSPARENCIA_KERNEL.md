# Transparência e Catálogo de Fontes dos Kernels

**Última verificação:** 15 de agosto de 2026
**Objetivo:** fornecer URLs oficiais, diretas e clonáveis para as árvores de kernel, patches e arquivos de empacotamento usados como referência pelo Parcel Play OS.

## Como interpretar este catálogo

As distribuições não publicam seus kernels sempre da mesma forma:

- **Árvore completa:** contém o código-fonte completo do kernel.
- **Árvore downstream:** contém o Linux completo mais patches e configurações da distribuição.
- **Empacotamento:** contém `PKGBUILD`, spec, regras Debian, configurações ou receitas que buscam o código upstream durante o build.
- **Patchset:** contém apenas diferenças aplicadas sobre uma versão do Linux upstream.
- **Sistema BSD:** o kernel faz parte da árvore completa do sistema base; não é normalmente mantido como projeto isolado.

Por isso, um link de empacotamento ou patchset não deve ser descrito como se fosse sozinho o código completo do kernel.

## 1. Base Linux upstream

### Linux mainline — kernel.org

- **Tipo:** árvore completa e fonte canônica do Linux.
- **Navegação:** <https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/>
- **Clone direto:** <https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git>

```bash
git clone https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
```

O espelho de Torvalds no GitHub também é clonável:

```text
https://github.com/torvalds/linux.git
```

## 2. Decágono de referência

### Arch Linux

- **Árvore downstream completa:** <https://github.com/archlinux/linux.git>
- **Empacotamento oficial:** <https://gitlab.archlinux.org/archlinux/packaging/packages/linux.git>
- **Página do pacote:** <https://archlinux.org/packages/core/x86_64/linux/>

```bash
git clone https://github.com/archlinux/linux.git arch-linux
git clone https://gitlab.archlinux.org/archlinux/packaging/packages/linux.git arch-linux-packaging
```

A árvore do GitHub contém o kernel Arch. O repositório do GitLab contém a receita oficial de build e aponta para as fontes utilizadas pelo pacote corrente.

### openSUSE

- **Tipo:** fonte e empacotamento do kernel openSUSE/SUSE.
- **Navegação:** <https://github.com/openSUSE/kernel-source>
- **Clone direto:** <https://github.com/openSUSE/kernel-source.git>

```bash
git clone https://github.com/openSUSE/kernel-source.git opensuse-kernel-source
```

Os branches variam por produto e ciclo. A revisão deve ser fixada explicitamente antes de qualquer comparação ou porte.

### Fedora — Kernel ARK

- **Tipo:** árvore downstream completa, configurações, patches e scripts de build Fedora/ARK.
- **Navegação:** <https://gitlab.com/cki-project/kernel-ark>
- **Clone direto:** <https://gitlab.com/cki-project/kernel-ark.git>
- **Documentação oficial:** <https://cki-project.gitlab.io/kernel-ark/>
- **Branch de desenvolvimento:** `os-build`.
- **Snapshot conhecido como bom:** `ark-latest`.

```bash
git clone --branch os-build https://gitlab.com/cki-project/kernel-ark.git fedora-kernel-ark
```

### FreeBSD

- **Tipo:** árvore completa do sistema base; o kernel está dentro de `sys/`.
- **Navegação:** <https://cgit.freebsd.org/src/>
- **Clone oficial direto:** <https://git.FreeBSD.org/src.git>
- **Espelho GitHub:** <https://github.com/freebsd/freebsd-src.git>

```bash
git clone -o freebsd https://git.FreeBSD.org/src.git freebsd-src
```

### Debian

- **Tipo:** árvore do pacote-fonte do kernel Debian, com código, patches e regras de empacotamento.
- **Navegação:** <https://salsa.debian.org/kernel-team/linux>
- **Clone direto:** <https://salsa.debian.org/kernel-team/linux.git>

```bash
git clone https://salsa.debian.org/kernel-team/linux.git debian-linux
```

Os branches correspondem a diferentes versões e suítes Debian. O branch deve ser escolhido e fixado conforme a versão que estiver sendo auditada.

### Gentoo

- **Tipo:** patchset Gentoo; não é sozinho uma árvore Linux completa.
- **Navegação:** <https://gitweb.gentoo.org/proj/linux-patches.git/>
- **Clone direto:** <https://anongit.gentoo.org/git/proj/linux-patches.git>
- **Receitas oficiais do Portage:** <https://gitweb.gentoo.org/repo/gentoo.git/tree/sys-kernel>

```bash
git clone https://anongit.gentoo.org/git/proj/linux-patches.git gentoo-linux-patches
```

Para reproduzir `gentoo-sources`, é necessário combinar a versão upstream indicada pelo ebuild com o patchset Gentoo correspondente. O repositório `linux-patches` isolado não compila como kernel.

### NetBSD

- **Tipo:** árvore completa do sistema base; o kernel está dentro de `sys/`.
- **Espelho Git oficial clonável:** <https://github.com/NetBSD/src.git>
- **Navegação CVS oficial:** <https://cvsweb.netbsd.org/bsdweb.cgi/src/>

```bash
git clone https://github.com/NetBSD/src.git netbsd-src
```

O GitHub é um espelho do projeto. O histórico e o fluxo primário do NetBSD continuam ligados à infraestrutura CVS oficial.

### OpenBSD

- **Tipo:** árvore completa do sistema base; o kernel está dentro de `sys/`.
- **Espelho Git oficial clonável:** <https://github.com/openbsd/src.git>
- **Navegação CVS oficial:** <https://cvsweb.openbsd.org/src/>

```bash
git clone https://github.com/openbsd/src.git openbsd-src
```

O GitHub é um espelho somente leitura. O desenvolvimento oficial do OpenBSD usa CVS.

### CentOS Stream 10

- **Tipo:** source-git completo do kernel CentOS Stream 10.
- **Navegação:** <https://gitlab.com/redhat/centos-stream/src/kernel/centos-stream-10>
- **Clone direto:** <https://gitlab.com/redhat/centos-stream/src/kernel/centos-stream-10.git>
- **Documentação oficial:** <https://redhat.gitlab.io/centos-stream/src/kernel/documentation/docs/kernel_git_repo_info.html>

```bash
git clone https://gitlab.com/redhat/centos-stream/src/kernel/centos-stream-10.git centos-stream-10-kernel
```

### Oracle Linux — UEK

- **Tipo:** árvore downstream completa do Unbreakable Enterprise Kernel.
- **Navegação:** <https://github.com/oracle/linux-uek>
- **Clone direto:** <https://github.com/oracle/linux-uek.git>
- **Documentação oficial:** <https://docs.oracle.com/en/operating-systems/uek/>

```bash
git clone https://github.com/oracle/linux-uek.git oracle-linux-uek
```

O repositório contém múltiplas linhas UEK. É obrigatório selecionar uma tag ou branch correspondente à release que será estudada.

## 3. Ubuntu Resolute — base do MVP

- **Tipo:** árvore Ubuntu completa para a série Resolute.
- **Navegação:** <https://git.launchpad.net/~ubuntu-kernel/ubuntu/+source/linux/+git/resolute>
- **Clone direto HTTPS:** <https://git.launchpad.net/~ubuntu-kernel/ubuntu/+source/linux/+git/resolute>
- **Documentação oficial:** <https://documentation.ubuntu.com/kernel/explanation/ubuntu-linux-kernel-sources/>
- **Branch publicado:** `master`.
- **Próxima atualização em integração:** `master-next`.

Para obter a árvore em desenvolvimento do Resolute:

```bash
git clone --branch master-next \
  https://git.launchpad.net/~ubuntu-kernel/ubuntu/+source/linux/+git/resolute \
  ubuntu-resolute-kernel
```

Antes do build, confirmar obrigatoriamente:

```bash
git -C ubuntu-resolute-kernel remote -v
git -C ubuntu-resolute-kernel branch --show-current
git -C ubuntu-resolute-kernel log -1 --oneline
head -n 5 ubuntu-resolute-kernel/debian.master/changelog
make -s -C ubuntu-resolute-kernel kernelversion
```

O clone deve ficar em um caminho sem espaços ou dois-pontos, pois o Makefile do Linux rejeita esses caracteres no caminho da árvore-fonte.

## 4. Kernels comunitários de performance

Estas árvores são referências opcionais, não bases aprovadas automaticamente para o NitroCore.

| Projeto | Clone direto |
| --- | --- |
| XanMod | <https://github.com/xanmod/linux.git> |
| Zen Kernel | <https://github.com/zen-kernel/zen-kernel.git> |
| CachyOS | <https://github.com/CachyOS/linux-cachyos.git> |
| Clear Linux, arquivado | <https://github.com/clearlinux-pkgs/linux.git> |

## 5. Projetos Parcel

Estes repositórios devem ser tratados como projetos próprios, não como fontes oficiais das distribuições citadas acima:

- <https://github.com/marcel1237/kernel.git>
- <https://github.com/marcel1237/kernel-source.git>

## 6. Política de uso no Parcel Play OS

1. Nunca usar somente o nome de uma distribuição como identificação de fonte.
2. Registrar URL clonável, branch ou tag e commit completo.
3. Registrar se a origem é árvore completa, patchset, empacotamento ou espelho.
4. Preservar licenças, avisos de copyright e identificadores SPDX.
5. Não misturar código BSD e GPL sem análise por arquivo e arquitetura de integração compatível.
6. Não declarar uma qualidade “herdada” antes de existir patch, configuração, build e teste mensurável.
7. Manter o Ubuntu Resolute oficial como baseline e fallback enquanto NitroCore não estiver validado.

Modelo mínimo para registrar uma revisão:

```text
Sistema: Fedora Kernel ARK
URL: https://gitlab.com/cki-project/kernel-ark.git
Branch: os-build
Commit: SHA-1/SHA-256 completo obtido após o clone
Tipo: árvore downstream completa
Data da auditoria: AAAA-MM-DD
```

## 7. Estado da verificação

As URLs foram revisadas em 15 de agosto de 2026 contra páginas dos projetos e documentação oficial disponível. A presença de um repositório não significa que qualquer branch corrente seja estável ou compatível com o Parcel Play OS. Builds reproduzíveis devem sempre fixar um commit e validar sua assinatura ou proveniência quando o projeto de origem oferecer esse mecanismo.
