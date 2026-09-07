# PlayOS Userspace + KDE Full + kernel Noble — Live inspirada no KNOPPIX

- ID: `PLAYOS-USERSPACE-KDE-KNOPPIX-001`
- tipo: `implementation-plan`
- estado: userspace e perfil Live estruturados; preflight, build e runtime pendentes
- confiança: alta para arquitetura; média para primeiro build; runtime `unknown`
- data: 2026-09-07

## Decisão

O produto não usará um rootfs KNOPPIX nem um userspace Debian. A primeira
geração terá identidade e composição PlayOS, usando os binários Ubuntu Noble
como baseline de bootstrap e compatibilidade. Essa dependência deve permanecer
visível: mudar `/etc/os-release` não transforma pacotes Ubuntu em software
desenvolvido pelo PlayOS.

O KNOPPIX 9.1 público é baseado em Debian Bullseye e inclui alguns pacotes Sid.
Também usa patches `cloop` e AUFS. Portanto, usar o rootfs ou pipeline exato do
KNOPPIX contrariaria o requisito de não usar userspace Debian e exigiria
alterações desnecessárias no kernel Noble.

## O que será reproduzido do modelo KNOPPIX

| Comportamento KNOPPIX | Implementação PlayOS inicial |
|---|---|
| filesystem comprimido somente leitura | SquashFS |
| escrita durante a sessão | OverlayFS em RAM |
| copiar a raiz para RAM | parâmetro `toram` do `live-boot` |
| conferir integridade da mídia | `verify-checksums` e `md5sum.txt` |
| mídia utilizável como ISO e USB | ISO híbrida BIOS/UEFI |
| autodetecção | kernel Noble, udev e systemd |
| persistência opcional | gate futuro com `persistence` |

Não entram `cloop`, AUFS, scripts antigos de detecção, kernel 32-bit ou mistura
de releases. A arquitetura é inspirada no KNOPPIX, não compatível com o layout
privado de sua mídia.

## Composição da primeira ISO

- identidade: PlayOS 1;
- bootstrap de pacotes: arquivos Ubuntu Noble `main`, `restricted`, `universe`
  e `multiverse`;
- kernel: Ubuntu Noble `generic`, versão exata registrada após o build;
- desktop: `kde-full` do Ubuntu Noble, Plasma 5.27 na baseline do arquivo;
- sessões: Plasma X11 e Wayland;
- login: SDDM, inicialmente com greeter X11 e autologin da sessão Live;
- rede: NetworkManager;
- áudio: PipeWire, WirePlumber e ALSA;
- gráficos: Mesa, Vulkan e firmware Ubuntu;
- Live: `live-boot`, `live-config`, SquashFS e OverlayFS;
- instalador: nenhum.

## Fontes e propriedade

`userspace/playos-noble/` é a fonte canônica da composição do userspace. O
perfil de ISO está em
`live-build/playos-ubuntu-noble-kde-full-knoppix-style/`. Nesta fase, pacotes
binários continuam sendo baixados dos mirrors Ubuntu; nenhum mirror Debian é
aceito pela auditoria.

Para o userspace se tornar progressivamente independente, o projeto ainda
precisa de um pacote `playos-base-files`, repositório APT assinado, publicação
de fontes correspondentes, rebuilds dos pacotes modificados, infraestrutura de
atualizações e política de segurança.

## Estado de capacidade

Após a limpeza da VM anterior, o host apresentou aproximadamente 20 GiB
livres. O build KDE Full anterior precisou de mais espaço de staging. Por isso,
o preflight do novo perfil exige 30 GiB livres e o build não foi iniciado.
Apagar ISOs ou VMs adicionais requer inventário e autorização específica para
não perder resultados únicos.

## Gates

1. liberar pelo menos 30 GiB e executar o preflight;
2. construir em staging sem espaços no caminho;
3. confirmar que todos os repositórios são Ubuntu Noble;
4. validar identidade PlayOS e versões reais dos pacotes;
5. verificar SquashFS, OverlayFS, initramfs, BIOS e UEFI;
6. inicializar em VM e testar SDDM, Plasma X11/Wayland, rede, áudio e Vulkan;
7. implementar persistência somente após o modo Live imutável funcionar;
8. empacotar a identidade em `playos-base-files` antes de uma release.

## Fontes primárias consultadas

- [KNOPPIX 9.1 — notas oficiais](https://www.knopper.net/knoppix/knoppix910-en.html)
- [Descrição oficial do KNOPPIX](https://www.knopper.net/knoppix/index-en)
- [Fontes dos componentes especiais KNOPPIX](https://knopper.net/knoppix-sources/)
- [Ubuntu Noble — pacote kde-full](https://packages.ubuntu.com/en/noble/kde-full)
- [Ubuntu — manual live-boot](https://manpages.ubuntu.com/manpages/resolute/man7/live-boot.7.html)

As notas do KNOPPIX confirmam Debian Bullseye, `cloop`, AUFS, mídia híbrida,
filesystem comprimido, overlay persistente e `flash-knoppix`. O arquivo Ubuntu
confirma `kde-full` 5:146ubuntu3 em Noble. Nenhuma dessas fontes comprova o boot
da futura ISO PlayOS; isso permanece pendente.
