# Estratégia de Compatibilidade Universal

O objetivo do **Parcel Play OS** é ser o sistema operacional mais compatível do mercado, unificando os ecossistemas Windows, Android e Linux em uma única experiência de alta performance.

## 1. As 4 Camadas de Compatibilidade

### A. Camada Windows (Proton / Wine-GE)
- **Foco**: Jogos AAA e Aplicativos de Produtividade.
- **Implementação**: Integração nativa do **Steam/Proton** com o kernel NitroCore.
- **Otimização**: Suporte a **Fsync/Esync** para reduzir latência de CPU em jogos.

### B. Camada Android (Waydroid Native)
- **Foco**: Aplicativos móveis e redes sociais.
- **Implementação**: Uso de **LXC (Linux Containers)** compartilhando o núcleo NitroCore.
- **Vantagem**: Performance nativa, sem emulação, com acesso direto à GPU.

### C. Camada Multiverso (Distrobox / Containers)
- **Foco**: Softwares exclusivos de outras distros (Arch, Fedora, openSUSE).
- **Implementação**: Interface que cria ambientes virtuais de outras distribuições de forma transparente.
- **Uso**: Permite rodar o **AUR (Arch)** ou pacotes **RPM** dentro da nossa base APT.

### D. Camada Universal (Snap, Flatpak, AppImage)
- **Foco**: Modernidade e segurança.
- **Implementação**: Suporte "out-of-the-box" para todos os formatos de sandbox.

## 2. Requisitos de Kernel (NitroCore Configuration)

Para sustentar essa compatibilidade, o kernel deve ter:
- `CONFIG_FUTEX_WAIT_MULTIPLE=y` (Para jogos Windows).
- `CONFIG_ANDROID_BINDER_IPC=y` e `CONFIG_ANDROID_BINDERFS=y` (Para Waydroid).
- `CONFIG_USER_NS=y` (Para containers sem privilégios de root).

## 3. Experiência de Usuário: Parcel Software Center
A loja de aplicativos unifica todos esses motores. Ao buscar por "Instagram", o usuário verá a versão Android (Waydroid). Ao buscar por "Cyberpunk 2077", verá a versão Windows (Proton), tudo de forma transparente.

## 4. Matriz de Software Suportado (Metas)

| Categoria | Suporte no Parcel Play OS | Ferramenta Base |
| :--- | :--- | :--- |
| **Jogos Windows** | Platina (99% de compatibilidade) | Proton-GE / DXVK |
| **Apps Adobe** | Gold (Via camadas de tradução) | Wine-Staging / Winetricks |
| **Apps Android** | Nativo (Com aceleração GPU) | Waydroid / Mesa |
| **Apps Arch (AUR)** | Total (Via container nativo) | Distrobox / Podman |
| **Jogos Linux** | Nativo | Steam / Heroic Launcher |
| **Softwares Web** | Ultra-Acelerado | Thunder Browser (Qt 6.7) |
| **Snaps/Flatpaks** | Integrado | Snapd / Flatpak |

## 5. Filosofia de Design: "The Invisible Layer"
O usuário não precisa saber se o app é .deb, .flatpak ou um .exe do Windows. O **Parcel Play OS** gerencia a compatibilidade nos bastidores através do **NitroCore**, garantindo que o software rode com a menor latência possível.

---
*Filosofia: Se o software existe, ele deve rodar no Parcel Play OS.*
