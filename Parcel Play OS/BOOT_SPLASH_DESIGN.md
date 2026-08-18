# Design de Abertura: Boot Splash Parcel (Plymouth)

Este documento detalha a identidade visual de abertura do **Parcel Play OS**, refletindo a união entre a robustez do Ubuntu e a velocidade do SteamOS.

## 1. Identidade Visual
O Boot Splash (Plymouth) é o primeiro contato do usuário com o sistema.
- **Tema**: **Nitro-Pulse**.
- **Cores**: Fundo `#232629` (Breeze Dark) com animação em Azul Neon (`#3daee9`) e Verde Nitro (`#27ae60`).
- **Animação**: Um logotipo central do "Parcel Suite" que pulsa suavemente em 60 FPS, indicando a atividade do **Kernel NitroCore**.

## 2. Implementação Técnica (Ubuntu 26/27)
Utilizaremos o motor de script do Plymouth para garantir fluidez mesmo em boots ultra-rápidos de NVMe.

### Localização dos Arquivos:
- `/usr/share/plymouth/themes/parcel-pulse/`

### Otimização para Boot Rápido:
Em 2026, com o boot em menos de 2 segundos, a animação do Plymouth pode ser interrompida bruscamente.
- **Solução**: Implementaremos um "Hero Delay" de 1.5 segundos no serviço `plymouth-quit.service` para garantir que o usuário veja a transição suave para a tela de login.

## 3. Integração com o Dark Volt
Se o usuário ativar o **Dark Volt**, o Boot Splash transitará diretamente para a interface EGLFS sem passar pelo console preto (TTY), garantindo uma experiência "Flicker-Free".

---
*Status: Design de animação concluído. Próximo: Criação dos assets PNG.*
