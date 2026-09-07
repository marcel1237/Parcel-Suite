# Live Debian Trixie KDE Full com kernel Noble

- ID: `PLAYOS-LIVE-DEBIAN-KDE-FULL-NOBLE-001`
- Tipo: `implementation`
- Estado: perfil implementado; ISO compilada e validada estaticamente; runtime pendente
- Confiança: alta para build e estrutura estática; runtime `unknown`
- Data: 2026-09-07

## Decisão

O userspace Debian é requisito obrigatório. Por isso, KDE neon e KDE Linux não
são baselines do produto:

- KDE neon usa Ubuntu 24.04 Noble como userspace;
- KDE Linux é um sistema image-based próprio, derivado de pacotes Arch, ainda
  classificado como Alpha;
- pacotes KDE neon não possuem garantia de ABI no Debian Trixie.

Como o objetivo também é evitar compilar toda a plataforma, a variante usa
`kde-full` dos repositórios Debian. O código é desenvolvido pelo KDE; o
empacotamento, dependências e integração são mantidos pelo Debian Qt/KDE Team.
Não existe repositório binário oficial KDE destinado ao Debian Trixie que
substitua essa camada.

## Composição

- userspace: Debian 13 Trixie;
- Live: `live-build`, `live-boot`, `live-config`, SquashFS e OverlayFS Debian;
- desktop: `kde-full` 5:162;
- Plasma: 6.3.6 na baseline consultada;
- sessão: Wayland e X11, KWin, SDDM;
- kernel: Ubuntu Noble `6.8.0-138-generic`, módulos e módulos-extra locais;
- instalador: nenhum;
- firmware, Mesa, Vulkan, PipeWire e NetworkManager: Debian.

O metapacote `kde-full` inclui as famílias KDE Plasma, Standard, Admin,
Education, Games, Graphics, Multimedia, Network, PIM, Utils, SDK, Toys e Webdev.
A simulação APT resultou em 2.108 pacotes novos e aproximadamente 2,11 GiB de
arquivos compactados para a VM mínima.

## Perfil

```text
live-build/playos-debian-trixie-kde-full-noble-kernel/
```

O hook de auditoria rejeita Calamares, Subiquity, Curtin, Casper, GNOME, XFCE,
LightDM e metapacotes de kernel Debian. Ele exige os três pacotes Noble,
`kde-full`, Plasma, KWin Wayland, SDDM, Dolphin, Konsole, NetworkManager,
PipeWire e WirePlumber.

O SDDM usa seu servidor de exibição padrão. Forçar o greeter SDDM a Wayland foi
deliberadamente evitado porque requer configuração adicional e aumentaria o
risco de uma tela preta. Isso não remove a sessão Plasma Wayland.

## Capacidade preparada

- staging GNOME anterior limpo da VM;
- download parcial KDE neon cancelado e removido;
- pool LXD ampliado de 45 para 60 GiB;
- disco lógico da VM ampliado de 24 para 36 GiB;
- aproximadamente 34 GiB livres no início do build.

Nenhuma outra ISO ou VM foi apagada.

## Execução atual

```text
VM: playos-debian-trixie-builder-vm
perfil: /root/playos-debian-trixie-kde-full-noble-kernel
unidade: playos-debian-kde-full-build.service
invocation: a55ad781e29a4d8bb990f9c3a30679a5
log: /root/playos-debian-trixie-kde-full-noble-kernel/build.log
```

O primeiro checkpoint confirmou `live-build 20250505+deb13u1`, Debian Trixie
amd64, repositórios assinados e etapa `bootstrap_debootstrap`. A execução
terminou com `P: Binary stage completed` e `P: Build completed successfully`.
Como a unidade foi criada por `systemd-run`, ela desapareceu após a conclusão.

## Resultado e validação estática

```text
ISO: build/playos-debian-trixie-kde-full-noble/output/live-image-amd64.hybrid.iso
tamanho: 3755513856 bytes (aproximadamente 3,50 GiB)
SHA-256: 03e2482e91fdd98a3c4ada568f505ef050766c25fab023693385244057983635
volume: PLAYOS_D13_KDE
boot: El Torito BIOS + UEFI, GRUB 2, MBR protetora e GPT
```

O SHA-256 passou na VM e novamente após a cópia local transacional. Também
foram preservados os arquivos `.packages`, `.contents` e `.iso.sha256`.

O manifesto interno confirmou:

- kernel, módulos e módulos-extra Noble `6.8.0-138.138`;
- `kde-full` 5:162;
- Plasma Desktop 6.3.6 e Plasma Workspace 6.3.6;
- KWin Wayland e X11;
- SDDM, Dolphin e Konsole;
- ausência de Calamares, Subiquity, Curtin, Casper, GNOME, XFCE e LightDM.

A árvore `/live` contém o SquashFS, `vmlinuz-6.8.0-138-generic` e seu initrd.

Durante configuração no chroot apareceram avisos de `grub-probe` sem `/dev` e
conexão indisponível ao D-Bus do host. Eles não encerraram o hook nem o build,
mas devem permanecer registrados para auditoria. O boot ainda precisa provar
que não causaram efeito no artefato.

Após ampliar o pool LXD e copiar a ISO, o filesystem do host ficou em 96%, com
aproximadamente 11 GiB livres. Não duplicar a imagem para outro volume nem
iniciar novo build antes de recuperar espaço.

Monitoramento:

```sh
lxc exec playos-debian-trixie-builder-vm -- \
  tail -n 40 -f /root/playos-debian-trixie-kde-full-noble-kernel/build.log
```

## Gates restantes

1. recuperar espaço seguro no host;
2. inicializar em VM e confirmar kernel Noble, SDDM e Plasma;
3. testar Wayland, X11, rede, áudio, Mesa/Vulkan e aplicações KDE;
4. testar hardware real somente após os gates de VM.

Build concluído não comprova boot ou sessão gráfica funcional.
