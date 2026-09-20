# Receita KIWI: PlayOS Híbrido (Noble + Trixie)

Esta é a estrutura base para configurar o build do PlayOS usando o **KIWI NG**.

## 1. Estrutura de Diretórios do Projeto
```text
playos-kiwi/
├── config.xml         # Definição declarativa da distro
├── config.sh          # Script de configuração pós-instalação
└── root/              # Arquivos customizados (Wallpapers, ícones, etc.)
    └── etc/
        └── skel/      # Perfil padrão do KDE
```

---

## 2. Definição do Projeto (`config.xml`)

Este arquivo define como o KIWI deve montar o sistema:

```xml
<?xml version="1.0" encoding="utf-8"?>
<image schemaversion="7.4" name="PlayOS-Hybrid">
    <description type="system">
        <author>Marcel</author>
        <contact>marcel@playos.org</contact>
        <specification>PlayOS Noble Kernel + Debian Trixie Userspace</specification>
    </description>

    <preferences>
        <type image="iso" filesystem="squashfs" bootloader="grub2"/>
        <version>1.0.0</version>
        <packagemanager>apt</packagemanager>
        <locale>pt_BR.UTF-8</locale>
        <keytable>br-abnt2</keytable>
    </preferences>

    <!-- REPOSITÓRIOS -->
    <!-- 1. Base Debian Trixie -->
    <repository type="apt-deb" alias="debian-trixie">
        <source path="http://deb.debian.org/debian/"/>
        <distribution name="trixie"/>
        <components name="main contrib non-free-firmware"/>
    </repository>

    <!-- 2. Seu Kernel Noble Local (Pasta no seu PC) -->
    <!-- O KIWI vai ler os .deb desta pasta e instalá-los -->
    <repository type="apt-deb" alias="playos-kernel-local" imageinclude="true">
        <source path="dir:///home/marcel/meus-kernels/noble"/>
    </repository>

    <!-- LISTA DE PACOTES -->
    <packages type="image">
        <!-- O KDE Completo vindo do Debian -->
        <package name="kde-full"/>
        <package name="sddm"/>
        <package name="plasma-nm"/>
        
        <!-- O Kernel vindo da sua pasta local (Coloque o nome exato do seu .deb) -->
        <package name="linux-image-6.8.0-138-generic"/>
        <package name="linux-modules-extra-6.8.0-138-generic"/>
        
        <!-- Base de Sistema -->
        <package name="sudo"/>
        <package name="network-manager"/>
        <package name="firmware-linux"/>
    </packages>
</image>
```

---

## 3. Configuração de Scripts (`config.sh`)

Este script roda no final do build para fazer ajustes finos:

```bash
#!/bin/bash
# Habilitar o SDDM (Gerenciador de Login do KDE)
systemctl enable sddm

# Configurar o grupo sudo para o usuário padrão
# O usuário padrão do KIWI geralmente é 'linux' ou definido no XML
useradd -m -G sudo playos
echo "playos:playos" | chpasswd

exit 0
```

---

## 4. Como Rodar o Build

Certifique-se de que o KIWI NG está instalado no seu host:
```bash
sudo apt install python3-kiwi
```

Execute o processo em dois passos (recomendado para debugar):

1.  **Prepare**: Cria a pasta do sistema base.
    ```bash
    sudo kiwi-ng system prepare --description ./playos-kiwi --target-dir ./rootfs
    ```

2.  **Create**: Gera a ISO final a partir da pasta rootfs.
    ```bash
    sudo kiwi-ng system create --description ./playos-kiwi --root ./rootfs --target-dir ./output
    ```

---

## 5. Dica de Especialista para 2025
Para tornar o PlayOS ainda mais profissional, use o KIWI para gerar uma imagem **OEM**. No `preferences`, mude o tipo de imagem:
`<type image="oem" filesystem="ext4" bootloader="grub2"/>`

Isso gerará um arquivo que, ao ser gravado em um SSD, transformará o computador em uma "Workstation PlayOS" nativa no primeiro boot.
