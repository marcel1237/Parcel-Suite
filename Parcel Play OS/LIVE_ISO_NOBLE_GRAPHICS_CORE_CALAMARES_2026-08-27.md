# Live ISO Noble com XFCE e Calamares sobre Graphics Core neutro

## Metadados e conclusão

- **ID:** `KB-PLAYOS-LIVE-CALAMARES-NODE-001`
- **Tipo:** `implementation-report`
- **Estado:** `implementation`; build final e runtime pendentes
- **Confiança:** alta para pacotes, média para integração, `unknown` para instalação
- **Verificado em:** 2026-08-27
- **Fontes:** Ubuntu Noble, perfil local e documentação upstream Calamares

É possível incluir o instalador sem torná-lo dependente de um desktop. A Live
agora fornece XFCE 4.18 como desktop X11, enquanto o Graphics Core permanece
sem XFCE, GNOME ou KDE Plasma. O Calamares é uma aplicação Qt modular;
bibliotecas Qt/KF5 não constituem o desktop Plasma. Ele pode operar na sessão
X11/XFCE e, por Xwayland, em Labwc. A VM confirmou `calamares 3.3.5-0ubuntu4` em `noble/universe` e
`ubiquity 24.04.5` em `noble/main`.

Para esta edição foi escolhido Calamares como único motor. A decisão vale para
`playos-graphics-core-noble` e não mistura Calamares com Subiquity.

## Histórico completo do build até aqui

1. Criado perfil `live-build` Noble amd64 com kernel oficial Noble.
2. Incluídos systemd, D-Bus, polkit, NetworkManager, UPower, udisks2, XDG,
   DRM/Mesa, Vulkan, libinput, fontes, Xorg, Xwayland, Labwc,
   LightDM, ALSA, PipeWire e WirePlumber.
3. Criadas inicialmente sessões técnicas X11/Openbox e Wayland/Labwc.
4. O perfil foi revisto: Openbox saiu e XFCE 4.18 tornou-se o desktop X11 da
   Live; GNOME e KDE Plasma continuam excluídos.
5. O root filesystem foi montado; o SquashFS resultou em cerca de 1,37 GiB.
6. A montagem binária falhou ao procurar temas obsoletos do Syslinux.
7. O perfil foi corrigido para selecionar GRUB; a ISO final ainda não existe.
8. O Calamares e seu perfil de implantação offline foram agora adicionados.

## Integração realizada

Pacotes adicionados: `calamares`, `parted`, `dosfstools`, `e2fsprogs`, `rsync`,
`squashfs-tools`, `grub-pc-bin` e `grub-efi-amd64-bin`.

Fluxo configurado:

```text
Live XFCE/Labwc -> pkexec -> Calamares -> idioma/teclado -> partição
-> usuário -> mount -> unpackfs -> fstab/initramfs -> LightDM -> GRUB -> reboot
```

O payload offline é `/run/live/medium/live/filesystem.squashfs`. O launcher
recusa execução fora da Live quando esse arquivo não existe.

Arquivos no futuro sistema Live, todos originados de
`live-build/playos-graphics-core-noble/config/includes.chroot/`:

- `/etc/calamares/settings.conf`: sequência dos módulos;
- `/etc/calamares/modules/{welcome,partition,unpackfs,users}.conf`;
- `/etc/calamares/modules/{displaymanager,services-systemd}.conf`;
- `/etc/calamares/modules/{bootloader,finished}.conf`;
- `/usr/share/calamares/branding/playos/branding.desc`;
- `/usr/local/sbin/playos-installer`;
- `/usr/share/applications/playos-install.desktop`.

## Estado de validação

- `fact`: os pacotes existem no Noble e os módulos requeridos constam no pacote.
- `implementation`: manifesto, configuração, branding e launcher existem.
- `result`: Calamares 3.3.5 carregou o perfil em modo offscreen, abriu oito
  etapas e recusou avançar porque a VM de inspeção não possuía disco elegível.
- `result`: o teste não executou particionamento nem qualquer job de instalação.
- `unknown`: Calamares ainda não concluiu uma instalação.
- `unknown`: boot da ISO e boot do sistema instalado.
- `unknown`: tamanho final após Qt/KF5.

Build ou abertura da interface não comprovam instalação. Particionamento,
extração, GRUB e boot precisam ser testados em disco virtual descartável.

## Gates obrigatórios

1. Validar YAML e carregar o perfil no Calamares 3.3.5.
2. Regenerar a ISO com GRUB e produzir manifesto e SHA-256.
3. Abrir o instalador em XFCE e Labwc sem disco conectado.
4. Instalar offline em disco virtual vazio de pelo menos 20 GiB, primeiro UEFI.
5. Remover a ISO e provar GRUB, kernel, initramfs, LightDM e ambas as sessões.
6. Repetir em BIOS legado.
7. Só depois avaliar dual boot, criptografia, LVM e Secure Boot.

Os primeiros testes não podem usar disco físico. Também falta definir e testar
a limpeza de `live-boot`, `live-config`, Calamares e seu launcher no alvo.

## Referências primárias

- [Configuração principal](https://github.com/calamares/calamares/blob/calamares/settings.conf)
- [Módulo unpackfs](https://github.com/calamares/calamares/blob/calamares/src/modules/unpackfs/unpackfs.conf)
- [Particionamento](https://calamares.io/docs/partitions/)
