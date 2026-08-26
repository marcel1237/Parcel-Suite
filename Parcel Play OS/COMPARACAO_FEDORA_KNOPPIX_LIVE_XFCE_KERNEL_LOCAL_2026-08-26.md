# Live ISO simples com XFCE e kernel local: Ubuntu, Fedora e Knoppix

- ID: `PLAYOS-LIVE-COMPARE-002`
- tipo: `analysis`
- estado: procedimento projetado; não compilado; não inicializado
- confiança: alta para escolha da arquitetura; média para comandos até execução
- data: 2026-08-26
- kernel: fonte local Noble `6.8.0-30.30`/Linux 6.8.4

## Resultado

O caminho mais simples é:

```text
pacotes .deb do kernel local
        ↓
live-build em modo Ubuntu
        ↓
Resolute mínimo + live-boot + XFCE 4.20 + LightDM
        ↓
SquashFS + OverlayFS + GRUB → ISO híbrida
```

Do Fedora deve ser aproveitada a ideia de um manifesto declarativo pequeno,
equivalente a Kickstart. Do Knoppix, a raiz comprimida e o overlay gravável. As
ferramentas Fedora e os patches Knoppix não devem entrar no pipeline Ubuntu.

## Comparação

| Sistema | Compositor de ISO | Declaração | Boot Live | Adequação ao rootfs Ubuntu |
|---|---|---|---|---:|
| Ubuntu/Debian Live | `live-build` | listas, hooks e includes | `live-boot` ou `casper` | alta |
| Fedora | `livemedia-creator` + Lorax + Anaconda | Kickstart | dracut-live | baixa |
| Knoppix | infraestrutura própria | scripts/remaster | cloop + aufs | baixa |

### Fedora

`livemedia-creator` usa Anaconda, Kickstart e Lorax. A criação ocorre em duas
etapas: uma instalação gera a imagem de sistema e Lorax transforma essa imagem
em mídia Live. O fluxo oferece ISO final, kernel, initrd e SquashFS e permite
customização na seção `%post` do Kickstart.

Vantagens conceituais:

- lista explícita de pacotes;
- configuração reproduzível num arquivo;
- customização pós-instalação;
- separação entre imagem de sistema e mídia de boot;
- fluxo oficial para Fedora XFCE Spin.

Por que não usar no PlayOS Ubuntu:

- espera pacotes e repositórios RPM/DNF;
- depende de Anaconda, Lorax e `dracut-live`;
- normalmente usa QEMU/virt para executar a instalação;
- `--no-virt` é documentado como menos seguro e mais confiável quando host e
  alvo têm a mesma release;
- converter os `.deb` do kernel local para RPM seria trabalho e risco sem
  benefício funcional.

No host atual, `livemedia-creator`, Lorax, Anaconda e `ksflatten` estão ausentes.
Instalá-los não tornaria o build Ubuntu mais simples.

### Knoppix

Knoppix demonstra que uma mídia útil pode conter apenas kernel, desktop leve e
ferramentas selecionadas. Usa filesystem comprimido somente leitura e overlay
gravável, com persistência opcional em USB.

Aplicar ao PlayOS:

- SquashFS para a raiz;
- OverlayFS para escrita em RAM;
- imagem híbrida para ISO/USB;
- desktop e aplicativos estritamente selecionados;
- persistência apenas após o boot básico estar validado.

Não aplicar:

- `cloop` e `aufs`;
- patches Knoppix no kernel Ubuntu;
- dois kernels 32/64 bits;
- scripts antigos de detecção no lugar de udev/systemd;
- mistura de versões de distribuição.

### Ubuntu/Debian Live

`live-build` já está instalado no host e entende pacotes `.deb`, debootstrap,
SquashFS, bootloader e pacotes locais. O backend `live-boot` cria o ambiente
gravável por OverlayFS e `live-config` configura usuário, hostname, locale e
autologin.

Este é o único dos três métodos que combina diretamente com:

- rootfs Resolute;
- XFCE 4.20 do arquivo Ubuntu;
- pacotes `.deb` produzidos pela fonte local do kernel;
- ferramentas já presentes no host.

## Estado do host

Confirmado em 2026-08-26:

```text
Host: Ubuntu 26.04
live-build: instalado
debootstrap: instalado
mksquashfs: instalado
xorriso: instalado
grub-mkrescue: instalado
livemedia-creator/Lorax/Anaconda: ausentes
disco disponível: aproximadamente 45 GiB
RAM: 5,1 GiB
swap: 9 GiB
```

Faltam dependências do empacotamento do kernel, incluindo ao menos GCC 13,
`debhelper` e `dwarves`. O conjunto completo deve ser calculado pelo
`debian/control` gerado, não por uma lista estimada.

## Duas fases obrigatórias

### Fase 1 — produzir o kernel

A fonte externa é somente leitura. Criar staging e produzir pacotes:

```text
linux-image-unsigned-6.8.0-30-generic
linux-modules-6.8.0-30-generic
linux-modules-extra-6.8.0-30-generic
linux-headers-6.8.0-30-generic
```

Os nomes são esperados, não resultados. Devem ser confirmados nos `.deb`.

Antes do build, criar uma revisão PlayOS no changelog do staging para não
colidir com `6.8.0-30.30` oficial. O kernel, módulos e initramfs precisam usar a
mesma ABI.

Comando de laboratório previsto:

```bash
fakeroot debian/rules clean
fakeroot debian/rules binary-headers binary-generic skipabi=true skipmodule=true
```

Nenhum desses comandos foi executado nesta análise.

### Fase 2 — compor a Live

Não usar `--linux-flavours generic` sozinho: esta versão de `live-build`
agendaria um kernel do arquivo Ubuntu. É necessário desativar a seleção
automática com `--linux-packages none` e fornecer os `.deb` locais em
`config/packages.chroot/`.

## Perfil mínimo proposto

Estrutura versionada:

```text
live-resolute-xfce/
├── auto/config
├── config/package-lists/playos-live.list.chroot
├── config/packages.chroot/
│   ├── linux-image-unsigned-..._amd64.deb
│   ├── linux-modules-..._amd64.deb
│   └── linux-modules-extra-..._amd64.deb
├── config/hooks/010-playos-live.chroot
└── config/includes.chroot/etc/...
```

Os `.deb` grandes podem permanecer como outputs ignorados; o manifesto deve
registrar caminho externo e SHA-256.

### `auto/config`

Esta versão local usa `--binary-images` no plural. O singular escrito no estudo
anterior deve ser considerado corrigido por este documento.

```bash
#!/bin/sh
set -eu

lb config noauto \
  --mode ubuntu \
  --distribution resolute \
  --architectures amd64 \
  --binary-images iso-hybrid \
  --system live \
  --initramfs live-boot \
  --archive-areas "main restricted universe multiverse" \
  --linux-packages none \
  --debian-installer false \
  --memtest none \
  --bootappend-live "boot=live components username=playos hostname=playos locales=pt_BR.UTF-8 keyboard-layouts=br" \
  "$@"
```

Não usar `--apt-recommends false` no primeiro build. Metapacotes de desktop
frequentemente delegam integração a recomendações; otimizar antes de obter um
boot funcional torna o diagnóstico mais difícil.

### Lista de pacotes

```text
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

Não listar `linux-generic`. Os pacotes de kernel virão de
`config/packages.chroot/`.

### Hook mínimo

```bash
#!/bin/sh
set -eu

systemctl set-default graphical.target
systemctl enable lightdm.service

printf '%s\n' overlay isofs >> /etc/initramfs-tools/modules
update-initramfs -u -k all
```

O hook deve ser executável. A presença de `overlay` e `isofs` no initramfs deve
ser posteriormente confirmada com `lsinitramfs`; não basta confiar no comando.

### Build

```bash
sudo lb clean --purge
sudo lb build 2>&1 | tee build.log
```

O build precisa ocorrer em staging isolado. Com apenas cerca de 45 GiB livres,
não manter múltiplos chroots, árvores de kernel e ISOs simultâneos.

## Autologin e XFCE

Primeiro deixar `live-config` criar o usuário e configurar LightDM. Se não
iniciar automaticamente, diagnosticar nesta ordem:

1. usuário Live existe;
2. `lightdm.service` está habilitado;
3. `/usr/share/xsessions/xfce.desktop` existe;
4. `live-config` executou os componentes user-setup e LightDM;
5. logs do display manager não mostram falha de Xorg/driver.

Não colocar senha fixa no SquashFS. Não adicionar configuração manual de
autologin antes de confirmar a integração nativa.

## Bootloader e Secure Boot

Para o laboratório, gerar ISO híbrida e testar BIOS e UEFI com Secure Boot
desativado. O kernel compilado localmente não recebe assinatura Canonical.

Secure Boot é outro projeto:

1. chave PlayOS protegida;
2. assinatura de kernel e módulos;
3. certificado distribuído;
4. fluxo de enrollment;
5. teste de rejeição de módulos não assinados.

Nada disso deve bloquear o primeiro boot de laboratório.

## Testes em camadas

### Gate 1 — pacotes do kernel

```bash
dpkg-deb -f linux-image-*.deb Package Version Architecture
dpkg-deb -c linux-modules-*.deb
```

### Gate 2 — initramfs

```bash
lsinitramfs initrd.img | grep -E 'overlay|isofs|squashfs'
```

### Gate 3 — conteúdo da ISO

Confirmar `vmlinuz`, `initrd` e SquashFS, El Torito BIOS/UEFI e SHA-256.

### Gate 4 — console Live

Boot com alvo texto antes do desktop. Confirmar:

```bash
uname -r
findmnt -t squashfs,overlay
test -d /lib/modules/"$(uname -r)"
```

### Gate 5 — XFCE

```bash
xfce4-session --version
printf '%s\n' "$XDG_SESSION_TYPE"
systemctl is-active lightdm
nmcli general status
```

Resultado esperado: XFCE 4.20, X11, LightDM e rede ativa.

## Decisão recomendada

1. Não instalar Fedora/Lorax/Anaconda no host para este build.
2. Não portar cloop/aufs do Knoppix.
3. Usar `live-build` + `live-boot` como MVP sem instalador.
4. Tratar os arquivos de configuração como o “Kickstart PlayOS”.
5. Empacotar o kernel local antes de montar o desktop.
6. Migrar para `livecd-rootfs` + `casper` somente quando instalador e Secure
   Boot oficial se tornarem requisitos.

## Fontes primárias

- [Lorax/livemedia-creator](https://weldr.io/lorax/livemedia-creator.html)
- [Código e documentação Lorax](https://github.com/weldr/lorax/blob/master/docs/livemedia-creator.rst)
- [Fedora — tipos de mídia Live](https://docs.fedoraproject.org/cs/fedora/f40/fedora-downloads-info/)
- [KNOPPIX 9.1 — arquitetura e edição mínima](https://www.knopper.net/knoppix/knoppix910-en.html)
- [KNOPPIX — sistema Live](https://knoppix.knopper.net/knoppix/index-en.html)
- [Debian Live Manual](https://live-team.pages.debian.net/live-manual/html/live-manual.en.html)
- [Ubuntu Resolute — XFCE 4.20.1](https://packages.ubuntu.com/source/resolute/xfce4)
- [Ubuntu Resolute — xubuntu-desktop-minimal](https://packages.ubuntu.com/resolute/xubuntu-desktop-minimal)
