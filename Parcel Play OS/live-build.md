# O Caminho de "Baixo Nível": live-build

O **live-build** é o conjunto de scripts oficial do projeto Debian para criar sistemas Live (que rodam em memória RAM) e imagens de instalação. É o motor por trás das imagens oficiais do Debian e do Kali Linux.

---

## 1. Por que usar o live-build no PlayOS?

Para o PlayOS, o live-build é a ferramenta mais poderosa porque permite o **Pipeline Híbrido**:
- **Kernel Específico**: Você pode proibir o download do kernel padrão e injetar manualmente os pacotes `.deb` do Kernel Noble que você compilou.
- **Initramfs Customizado**: Controle total sobre o `live-boot` para garantir que o sistema encontre o SquashFS corretamente.
- **Granularidade**: Você controla cada hook (script) que roda durante a criação do ambiente chroot.

---

## 2. Estrutura de Diretórios Crítica

O segredo do `live-build` não está nos comandos, mas na organização das pastas:

- `auto/`: Contém scripts (`config`, `build`, `clean`) que automatizam o processo.
- `config/`:
    - `package-lists/`: Arquivos `.list.chroot` com os nomes dos pacotes do APT.
    - `packages.chroot/`: **Local onde você coloca os arquivos .deb locais** (ex: seu Kernel Noble).
    - `includes.chroot/`: Espelhamento da raiz do sistema. O que você colocar aqui vai para dentro da ISO (ex: `/etc/skel` para o home do usuário).
    - `hooks/`: Scripts executados dentro do ambiente chroot durante o build.

---

## 3. Fluxo de Trabalho (Exemplo PlayOS)

### Passo 1: Configuração Inicial
```bash
lb config \
  --mode debian \
  --distribution trixie \
  --archive-areas "main contrib non-free-firmware" \
  --binary-images iso-hybrid \
  --initramfs live-boot \
  --linux-packages none  # Impede o download do kernel Debian
```

### Passo 2: Injeção do Kernel Noble
Coloque os arquivos `.deb` do kernel compilado em:
`config/packages.chroot/linux-image-6.8.4-playos.deb`

### Passo 3: Injeção de Configurações
Para que o sistema já inicie com o KDE configurado, coloque os arquivos em:
`config/includes.chroot/etc/skel/.config/kdeglobals`

### Passo 4: Build
```bash
sudo lb build
```

---

## 4. Gerenciamento de Erros Comuns

1. **Permissão Negada no /dev/null**: Geralmente ocorre ao rodar o build em sistemas com restrição de montagem. **Solução**: Rodar dentro de uma VM LXD Noble conforme documentado no `MANUAL_CRIACAO_ISO_VMS.md`.
2. **GPG Error (Repository not signed)**: O Debian Testing (Trixie) é rigoroso. **Solução**: Usar `--apt-secure false` no config ou criar um hook que force o `trusted=yes` no repositório local.
3. **Boot falha (Initramfs)**: Se o sistema não encontrar a mídia, verifique se a linha de boot no GRUB tem `boot=live`.

---

## 5. Veredito para o PlayOS
O `live-build` é o método de escolha para **engenharia de kernel**. Se você está modificando o kernel e quer testar a integração profunda com o sistema operacional, esta é a única ferramenta que te dá o controle necessário.
