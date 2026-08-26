# Análise do software freedesktop.org para o PlayOS Graphics Platform

## Estado, fonte e limite

- **Classificação:** `analysis` e `proposal`.
- **Data da análise:** 2026-08-26.
- **Fonte solicitada:** <https://www.freedesktop.org/wiki/Software/>.
- **Página acessível para inventário:** <https://people.freedesktop.org/~mak/fdo-web/software/>.
- **Implementação:** nenhuma seleção de pacote foi aplicada por este documento.

A página declara que sua lista é **incompleta** e reúne projetos hospedados,
relacionados, transferidos para outros locais e inativos. Portanto, ela não é
uma receita de distribuição e não significa que todos os itens devam entrar no
PlayOS.

O propósito avaliado é o produto já definido:

```text
Ubuntu Noble + kernel PlayOS + X11/Wayland/Xwayland + XFCE/GNOME/KDE Plasma
```

## Método de classificação

| Classe | Significado |
|---|---|
| `CORE` | necessário para o produto gráfico base ou sua cadeia normal |
| `PROFILE` | necessário apenas em um perfil de hardware ou função |
| `RECOMMENDED` | não impede o primeiro desktop, mas completa uma experiência de mercado |
| `OPTIONAL` | recurso adicional, fora do núcleo do produto |
| `DEVTEST` | usado para build, teste ou diagnóstico; não entra por padrão na ISO |
| `EXCLUDE` | inadequado, obsoleto, de outra plataforma ou substituído |
| `TRANSITIVE` | biblioteca que deve chegar por dependência do consumidor, sem metapacote fixá-la diretamente |

`CORE` não quer dizer que o pacote superior deve declarar todos os nomes
manualmente. Bibliotecas internas devem ser resolvidas pelos pacotes que usam
suas ABIs. Isso reduz acoplamento e evita dependências redundantes.

## Conclusão executiva

O catálogo confirma as famílias necessárias, mas não cobre sozinho o produto.
Para o PlayOS, o núcleo mínimo freedesktop é:

```text
systemd/logind + D-Bus + polkit
NetworkManager + UPower + udisks2
desktop-file-utils + shared-mime-info + xdg-utils + xdg-user-dirs
hicolor-icon-theme
DRM/KMS + Mesa + libinput + libevdev
fontconfig + FreeType + HarfBuzz + xkeyboard-config
X.Org/XCB/Xft + Wayland + Xwayland
```

Para uma experiência desktop padrão de mercado, acrescentam-se acessibilidade,
áudio moderno, multimídia, vídeo acelerado, descoberta de serviços, cor,
software center e portals. Alguns desses projetos não aparecem na página.

## 1. Middleware e frameworks de desktop

| Projeto da página | Classe | Uso no PlayOS |
|---|---|---|
| AccountsService | `RECOMMENDED` | expõe contas locais para login e configurações; validar integração real com LightDM antes de elevar a `CORE` |
| D-Bus | `CORE` | IPC de sistema e sessão; usado por systemd, polkit, NetworkManager, UPower e desktop |
| GeoClue | `OPTIONAL` | localização; instalar somente se aplicações e política de privacidade justificarem |
| PolicyKit/polkit | `CORE` | autorização de ações privilegiadas solicitadas pelo desktop |
| NetworkManager | `CORE` | rede cabeada, Wi-Fi e integração com applet do XFCE |
| realmd | `PROFILE` | ingresso em Active Directory e domínios corporativos |
| UPower | `CORE` em portátil; `RECOMMENDED` geral | bateria, carregamento e energia para o desktop |
| Zeitgeist | `EXCLUDE` padrão | registra atividades do usuário; não é necessário e aumenta superfície de privacidade/indexação |

### Decisão

O metapacote padrão inclui D-Bus, polkit e NetworkManager. UPower entra no
desktop padrão pela pequena diferença entre notebook e desktop. AccountsService
é recomendado até o teste do greeter. GeoClue, realmd e Zeitgeist não entram no
número mínimo.

## 2. Especificações e utilitários de integração

| Projeto | Classe | Uso |
|---|---|---|
| desktop-file-utils | `CORE` | valida e atualiza entradas `.desktop` e menus |
| icon-theme/hicolor | `CORE` | fallback padronizado de ícones |
| pyxdg | `TRANSITIVE`/`DEVTEST` | biblioteca Python; necessária somente a ferramentas que a importem |
| shared-mime-info | `CORE` | banco de tipos MIME e associação coerente de arquivos |
| startup-notification | `RECOMMENDED` X11 | feedback de abertura; compatibilidade de aplicações X11 |
| xdg-utils | `CORE` | `xdg-open`, navegador, e-mail e integração cross-desktop |
| xdg-user-dirs | `CORE` | Desktop, Documents, Downloads e outras pastas de usuário |

Além dos pacotes, o PlayOS deve respeitar as especificações XDG de diretórios,
autostart, desktop entries, menus, ícones, MIME e lixeira. Não existe exigência
freedesktop de implementar todas as especificações publicadas.

## 3. Gráficos, drivers e sistemas de janelas

| Projeto | Classe | Uso |
|---|---|---|
| Beignet | `EXCLUDE` | OpenCL Intel antigo, substituído pelo NEO; não pertence ao desktop base |
| Cairo | `TRANSITIVE` | renderização 2D usada por toolkits; deixar GTK/XFCE resolver a biblioteca |
| DRM | `CORE` | subsistema gráfico do kernel; interface KMS/render nodes para Xorg, Mesa e compositor |
| drm_hwcomposer | `EXCLUDE` | backend Android HWComposer, fora do PlayOS XFCE |
| Mesa | `CORE` | OpenGL, Vulkan, EGL, GLX e renderização por hardware/software |
| Monado | `PROFILE` | OpenXR para VR/AR; perfil futuro de realidade estendida |
| Nouveau | `PROFILE` de GPU | driver aberto NVIDIA no kernel e Mesa; selecionado pelo hardware, não como regra universal |
| Piglit | `DEVTEST` | conformidade/regressão OpenGL; imagem de teste, não ISO final |
| VirGL | `PROFILE` de VM | aceleração 3D em convidados virtuais compatíveis |
| Pixman | `TRANSITIVE` | composição 2D de baixo nível, normalmente dependência do Xorg/Cairo |
| Plymouth | `RECOMMENDED` | splash do boot; não pode ocultar logs de recuperação |
| Wayland | `CORE` | protocolo e bibliotecas da sessão Wayland |
| X.Org | `CORE` | servidor X11 da sessão estável |
| XCB | `CORE` transitivo | biblioteca de cliente X11 usada pela pilha |
| Xephyr | `DEVTEST` | servidor X11 aninhado para testes |
| xrestop | `DEVTEST` | diagnóstico de recursos do X server |
| xsettings | `RECOMMENDED` X11 | propagação de configurações para aplicações X11 compatíveis |
| X Testing | `DEVTEST` | conjunto/referência de ferramentas de teste |
| xwininfo | `DEVTEST` | inspeção de janelas X11 |

### Itens gráficos necessários que a página não representa completamente

- **Xwayland:** `CORE` para aplicações X11 na sessão Wayland;
- **Labwc:** `CORE` da sessão Wayland escolhida pelo PlayOS;
- **wlroots:** `TRANSITIVE`, conforme o pacote Labwc;
- **GTK 3/GLib:** `CORE` transitivo do XFCE e de aplicações padrão;
- **drivers Intel e AMD:** perfis selecionados pelo kernel/Mesa;
- **firmware Linux:** perfilado por hardware e licença;
- **libglvnd/Vulkan loader:** resolvido conforme a matriz Mesa/driver;
- **kernel DRM/KMS e dma-buf:** configuração obrigatória no kernel PlayOS.

## 4. Entrada, internacionalização e fontes

| Projeto | Classe | Uso |
|---|---|---|
| fontconfig | `CORE` | descoberta e configuração de fontes |
| Xft | `CORE` X11/`TRANSITIVE` | fontes em clientes X11 |
| FreeType | `CORE` transitivo | rasterização de fontes |
| libinput | `CORE` | teclado, mouse, touchpad, touchscreen e tablet em X11/Wayland |
| libevdev | `CORE` transitivo | interface de baixo nível para eventos do kernel |
| uchardet | `OPTIONAL` | detecção de codificação em aplicações que precisem |
| UTF-8 | `CORE` como política | locale UTF-8 obrigatório; é orientação, não pacote a instalar |
| xkeyboard-config | `CORE` | layouts e regras XKB compartilhados por X11/Wayland |

Para português do Brasil, o produto precisa de locale UTF-8, layout ABNT2 e
fontes com cobertura adequada. Métodos de entrada CJK pertencem ao perfil i18n,
não ao núcleo brasileiro inicial.

## 5. Projetos diversos

| Projeto | Classe | Uso |
|---|---|---|
| Bustle | `DEVTEST` | visualiza tráfego D-Bus durante diagnóstico |
| CppUnit | `DEVTEST` | framework de testes C++ somente para projetos que o utilizem |
| kmscon | `OPTIONAL` | console baseado em DRM/KMS; não substituir console atual sem estudo |
| libbsd | `TRANSITIVE`/`DEVTEST` | APIs utilitárias BSD em userspace; não importa kernel FreeBSD |
| pkg-config | `DEVTEST` | flags de compilação; necessário no ambiente de build, não no desktop final |
| Slirp | `PROFILE` | rede userspace para VMs/containers |
| SPICE | `PROFILE` de VM | console remoto e integração de convidados virtuais |
| SyncEvolution | `OPTIONAL` | sincronização de contatos/calendários; não é base gráfica |

`libbsd` não transforma Ubuntu em FreeBSD e não substitui o trabalho nativo de
kernel. Pode ser útil a programas portáveis em userspace.

## 6. Multimídia e imagens

| Projeto | Classe | Uso |
|---|---|---|
| Farstream | `OPTIONAL` | streaming de comunicação em tempo real |
| GStreamer | `RECOMMENDED` | reprodução/captura multimídia e integração com aplicações |
| libnice | `OPTIONAL`/`TRANSITIVE` | ICE para comunicação através de NAT |
| libopenraw | `OPTIONAL` | imagens RAW de câmeras |
| libspectre | `OPTIONAL` | renderização PostScript |
| media-player-info | `OPTIONAL` | identificação de players portáteis |
| Poppler | `RECOMMENDED` | PDF, thumbnails e aplicações documentais |
| PulseAudio | `COMPATIBILITY` | não será o servidor novo principal; usar compatibilidade sobre PipeWire se necessário |
| VDPAU | `PROFILE` | aceleração de vídeo para drivers/aplicações compatíveis |

### Áudio moderno ausente do catálogo

O catálogo ainda apresenta PulseAudio, mas a arquitetura nova deve avaliar:

- **ALSA:** interface de áudio no kernel/userspace de baixo nível;
- **PipeWire:** servidor de áudio e vídeo do desktop;
- **WirePlumber:** gerenciador de sessão/política do PipeWire;
- **pipewire-pulse:** compatibilidade com clientes PulseAudio;
- **GStreamer plugins:** conjuntos escolhidos por codecs, licença e tamanho.

Para um PlayOS desktop atual, a proposta é PipeWire + WirePlumber como padrão,
mantendo a API PulseAudio por compatibilidade, sujeita à matriz real do Noble.

## 7. Outros dispositivos

| Projeto | Classe | Uso |
|---|---|---|
| cups-pk-helper | `PROFILE` impressão | autorização desktop para configurar CUPS |
| fprint | `PROFILE` biometria | leitores de impressão digital; exige hardware e política de autenticação |
| ModemManager | `PROFILE` móvel | modems celulares e integração com NetworkManager |
| libmbim | `TRANSITIVE` móvel | dispositivos MBIM usados pelo ModemManager |
| libqmi | `TRANSITIVE` móvel | dispositivos QMI usados pelo ModemManager |

Impressão, biometria e banda larga móvel não precisam aumentar o Live mínimo.
Podem integrar a edição desktop standard ou pacotes de hardware.

## 8. Projetos hoje hospedados em outros locais

A mudança de hospedagem não torna o software inválido. A decisão depende de
manutenção e utilidade atual.

| Projeto | Classe | Decisão PlayOS |
|---|---|---|
| AppStream | `RECOMMENDED` | metadados para catálogo de software |
| at-spi2 | `CORE` standard | infraestrutura de acessibilidade |
| Avahi | `RECOMMENDED` | descoberta mDNS, impressoras e serviços locais |
| Clipart | `EXCLUDE` | conteúdo, não infraestrutura do sistema |
| Cogl | `TRANSITIVE` | somente se aplicação/toolkit escolhido depender |
| colord | `RECOMMENDED` | perfis e gestão de cor |
| epoxy | `TRANSITIVE` | carregamento OpenGL conforme consumidores |
| Flatpak | `OPTIONAL` | canal de aplicações sandboxed, fora do boot mínimo |
| Galago | `EXCLUDE` | presença antiga, sem função no produto |
| FriBidi | `TRANSITIVE` | texto bidirecional, puxado por bibliotecas de texto |
| HarfBuzz | `CORE` transitivo | shaping OpenType e internacionalização |
| intltool | `DEVTEST` | ferramenta histórica de tradução/build |
| LDTP | `DEVTEST` | automação de testes de desktop |
| libburn | `OPTIONAL` | gravação de mídia óptica |
| libminidump | `DEVTEST`/`OPTIONAL` | crash dumps se adotado por um coletor definido |
| LibreOffice | `OPTIONAL` aplicação | suíte de escritório, não requisito da plataforma gráfica |
| OHM | `EXCLUDE` | item histórico sem papel no baseline |
| OpenRaster | `OPTIONAL` | formato para aplicações gráficas |
| p11-glue/p11-kit | `RECOMMENDED` | integração PKCS#11, certificados e tokens |
| PackageKit | `RECOMMENDED` se houver loja | backend abstrato para software center; não substitui APT |
| SCIM | `EXCLUDE` padrão | método de entrada legado; escolher framework i18n atual se necessário |
| systemd | `CORE` | PID 1, serviços, journal, logind e sessões |
| Telepathy | `EXCLUDE` padrão | framework de comunicação antigo, sem função central |
| Tracker | `OPTIONAL` | indexação/pesquisa; custo e privacidade precisam ser avaliados |
| udisks | `CORE` desktop | mídia removível e operações de armazenamento via desktop |
| uim | `PROFILE` i18n | método de entrada; não instalar junto a alternativas sem política |
| VA-API | `RECOMMENDED` | aceleração de encode/decode de vídeo |
| xiccd | `OPTIONAL` X11 | gestão de cor X11 se a matriz colord exigir |
| XQuartz | `EXCLUDE` | servidor X11 para macOS, não Linux PlayOS |

## 9. Projetos inativos: decisão explícita

Todos os itens marcados como inativos pela página ficam fora do produto base.
Quando uma função ainda for necessária, usa-se o sucessor mantido.

| Projetos inativos | Classe | Motivo/substituição geral |
|---|---|---|
| APOC, CCSS, Desktop VFS, Eventuality, Galago relacionado, shared-desktop-ontologies, Ytstenut | `EXCLUDE` | frameworks históricos sem requisito atual |
| CJK-Unifonts, unicode-translation | `EXCLUDE` | usar famílias e infraestrutura i18n mantidas |
| ConsoleKit | `EXCLUDE` | substituído por systemd-logind no desenho PlayOS |
| dolt, Shave, Scratchbox2 | `EXCLUDE` | ferramentas antigas de build, sem papel no runtime |
| Enchant listado como inativo | `EXCLUDE` desta entrada | se correção ortográfica for necessária, selecionar implementação mantida do repositório, não assumir este item histórico |
| glitz, Hieroglyph, liboil | `EXCLUDE` | renderização/bibliotecas históricas substituídas |
| GTK-Qt Theme Engine, Tango, icon-slicer | `EXCLUDE` | não fazem parte da identidade XFCE PlayOS atual |
| Gypsy, HAL, pm-utils, system-tools-backends | `EXCLUDE` | funções assumidas por kernel/udev, UPower, systemd e serviços atuais |
| immodule for Qt, libxklavier | `EXCLUDE` | usar frameworks de input/XKB mantidos |
| libdlo | `EXCLUDE` padrão | hardware especializado antigo; tratar por perfil se reaparecer requisito |
| liblazy | `EXCLUDE` | wrapper D-Bus antigo |
| Loudmouth, Papyon | `EXCLUDE` | protocolos/frameworks de comunicação antigos |
| OpenSync | `EXCLUDE` | substituído por soluções específicas atuais |
| Razor | `EXCLUDE` | experimento RPM; PlayOS Noble usa APT/dpkg |
| swfdec | `EXCLUDE` | Adobe Flash obsoleto e inseguro |
| waimea, wmctrl, xfullscreen, Xoo, xprint, xresponse | `EXCLUDE` base | utilitários/WM X11 históricos, desnecessários para XFCE moderno |

Essa linha também cobre `dolt`, `icon-slicer`, `liblazy`, `Papyon`, `Shave` e
demais nomes da seção inativa da fonte; nenhum entra por herança histórica.

## 10. Software necessário que não está adequadamente coberto pela página

O produto não pode ser construído somente com o catálogo solicitado.

Além do XFCE inicialmente estudado, o PlayOS passa a incluir GNOME e KDE
Plasma. GNOME acrescenta GNOME Shell, Mutter, GDM e portal GNOME. Plasma
acrescenta KWin, SDDM, Qt/KDE Frameworks e portal KDE. Esses componentes são
tratados em `ARQUITETURA_MULTI_DESKTOP_PLAYOS_XFCE_GNOME_KDE.md`.

### Inicialização e sessão

- GRUB e ferramentas EFI;
- initramfs-tools e live-boot;
- udev, systemd-logind e PAM;
- LightDM e greeter GTK;
- XFCE (`xfce4-session`, `xfwm4`, painel, desktop, settings e Thunar).

### Wayland moderno

- Labwc, wlroots e protocolos Wayland;
- Xwayland;
- `xdg-desktop-portal` e backend GTK/XFCE compatível;
- PipeWire para compartilhamento/captura quando usado por portals.

### Áudio e desktop

- ALSA, PipeWire, WirePlumber e compatibilidade PulseAudio;
- serviço de keyring/Secret Service a escolher;
- Notification Specification e daemon de notificações XFCE;
- GVfs para locais e dispositivos integrados ao gerenciador de arquivos;
- thumbnails, temas GTK, cursores e fontes padrão.

### Distribuição e Live

- APT/dpkg, repositório assinado e metadados;
- SquashFS, OverlayFS e geração ISO híbrida;
- firmware por hardware;
- instalador somente em edição que o inclua;
- ferramentas de diagnóstico `playos-graphicsctl`.

## 11. Composição proposta por perfil

### `playos-graphics-platform-core`

Sistema inicializável e desktop funcional:

- systemd/logind, D-Bus, polkit;
- NetworkManager, UPower e udisks2;
- utilitários e especificações XDG essenciais;
- DRM/KMS, Mesa, libinput, fontes e teclado;
- Xorg, Wayland, Xwayland e Labwc;
- LightDM e XFCE;
- ALSA, PipeWire e WirePlumber;
- diagnóstico PlayOS.

### `playos-graphics-platform-standard`

Depende do core e acrescenta:

- at-spi2 e recursos de acessibilidade;
- GStreamer e plugins aprovados;
- VA-API;
- Avahi e colord;
- AppStream e backend de software escolhido;
- Poppler, portals, GVfs e integração de desktop;
- Plymouth sem remover o console de diagnóstico.

### Perfis separados

- `playos-hardware-printing`;
- `playos-hardware-fingerprint`;
- `playos-hardware-mobile-broadband`;
- `playos-virtualization-guest`;
- `playos-i18n-extended`;
- `playos-xr`;
- `playos-developer-graphics-tests`.

## 12. O que não deve acontecer

- instalar todo projeto listado apenas porque está no freedesktop.org;
- incluir projetos inativos na ISO;
- fixar bibliotecas transitivas sem necessidade;
- substituir APT por PackageKit — PackageKit, se usado, será frontend/backend de
  integração, enquanto dpkg/APT continuam a autoridade;
- usar PulseAudio como arquitetura nova sem avaliar PipeWire do Noble;
- instalar vários frameworks de método de entrada concorrentes por padrão;
- tratar DRM, Nouveau ou ALSA como programas comuns fora do relacionamento com
  kernel e hardware;
- declarar suporte a VR, modem, biometria ou impressão sem teste do perfil.

## 13. Gates antes de transformar a análise em pacotes

| Gate | Evidência necessária | Estado |
|---|---|---|
| F0 | matriz conceitual revisada | presente neste documento |
| F1 | nomes/versões resolvidos em Ubuntu Noble | pendente |
| F2 | licenças e componentes `main/universe/restricted` classificados | pendente |
| F3 | tamanho instalado e comprimido por perfil | pendente |
| F4 | dependências diretas separadas das transitivas | pendente |
| F5 | metapacotes Debian compilados | pendente |
| F6 | instalação APT limpa e reproduzível | pendente |
| F7 | boot, X11, Wayland, áudio e rede em VM | pendente |
| F8 | perfis de hardware testados | pendente |
| F9 | ISO medida e inicializada | pendente |

## 14. Próxima ação recomendada

Gerar uma matriz a partir dos índices APT da suite Noble efetivamente usada,
com colunas: projeto, pacote Ubuntu, versão, componente do repositório,
dependência direta/transitiva, download, tamanho instalado, licença e perfil.

Somente depois dessa resolução os nomes entram em `debian/control`. O catálogo
freedesktop orienta a função; o repositório Ubuntu determina os pacotes reais.

## Fontes

- Catálogo freedesktop.org: <https://www.freedesktop.org/wiki/Software/>
- Espelho navegável do catálogo: <https://people.freedesktop.org/~mak/fdo-web/software/>
- Especificações freedesktop.org: <https://www.freedesktop.org/wiki/Specifications/>
- D-Bus: <https://www.freedesktop.org/wiki/Software/dbus/>
- systemd: <https://systemd.io/>
- Wayland: <https://wayland.freedesktop.org/>
- Mesa: <https://docs.mesa3d.org/>

## Documentos PlayOS relacionados

- `PROJETO_SOFTWARE_UNICO_PLAYOS_GRAPHICS_PLATFORM.md`;
- `INICIALIZACAO_PLAYOS_GRAPHICS_PLATFORM.md`;
- `MANUAL_PLAYOS_GRAPHICS_KERNEL_STACK_X11_WAYLAND.md`;
- `MEDICAO_TAMANHO_ISO_NOBLE_X11_WAYLAND_XFCE_2026-08-26.md`.
