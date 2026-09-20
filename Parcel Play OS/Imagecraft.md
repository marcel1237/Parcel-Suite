# O Caminho Profissional e Moderno: Imagecraft

O **Imagecraft** é a ferramenta de próxima geração da Canonical para a criação de imagens de disco bootáveis e pré-instaladas. Ele segue a mesma filosofia declarativa do Snapcraft e Rockcraft, utilizando um arquivo YAML para definir toda a estrutura da distribuição.

---

## 1. Por que usar o Imagecraft em 2024-2025?

Ao contrário dos métodos antigos de "remasterização" (onde você abre uma ISO e a modifica), o Imagecraft constrói a imagem **do zero** de forma reprodutível.
- **Declarativo**: Tudo está no `imagecraft.yaml`. Se você perder a ISO, basta rodar o comando novamente para ter uma idêntica.
- **Modular**: Permite separar a construção em "parts" (partes), como kernel, pacotes extras e scripts de customização.
- **Suporte Nativo**: É a ferramenta oficial para criar imagens Ubuntu para IoT, Nuvem e Desktop moderno.

---

## 2. Instalação e Preparação

O Imagecraft roda dentro de instâncias isoladas (usando Multipass ou LXD) para não sujar o seu sistema host.

```bash
# Instalar o Imagecraft
sudo snap install imagecraft --beta --classic

# Instalar o Multipass (provedor padrão de instâncias)
sudo snap install multipass
```

---

## 3. Fluxo de Trabalho (Workflow)

### Passo 1: Inicialização
Crie uma pasta para o seu projeto e inicialize o arquivo de configuração:
```bash
mkdir minha-distro-moderna && cd minha-distro-moderna
imagecraft init
```

### Passo 2: Configuração (`imagecraft.yaml`)
Edite o arquivo gerado. Um exemplo para uma distro baseada no **Ubuntu 24.04 (Noble)**:

```yaml
name: playos-modern
base: bare
build-base: ubuntu@24.04
version: '1.0'
summary: PlayOS versão moderna baseada em Imagecraft.

platforms:
  amd64:

parts:
  # Parte 1: O sistema base usando mmdebstrap
  ubuntu-rootfs:
    plugin: mmdebstrap
    mmdebstrap-release: noble
    mmdebstrap-packages:
      - linux-image-generic
      - systemd-sysv
      - grub-pc
      - xfce4  # Sua interface escolhida
      - network-manager

  # Parte 2: Seus arquivos customizados (Wallpapers, Configurações)
  custom-assets:
    plugin: dump
    source: ./assets
    organize:
      branding/wallpaper.jpg: /usr/share/backgrounds/playos.jpg

# Definição do disco e partições
volumes:
  playos-disk:
    schema: gpt
    bootloader: grub-pc
    structure:
      - name: root
        type: partition
        size: 4G
        filesystem: ext4
        content:
          - source: ubuntu-rootfs
          - source: custom-assets
```

### Passo 3: Construção
Para gerar a imagem final (geralmente um arquivo `.img` que pode ser convertido em `.iso` ou gravado direto em pendrive):
```bash
imagecraft build
```

---

## 4. Comandos Principais

- `imagecraft init`: Cria o template inicial.
- `imagecraft build`: Executa todo o ciclo (puxa pacotes, monta chroot, aplica scripts e empacota).
- `imagecraft clean`: Remove os arquivos temporários se algo der errado.
- `imagecraft expand-extensions`: Mostra o YAML completo após aplicar heranças de modelos oficiais.

---

## 5. Veredito para o PlayOS
O Imagecraft é ideal para a fase de **produção** do PlayOS. Ele garante que a imagem que o usuário baixa seja exatamente a mesma que você testou, eliminando o fator "na minha máquina funciona".
