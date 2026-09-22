# Como Criar uma Distribuição Baseada no Arch Linux (2024-2025)

O Arch Linux é conhecido por sua simplicidade técnica e pelo modelo *Rolling Release*. Para criar uma distribuição customizada baseada no Arch, a ferramenta padrão e oficial é o **archiso**.
-
---

## 1. O Motor de Build: archiso

O **archiso** é uma coleção de scripts que automatizam a criação de imagens ISO bootáveis do Arch Linux. Ele utiliza o `pacman` para instalar pacotes em um diretório temporário e depois o comprime em um SquashFS.

### Perfis de Build (Templates):
- **releng**: O perfil usado para criar a ISO oficial do Arch Linux. Inclui ferramentas de rede e recuperação. É o melhor ponto de partida para distros completas.
- **baseline**: Um perfil minimalista que instala apenas o básico para o boot. Ideal para sistemas embarcados ou quiosques.

---

## 2. Estrutura do Projeto Archiso

Ao copiar o perfil `releng` (`cp -r /usr/share/archiso/configs/releng/ .`), você encontrará esta estrutura:

- **`profiledef.sh`**: Arquivo mestre de configuração. Define o nome da ISO, o rótulo do disco, os bootloaders (GRUB/systemd-boot) e as permissões de arquivos.
- **`packages.x86_64`**: Lista de pacotes que serão instalados via `pacman`.
- **`airootfs/`**: O diretório raiz (`/`) do sistema final. Tudo o que você colocar aqui aparecerá na ISO.
    - `etc/skel/`: Coloque aqui as configurações padrão para o usuário live.
- **`pacman.conf`**: Configuração do gerenciador de pacotes. Permite adicionar repositórios customizados.

---

## 3. Fluxo de Trabalho (Workflow)

### Passo 1: Instalação
```bash
sudo pacman -Syu archiso
```

### Passo 2: Customização de Pacotes
Edite o arquivo `packages.x86_64` para incluir sua interface (ex: KDE Plasma) e ferramentas:
```text
plasma-desktop
sddm
konsole
dolphin
networkmanager
firefox
```

### Passo 3: Habilitar Serviços
Diferente do Debian, no Archiso você deve habilitar os serviços manualmente criando links simbólicos dentro de `airootfs/`:
```bash
# Exemplo para habilitar o NetworkManager
mkdir -p airootfs/etc/systemd/system/multi-user.target.wants
ln -s /usr/lib/systemd/system/NetworkManager.service airootfs/etc/systemd/system/multi-user.target.wants/NetworkManager.service
```

### Passo 4: Build da ISO
```bash
mkarchiso -v -w /caminho/para/work_dir -o /caminho/para/out_dir ./meu_perfil
```

---

## 4. Arch Linux vs. Ubuntu/Debian no PlayOS

| Recurso | **Archiso** | **live-build** (Debian) | **Imagecraft** (Ubuntu) |
| :--- | :--- | :--- | :--- |
| **Kernel** | Sempre o mais recente (Mainline) | Conservador (LTS) | HWE ou Mainline PPA |
| **Instalador** | `archinstall` ou `Calamares` | `Debian Installer` | `Subiquity` |
| **Configuração** | Manual (DIY) | Scripts de Hook | Declarativa (YAML) |
| **Atualização** | Rolling (Contínua) | Point Release (Estática) | Point Release (Estática) |

---

## 5. Estratégia PlayOS para Arch
Se o PlayOS decidir usar o Arch como base:
- **Vantagem**: O Kernel Vanilla 7.x e drivers Mesa/Vulkan mais novos chegam primeiro no Arch.
- **Desafio**: Exige mais scripts manuais para garantir que o sistema não "quebre" em atualizações totais do `pacman -Syu`.
- **Kernel Customizado**: No Arch, basta criar um pacote `.pkg.tar.zst` do seu Kernel Noble/7.3 e adicioná-lo a um repositório local definido no `pacman.conf` do archiso.

---

## 6. Veredito 2025
O **archiso** é a ferramenta ideal se você quer que o PlayOS seja uma distro de **altíssima performance**, voltada para usuários que querem o hardware sempre no limite tecnológico.

**Dica:** Use o instalador **Calamares** (disponível no AUR) para dar à sua distro Arch uma cara amigável de "clicar e instalar".
