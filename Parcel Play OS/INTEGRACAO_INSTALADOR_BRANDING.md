# Integração de Branding no Instalador

Este documento detalha como a marca **PlayOS** é integrada aos dois motores de instalação suportados pelo projeto.

## 1. Calamares (Interface KDE)

O Calamares é o instalador planejado para a Sessão KDE Full. O branding é controlado em \`installer/branding/\`.

- **slideshow**: O arquivo [\`show.qml\`](installer/branding/show.qml) foi atualizado para destacar a "Infraestrutura PlayOS com Kernel NitroCore".
- **branding.desc**: Define o nome do produto como "Parcel Play OS" e redireciona para as URLs oficiais do projeto.
- **Módulos Customizados**:
    - \`kernel_selector\`: Permite escolher um dos 10 sabores do NitroCore durante a instalação.
    - \`network_config\`: Configura as otimizações de rede do FreeBSD logo no início.

## 2. Subiquity (Ubuntu Desktop Installer - MVP)

Como o MVP utiliza o instalador oficial do Ubuntu (baseado em Flutter), o branding é injetado via manipulação da árvore ISO.

- **Configuração de Fontes**: O arquivo \`casper/install-sources.yaml\` é modificado pelo script de build para renomear as opções de instalação de "Ubuntu Desktop" para "PlayOS Desktop".
- **Identidade Visual**: As strings de boas-vindas são alteradas em arquivos de metadados na raiz da ISO.
- **Configuração Híbrida**: O arquivo [\`config/installer/subiquity-branding.yaml\`](config/installer/subiquity-branding.yaml) define o template de identidade para futuras versões customizadas do motor Subiquity.

## 3. Scripts de Automação

- **[\`scripts/build-playos-iso.sh\`](scripts/build-playos-iso.sh)**: Orquestra a substituição de strings em toda a árvore ISO e define o Volume ID do disco.
- **[\`scripts/apply-internal-branding.sh\`](scripts/apply-internal-branding.sh)**: Destinado à execução via chroot para alterar a identidade dentro do sistema instalado.

---
*Status: Branding integrado aos fluxos de instalação.*
