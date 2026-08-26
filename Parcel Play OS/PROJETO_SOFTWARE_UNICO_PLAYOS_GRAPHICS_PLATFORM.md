# PlayOS Graphics Platform: quatro componentes como um único software

## Estado

- **Classificação:** `proposal` e `decision` de arquitetura.
- **Data:** 2026-08-26.
- **Produto proposto:** `playos-graphics-platform`.
- **Implementação, build, ISO e boot:** ainda não realizados.

Este documento define como entregar como **um único produto**: Ubuntu Noble e
kernel PlayOS, X11/Xorg, Wayland/Xwayland e os desktops XFCE, GNOME e KDE
Plasma. Labwc atende o laboratório Wayland do XFCE; GNOME usa Mutter e Plasma
usa KWin.

“Um software” significa uma identidade, uma instalação, uma versão, um
diagnóstico e uma política de suporte. Não significa um executável monolítico:
essas camadas têm processos, privilégios, interfaces e ciclos de atualização
diferentes.

## Conexão simples entre os quatro componentes

Os quatro componentes formam uma corrente:

```text
Ubuntu Noble
     ↓
Kernel PlayOS
     ↓
X11 ou Wayland
     ↓
XFCE
```

### 1. Ubuntu Noble: a base

Ubuntu Noble fornece a estrutura geral do sistema: APT, pacotes, bibliotecas,
serviços, ferramentas administrativas e organização do sistema de arquivos.
É a plataforma sobre a qual os outros componentes são instalados.

### 2. Kernel PlayOS: a ligação com o hardware

O kernel controla CPU, memória, armazenamento, teclado, mouse e GPU. Para os
gráficos, oferece mecanismos como DRM/KMS e os drivers necessários. O kernel
prepara e controla os recursos do hardware, mas não desenha menus, janelas ou
o desktop.

### 3. X11 ou Wayland: o caminho gráfico

X11 e Wayland são dois caminhos alternativos entre as aplicações e os recursos
gráficos oferecidos pelo kernel:

- **X11/Xorg:** caminho tradicional, adotado como padrão de compatibilidade;
- **Wayland/Labwc:** caminho moderno, inicialmente experimental no PlayOS;
- **Xwayland:** camada que permite executar aplicações X11 dentro da sessão
  Wayland.

X11 e Wayland não serão os dois servidores principais da mesma sessão. O
usuário escolhe uma sessão na tela de login.

### 4. XFCE: o ambiente que o usuário vê

XFCE fornece painel, menu, área de trabalho, configurações, janelas e
gerenciador de arquivos. Ele depende do caminho gráfico selecionado para
aparecer no monitor e receber teclado e mouse.

Na sessão X11, o fluxo simplificado é:

```text
Aplicação → XFCE/xfwm4 → Xorg → kernel/DRM → GPU → monitor
```

Na sessão Wayland, o fluxo é:

```text
Aplicação → XFCE → Labwc/Wayland → kernel/DRM → GPU → monitor
                         ↑
              Xwayland para aplicações X11
```

### Como isso se torna um produto único

`playos-graphics-platform` conecta as quatro partes por dependências,
configuração, sessões, diagnóstico e política de atualização. Assim, o usuário
instala o conjunto com um único comando, embora cada componente permaneça
tecnicamente separado e possa ser atualizado ou recuperado individualmente.

Em uma frase: **Ubuntu fornece a base, o kernel controla o hardware, X11 ou
Wayland transporta os gráficos e XFCE oferece o ambiente visual.**

## Contrato público

```text
sudo apt install playos-graphics-platform
playos-graphicsctl status
playos-graphicsctl diagnose
```

Na tela de login haverá duas sessões:

- **PlayOS XFCE (X11):** padrão estável, com Xorg e `xfwm4`;
- **PlayOS XFCE (Wayland Lab):** experimental, com Labwc e Xwayland.

Esta lista original foi ampliada. O produto também oferecerá GNOME em X11 e
Wayland, e KDE Plasma em X11 e Wayland, conforme disponibilidade e validação da
base Noble. A arquitetura completa está em
`ARQUITETURA_MULTI_DESKTOP_PLAYOS_XFCE_GNOME_KDE.md`.

## Arquitetura

```text
playos-graphics-platform (entrada única)
├── playos-kernel-graphics-meta
│   └── kernel PlayOS versionado + módulos + firmware
├── playos-display-x11
│   └── Xorg + drivers de entrada/vídeo
├── playos-display-wayland
│   └── Labwc + Xwayland + utilitários Wayland
├── playos-desktop-xfce
│   └── XFCE + LightDM + integração de sessão
├── playos-desktop-gnome
│   └── GNOME Shell + Mutter + portal GNOME
├── playos-desktop-kde
│   └── Plasma + KWin + portal KDE
├── playos-display-manager-profile
│   └── um entre LightDM, GDM ou SDDM ativo
└── playos-graphics-tools
    └── manifesto + CLI + diagnóstico
```

O pacote superior será um **metapacote binário**. APT instala e atualiza a
composição inteira, mantendo as correções normais dos pacotes Ubuntu. Não se
devem copiar binários upstream para um pacote privado.

## Um pacote-fonte, vários pacotes internos

Um pacote-fonte nativo PlayOS gera os metapacotes e arquivos de coordenação;
ele não recompila Xorg, Wayland ou XFCE.

```text
packages/playos-graphics-platform/
├── debian/
│   ├── changelog
│   ├── control
│   ├── copyright
│   ├── rules
│   ├── source/format
│   └── *.install
├── sessions/
│   ├── playos-xfce-x11.desktop
│   └── playos-xfce-wayland.desktop
├── bin/playos-graphicsctl
├── libexec/playos-xfce-wayland-session
├── manifest/platform.json
├── defaults/graphics.conf
└── tests/
```

O formato sugerido é `3.0 (native)` enquanto houver somente trabalho PlayOS.
Se código upstream for incorporado, origem, licenças e formato serão revistos.

## Dependências Debian

`Depends` contém o núcleo funcional; `Recommends`, a experiência normal não
indispensável; `Suggests`, integrações opcionais. `Pre-Depends` não será usado
sem necessidade comprovada.

```debcontrol
Source: playos-graphics-platform
Section: metapackages
Priority: optional
Maintainer: PlayOS Team <substituir-por-endereco-real>
Standards-Version: 4.7.2
Rules-Requires-Root: no

Package: playos-graphics-platform
Architecture: all
Depends:
 playos-kernel-graphics-meta,
 playos-display-x11,
 playos-display-wayland,
 playos-desktop-xfce,
 playos-graphics-tools,
 ${misc:Depends}
Description: PlayOS integrated kernel and graphics platform

Package: playos-display-x11
Architecture: all
Depends: xserver-xorg, xserver-xorg-input-libinput, mesa-utils, ${misc:Depends}
Description: PlayOS supported X11 display stack

Package: playos-display-wayland
Architecture: all
Depends: labwc, xwayland, wayland-protocols, ${misc:Depends}
Description: PlayOS experimental Wayland display stack

Package: playos-desktop-xfce
Architecture: all
Depends: xfce4, lightdm, lightdm-gtk-greeter, playos-xfce-sessions, ${misc:Depends}
Recommends: xfce4-goodies
Description: PlayOS XFCE desktop and login integration
```

Os nomes e versões exatos serão resolvidos contra os repositórios usados no
primeiro build. O endereço de mantenedor acima é deliberadamente um marcador.

`playos-kernel-graphics-meta` aponta para o kernel versionado, módulos e
headers. O pacote superior não fixa eternamente uma ABI. Ao avançar, o kernel
anterior permanece no GRUB como fallback até uma política explícita removê-lo.

## Arquivos e propriedade

| Arquivo | Pacote | Função |
|---|---|---|
| `/usr/bin/playos-graphicsctl` | `playos-graphics-tools` | controle e diagnóstico |
| `/usr/share/playos/graphics/platform.json` | `playos-graphics-tools` | manifesto |
| `/etc/playos/graphics.conf` | `playos-graphics-tools` | preferências |
| `/usr/share/xsessions/playos-xfce-x11.desktop` | `playos-xfce-sessions` | sessão X11 |
| `/usr/share/wayland-sessions/playos-xfce-wayland.desktop` | `playos-xfce-sessions` | sessão Wayland |
| `/usr/libexec/playos/playos-xfce-wayland-session` | `playos-xfce-sessions` | launcher Labwc/XFCE |
| `/usr/lib/systemd/system/playos-graphics-check.service` | `playos-graphics-tools` | diagnóstico pós-boot |

Nenhum pacote PlayOS sobrescreve arquivos pertencentes a Xorg, Labwc, XFCE ou
Ubuntu. A integração usa nomes próprios e interfaces públicas.

## Manifesto e versão

```json
{
  "schema": 1,
  "product": "PlayOS Graphics Platform",
  "release": "1.0.0",
  "base": "Ubuntu Noble",
  "default_session": "playos-xfce-x11",
  "experimental_sessions": ["playos-xfce-wayland"],
  "components": {
    "kernel": "resolved-at-build-time",
    "x11": "distribution-package",
    "wayland": "distribution-package",
    "xfce": "distribution-package"
  }
}
```

Versões instaladas vêm de `dpkg-query`. A versão PlayOS identifica a matriz
suportada sem substituir versões upstream. Incompatibilidade na CLI ou schema
aumenta `major`; nova matriz compatível, `minor`; correção, `patch`.

## Interface `playos-graphicsctl`

```text
playos-graphicsctl status
playos-graphicsctl sessions
playos-graphicsctl diagnose [--json]
playos-graphicsctl manifest
playos-graphicsctl select-default x11|wayland
```

- `status`: produto, kernel, GPU e sessão corrente;
- `sessions`: sessões e nível estável/experimental;
- `diagnose`: testes por camada, sem mudar o sistema;
- `manifest`: composição e versões resolvidas;
- `select-default`: muda a preferência sem encerrar a sessão.

A ferramenta não instala pacotes silenciosamente, não edita arquivos upstream
e não descarrega módulos em uso. Operações privilegiadas exigem `sudo`.

## Diagnóstico integrado

O diagnóstico verifica: estado do `dpkg`; ABI, módulos e firmware; DRM/KMS e
`/dev/dri`; renderer Mesa; Xorg; Labwc, Wayland e Xwayland; XFCE; LightDM e
arquivos de sessão.

Resultados: `PASS`, `WARN`, `FAIL` ou `NOT-APPLICABLE`. Um serviço
`Type=oneshot` pode gravar
`/var/lib/playos/graphics/last-validation.json`, sem bloquear o alvo gráfico.
Ele não substitui testes interativos.

## Sessões e fallback

A sessão X11 executa `startxfce4`; LightDM cuida da autenticação. Xorg não é
iniciado no kernel nem no initramfs.

A sessão Wayland chama um launcher pequeno que valida `XDG_RUNTIME_DIR`, inicia
Labwc, inicia componentes XFCE compatíveis, disponibiliza Xwayland e encerra
limpamente em falha. Ela não inicia `xfwm4`, pois Labwc já é compositor e
gerenciador de janelas. Se Wayland falhar, X11 continua no login.

## Live ISO

Depois de produzir os `.deb`, a lista do `live-build` solicita apenas:

```text
playos-graphics-platform
live-boot
systemd-sysv
```

Pacotes locais entram em `config/packages.chroot/` ou em repositório APT local
assinado. Para usar exclusivamente o kernel PlayOS, mantém-se
`--linux-packages none`. O build deve falhar se a composição completa não
puder ser resolvida.

## Atualização, rollback e remoção

- APT atualiza componentes; o metapacote define combinações suportadas.
- Uma atualização não muda o kernel em execução antes do reboot.
- Scripts de mantenedor não reiniciam a sessão ativa.
- Conserva-se um kernel inicializável anterior no GRUB.
- X11 permanece como fallback enquanto Wayland for experimental.
- `apt remove` retira a seleção superior; dependências necessárias permanecem.
- `apt autoremove` é separado; `purge` não remove dados pessoais/upstream.

Scripts de mantenedor devem ser evitados quando a configuração declarativa
basta. Se indispensáveis, serão idempotentes, não interativos e reexecutáveis.

Não usar `update-alternatives` para escolher X11 ou Wayland: eles não são duas
implementações de um único executável genérico. A seleção ocorre pelas sessões
do display manager e pela preferência PlayOS.

## Segurança

- gráficos permanecem no userspace e sem privilégio quando possível;
- pacotes e repositório APT são assinados;
- diagnóstico não coleta conteúdo de aplicações nem segredos;
- serviços D-Bus e portals entram só por necessidade definida;
- Xwayland oferece compatibilidade, não isolamento completo;
- Xorg, Wayland e XFCE nunca entram no kernelspace.

## Gates

| Gate | Evidência | Estado |
|---|---|---|
| U0 — especificação | documento aprovado | presente |
| U1 — pacote-fonte | `dpkg-buildpackage` concluído | pendente |
| U2 — resolução | instalação APT limpa em Noble | pendente |
| U3 — integração | sessões, manifesto e CLI | pendente |
| U4 — X11 | login, GPU, áudio, rede e logout | pendente |
| U5 — Wayland | Labwc, XFCE, Xwayland e logout | pendente |
| U6 — upgrade | atualização e scripts idempotentes | pendente |
| U7 — rollback | kernel anterior e X11 recuperáveis | pendente |
| U8 — Live ISO | build, boot, persistência e shutdown | pendente |
| U9 — hardware | Intel, AMD, nouveau e VMs | pendente |

Ferramentas previstas: `lintian`, `piuparts`, `autopkgtest`,
`dpkg-buildpackage`, testes shell e QEMU. Só resultados guardados satisfazem os
gates.

## Ordem de implementação

1. congelar nomes e matriz Noble;
2. criar pacote-fonte, metapacotes e manifesto;
3. implementar a CLI inicialmente somente leitura;
4. criar e testar X11;
5. criar launcher Wayland/Labwc experimental;
6. conectar o metapacote do kernel PlayOS;
7. testar instalação, remoção, reinstalação e lint;
8. testar as duas sessões em VM;
9. inserir os `.deb` no perfil Live;
10. gerar, inicializar e medir a ISO;
11. testar atualização e fallback;
12. somente então declarar `implementation/result`.

## Aceitação

Só será correto dizer “os quatro softwares em um” quando um comando instalar
tudo; a CLI identificar a matriz; X11 iniciar como padrão; Wayland iniciar sem
conflito com `xfwm4`; Xwayland funcionar; upgrade, remoção e rollback forem
testados; e a ISO tiver build e boot reais.

Até lá: **produto especificado, ainda não implementado**.

## Fontes primárias

- Debian Policy, relações: <https://www.debian.org/doc/debian-policy/ch-relationships.html>
- Debian Policy, campos: <https://www.debian.org/doc/debian-policy/ch-controlfields.html>
- Debian Policy, scripts: <https://www.debian.org/doc/debian-policy/ch-maintainerscripts.html>
- `update-alternatives(1)`: <https://manpages.debian.org/unstable/dpkg/update-alternatives.1.en.html>

## Documentos relacionados

- `ARQUITETURA_PLAYOS_GRAPHICS_KERNEL_STACK_2026-08-26.md`;
- `MANUAL_PLAYOS_GRAPHICS_KERNEL_STACK_X11_WAYLAND.md`;
- `MEDICAO_TAMANHO_ISO_NOBLE_X11_WAYLAND_XFCE_2026-08-26.md`;
- `COMPARACAO_FEDORA_KNOPPIX_LIVE_XFCE_KERNEL_LOCAL_2026-08-26.md`.
- `ANALISE_SOFTWARE_FREEDESKTOP_PLAYOS_GRAPHICS_PLATFORM_2026-08-26.md`.
- `MANUAL_COMPONENTES_BASE_PLAYOS_DESKTOP.md`.
- `ARQUITETURA_MULTI_DESKTOP_PLAYOS_XFCE_GNOME_KDE.md`.

A unificação ocorre em empacotamento, identidade, configuração, diagnóstico,
testes e suporte — nunca pela fusão incorreta das camadas no kernel.
