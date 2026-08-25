# Estratégia de Transição: PlayOS como Ubuntu Flavor Oficial

Este plano detalha a migração do Parcel Play OS de um sistema "remasterizado manualmente" para um **Flavor Reconhecido do Ubuntu**, seguindo os padrões técnicos e comunitários da Canonical.

## User Review Required

> [!IMPORTANT]
> A transição para um Flavor oficial exige que **todas** as alterações proprietárias (NitroCore) sejam empacotadas como arquivos `.deb` e hospedadas publicamente no Launchpad. Não poderemos usar binários de kernel externos na ISO final se buscarmos o selo "Official".

## Proposed Changes

O objetivo é transformar os scripts atuais em pacotes de sistema modulares.

### 1. Pacotes Base (Debianization)

#### [NEW] `packages/playos-default-settings/`
Este pacote conterá as configurações de sistema que hoje são aplicadas via `chroot`.
- **`/etc/playos/nitro-tuning.conf`**: Configurações de `sysctl` para performance.
- **`/usr/lib/playos/hooks/`**: Scripts de otimização de boot e memória (ex-NitroCore).
- **`/etc/os-release.d/`**: Overrides de identidade.

#### [NEW] `packages/playos-artwork/`
Centralização da identidade visual.
- **`/usr/share/backgrounds/playos/`**: Wallpapers 2K.
- **`/usr/share/icons/playos/`**: Logotipos e ícones de marca.
- **`99_playos-branding.gschema.override`**: Configuração padrão de interface.

#### [NEW] `packages/playos-desktop/` (Meta-package)
O pacote "guarda-chuva" que define o sistema.
- Dependências: `kde-full`, `playos-default-settings`, `playos-artwork`, `gamescope`, `waydroid`.

### 2. Infraestrutura de Build (Launchpad)

#### [NEW] `governance/FLAVOR_PROPOSAL.md`
Documento mestre seguindo o template do Ubuntu Technical Board para submissão oficial.

#### [MODIFY] `ubuntu26-build/livecd-rootfs/`
Ajustar o projeto `playos` criado para puxar os novos pacotes `.deb` do repositório em vez de injetar arquivos manualmente.

## Verification Plan

### Automated Tests
1. **`pbuilder` / `sbuild`**: Validar a compilação dos pacotes `.deb` em ambiente limpo.
2. **`livecd-rootfs`**: Executar build completo via LXD garantindo que o wallpaper do PlayOS aparece nativamente (sem overrides manuais pós-build).

### Manual Verification
1. Instalar o pacote `playos-desktop` sobre um Ubuntu Server limpo e verificar se a "metamorfose" ocorre corretamente.
