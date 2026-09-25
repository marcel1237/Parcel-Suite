# PlayOS: Live CD com KIWI NG, Debian e Oracle UEK

ID: `KB-PLAYOS-KIWI-ORACLE-UEK`

- tipo: `decision`
- confiança: `high`
- estado: `current`
- verificado em: `2026-09-18`
- fontes: `SRC-PLAYOS-KIWI-ORACLE-UEK`, `SRC-PLAYOS-NOBLE-KERNEL-DEBIAN`

## Síntese Técnica

O PlayOS utiliza o motor de construção declarativo **KIWI NG** (`kiwi-ng`) para integrar o **Oracle Unbreakable Enterprise Kernel (UEK)** sobre o **userspace Debian 13 (Trixie)** em um formato de Live ISO híbrida.

## Princípios de Arquitetura

1. **Separação Declarativa Kernel/Userspace:** O kernel Oracle UEK (Release 7 ou 8) e seus módulos inseparáveis são importados dos RPMs oficiais da Oracle e convertidos para pacotes `.deb` locais (`oracle-kernel-uek-image` e `oracle-kernel-uek-modules`), sem misturar mirrors APT e RPM.
2. **Motor KIWI NG:** A construção é regida por `kiwi-build/playos-debian-oracle-uek-live/config.xml` (schema 7.4), que parametriza o bootstrap Debian via APT, a integração do repositório local do UEK, a geração do initramfs por `dracut` e o empacotamento da ISO Live.
3. **Desktops e Serviços:** O userspace (glibc, systemd, Xorg, XFCE 4.20, LightDM, drivers Mesa) é 100% derivado dos repositórios oficiais do Debian 13 Trixie.

## Estado Registrado

- Perfil KIWI NG e scripts de automação (`config.xml`, `config.sh`, `images.sh`, `import_oracle_uek.sh`, `build.sh`) implementados.
- Documento técnico de referência em `ARQUITETURA_PLAYOS_KIWI_DEBIAN_ORACLE_UEK.md`.
- Geração de ISO e teste de runtime em VM/hardware permanecem no estado `pending-execution` / `unknown`.
