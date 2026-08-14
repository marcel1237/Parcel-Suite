# Execução do MVP Live Ubuntu Resolute

## Objetivo

Produzir o primeiro baseline do Parcel Play OS a partir da ISO Ubuntu Resolute Desktop amd64, preservando GNOME/GDM e Ubuntu Desktop Installer/Subiquity, acrescentando KDE Full e validando boot e instalação.

## Execução em 2026-08-13

### Auditoria inicial

Comandos executados em modo somente leitura:

```bash
command -v xorriso
command -v unsquashfs
command -v mksquashfs
command -v qemu-system-x86_64
command -v gpg
df -h .
git status --short
```

Resultados:

- `xorriso`, `unsquashfs`, `mksquashfs` e `gpg` estão instalados;
- QEMU não está instalado;
- havia aproximadamente 161 GiB livres antes do download;
- as alterações preexistentes do usuário foram preservadas;
- foram criados somente diretórios novos sob `build/resolute-mvp/`.
- foi criado `.gitignore` com `/build/`, impedindo que aproximadamente 11,8 GiB de downloads e arquivos temporários sejam adicionados acidentalmente ao Git; os artefatos permanecem no disco.

### Artefato oficial

Origem:

```text
https://cdimage.ubuntu.com/ubuntu/resolute/daily-live/current/
```

Artefatos obtidos:

- `resolute-desktop-amd64.iso`, build de 2026-08-11, aproximadamente 5,84 GiB;
- `SHA256SUMS`;
- `SHA256SUMS.gpg`.

Caminho local:

```text
build/resolute-mvp/download/
```

A imagem oficial está marcada como `OVERSIZED`. Ela é apropriada para Live USB, DVD de capacidade suficiente ou VM, mas não cabe em CD de 703 MiB.

### Integridade e assinatura

O comando abaixo confirmou o hash publicado:

```bash
sha256sum -c SHA256SUMS --ignore-missing
```

Resultado:

```text
resolute-desktop-amd64.iso: OK
```

A chave foi importada em um keyring isolado do build a partir de `hkps://keyserver.ubuntu.com`:

```text
Ubuntu CD Image Automatic Signing Key (2012) <cdimage@ubuntu.com>
8439 38DF 228D 22F7 B374 2BC0 D94A A3F0 EFE2 1092
```

`gpg --verify` retornou `Good signature`. O keyring temporário não possui uma cadeia de confiança local; por isso o GPG também exibiu o aviso esperado de confiança desconhecida. Hash e assinatura criptográfica foram verificados, mas uma política própria de certificação da chave ainda não foi configurada.

### Inspeção e extração

A ISO foi inspecionada e extraída sem montagem privilegiada:

```text
build/resolute-mvp/work/iso-tree/
```

O boot original é híbrido:

- El Torito para BIOS;
- imagem EFI anexada;
- MBR protetivo e GPT;
- GRUB 2;
- volume `Ubuntu 26.04 LTS amd64`.

O Resolute não utiliza um único `filesystem.squashfs`. A fonte Desktop completa é composta por camadas:

| Camada | Comprimida | Compressão | Função observada |
| :--- | ---: | :---: | :--- |
| `minimal.squashfs` | 3.269,64 MiB | xz | sistema base comum |
| `minimal.standard.squashfs` | 561,26 MiB | xz | complemento do Desktop completo |
| `minimal.standard.live.squashfs` | 522,66 MiB | xz | complemento da sessão Live/instalador |

O arquivo `casper/install-sources.yaml` define:

- `ubuntu-desktop-minimal`, padrão;
- `ubuntu-desktop`, opção de Desktop completo;
- tipo `fsimage-layered`.

Isso significa que alterar apenas a camada `live` não garante que KDE seja transferido ao sistema instalado. KDE Full deve integrar o payload da fonte `ubuntu-desktop` e também estar disponível na sessão Live.

## Bloqueios confirmados

### Privilégio administrativo

O teste:

```bash
sudo -n true
```

retornou:

```text
sudo: interactive authentication is required
```

A instalação correta de `kde-full` requer executar APT e scripts de manutenção dentro de um rootfs com privilégios, além de mounts/bind mounts ou uma ferramenta oficial equivalente. `fakeroot` não fornece as chamadas privilegiadas necessárias. O user namespace também não pôde mapear UID 0 neste ambiente (`unshare: write failed /proc/self/uid_map: Operation not permitted`).

Não foi feita uma falsa instalação copiando pacotes `.deb`, pois isso deixaria dependências, alternativas, gatilhos, caches e configuração do GDM inconsistentes.

### Teste em VM

QEMU não está instalado e `/dev/kvm` não estava presente na auditoria anterior. Logo, boot e instalação não podem ser validados nesta etapa sem instalar ferramentas e habilitar KVM.

## Estado real

Concluído:

- localização da build oficial corrente;
- download integral da ISO e manifestos;
- validação SHA-256;
- validação da assinatura GPG;
- extração integral da árvore ISO;
- inspeção do boot híbrido;
- identificação das camadas corretas do Casper/Subiquity.

Pendente por exigir autenticação administrativa:

- montar/compor o rootfs em camadas;
- executar `apt install kde-full` no payload;
- manter/configurar GDM;
- regenerar manifestos, tamanhos e SquashFS;
- reconstruir a ISO preservando BIOS/UEFI;
- instalar QEMU/OVMF;
- testar Live GNOME/Plasma e Subiquity em disco virtual descartável.

Nenhuma ISO Parcel foi gerada. A ISO baixada continua sendo a imagem oficial não modificada.

## Protótipo posterior do menu de onze opções

Depois da inspeção inicial, foi gerada uma ISO Parcel que altera somente os dois menus GRUB. Esta atualização substitui, apenas para o menu, o estado anterior de “nenhuma ISO Parcel”; KDE e os dez payloads adicionais continuam não integrados.

```text
build/resolute-mvp/output/parcel-play-11-menu-prototype-amd64.iso
Tamanho: 6.279.266.304 bytes
SHA-256: 44a1ca2c3c239b0b87747c8372daee7d50c1a8d043644a1a5b0666516b95ec5d
```

O build usou `xorriso -boot_image any replay`, preservando BIOS/UEFI. Os menus foram reextraídos, comparados com a fonte e aprovados por `grub-script-check`. Somente Ubuntu possui kernel/initrd; as outras dez posições ficam explicitamente indisponíveis. QEMU permanece ausente, portanto não houve teste dinâmico.

## Próxima execução autorizada

Quando houver uma sessão capaz de autenticar `sudo`, primeiro instalar/confirmar as ferramentas:

```bash
sudo apt install qemu-system-x86 qemu-utils ovmf debootstrap
```

Depois, a composição das camadas deve ser feita por OverlayFS ou pelo pipeline oficial `livecd-rootfs`, mantendo uma camada inferior imutável e registrando precisamente os arquivos acrescentados por KDE. Antes de gerar a ISO, é obrigatório validar:

```bash
dpkg-query -W kde-full gdm3 ubuntu-desktop ubuntu-desktop-bootstrap
systemctl get-default
```

O boot original deve ser reproduzido com os parâmetros retornados por:

```bash
xorriso -indev resolute-desktop-amd64.iso -report_el_torito as_mkisofs
```

Não se deve reconstruir a imagem com um comando ISO genérico que descarte a partição EFI anexada ou o MBR do GRUB.
