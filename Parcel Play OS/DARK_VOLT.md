# Tecnologia Dark Volt: O Atalho de Hardware

O **Dark Volt** é a tecnologia de boot instantâneo do Parcel Play OS, projetada para disponibilizar a interface de usuário em menos de 2 segundos após a inicialização do Kernel.

## 1. Funcionamento Técnico

A maioria das distribuições Linux segue uma sequência serial e lenta:
`Kernel -> Init (Systemd) -> Network/LocalFS -> Display Manager (SDDM/GDM) -> Desktop Session (KDE/Gnome)`

O Dark Volt cria um **atalho direto ao hardware**:
1.  **Direct Rendering Manager (DRM)**: O serviço Dark Volt assume o controle da GPU assim que o driver (amdgpu, i915, nouveau) é carregado.
2.  **Qt EGLFS**: Em vez de carregar um servidor gráfico complexo (X11 ou Wayland), o Dark Volt utiliza o backend `eglfs`, desenhando a interface diretamente no buffer de vídeo.
3.  **Handoff Progressivo**: O Dark Volt apresenta a **Tela de Login** ou o **Thunder Browser** instantaneamente. Enquanto o usuário utiliza a interface imediata, o sistema carrega os serviços pesados (rede, montagem de discos, sessão KDE/Gnome) em background.

## 2. A Tela de Login Dark Volt

A tela de login do Dark Volt é uma aplicação **Qt/QML ultra-leve**:
- **Design**: Segue o padrão **Breeze Dark**.
- **Segurança**: Utiliza **PAM (Pluggable Authentication Modules)** de forma direta, garantindo que a segurança do Linux não seja comprometida pela velocidade.
- **Transição**: Assim que autenticado, o Dark Volt encerra seu processo e "entrega" o console para o compositor Wayland da sessão escolhida (Basic ou Full).

## 3. Configuração do Sistema

Para que o Dark Volt funcione, o sistema alvo deve conter:
- O serviço `thunder-dark-volt.service` habilitado.
- O arquivo de ambiente em `/etc/thunder/dark-volt-env`.
- Configuração KMS em `/etc/thunder/kms-config.json`.

---
*Status: Motor de Boot Acelerado Ativo.*
