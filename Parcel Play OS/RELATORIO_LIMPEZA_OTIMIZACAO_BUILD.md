# Relatório de Limpeza e Otimização de Espaço

- **Data:** 20 de Setembro de 2026
- **Objetivo:** Recuperação de espaço em disco no host (Lenovo V14) e manutenção de artefatos finais.
- **Estado:** Concluído.

## 1. Ações Realizadas

### No Sistema Host (Diretório build/):
Foi realizada uma purga manual de diretórios intermediários de construção dentro da pasta `Parcel Play OS/build/`.
- **Diretórios Removidos:** `chroot/` e `binary/` de todos os perfis (KDE, GNOME, XFCE).
- **Justificativa Técnica:** Estes diretórios continham os sistemas de arquivos descompactados e caches do `live-build`, ocupando aproximadamente 15 GB por perfil.
- **Espaço Recuperado Estimado:** ~60 GB.

### Na Infraestrutura LXD:
- **Instâncias Removidas:** Todas as VMs e Containers (`playos-noble-graphics-builder`, `playos-ubuntu-noble-kde-builder-vm`, `playos-debian-trixie-kde-installer-vm`).
- **Storage Pool:** O pool `default` (ZFS) de 60 GB foi deletado, removendo o arquivo físico `/var/snap/lxd/common/lxd/disks/default.img`.

## 2. Artefatos Preservados (Status Quo)

A limpeza foi seletiva. Os seguintes arquivos críticos foram mantidos em suas respectivas pastas `output/`:

| ISO | Tamanho | Status |
| :--- | :--- | :--- |
| `playos-debian-trixie-kde-full-noble` | 3.5 GB | ISO, .packages e .log preservados. |
| `playos-debian-trixie-gnome-noble` | 1.9 GB | ISO, .packages e .log preservados. |
| `playos-debian-trixie-xfce-noble` | 1.3 GB | ISO, .packages e .log preservados. |
| `playos-graphics-core-noble` | 1.7 GB | ISO, .packages e .log preservados. |

## 3. Impacto no Fluxo de Trabalho
- **Manutenção:** A auditoria estática das imagens ainda é possível através dos arquivos `.packages` e `.log`.
- **Novas Iterações:** Caso seja necessário alterar a composição de uma ISO, o build deverá ser reiniciado do estágio `bootstrap`, pois os caches locais foram removidos.
- **Saúde do Host:** O disco principal agora possui ~64 GB livres, garantindo estabilidade para o sistema operacional e novas tarefas de desenvolvimento.

---
**Conclusão:** O projeto encontra-se em estado "Lean" (enxuto). Os resultados técnicos (ISOs) estão garantidos, enquanto o lixo de processamento foi eliminado.
