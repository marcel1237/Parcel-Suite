# Criação de ISOs de Instalação: simple-cdd

O **simple-cdd** (Simple Custom Debian Desktop) é a ferramenta oficial recomendada para criar imagens de instalação personalizadas do Debian. Ao contrário do live-build, que foca em sistemas que rodam na RAM, o simple-cdd foca em criar um disco que **instala** o Debian 12 (Bookworm) ou 13 (Trixie) no HD/SSD do usuário com pacotes e configurações pré-definidos.

---

## 1. O Conceito de Perfis (Profiles)

A força do simple-cdd reside nos **perfis**. Um perfil é um conjunto de arquivos que define o que será instalado e como o instalador deve se comportar.

- **`.packages`**: Lista de pacotes para instalar.
- **`.preseed`**: Respostas automáticas para o instalador (idioma, teclado, particionamento).
- **`.postinst`**: Script que roda logo após a instalação, antes do primeiro boot.

---

## 2. Preparação do Ambiente

Instale as ferramentas necessárias no seu host ou VM Debian/Ubuntu:
```bash
sudo apt update
sudo apt install simple-cdd qemu-system-x86
```

---

## 3. Fluxo de Trabalho (Workflow)

### Passo 1: Estrutura do Projeto
Crie uma pasta para o seu projeto e a subpasta de perfis:
```bash
mkdir meu-instalador-debian && cd meu-instalador-debian
mkdir profiles
```

### Passo 2: Configuração Global (`simple-cdd.conf`)
Crie o arquivo principal de configuração na raiz da pasta:
```bash
# simple-cdd.conf
dist="trixie"  # Versão alvo (Debian 13)
# Essencial para hardware moderno em 2024/2025:
mirror_components="main contrib non-free non-free-firmware"
profiles="playos-server"
auto_profiles="playos-server"
```

### Passo 3: Definir o Perfil (`profiles/playos-server.*`)
1.  **Lista de Pacotes (`profiles/playos-server.packages`)**:
    ```text
    ssh
    vim
    network-manager
    firmware-linux
    sudo
    ```
2.  **Automação (`profiles/playos-server.preseed`)**:
    Neste arquivo, você coloca comandos para o instalador não fazer perguntas, como:
    ```text
    d-i debian-installer/locale string pt_BR
    d-i keyboard-configuration/xkb-keymap select br
    d-i partman-auto/method string regular
    d-i partman-auto/choose_recipe select atomic
    ```

### Passo 4: Construir a ISO
Execute o comando de build apontando para o seu arquivo de configuração:
```bash
build-simple-cdd --conf simple-cdd.conf
```

---

## 4. Diferenciais para 2024-2025

1.  **non-free-firmware**: Desde o Debian 12, o firmware proprietário foi movido para uma seção separada. É obrigatório incluí-lo no `mirror_components` para que Wi-Fi e GPUs funcionem no sistema instalado.
2.  **Teste Rápido**: O simple-cdd possui integração nativa com o QEMU. Você pode testar se a sua ISO de instalação funciona rodando:
    ```bash
    build-simple-cdd --qemu --profiles playos-server
    ```

---

## 5. Veredito para o PlayOS
Use o **simple-cdd** se o seu objetivo for criar uma ISO que o usuário insere no computador e, em poucos minutos, tem o PlayOS instalado no disco rígido exatamente como você planejou, sem que ele precise configurar nada manualmente durante a instalação.
