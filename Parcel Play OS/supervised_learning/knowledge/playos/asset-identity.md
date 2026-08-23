# Identidade Visual e Assets do PlayOS

Este documento define os caminhos e padrões para a substituição de ativos visuais (ícones, wallpapers, logos) no sistema.

## Alvos de Substituição (RootFS)

Estes arquivos residem dentro das camadas SquashFS e devem ser substituídos para remover o branding visual do Ubuntu:

### 1. Wallpapers (Planos de Fundo)
- **Caminho**: `/usr/share/backgrounds/`
- **Ação**: Remover imagens `ubuntu-default.png` e adicionar `playos-neon-v1.jpg`.
- **Configuração**: Atualizar `/usr/share/gnome-background-properties/` para apontar para o novo padrão.

### 2. Ícones de Sistema
- **Caminho**: `/usr/share/icons/`
- **Ícone do Menu**: Substituir `distributor-logo-ubuntu.svg` em todos os tamanhos por `playos-logo.svg`.
- **Tema de Ícones**: O PlayOS utilizará o tema **Breeze-Noir** (customizado) por padrão.

### 3. Plymouth (Boot Splash)
- **Caminho**: `/usr/share/plymouth/themes/default.plymouth`
- **Ação**: Apontar para o tema `parcel-pulse` (Nitro-Pulse).

## Mockups de Interface

Os mockups em QML devem utilizar os seguintes identificadores:
- **Logo**: `playos-logo`
- **Selo de Performance**: `nitro-optimized-badge`

## Próximos Passos
1.  Criar os arquivos SVG/JPG oficiais.
2.  Preparar script de injeção de assets para o estágio de reconstrução do SquashFS.
