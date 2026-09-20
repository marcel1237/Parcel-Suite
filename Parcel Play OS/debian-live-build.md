# Criação de Sistemas Live Customizados: live-build (Debian)

O **live-build** é o motor oficial do projeto Debian para criar sistemas que rodam diretamente de mídias removíveis (USB/DVD) sem necessidade de instalação prévia. É a base do Kali Linux e do Tails.

---

## 1. Estrutura Avançada de Customização

Para builds profissionais em 2024 e 2025, o live-build utiliza uma estrutura de diretórios específica sob a pasta `config/`:

### A. Includes do Sistema (`includes.chroot/`)
O que você colocar aqui será copiado literalmente para a raiz (`/`) do sistema final.
- **Exemplo**: Colocar um papel de parede em `config/includes.chroot/usr/share/backgrounds/playos.png`.
- **Dica 2025**: Use `config/includes.chroot/etc/skel/` para configurar o ambiente de desktop (KDE/GNOME) que todo novo usuário receberá.

### B. Hooks de Build (`hooks/live/`)
Scripts que rodam *durante* o processo de criação, permitindo lógica dinâmica.
- **`.chroot`**: Roda dentro do sistema operacional sendo construído. Útil para habilitar serviços via `systemctl` ou remover pacotes desnecessários.
- **`.binary`**: Roda após a imagem ser gerada. Útil para modificar o menu do GRUB ou adicionar arquivos à raiz da ISO.

---

## 2. Fluxo de Trabalho Moderno

### Passo 1: Inicialização Limpa
```bash
mkdir playos-live && cd playos-live
lb config \
    --mode debian \
    --distribution trixie \
    --archive-areas "main contrib non-free-firmware" \
    --binary-images iso-hybrid
```

### Passo 2: Gerenciamento de Pacotes
Crie listas em `config/package-lists/`. 
- **Backports**: Para hardware de 2025, você pode puxar kernels mais novos do repositório de backports adicionando uma lista em `config/archives/`.

### Passo 3: Firmware e Hardware
Desde o Debian 12, o tratamento de firmware mudou. Garanta estas flags:
```bash
lb config \
    --firmware-chroot true \
    --firmware-binary true
```

### Passo 4: Build e Limpeza
Sempre limpe artefatos anteriores antes de um novo build:
```bash
sudo lb clean --purge
sudo lb build
```

---

## 3. Regras de Ouro para 2024-2025

1.  **UEFI e Secure Boot**: Certifique-se de incluir `grub-efi-amd64-signed` e `shim-signed` nas suas listas de pacotes para que a ISO dê boot em computadores modernos.
2.  **Persistência**: Se você quer que o usuário possa salvar arquivos entre reboots no próprio pendrive, ative a flag `--persistence` durante o config.
3.  **Caching**: Se você faz muitos builds, instale o `apt-cacher-ng` no host e configure o proxy no live-build para acelerar o download de pacotes em 90%.

---

## 4. Veredito para o PlayOS
O **live-build** é a ferramenta definitiva para o PlayOS porque permite criar o ambiente "híbrido" (Userspace Debian + Kernel Noble) com controle total sobre o initramfs e o processo de boot, garantindo a performance "bare-metal" que o projeto busca.
