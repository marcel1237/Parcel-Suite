# PlayOS Noble XFCE Live-only

Perfil `live-build` para uma Live CD Ubuntu Noble amd64 com XFCE 4.18 e sem
instalador. Ele deriva da primeira composição XFCE/Calamares, mas remove:

- Calamares e toda sua configuração, branding, módulos e lançador;
- Subiquity Server e Curtin;
- Casper, mantendo `live-boot` como infraestrutura da sessão Live.

Kernel, XFCE, LightDM, X11, Wayland/Labwc, Mesa/Vulkan, PipeWire,
NetworkManager, UPower, UDisks2, firmware e utilitários permanecem.

## Fonte e staging

A fonte versionável está neste diretório. Como a versão antiga de `live-build`
não trabalha de forma confiável sob caminhos com espaços, copie a receita para
um staging limpo:

```sh
sudo lb clean --purge 2>/dev/null || true
rm -rf /home/marcel/playos-noble-xfce-live-only
cp -a \
  "/home/marcel/Parcel-Suite/Parcel Suite/Parcel Play OS/live-build/playos-noble-xfce-live-only" \
  /home/marcel/playos-noble-xfce-live-only
cd /home/marcel/playos-noble-xfce-live-only
sudo lb config
```

O `rm -rf` acima deve ser usado somente para esse staging exato e depois de
confirmar que nenhum build está ativo e nenhuma montagem permanece nele.

## Build desacoplado do terminal

```sh
sudo systemd-run \
  --unit=playos-xfce-live-build \
  --working-directory=/home/marcel/playos-noble-xfce-live-only \
  --property=StandardOutput=append:/home/marcel/Documentos/log-build-iso-xfce-live.txt \
  --property=StandardError=append:/home/marcel/Documentos/log-build-iso-xfce-live.txt \
  /usr/bin/lb build
```

Acompanhe com:

```sh
sudo systemctl status playos-xfce-live-build
tail -f /home/marcel/Documentos/log-build-iso-xfce-live.txt
```

Sair do `tail` não interrompe o serviço. O output esperado da composição é
`live-image-amd64.hybrid.iso`; após auditoria, copie-o como
`playos-noble-xfce-live-amd64.iso` para
`build/playos-noble-xfce-live-only/output/`.

## Gates

1. código de saída zero;
2. manifesto sem Calamares, Subiquity, Curtin ou Casper;
3. manifesto com XFCE, LightDM e `live-boot`;
4. estrutura ISO BIOS/UEFI;
5. boot e autologin XFCE em VM;
6. rede, áudio, armazenamento e desligamento testados;
7. ausência de lançador de instalação no menu.

Build bem-sucedido não comprova funcionamento da Live em runtime.
