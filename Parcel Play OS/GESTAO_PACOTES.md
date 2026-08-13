# Gestão de Pacotes: Parcel Software Center

O **Parcel Software Center** é a interface unificada de gerenciamento de software do Parcel Play OS, projetada para oferecer compatibilidade universal sem sacrificar a performance.

## 1. Motores de Pacotes Integrados
O sistema utiliza uma arquitetura híbrida que permite a coexistência de múltiplos formatos:
- **APT (Advanced Package Tool)**: Baseado no **Ubuntu 26**, fornecendo a base estável e os drivers do sistema.
- **Snap**: Integrado nativamente para aplicativos que exigem isolamento total e atualizações automáticas (ex: navegadores, ferramentas de dev).
- **Flatpak**: Cidadão de primeira classe, ideal para aplicativos de interface gráfica e jogos.
- **AppImage**: Suporte nativo via `appimaged` para execução direta.

## 2. Conceito: Parcel Unified Search
A busca na loja é inteligente e prioriza:
1.  **Performance**: Se um app existe em Snap e APT, a loja sugere a versão que melhor se integra às otimizações do **Thunder SDK**.
2.  **Segurança**: Apps em sandboxes (Snap/Flatpak) são sinalizados com selos de segurança.
3.  **Compatibilidade**: Apps Windows (via Bottles/Proton) são exibidos nos resultados de busca como se fossem nativos.

## 3. Integração Thunder SDK
- **Pre-Optimization**: Ao instalar um pacote via APT, o sistema verifica se há necessidade de habilitar flags específicas no **NitroCore** ou **OmniLock**.
- **Shader Caching**: Integração com drivers de GPU para pré-compilar shaders de apps instalados via Snap/Flatpak durante o tempo ocioso.

## 4. Manutenção "No-Legacy" Dinâmica
Embora o sistema mantenha compatibilidade (não removendo suporte a 32 bits, por exemplo), ele utiliza **LXC (Linux Containers)** ou **Sandboxes** para rodar componentes antigos, garantindo que o kernel principal e o desktop Wayland permaneçam limpos e rápidos.

---
*Status: Em fase de design de interface (Qt 6.7+ / Kirigami).*
