# Design de Interface: Nitro-Control Center

O **Nitro-Control** é a nossa versão do **YaST (openSUSE)**, uma central de comando unificada baseada em **KDE Plasma 6 / Kirigami** que permite gerenciar todas as potências do **Decágono de Referência**.

## 1. Módulos do Painel de Controle

A interface será dividida em abas de alto impacto visual:

| Aba | Função | Tecnologia Base |
| :--- | :--- | :--- |
| **Performance** | Ajustar o "Nitro-Boost" e perfis de energia. | SteamOS / Arch |
| **Núcleos** | Alternar entre os 10 sabores do NitroCore. | O Decágono |
| **Agilidade** | Ligar/Desligar contêineres Arch, Fedora e openSUSE. | Distrobox / Podman |
| **Segurança** | Gerenciar o isolamento das **Nitro-Jails**. | OpenBSD / Sony |
| **Rollback** | Viajar no tempo através de Snapshots BTRFS. | openSUSE (Snapper) |

## 2. A Experiência "Console Mode"
O Nitro-Control terá um modo "Big Picture", permitindo que usuários de joystick gerenciem as otimizações do OS de forma 100% visual, sem tocar no terminal.

## 3. Integração Thunder SDK
- O painel mostrará em tempo real a economia de ciclos de CPU gerada pelo **UDMABUF** e a velocidade de rede do **Nitro-Net**.

---
*Status: Design de Fluxo concluído. Próximo: Implementação do Protótipo QML.*
