# Solução dos impedimentos da recriação da ISO Calamares + XFCE

## Metadados

- **ID:** `KB-PLAYOS-SOLVE-FIRST-CALAMARES-ISO-001`
- **Tipo:** `audit-and-corrective-procedure`
- **Estado:** `result` para a auditoria; `implementation` para as correções; novo build pendente
- **Confiança:** alta
- **Data:** 2026-08-29
- **Entrada:** `RELATORIO_TECNICO_IMPEDIMENTOS_ISO.artifact.md`
- **Artefato:** `build/playos-graphics-core-noble/output/playos-noble-xfce-calamares-amd64.iso`

## Conclusão

O relatório revela que foram combinados dois pipelines incompatíveis:

```text
ISO original: live-build -> live-boot -> /live/filesystem.squashfs -> boot=live
tentativa:     livecd-rootfs -> Casper -> /casper/filesystem.squashfs -> boot=casper
```

A solução para recriar a primeira ISO é usar exclusivamente o primeiro.
Desktop Provision deverá usar o segundo em outro perfil, outra VM e outro
output.

## Respostas aos impedimentos

### Conflito `dpkg-divert`

Na ISO original, `live-tools` está instalado, mas `livecd-rootfs` não aparece
no manifesto. O build histórico não deveria possuir previamente:

```text
local diversion of /usr/sbin/update-initramfs
to /usr/sbin/update-initramfs.REAL
```

Essa diversão veio do `livecd-rootfs`. Removê-la por hook dentro de um chroot
parcialmente configurado é inseguro. Descarte esse chroot e use uma VM/diretório
limpo com apenas `lb config` e `lb build`. Não execute `build-livefs`,
`build-livefs-lxd` ou scripts de `livecd-rootfs` nesse ambiente.

### Tasks, germinate e NVIDIA

A primeira ISO não usa `common_layered_desktop_image`, projeto `playos` do
`livecd-rootfs`, seeds customizadas ou `germinate-output/structure`. XFCE e
Calamares entram por
`config/package-lists/playos-graphics-core.list.chroot`.

Portanto, `did not find task 'minimal'` e a resolução de `nvidia-driver-550`
são problemas da rota errada. Não injete o manifesto de 1.110 pacotes como
lista direta: ele inclui dependências transitivas históricas. Use a lista
direta do perfil e deixe o APT resolver dependências Noble.

### Detecção da mídia

A ISO canônica contém:

```text
/.disk/info
/live/filesystem.squashfs
/live/vmlinuz-6.8.0-138-generic
/live/initrd.img-6.8.0-138-generic
```

Ela não possui nem exige marcador `/ubuntu`, diretório `/casper/` ou
`live-media-path=/casper/`. Seu GRUB real usa:

```text
linux /live/vmlinuz-6.8.0-138-generic boot=live config components ...
initrd /live/initrd.img-6.8.0-138-generic
```

O kernel 6.8.0-138 não exige outro parâmetro conhecido nesse pipeline. O erro
de mídia da tentativa resultou da convenção Casper aplicada a uma composição
que deveria usar `live-boot`.

### Recursos do host

`nohup` não resolve falta de memória; apenas desacopla o terminal. Use VM de no
máximo 4 GiB neste host e reduza concorrência. Após SIGHUP, reset de conexão,
soft lockup ou interrupção do `dpkg`, descarte o chroot. Não declare como
reproduzível um chroot recuperado com `dpkg --configure -a` após interrupção.

### XFCE versus Graphics Core neutro

Não há contradição. O Graphics Core é uma camada sem desktop. A Live consome
essa camada e acrescenta XFCE. O hook registra separadamente:

```text
graphics_core_desktop_environment=none
live_profile_desktop_environment=xfce
```

XFCE já está autorizado e declarado no perfil da Live.

## Procedimento corrigido

Na raiz do projeto:

```sh
profile_work="$(mktemp -d /tmp/playos-first-calamares.XXXXXX)"
rmdir "$profile_work"
./live-build/playos-graphics-core-noble/tools/prepare-first-calamares-profile.sh \
  "$profile_work"
cd "$profile_work"
```

O preparador restaura o `settings.conf` extraído da ISO, remove da cópia
`subiquity-server`, `curtin`, `casper` e os módulos híbridos posteriores, e
valida `live-boot`, `unpackfs` e `bootloader`.

Em uma VM Ubuntu Noble limpa:

```sh
sudo apt-get update
sudo apt-get install -y \
  live-build debootstrap squashfs-tools xorriso \
  grub-pc-bin grub-efi-amd64-bin mtools dosfstools

sudo lb clean --purge
sudo lb config
sudo lb build 2>&1 | tee playos-noble-xfce-calamares-build.log
```

Se `live-build 3.0~a57` produzir `binary/` ou `chroot/binary/` e falhar somente
na montagem final:

```sh
sudo ./tools/finalize-grub-iso.sh \
  playos-noble-xfce-calamares-amd64.iso
```

Não execute funções `common_layered_*`, germinate ou `build-livefs-lxd`. Não
renomeie `/live` para `/casper`.

## Gates obrigatórios

Antes do build:

```sh
grep -qx live-boot config/package-lists/playos-graphics-core.list.chroot
! grep -qxE '(casper|subiquity-server|curtin)' \
  config/package-lists/playos-graphics-core.list.chroot
grep -q -- '--initramfs live-boot' auto/config
! grep -R -E 'common_layered|germinate|boot=casper|/casper/' auto config tools
```

Depois da ISO:

```sh
xorriso -indev playos-noble-xfce-calamares-amd64.iso \
  -find /live -maxdepth 2 -type f
xorriso -osirrox on \
  -indev playos-noble-xfce-calamares-amd64.iso \
  -extract /boot/grub/grub.cfg /tmp/playos-first-grub.cfg
grep -E 'boot=live|/live/vmlinuz|/live/initrd' /tmp/playos-first-grub.cfg
! grep -E 'boot=casper|/casper/' /tmp/playos-first-grub.cfg
```

## Limite

Isso resolve os bloqueios de recriação da composição histórica. Não resolve
automaticamente a falha funcional do Calamares informada pelo usuário. Essa
falha exige boot em VM e coleta de `calamares -d`, `journalctl`, `lsblk` e
`findmnt`. Desktop Provision é uma variante separada, não um remendo deste
perfil.
