# Como Criar uma Distribuição Baseada no Debian (2024-2025)

O Debian é a base mais sólida e versátil para novas distribuições. Em 2024/2025, o foco está no **Debian 12 (Bookworm)** e no desenvolvimento do **Debian 13 (Trixie)**.

---

## 1. Escolha a sua Ferramenta Base

No universo Debian, existem dois caminhos oficiais dependendo do seu objetivo:

### A. live-build (Para Sistemas Live/Desktop)
É a ferramenta usada para criar imagens que rodam direto do pendrive e permitem ao usuário testar o sistema.
- **Melhor para**: "Sempre-Live" OS, Distros de Pentest (como Kali), Estações de Trabalho Customizadas.
- **Workflow**: `lb config` -> `lb build`.

### B. simple-cdd (Para Instaladores Customizados)
O `simple-cdd` (Simple Custom Debian Desktop) é um wrapper em volta do `debian-cd`. Ele é otimizado para criar ISOs que **instalam** o sistema de forma automática.
- **Melhor para**: Servidores pré-configurados, Quiosques, Frotas de máquinas de escritório.
- **Diferencial**: Usa arquivos de "preseed" para responder às perguntas do instalador automaticamente.

---

## 2. Passo a Passo com `simple-cdd`

1.  **Instalação**:
    ```bash
    sudo apt install simple-cdd
    ```
2.  **Criação de Perfil**:
    Crie uma pasta e defina quais pacotes você quer:
    ```bash
    mkdir my-debian && cd my-debian
    mkdir profiles
    echo "gnome-core network-manager firefox-esr" > profiles/playos.packages
    ```
3.  **Configuração de Preseed** (Opcional):
    Crie `profiles/playos.preseed` para pular a configuração de teclado e timezone.
4.  **Build**:
    ```bash
    build-simple-cdd --profiles playos --dist trixie
    ```

---

## 3. O Futuro: **mkosi** (A Alternativa Moderna)

Para desenvolvedores que acham as ferramentas acima "datadas", o **`mkosi`** (Make Operating System Image) é a recomendação para 2025.
- **Foco**: Imagens puramente baseadas em `systemd`.
- **Formato**: Gera imagens de disco GPT nativas que suportam "A/B Updates" (atualizações atômicas).
- **Uso**: Excelente para containers de sistema e ambientes de desenvolvimento isolados.

---

## 4. Diferenças Cruciais: Debian vs Ubuntu

Se você vem do Ubuntu, o Debian exige atenção em:
1.  **Firmware**: No Debian 12+, use o componente `non-free-firmware` para Wi-Fi e placas de vídeo.
2.  **Kernel**: O kernel do Debian é mais conservador. Para o PlayOS, usamos a técnica de injetar o kernel do Ubuntu Noble no userspace do Debian Trixie para ter o melhor dos dois mundos (estabilidade do Debian + drivers novos do Ubuntu).
3.  **Sudo**: Por padrão, o Debian não configura o `sudo`. Você deve incluí-lo explicitamente na sua lista de pacotes e adicionar o usuário ao grupo `sudo` via script de hook.

---

## 5. Estratégia PlayOS para Debian
Nossa estratégia atual é o **Hybrid Noble-Trixie**:
- **Userspace**: Debian Trixie (pelo software atualizado).
- **Kernel**: Ubuntu Noble 6.8.x (pela compatibilidade de hardware).
- **Ferramenta**: `live-build` com injeção de pacotes locais.
