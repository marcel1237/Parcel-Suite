# Live ISO Ubuntu Noble + GNOME + Calamares

Data: 2026-08-31  
Tipo: `implementation-report`  
Estado: perfil implementado; build e runtime pendentes.

## Objetivo

Criar uma segunda ISO a partir do perfil funcional Ubuntu Noble + XFCE +
Calamares, substituindo somente o desktop XFCE pelo GNOME. Kernel, base Noble,
`live-boot`, Graphics Core e Calamares permanecem na mesma arquitetura.

## Alterações da variante

- removidos do manifesto desejado: `xfce4`, `xfce4-goodies`,
  `xfce4-terminal`, `xfce4-power-manager`, `thunar-volman`, LightDM e
  `lxpolkit`;
- adicionados: `ubuntu-desktop-minimal`, `gnome-shell`, `gnome-session`,
  `gnome-control-center`, `gnome-terminal`, `nautilus` e GDM3;
- autologin da conta Live `playos` transferido de LightDM para GDM3;
- módulos `displaymanager`, `services-systemd` e bridge Subiquity do Calamares
  atualizados para ativar GDM3 no sistema instalado;
- rótulo da ISO alterado para `PLAYOS_NOBLE_GNOME`;
- nome de saída definido como `playos-noble-gnome-calamares-amd64.iso`.

O Graphics Core continua desktop-neutral. GNOME pertence à composição da Live,
assim como XFCE pertencia à variante anterior.

## Perfil

Fonte versionável:

```text
live-build/playos-graphics-core-noble-gnome/
```

Composição:

```sh
cd live-build/playos-graphics-core-noble-gnome
sudo lb clean --purge
sudo lb config
sudo lb build
```

O build deve ocorrer num builder Ubuntu 24.04 isolado e com espaço suficiente.
O host atual exige autenticação interativa para `sudo`; além disso, o pool LXD
usado anteriormente foi medido em 28,80/28,80 GiB. Por isso nenhuma ISO GNOME
foi produzida nesta execução.

## Validação obrigatória depois do build

1. gerar SHA-256 e manifesto;
2. confirmar kernel Noble, `gnome-shell`, `gnome-session`, `gdm3` e
   `calamares`;
3. confirmar ausência de XFCE e LightDM;
4. auditar boot híbrido BIOS/UEFI;
5. iniciar em VM e confirmar autologin na sessão GNOME;
6. abrir Calamares pelo menu;
7. concluir uma instalação em disco virtual descartável;
8. reinicializar e confirmar que GDM3 e GNOME iniciam no sistema instalado.

Build bem-sucedido não comprova boot nem funcionamento do instalador.

