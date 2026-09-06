# Live Debian Trixie GNOME com kernel Noble, sem instalador

- ID: `PLAYOS-LIVE-DEBIAN-GNOME-NOBLE-001`
- Tipo: `implementation` e `implementation-plan`
- Estado: perfil implementado; ISO compilada e validada estaticamente; runtime pendente
- Confiança: alta para build e estrutura estática; runtime `unknown`
- Data: 2026-09-06

## Composição

Esta variante preserva a arquitetura validada da Live XFCE:

- Debian 13 Trixie para base, userspace e pipeline Live;
- `live-build`, `live-boot`, `live-config`, SquashFS e OverlayFS Debian;
- kernel, módulos e módulos-extra Ubuntu Noble `6.8.0-138-generic`;
- firmware, Mesa, Vulkan, PipeWire e NetworkManager Debian;
- nenhum Calamares, Subiquity, Curtin, Casper ou kernel Debian.

A única troca funcional pretendida é a camada de desktop:

```text
XFCE + LightDM -> GNOME + GDM3
```

## Implementação

Perfil criado em:

```text
live-build/playos-debian-trixie-gnome-noble-kernel/
```

Foram removidos da lista direta `xfce4`, XFCE Goodies, terminal e power
manager XFCE, LightDM, greeter LightDM, `lxpolkit` e `thunar-volman`. Foram
adicionados `gnome-core`, `gdm3`, `gnome-terminal` e `gnome-software`.

A seleção direta possui 62 pacotes. Dependências são resolvidas novamente pelo
APT Trixie; nenhum pacote Ubuntu além dos três artefatos locais do kernel é
obtido por repositório.

O volume da ISO é `PLAYOS_D13_GNOME`. O hook habilita `graphical.target`, GDM3
e NetworkManager. O autologin Live é configurado para `playos` em
`/etc/gdm3/daemon.conf`. O hook de auditoria exige GNOME Shell, GNOME Session,
GDM3 e Nautilus e continua bloqueando instaladores e metapacotes de kernel
Debian.

## Execução

A ISO XFCE e seus artefatos foram preservados no projeto. O staging XFCE dentro
da VM builder foi limpo com `lb clean --purge`, recuperando aproximadamente
11 GiB livres.

O perfil GNOME foi copiado para
`/root/playos-debian-trixie-gnome-noble-kernel`. O preflight aprovou os três
checksums Noble, as ferramentas e os pacotes GNOME nos índices Debian.

O build foi iniciado como serviço transitório:

```text
unidade: playos-debian-gnome-live-build.service
invocation: c2c32f70a23a4d6ca0c529b72d1617d5
início: 2026-09-06 17:26:34 UTC
log: /root/playos-debian-trixie-gnome-noble-kernel/build.log
```

O serviço concluiu com `P: Binary stage completed` e
`P: Build completed successfully`. A unidade transitória desapareceu depois da
conclusão, comportamento esperado para a execução por `systemd-run`.

### Monitoramento em tempo real

O log pode ser acompanhado no host sem interromper o serviço:

```sh
lxc exec playos-debian-trixie-builder-vm -- \
  tail -n 40 -f /root/playos-debian-trixie-gnome-noble-kernel/build.log
```

`Ctrl+C` encerra somente o processo `tail`; o build continua sob controle da
unidade systemd. Não usar `systemctl stop`, `lxc stop` ou iniciar outro
`lb build` durante a composição.

### Checkpoint de instalação de pacotes

Na captura feita após aproximadamente oito minutos:

```text
serviço: active (running)
etapa: lb chroot_install-packages install
memória corrente: aproximadamente 2,1 GiB
pico de memória: aproximadamente 2,2 GiB
disco usado: aproximadamente 3,4 GiB
espaço livre: aproximadamente 8,1 GiB
```

O APT havia iniciado a instalação da lista completa. Foram observados GNOME,
GDM3, Nautilus, GNOME Shell, GNOME Session, GTK 3/4, Wayland, Vulkan,
Fontconfig, HarfBuzz, PipeWire, Firefox ESR e firmware. No trecho mais recente,
GTK 4, bibliotecas Wayland/Vulkan, fontes e componentes de segurança estavam
sendo desempacotados. Nenhum erro de `dpkg`, APT ou `live-build` havia sido
registrado.

Os avisos de `dpkg-divert` sobre `start-stop-daemon` e `hostname` são emitidos
pela preparação normal do chroot do `live-build`; não foram classificados como
falha nesta execução.

## Resultado do build e validação estática

A saída foi copiada de forma transacional: primeiro como `.partial`, depois
promovida ao nome final somente após tamanho e SHA-256 coincidirem com a origem.

```text
ISO: build/playos-debian-trixie-gnome-noble/output/live-image-amd64.hybrid.iso
tamanho: 2007859200 bytes (aproximadamente 1,87 GiB)
SHA-256: 3d37930ce1db4853a4eda72152b8f5e13f99a942e9e6840ace2a84a3214743eb
volume: PLAYOS_D13_GNOME
boot: El Torito BIOS + UEFI, GRUB 2, MBR protetora e GPT
```

Também foram preservados `live-image-amd64.packages`,
`live-image-amd64.contents` e `live-image-amd64.hybrid.iso.sha256`. O manifesto
interno `/live/filesystem.packages` confirma imagem, módulos e módulos-extra
Ubuntu Noble `6.8.0-138.138`. A árvore `/live` contém
`vmlinuz-6.8.0-138-generic`, o initramfs correspondente e o SquashFS.

GNOME Core, GNOME Shell e GDM3 foram confirmados. XFCE, LightDM, Calamares e
Anaconda não apareceram no manifesto consultado. Isso é uma validação estática,
não uma prova de que a sessão gráfica inicializa.

### Alerta de capacidade

Ao terminar, a raiz de 12 GiB da VM builder estava em 100%, com somente 58 MiB
livres. A ISO foi gerada e seu checksum passou, mas nenhum novo build deve ser
iniciado nessa VM antes de liberar ou ampliar espaço. Os artefatos já foram
retirados dela e preservados no projeto.

## Gates pendentes

1. inicializar em VM e confirmar kernel Noble, OverlayFS, GDM3 e GNOME Shell;
2. testar boot BIOS e UEFI em runtime;
3. testar rede, áudio, Mesa/Vulkan e hardware;
4. liberar ou ampliar o disco da VM builder antes de nova composição.

Build bem-sucedido não será tratado como prova de desktop funcional antes do
teste visual e de runtime.
