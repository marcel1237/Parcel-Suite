# Build Profissional: Ubuntu 26 Standard via Imagecraft

Este guia descreve como utilizar o **Imagecraft** (a ferramenta moderna da Canonical) para criar uma imagem do **Ubuntu 26.04 (Resolute Raccoon)** seguindo os padrões oficiais, sem customizações ou "invenções" (Pure Ubuntu Experience).

---

## 1. O Conceito "Standard"
Para este build, "Standard" significa:
- **Kernel Oficial**: Uso do `linux-image-generic` da suite alvo.
- **Desktop Oficial**: Metapacote `ubuntu-desktop` (GNOME padrão).
- **Sem Modificações**: Repositórios oficiais (`main`, `restricted`, `universe`, `multiverse`) e configurações padrão do sistema.

---

## 2. Preparação do Ambiente
O Imagecraft utiliza o **Multipass** para criar uma VM isolada e garantir que o build não dependa da configuração do seu host.

```bash
# Instalar ferramentas necessárias
sudo snap install imagecraft --beta --classic
sudo snap install multipass
```

---

## 3. Receita: `imagecraft.yaml`
Crie um diretório chamado `ubuntu-resolute-standard` e salve o conteúdo abaixo em um arquivo chamado `imagecraft.yaml`.

```yaml
name: ubuntu-resolute-standard
base: bare
build-base: ubuntu@24.04 # Ambiente de build estável (Noble)
version: '26.04.1'
summary: Imagem Standard do Ubuntu 26.04 LTS (Resolute Raccoon)
description: |
  Esta imagem segue rigorosamente o padrão oficial da Canonical para o 
  Ubuntu Desktop, utilizando o metapacote ubuntu-desktop e o kernel generic.

platforms:
  amd64:

volumes:
  disk:
    schema: gpt
    bootloader: grub
    items:
      - name: efi
        size: 100M
        role: efi
      - name: rootfs
        size: 10G # Espaço suficiente para o desktop completo

filesystems:
  default:
    - device: (volume/disk/rootfs)
      mount: /
    - device: (volume/disk/efi)
      mount: /boot/efi

parts:
  # 1. Bootstrap do sistema base
  system-root:
    plugin: mmdebstrap
    mmdebstrap-suite: resolute # Suite alvo
    # Nota: Em 2025, se a suite 'resolute' ainda não estiver nos espelhos, 
    # usa-se 'noble' ou o codinome de desenvolvimento atual.

  # 2. Instalação do Desktop e Kernel padrão
  official-desktop:
    after: [system-root]
    plugin: nil
    override-overlay: |
      # Habilitar repositórios padrão
      add-apt-repository -y universe
      add-apt-repository -y restricted
      add-apt-repository -y multiverse
      apt-get update
      # Instalar o desktop completo e o kernel estável
      apt-get install -y ubuntu-desktop linux-image-generic

  # 3. Configuração do usuário inicial (Obrigatório para login gráfico)
  default-user:
    after: [official-desktop]
    plugin: nil
    override-overlay: |
      useradd -m -s /bin/bash -G sudo playos
      echo "playos:playos" | chpasswd
```

---

## 4. Executando o Build

No diretório do projeto, execute:

```bash
# Inicia o processo de construção na VM isolada
imagecraft pack
```

### O que acontece durante o `pack`:
1.  **Pull**: O Multipass baixa a imagem base necessária para o build.
2.  **Build**: O `mmdebstrap` monta o rootfs da suite `resolute`.
3.  **Overlay**: O Imagecraft instala o GNOME (`ubuntu-desktop`) e o kernel.
4.  **Export**: O resultado final é um arquivo `.img` bootável.

---

## 5. Diferenciais de usar Imagecraft em vez de live-build
1.  **Isolamento Automático**: Você não precisa criar VMs manualmente; o Imagecraft gerencia o ciclo de vida da VM de build.
2.  **Facilidade de Kernel**: Ele usa o gerenciador de pacotes oficial para instalar o kernel mais recente da suite, garantindo compatibilidade de segurança e drivers.
3.  **Reprodutibilidade**: Outro desenvolvedor com o mesmo arquivo YAML terá um resultado 100% idêntico.

---

## 6. Veredito para o PlayOS
Esta abordagem é a ideal se você deseja criar um "baseline" estável para comparar com as versões customizadas do PlayOS. Ter uma imagem Ubuntu 26 Standard permite que você teste se um bug ou falha de performance é originário do kernel PlayOS ou se já existe na base oficial da Canonical.
