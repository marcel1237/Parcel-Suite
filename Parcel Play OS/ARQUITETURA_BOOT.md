# Arquitetura de Boot: Menu Híbrido com 11 Opções

Este documento detalha o funcionamento do processo de boot do **Parcel Play OS**, desde a inicialização do Live CD até a transição para o sistema instalado.

## Princípio central

O Parcel Play OS utilizará uma única mídia com onze opções: oito kernels Linux e três sistemas BSD. A escolha acontece antes da inicialização. Somente as opções Linux montam o rootfs Ubuntu compartilhado com GNOME e KDE Full.

```text
menu principal
├── Linux → kernel → initramfs → Plymouth → Casper → rootfs Ubuntu → GDM → GNOME/KDE
└── BSD → bootloader/kernel/rootfs nativos
```

Não haverá oito cópias do desktop Linux: o SquashFS Ubuntu é compartilhado entre as opções Linux. Os BSDs possuem payloads separados e não executam o desktop Ubuntu.

## 1. O Menu GRUB da Live ISO

Quando todos os componentes estiverem implementados, o menu poderá oferecer **Ubuntu, sete NitroCore Linux, FreeBSD, NetBSD e OpenBSD**.

### Configuração de Menu:
- **Opção padrão durante o desenvolvimento**: **Ubuntu Oficial**.
    - *Razão*: É o único kernel já integrado ao Resolute e serve como baseline e recuperação.
- **Opções Linux planejadas**: Arch, Fedora, openSUSE, Gentoo, Debian, CentOS e Oracle.
- **Opções BSD planejadas**: FreeBSD, NetBSD e OpenBSD com bootloaders e payloads nativos.
- **Regra Linux**: Exige kernel, initramfs, Plymouth e teste Live.
- **Regra BSD**: Exige bootloader, kernel, rootfs/ramdisk e teste próprios.

### Initramfs separado por entrada
Cada entrada Linux terá seu próprio initramfs e Plymouth. Os BSDs não usam esse mecanismo.

Estrutura planejada:

```text
/casper/vmlinuz-ubuntu
/casper/initrd-ubuntu
/casper/vmlinuz-nitro-arch
/casper/initrd-nitro-arch
...
/casper/vmlinuz-nitro-oracle
/casper/initrd-nitro-oracle
```

Os initramfs podem compartilhar módulos e conteúdo funcional, mas cada arquivo incorpora seu tema e identificação visual próprios.

Depois de carregar um par Linux, o initramfs deve montar as mesmas camadas `casper/*.squashfs`. Uma opção BSD carrega seu próprio ambiente e nunca usa o SquashFS Ubuntu como raiz.

## 2. Plymouth por entrada Linux

Cada `menuentry` deve carregar explicitamente o kernel e o initrd correspondentes. Exemplo conceitual:

```grub
menuentry "Parcel Play OS — Ubuntu Oficial" {
    linux /casper/vmlinuz-ubuntu boot=casper quiet splash parcel.kernel=ubuntu
    initrd /casper/initrd-ubuntu
}

menuentry "Parcel Play OS — NitroCore Arch" {
    linux /casper/vmlinuz-nitro-arch boot=casper quiet splash parcel.kernel=arch
    initrd /casper/initrd-nitro-arch
}
```

`quiet splash` habilita a experiência gráfica. `parcel.kernel=` é metadado próprio para logs e diagnóstico; ele não seleciona sozinho o tema Plymouth.

## 3. Processo de Transição e Aceleração

O boot do Parcel Play OS é dividido em estágios de alta performance:

### Estágio 1: Kernel de Gênese
- Boot do kernel escolhido no GRUB; durante o MVP, somente o Ubuntu Oficial estará disponível.

### Estágio 2: Dark Volt (Early UI)
- **Planejado e em hold**: o serviço Dark Volt não faz parte do boot atual e não será ativado sem aprovação e testes próprios.
- No MVP, Plymouth entrega a splash e o systemd conduz o boot normal até o display manager.

### Estágio 3: Handoff (O "Salto")
- Após o login, o sistema pode usar `kexec` se necessário ou simplesmente transicionar para o compositor Wayland (Gnome ou KDE).

## 4. Segurança e Integridade (UKI)

O uso futuro de **Unified Kernel Images (UKI)** está em avaliação:
- O Kernel, o Initrd e os parâmetros de boot são assinados digitalmente e unidos em um único arquivo `.efi`.
- A adoção exigirá uma estratégia de assinatura, gerenciamento de chaves e testes de Secure Boot para cada perfil.
- A primeira Live ISO preservará o modelo de boot oficial do Ubuntu, sem afirmar que UKIs Parcel já foram implementadas.

---
*Status: Arquitetura híbrida planejada; ainda não validada com as onze opções.*
