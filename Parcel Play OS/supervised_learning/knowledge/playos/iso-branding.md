# Branding e Identidade da Mídia PlayOS

Este documento detalha a estratégia de substituição da identidade Ubuntu pela marca PlayOS na mídia de instalação e no sistema básico.

## Identidade Externa (Mídia)

- **Volume ID**: `PlayOS-26.04-amd64`
- **Menu de Boot**: Controlado por `config/boot/grub-playos.cfg`.
- **Entrada Padrão**: "PlayOS Baseline 26.04 Resolute — Live/Instalar".
- **Parâmetro de Kernel**: `parcel.kernel=playos` substitui `parcel.kernel=ubuntu`.

## Identidade Interna (RootFS)

A substituição interna exige a modificação das camadas SquashFS. Os alvos principais são:

1.  `/etc/os-release`: Define o nome exibido em "Sobre este sistema".
2.  `/etc/lsb-release`: Utilizado por scripts de detecção de distribuição.
3.  `/etc/issue` e `/etc/issue.net`: Mensagem de boas-vindas do terminal.
4.  `/etc/hostname`: Nome padrão da máquina (alterado para `playos`).

## Implementação

- **Script de Build**: [`scripts/build-playos-iso.sh`](../../scripts/build-playos-iso.sh)
- **Configuração GRUB**: [`config/boot/grub-playos.cfg`](../../config/boot/grub-playos.cfg)

## Estado de Validação

- `fact`: Árvore ISO extraída possui branding externo PlayOS.
- `implementation`: Script de build gera ISO com Volume ID correto.
- `unknown`: Persistência do branding após instalação (depende do instalador Subiquity).
