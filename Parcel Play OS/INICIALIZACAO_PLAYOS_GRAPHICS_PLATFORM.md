# Inicialização do PlayOS Graphics Platform

## Estado e objetivo

- **Classificação:** `proposal` de engenharia.
- **Data:** 2026-08-26.
- **Escopo:** Ubuntu Noble, kernel PlayOS, X11/Wayland e os desktops XFCE,
  GNOME e KDE Plasma.
- **Implementação:** ainda não criada por este documento.
- **Boot validado:** não; VM, ISO e hardware permanecem pendentes.

Este documento descreve como o produto especificado em
`PROJETO_SOFTWARE_UNICO_PLAYOS_GRAPHICS_PLATFORM.md` deve sair de uma máquina
desligada e chegar à área de trabalho.

> **Ampliação:** as seções LightDM/XFCE abaixo continuam válidas para o perfil
> XFCE. O sistema multi-desktop também poderá usar GDM ou SDDM e iniciar GNOME
> com Mutter ou Plasma com KWin. Somente um display manager fica ativo. Consulte
> `ARQUITETURA_MULTI_DESKTOP_PLAYOS_XFCE_GNOME_KDE.md`.

## Visão simples

```text
Firmware UEFI
    ↓
GRUB
    ↓
Kernel PlayOS + initramfs
    ↓
systemd no sistema raiz
    ↓
LightDM
    ↓
sessão X11 ou sessão Wayland
    ↓
XFCE utilizável
```

Cada etapa entrega o controle para a seguinte. Se uma etapa falhar, as etapas
posteriores não conseguem compensá-la. Por exemplo, XFCE não pode corrigir um
driver de armazenamento ausente no initramfs.

## 1. Firmware UEFI

Ao ligar o computador, o firmware inicializa o hardware mínimo e procura uma
entrada de boot na partição EFI. O produto precisa oferecer uma entrada PlayOS
que carregue o bootloader aprovado.

Requisitos propostos:

- suporte inicial a UEFI amd64;
- partição EFI com bootloader e arquivos corretamente instalados;
- modo legado BIOS tratado como perfil separado, não pressuposto;
- Secure Boot somente será declarado suportado após assinatura e boot real.

Resultado esperado: o firmware transfere controle ao GRUB.

## 2. GRUB

GRUB apresenta as opções de inicialização e carrega dois artefatos:

```text
/boot/vmlinuz-<abi>-playos
/boot/initrd.img-<abi>-playos
```

Entradas mínimas:

1. PlayOS com o kernel atual;
2. opções avançadas;
3. kernel PlayOS anterior conhecido como fallback;
4. modo de recuperação.

O metapacote `playos-kernel-graphics-meta` seleciona a ABI atual, mas não deve
apagar imediatamente o kernel anterior. O menu precisa identificar claramente
versão e ABI.

Parâmetros como `nomodeset`, opções específicas de GPU e depuração não devem
ser padrão permanente. Eles pertencem ao diagnóstico ou a perfis de hardware
com evidência.

Resultado esperado: kernel e initramfs são carregados na memória.

## 3. Kernel PlayOS

O kernel assume CPU, memória, interrupções, armazenamento e dispositivos. Para
o produto gráfico, ele precisa disponibilizar:

- driver do controlador de armazenamento e sistema de arquivos raiz;
- `devtmpfs`, `proc`, `sysfs` e mecanismos necessários ao userspace;
- DRM/KMS e driver da GPU;
- dispositivos de entrada por evdev;
- módulos e firmware compatíveis com a mesma ABI;
- console funcional para recuperação.

O kernel não inicia XFCE, Xorg ou Labwc. Ele somente oferece os recursos sobre
os quais esses programas trabalham.

Resultado esperado: o kernel monta ou delega ao initramfs a descoberta do
sistema raiz e executa o primeiro processo userspace.

## 4. Initramfs

O initramfs é o ambiente temporário usado antes da raiz real. Ele precisa ser
gerado para a mesma ABI do kernel PlayOS e conter o necessário para encontrar
e montar o sistema:

- módulos de armazenamento indispensáveis;
- módulos do sistema de arquivos raiz;
- firmware necessário nessa fase;
- ferramentas de descoberta de disco;
- suporte a criptografia, LVM ou RAID somente quando usados;
- scripts do boot Live quando a mídia for uma ISO.

No sistema instalado, o initramfs localiza a partição raiz e realiza
`switch_root`. Na Live ISO, localiza o SquashFS, monta a imagem somente leitura,
cria o overlay gravável e então troca para essa raiz combinada.

Regra crítica: `vmlinuz`, módulos em `/lib/modules/<abi>` e initramfs devem ter
a mesma ABI. Uma combinação parcial não é um kernel PlayOS inicializável.

Resultado esperado: a raiz definitiva torna-se `/` e o controle passa ao
`systemd` dessa raiz.

## 5. systemd

O PID 1 inicializa o userspace do Ubuntu Noble. A meta normal será
`graphical.target`, que depende do funcionamento dos serviços essenciais e do
display manager.

Fluxo simplificado:

```text
systemd
├── montagem de sistemas de arquivos
├── udev e descoberta de dispositivos
├── rede, logs e serviços essenciais
├── multi-user.target
└── graphical.target
    └── display-manager.service → LightDM
```

O diagnóstico `playos-graphics-check.service` será `Type=oneshot` e não deverá
bloquear `graphical.target`. Ele registra problemas, mas não toma o lugar do
LightDM e não reinicia uma sessão.

Se a inicialização gráfica falhar, o sistema deve continuar permitindo console
local ou modo de recuperação.

Resultado esperado: LightDM é iniciado após o userspace essencial.

## 6. LightDM

LightDM apresenta autenticação e lista os arquivos de sessão instalados:

```text
/usr/share/xsessions/playos-xfce-x11.desktop
/usr/share/wayland-sessions/playos-xfce-wayland.desktop
```

A sessão X11 será selecionada por padrão. A preferência pode ser guardada pelo
display manager ou por configuração PlayOS, mas não pode remover a opção de
fallback.

Após autenticação, LightDM cria o ambiente da sessão do usuário, aplica as
credenciais corretas e executa a sessão escolhida. Serviços gráficos de usuário
não devem executar como root.

## 7A. Inicialização da sessão X11

```text
LightDM
   ↓
Xorg
   ↓
startxfce4
   ↓
xfce4-session + xfwm4 + painel + desktop
```

Sequência:

1. LightDM inicia o servidor Xorg;
2. Xorg abre os dispositivos DRM e de entrada pelas interfaces permitidas;
3. LightDM inicia `startxfce4` para o usuário autenticado;
4. `xfce4-session` inicia os componentes do desktop;
5. `xfwm4` gerencia janelas e composição nessa sessão;
6. painel, desktop e serviços de usuário tornam-se disponíveis.

Este é o caminho inicial de suporte e recuperação gráfica do PlayOS.

## 7B. Inicialização da sessão Wayland

```text
LightDM
   ↓
playos-xfce-wayland-session
   ↓
Labwc/Wayland
   ├── componentes XFCE compatíveis
   └── Xwayland → aplicações X11 antigas
```

O launcher PlayOS deve:

1. confirmar `XDG_RUNTIME_DIR` e permissões;
2. preparar apenas variáveis documentadas;
3. iniciar Labwc como compositor Wayland;
4. iniciar os componentes XFCE compatíveis com essa sessão;
5. disponibilizar Xwayland sob demanda ou pela política definida;
6. registrar falha de forma útil e encerrar sem loop de login.

`xfwm4` não deve ser iniciado, pois Labwc ocupa seu papel. O estado inicial da
sessão Wayland é experimental; problemas nela não podem impedir a seleção de
X11 no login seguinte.

## 8. Quando o sistema está “inicializado”

Mostrar o wallpaper não basta. A inicialização só será considerada concluída
quando forem confirmados:

- kernel e ABI esperados em execução;
- raiz montada sem erro crítico;
- módulos e firmware essenciais disponíveis;
- DRM/KMS ligado ao driver correto;
- LightDM funcional;
- sessão selecionada iniciada como usuário comum;
- painel, janelas, teclado, mouse e armazenamento utilizáveis;
- logout retornando ao LightDM;
- desligamento e reinicialização concluídos.

Áudio, rede, suspensão e aceleração 3D fazem parte do gate funcional do desktop,
mesmo não sendo necessários para desenhar a primeira tela.

## 9. Boot da Live ISO

O fluxo Live acrescenta uma camada antes do `systemd`:

```text
UEFI
 ↓
bootloader da ISO
 ↓
kernel PlayOS + initramfs com live-boot
 ↓
SquashFS somente leitura + OverlayFS gravável
 ↓
systemd → LightDM → X11/Wayland → XFCE
```

Artefatos mínimos da mídia:

- bootloader UEFI;
- kernel PlayOS e initramfs coerentes;
- `filesystem.squashfs` contendo `playos-graphics-platform`;
- configuração `live-boot`;
- manifesto da versão da plataforma;
- checksum da mídia.

O overlay normalmente vive em RAM e desaparece ao desligar. Persistência em
disco é outro recurso e precisa de especificação e testes próprios.

## 10. Ordem de implementação segura

1. empacotar o kernel, módulos e headers com uma ABI definida;
2. gerar e inspecionar o initramfs;
3. criar entrada GRUB e preservar um kernel de fallback;
4. provar boot até console em VM;
5. instalar o metapacote gráfico e LightDM;
6. criar e provar a sessão X11;
7. criar o diagnóstico somente leitura;
8. criar e provar a sessão Wayland experimental;
9. montar a raiz Live e validar o overlay;
10. construir a ISO e repetir os testes de boot;
11. testar recuperação, atualização e rollback;
12. testar hardware representativo.

Não se deve começar pelo autologin ou wallpaper. Primeiro se prova a cadeia de
boot até console; depois o display manager; depois cada sessão.

## 11. Diagnóstico por etapa

| Sintoma | Primeira camada a verificar | Evidência útil |
|---|---|---|
| firmware não mostra PlayOS | UEFI/ESP | entradas NVRAM e arquivos EFI |
| GRUB abre, kernel não inicia | GRUB/kernel | entrada, caminhos e console |
| prompt do initramfs | raiz/storage/ABI | UUID, módulos e `/lib/modules` |
| emergência do systemd | montagens/serviços | `systemctl --failed`, journal |
| console funciona, sem login gráfico | LightDM/GPU | estado do serviço e logs |
| X11 falha | Xorg/DRM | log Xorg, driver e `/dev/dri` |
| Wayland volta ao login | launcher/Labwc | journal da sessão e ambiente |
| XFCE abre incompleto | sessão/pacotes | processos e dependências |
| tela preta após atualização | kernel/GPU | boot com kernel anterior |

Comandos iniciais depois de obter um console:

```bash
uname -a
cat /proc/cmdline
systemctl --failed
systemctl status display-manager
journalctl -b -p warning
ls -l /dev/dri
playos-graphicsctl diagnose
```

O último comando só existirá depois da implementação do pacote de ferramentas.

## 12. Modos de recuperação

O produto deve preservar três rotas:

1. kernel anterior pelo GRUB;
2. console ou `multi-user.target` sem display manager;
3. sessão X11 quando a sessão Wayland falhar.

Um modo temporário para depurar o userspace gráfico é iniciar sem a meta
gráfica e então verificar o display manager manualmente. A documentação final
de operação deverá fornecer comandos específicos somente após testar seu
comportamento no pacote real.

## 13. Gates de validação

| Gate | Resultado exigido | Estado |
|---|---|---|
| B0 | artefatos e ABI coerentes | pendente |
| B1 | UEFI → GRUB | pendente |
| B2 | GRUB → kernel | pendente |
| B3 | initramfs → raiz | pendente |
| B4 | systemd → console limpo | pendente |
| B5 | LightDM disponível | pendente |
| B6 | XFCE/X11 funcional | pendente |
| B7 | XFCE/Wayland funcional | pendente |
| B8 | Live ISO funcional | pendente |
| B9 | rollback comprovado | pendente |
| B10 | hardware representativo | pendente |

Cada gate precisa de log, versões, comando e resultado. “Compilou”, “mostrou o
wallpaper” e “há arquivos na ISO” não equivalem a boot completo.

## 14. Critério para a primeira versão

A primeira versão inicializável pode ser declarada quando:

- a mesma matriz de pacotes puder ser reconstruída;
- o kernel PlayOS iniciar em UEFI numa VM;
- o initramfs montar corretamente a raiz instalada e a raiz Live;
- LightDM oferecer as duas sessões;
- X11 completar login e logout;
- Wayland completar login e logout ou permanecer explicitamente desabilitado;
- existir console e kernel anterior para recuperação;
- os resultados estiverem documentados como `result`.

Até isso acontecer, este documento é um plano de inicialização, não evidência
de que o PlayOS já inicializa.

## Documentos relacionados

- `PROJETO_SOFTWARE_UNICO_PLAYOS_GRAPHICS_PLATFORM.md`;
- `ARQUITETURA_PLAYOS_GRAPHICS_KERNEL_STACK_2026-08-26.md`;
- `MANUAL_PLAYOS_GRAPHICS_KERNEL_STACK_X11_WAYLAND.md`;
- `LIVE_CD_RESOLUTE_XFCE_MINIMAL_KNOPPIX.md`;
- `COMPARACAO_FEDORA_KNOPPIX_LIVE_XFCE_KERNEL_LOCAL_2026-08-26.md`.
