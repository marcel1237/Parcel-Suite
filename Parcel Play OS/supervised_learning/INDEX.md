# Índice da base de conhecimento

Entrada obrigatória para IA: [AGENTS.md](../AGENTS.md)

Portal visual inicial: [documentation-portal/index.html](../documentation-portal/index.html)

## BSD prioritário

- [FreeBSD 15.1: identidade e capacidades](knowledge/freebsd/identity-capabilities.md)
- [FreeBSD `sys/kern`: mapa técnico](knowledge/freebsd/sys-kern-map.md)
- [Referência de subsistemas FreeBSD](knowledge/freebsd/subsystem-reference.md)
- [Segurança e isolamento BSD](knowledge/freebsd/security-isolation.md)
- [Rede, armazenamento e virtualização](knowledge/freebsd/io-network-virtualization.md)
- [OpenBSD e NetBSD no PlayOS](knowledge/bsd-family/openbsd-netbsd.md)
- [Glossário BSD/Linux/PlayOS](knowledge/bsd-family/glossary.md)

## Comparação e aplicação

- [Mapeamento FreeBSD–Linux](knowledge/mappings/freebsd-linux.md)
- [Decisões e estado real do PlayOS](knowledge/playos/decisions-status.md)
- [Builds e evidências Linux](knowledge/linux/build-evidence.md)
- [PlayOS Kernel 7.1.8 com perfil Noble](knowledge/linux/playos-kernel-7.1.8.md)
- [Live ISO mínima Resolute + XFCE e estudo Knoppix](../LIVE_CD_RESOLUTE_XFCE_MINIMAL_KNOPPIX.md)
- [Auditoria da fonte local escolhida para a Live XFCE](../AUDITORIA_KERNEL_LOCAL_LIVE_RESOLUTE_XFCE_2026-08-26.md)
- [Comparação Fedora/Knoppix e procedimento Live XFCE](../COMPARACAO_FEDORA_KNOPPIX_LIVE_XFCE_KERNEL_LOCAL_2026-08-26.md)
- [PlayOS Graphics Kernel Stack: X11 e Wayland integrados](../ARQUITETURA_PLAYOS_GRAPHICS_KERNEL_STACK_2026-08-26.md)
- [Manual completo do PlayOS Graphics Kernel Stack](../MANUAL_PLAYOS_GRAPHICS_KERNEL_STACK_X11_WAYLAND.md)
- [Medição de tamanho Noble + X11 + Wayland + XFCE](../MEDICAO_TAMANHO_ISO_NOBLE_X11_WAYLAND_XFCE_2026-08-26.md)
- [Produto único PlayOS Graphics Platform](../PROJETO_SOFTWARE_UNICO_PLAYOS_GRAPHICS_PLATFORM.md)
- [Inicialização do PlayOS Graphics Platform](../INICIALIZACAO_PLAYOS_GRAPHICS_PLATFORM.md)
- [Software freedesktop.org necessário ao PlayOS](../ANALISE_SOFTWARE_FREEDESKTOP_PLAYOS_GRAPHICS_PLATFORM_2026-08-26.md)
- [Manual dos componentes-base do desktop PlayOS](../MANUAL_COMPONENTES_BASE_PLAYOS_DESKTOP.md)
- [Arquitetura multi-desktop XFCE, GNOME e KDE Plasma](../ARQUITETURA_MULTI_DESKTOP_PLAYOS_XFCE_GNOME_KDE.md)
- [Kernel gráfico PlayOS sem desktops](../KERNEL_GRAFICO_PLAYOS_SEM_DESKTOPS.md)
- [PlayOS Graphics Core completo sem desktops](../PLAYOS_GRAPHICS_CORE_COMPLETO_SEM_DESKTOPS.md)
- [Vulkan no PlayOS Graphics Core](../VULKAN_NO_PLAYOS_GRAPHICS_CORE.md)
- [ISO Noble GNOME + Calamares](../LIVE_ISO_NOBLE_GNOME_CALAMARES_2026-08-31.md)
- [Inventário da primeira Live Noble XFCE + Calamares](../INVENTARIO_LIVE_CD_XFCE_CALAMARES_2026-08-31.md)
- [Live Noble XFCE sem instalador](../LIVE_ISO_NOBLE_XFCE_SEM_INSTALADOR_2026-08-31.md)
- [Kernel Ubuntu Noble sobre userspace e Live Debian](../ARQUITETURA_PLAYOS_KERNEL_UBUNTU_NOBLE_USERSPACE_DEBIAN.md)
- [Live Debian Trixie XFCE com kernel Noble, sem Calamares](../LIVE_DEBIAN_TRIXIE_XFCE_KERNEL_NOBLE_SEM_CALAMARES.md)
- [Execução do build Debian Trixie XFCE com kernel Noble](../RELATORIO_EXECUCAO_BUILD_LIVE_DEBIAN_XFCE_NOBLE_2026-09-03.md)
- [Live Debian Trixie GNOME com kernel Noble, sem instalador](../LIVE_DEBIAN_TRIXIE_GNOME_KERNEL_NOBLE_SEM_INSTALADOR.md)

## Catálogos

- `catalog/sources.tsv`: documentos e fontes canônicas;
- `catalog/topics.tsv`: roteamento assunto → entrada;
- `catalog/decisions.tsv`: decisões, estado e evidência;
- `catalog/implementations.tsv`: código/patch/build e nível de validação.
- `catalog/document_inventory.tsv`: descoberta dos 65 documentos relacionados,
  incluindo histórico, contexto e propostas não canônicas.

## Datasets

- `datasets/train.jsonl`;
- `datasets/validation.jsonl`;
- `datasets/adversarial.jsonl`;
- `evaluations/questions.jsonl`.

## Governança

- [Política de evidência](governance/EVIDENCE_POLICY.md)
- [Auditoria inicial](AUDITORIA_BASE_IA_2026-08-19.md)
- [Cobertura atual](evaluations/COVERAGE.md)
- [Roadmap BSD](ROADMAP_BSD_KNOWLEDGE.md)
