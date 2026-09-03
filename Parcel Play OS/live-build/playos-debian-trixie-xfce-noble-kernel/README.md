# PlayOS Debian 13 XFCE com kernel Ubuntu Noble

Receita para uma Live amd64 baseada no pipeline Debian Live:

```text
Debian 13 trixie userspace
  + live-boot/live-config + SquashFS/OverlayFS
  + XFCE/Xorg/LightDM Debian
  + kernel e módulos Ubuntu Noble locais
  - Calamares/Subiquity/Curin/Casper
```

O kernel não transforma o userspace em Ubuntu. `/etc/os-release`, libc,
systemd, XFCE, Mesa, PipeWire, rede, firmware, bootloader e aplicações vêm dos
repositórios Debian Trixie. Somente imagem e módulos do kernel são artefatos
Ubuntu Noble locais.

## Relação com o manifesto da primeira ISO

`manifests/ubuntu-reference-minus-calamares.packages` deriva de
`Live cd Xfce-calamares filesystem.packages`: são 1.109 das 1.110 linhas, com
remoção literal apenas de `calamares 3.3.5-0ubuntu4`.

Esse arquivo é referência/auditoria, não uma lista APT Debian. Ele contém
versões, nomes e dependências já resolvidas pelo Ubuntu. Alimentá-lo diretamente
ao APT Debian misturaria distribuições e falharia em nomes exclusivos Ubuntu.

Após normalizar sufixos de arquitetura, 1.045 nomes também existem nos índices
Trixie e 64 não existem com o mesmo nome. Os relatórios ficam em
`manifests/debian-trixie-name-matches.txt` e
`manifests/ubuntu-names-not-in-debian-trixie.txt`. “Nome não encontrado” pode
significar pacote Ubuntu, troca de ABI ou renomeação Debian; não significa que
a função inteira foi descartada.

A lista operacional `config/package-lists/playos-xfce.list.chroot` preserva as
funções do manifesto usando nomes existentes no Debian. Como Calamares não é
solicitado, suas dependências exclusivas Qt/KPMcore não entram. Dependências
compartilhadas permanecem quando XFCE ou outra função precisar delas.

## Por que não usar `live-task-xfce`

No Debian 13, `live-task-xfce` recomenda `calamares-settings-debian`. Para uma
Live comprovadamente sem instalador, esta receita pede diretamente `xfce4`,
`xfce4-goodies`, LightDM, serviços e utilitários. O hook de auditoria aborta se
Calamares, seus settings ou instaladores Ubuntu aparecerem.

## Pré-requisitos

Construa em Debian 13 Trixie usando o `live-build` Debian atual. O pacote
`live-build 3.0~a57` do host Ubuntu é antigo e já apresentou falhas com GRUB e
`isohybrid`; `tools/preflight.sh` o rejeita deliberadamente.

No builder Debian:

```sh
sudo apt update
sudo apt install live-build debootstrap squashfs-tools xorriso \
  grub-pc-bin grub-efi-amd64-bin dosfstools mtools isolinux syslinux-common
```

## 1. Importar o kernel Noble

Obtenha os três `.deb` correspondentes exatamente à ABI confirmada no
manifesto histórico:

```text
linux-image-6.8.0-138-generic
linux-modules-6.8.0-138-generic
linux-modules-extra-6.8.0-138-generic
```

Depois:

```sh
./tools/import-noble-kernel.sh \
  /caminho/linux-image-6.8.0-138-generic_*_amd64.deb \
  /caminho/linux-modules-6.8.0-138-generic_*_amd64.deb \
  /caminho/linux-modules-extra-6.8.0-138-generic_*_amd64.deb
```

O importador valida nomes/arquitetura, copia os artefatos e grava SHA-256. Não
adicione mirror Ubuntu ao chroot Debian.

## 2. Construir

Use staging sem espaços, preferencialmente em filesystem com pelo menos 20 GiB
livres:

```sh
cp -a playos-debian-trixie-xfce-noble-kernel \
  /home/marcel/playos-debian-trixie-xfce-noble-kernel
cd /home/marcel/playos-debian-trixie-xfce-noble-kernel
sudo ./tools/build.sh
```

O script executa preflight, limpa somente o staging, configura `lb`, constrói
a ISO e gera SHA-256. Não há instalador.

## 3. Validar

Antes de chamar a imagem de funcional:

```sh
xorriso -indev *.iso -report_el_torito as_mkisofs
sha256sum -c *.iso.sha256
```

Testar BIOS e UEFI em VM. Dentro da Live:

```sh
cat /etc/os-release
uname -r
findmnt -t squashfs,overlay
systemctl is-active lightdm NetworkManager
xfce4-session --version
dpkg-query -W calamares calamares-settings-debian 2>&1
```

O resultado esperado é userspace Debian Trixie, kernel
`6.8.0-138-generic`, XFCE ativo e ausência dos pacotes Calamares. Secure Boot,
instalação em disco e hardware real ficam fora deste primeiro gate.
