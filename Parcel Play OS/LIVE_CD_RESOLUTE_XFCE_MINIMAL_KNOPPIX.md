# Live ISO mínima: Ubuntu Resolute + kernel oficial + XFCE 4.20

- ID: `PLAYOS-LIVE-RESOLUTE-XFCE-MINIMAL-001`
- tipo: `proposal`
- estado: analisado; não implementado; não compilado; não inicializado
- confiança: alta para a arquitetura; média para comandos até o primeiro build
- data: 2026-08-26

## Veredito

O procedimento mais simples para obter uma mídia pequena não é partir da ISO
Desktop Ubuntu nem instalar XFCE sobre GNOME. É construir uma raiz mínima
Resolute e adicionar `xubuntu-desktop-minimal`, o kernel `linux-generic`, o
mecanismo Live e poucos utilitários essenciais.

Para o primeiro protótipo sem instalador, recomenda-se `live-build` com
`live-boot` e `live-config`. Isso evita a complexidade das seeds, snaps e
camadas do `livecd-rootfs`. Após a mídia mínima inicializar, outro perfil pode
acrescentar instalador, firmware ampliado e Secure Boot.

“Kernel + XFCE” não bastam isoladamente. Uma Live ISO também precisa de
userland, PID 1, bibliotecas, initramfs, módulos, rootfs comprimido, bootloader,
usuário Live e drivers mínimos.

## O que aproveitar do Knoppix

O Knoppix é um sistema Live Debian com detecção automática de hardware. A
versão 9.1 ofereceu uma edição próxima de 700 MB com kernel, LXDE, ferramentas
de recuperação e navegador, como base enxuta para remasterização.

Sua arquitetura relevante é:

1. bootloader carrega kernel e initramfs;
2. sistemas de arquivos comprimidos ficam somente leitura;
3. uma camada de união oferece escrita durante a sessão;
4. opcionalmente, uma partição conserva mudanças;
5. a imagem híbrida funciona em CD/DVD ou USB.

Knoppix 9.1 usa `cloop` e `aufs`. Para o PlayOS Resolute, o equivalente nativo
e mais simples é SquashFS + OverlayFS. `live-boot` encontra a imagem em `/live`,
monta a raiz somente leitura e cria o ambiente gravável com OverlayFS.

### Aproveitar

- raiz pequena e comprimida;
- boot direto para desktop leve;
- autodetecção por udev e kernel Ubuntu;
- mídia imutável com escrita em RAM;
- persistência somente em etapa posterior;
- perfil mínimo como base de remasterização.

### Não copiar

- `cloop`, `aufs` e patches Knoppix;
- mistura de pacotes stable/unstable;
- scripts históricos sem adaptação ao Resolute;
- suporte 32 e 64 bits simultâneo no primeiro protótipo.

## Arquitetura proposta

```text
ISO híbrida amd64
├── GRUB/bootloader
├── /live/vmlinuz                 linux-generic Resolute
├── /live/initrd.img              initramfs com live-boot
└── /live/filesystem.squashfs
    ├── Ubuntu Resolute mínimo
    ├── systemd + udev + dbus
    ├── XFCE 4.20/Xorg
    ├── LightDM
    ├── NetworkManager
    └── identidade PlayOS mínima
```

```text
firmware → bootloader → kernel → initramfs/live-boot
         → SquashFS + OverlayFS em RAM
         → live-config → usuário Live → LightDM/XFCE
```

## Pacotes mínimos

```text
linux-generic
live-boot
live-config
live-config-systemd
systemd-sysv
xubuntu-desktop-minimal
lightdm
network-manager
sudo
locales
```

`xubuntu-desktop-minimal` é preferível a uma lista manual: no Resolute ele
depende de Xorg, sessão, painel, desktop, `xfwm4`, Thunar, áudio e configurações
Xubuntu. Isso reduz o risco de desktop incompleto. Sua arte deve ser substituída
por pacotes PlayOS somente após o boot básico funcionar.

Usar só `xfce4` + Xorg + LightDM pode ser menor, mas aumenta manutenção e risco.

### Fora do MVP

- GNOME, KDE/Plasma e `ubuntu-desktop`;
- suíte de escritório, loja e snaps de desktop;
- instalador, Calamares, Anaconda ou Subiquity;
- codecs e drivers proprietários;
- PlayOS Kernel 7.1.8;
- persistência.

## Comparação dos métodos

| Opção | Complexidade | Integração Ubuntu | Uso |
|---|---:|---:|---|
| `live-build` + `live-boot` | baixa | suficiente para Live puro | primeiro protótipo |
| `livecd-rootfs` + `casper` | alta | oficial e completa | instalável/release |
| remaster Desktop | média | herda GNOME | não usar no mínimo |
| infraestrutura Knoppix | alta | não é Ubuntu | somente referência |

`casper` continua adequado quando voltarem instalador Ubuntu, Secure Boot e
integração oficial. `live-boot` no MVP é uma simplificação consciente.

## Procedimento proposto

Ainda não executado; validar opções contra a versão instalada de `live-build`.

### 1. Configurar

```bash
mkdir -p build/live-resolute-xfce
cd build/live-resolute-xfce

lb config \
  --mode ubuntu \
  --distribution resolute \
  --architectures amd64 \
  --binary-image iso-hybrid \
  --archive-areas "main restricted universe multiverse" \
  --linux-flavours generic \
  --bootappend-live "boot=live components username=playos hostname=playos locales=pt_BR.UTF-8 keyboard-layouts=br"
```

### 2. Lista de pacotes

Criar `config/package-lists/playos-xfce-minimal.list.chroot`:

```text
linux-generic
live-boot
live-config
live-config-systemd
systemd-sysv
xubuntu-desktop-minimal
lightdm
network-manager
sudo
locales
```

Não fixar `linux-image-7.0.0-XX-generic`; `linux-generic` resolve a revisão do
arquivo Resolute e a versão exata deve entrar no manifesto.

### 3. Início gráfico

Adicionar hook chroot:

```bash
#!/bin/sh
set -eu
systemctl set-default graphical.target
systemctl enable lightdm.service
```

Delegar autologin a `live-config`, sem senha fixa na imagem.

### 4. Compilar

```bash
sudo lb build 2>&1 | tee build.log
```

Normalizar a saída final para `playos-resolute-xfce-amd64.iso`.

### 5. Validar

```bash
sha256sum playos-resolute-xfce-amd64.iso
xorriso -indev playos-resolute-xfce-amd64.iso -report_el_torito as_mkisofs
```

Testar BIOS e UEFI em VM. Na sessão Live:

```bash
uname -r
cat /etc/os-release
xfce4-session --version
printf '%s\n' "$XDG_SESSION_TYPE"
findmnt -t overlay,squashfs
systemctl is-active display-manager
nmcli general status
```

O MVP termina somente se XFCE abrir, SquashFS/OverlayFS estiverem ativos, rede
funcionar e GNOME/Plasma não estiverem instalados.

## Por que não `debootstrap` manual

É possível montar rootfs com `debootstrap`, instalar em chroot, executar
`mksquashfs` e montar GRUB/xorriso. Isso transfere ao projeto repositórios, DNS,
initramfs, exclusões, BIOS/UEFI, checksums e limpeza. É útil para diagnóstico,
mas não é o caminho operacional mais simples.

## Tamanho e desempenho

Os cerca de 700 MB da edição mínima histórica do Knoppix não estimam o
Resolute. Kernel, firmware, idiomas e dependências são diferentes. Tamanho, RAM
mínima e tempo de boot permanecem `unknown` até medição.

## Riscos

1. Resolute está em evolução e os pacotes podem mudar.
2. `live-build` não reproduz toda a engenharia das ISOs oficiais Ubuntu.
3. Xubuntu minimal adiciona configurações e arte além do XFCE puro.
4. Menos firmware reduz tamanho e compatibilidade.
5. Sem instalador, a ISO é somente Live/resgate/demonstração.
6. Secure Boot exige teste real.
7. X11 é recomendado; Wayland no XFCE 4.20 ainda é experimental.
8. Compatibilidade, RAM e tamanho não foram medidos.

## Gates

1. **Console:** kernel, initramfs, SquashFS e shell, sem XFCE.
2. **Desktop:** XFCE/LightDM, áudio e rede; confirmar XFCE 4.20/X11.
3. **PlayOS:** aplicar arte e defaults sem mudar o boot.
4. **Hardware:** QEMU e máquinas Intel, AMD e NVIDIA; firmware por evidência.
5. **Release:** migrar o conjunto validado para `livecd-rootfs` + `casper` se forem necessários instalador e Secure Boot.

## Fontes primárias

- [KNOPPIX 9.1 — notas oficiais](https://www.knopper.net/knoppix/knoppix910-en.html)
- [KNOPPIX — descrição oficial](https://knoppix.knopper.net/knoppix/index-en.html)
- [Debian Live Manual — componentes e boot](https://live-team.pages.debian.net/live-manual/html/live-manual/the-basics.en.html)
- [Debian Live Manual — live-boot e OverlayFS](https://live-team.pages.debian.net/live-manual/html/live-manual.en.html)
- [Ubuntu Resolute — xubuntu-desktop-minimal](https://packages.ubuntu.com/resolute/xubuntu-desktop-minimal)
- [Ubuntu Resolute — XFCE 4.20.1](https://packages.ubuntu.com/source/resolute/xfce4)
- [Ubuntu Resolute — casper](https://packages.ubuntu.com/resolute/casper)
- [Ubuntu — manual de lb config](https://manpages.ubuntu.com/manpages/noble/man1/lb_config.1.html)
