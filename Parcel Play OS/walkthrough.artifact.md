# Walkthrough: Transição para Ubuntu Flavor (PlayOS)

A estrutura base para transformar o PlayOS em um flavor reconhecido do Ubuntu foi implementada. Esta mudança move o projeto de scripts manuais para pacotes de sistema modulares.

## Mudanças Realizadas

### 1. "Debianização" das Otimizações
Criamos a estrutura de pacotes `.deb` que serão futuramente hospedados no Launchpad:
- **`packages/playos-default-settings`**:
    - Inclui `etc/sysctl.d/99-playos-nitro.conf` com ajustes de baixa latência (NitroCore).
    - Arquivos de controle Debian prontos para compilação.
- **`packages/playos-artwork`**:
    - Contém o wallpaper 2K e logotipos oficiais.
    - Inclui o `99_playos-branding.gschema.override` para garantir a identidade visual.
- **`packages/playos-desktop`**:
    - Meta-pacote que define o PlayOS puxando o KDE e as ferramentas de compatibilidade (`gamescope`, `waydroid`).

### 2. Governança e Roadmap
- **`governance/FLAVOR_PROPOSAL.md`**: Proposta formal para o Ubuntu Technical Board, detalhando o valor do PlayOS para gaming e performance.
- **`supervised_learning/knowledge/playos/flavor-roadmap.md`**: Integração do plano de flavor na base de conhecimento supervisionada.

## O Que Foi Testado
- **Estrutura de Arquivos**: Validada a criação dos diretórios e arquivos de configuração.
- **Configurações Nitro**: O arquivo `sysctl` foi revisado para alinhar com as metas de performance do projeto.

## Próximos Passos
1.  **Criação do PPA**: Registrar o time `~playos-dev` no Launchpad e subir os fontes destes pacotes.
2.  **Compilação Real**: Utilizar `debuild` ou `sbuild` para gerar os binários `.deb`.
3.  **Ajuste no Builder**: Modificar o `live-build` do `ubuntu26-build` para que ele instale o pacote `playos-desktop` diretamente dos repositórios, em vez de injetar arquivos via `chroot`.
