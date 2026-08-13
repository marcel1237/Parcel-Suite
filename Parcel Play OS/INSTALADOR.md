# O Instalador do Parcel Play OS: Inteligência e Experiência

Este documento detalha a arquitetura, o design e a estratégia técnica do instalador oficial do **Parcel Play OS**, codinome **"Parcel Setup Engine"**.

## 1. Filosofia: "A Alma do Arch, o Rosto do Calamares"

O nosso instalador busca o equilíbrio perfeito entre dois mundos:
*   **Transparência Técnica (Inspirado no `archinstall`)**: O usuário tem controle total sobre o que está acontecendo. Cada comando de particionamento e instalação de pacotes é logado de forma legível e pode ser automatizado via scripts Python ou arquivos JSON.
*   **Acessibilidade Visual (Construído no `Calamares`)**: Utilizamos o framework Calamares (Qt/QML) para oferecer uma experiência de usuário (UX) moderna, intuitiva e visualmente atraente, adequada tanto para iniciantes quanto para profissionais.

## 2. Análise Competitiva de Referências

Para criar o melhor instalador do mercado, analisamos os gigantes:

| Instalador | Origem | Ponto Forte | Uso no Parcel Play OS |
| :--- | :--- | :--- | :--- |
| **archinstall** | Arch Linux | Minimalismo e Scripting Python | Herança da lógica de automação e transparência de logs. |
| **Calamares** | Independente | Modularidade e Temas (Qt) | Base da nossa interface gráfica e sistema de módulos. |
| **Anaconda** | Fedora/RHEL | Poder de particionamento (RAID/LVM) | Referência para suporte a hardware enterprise. |
| **Subiquity** | Ubuntu | Velocidade de deploy (Curtin) | Referência para otimização do tempo de instalação. |

## 3. Arquitetura do "Parcel Setup Engine"

O instalador é composto por camadas modulares:

### A. Interface Gráfica (Frontend) - Tema Dark Kubuntu
- Baseada em **Qt 6.7+**, **QML** e **Kirigami**.
- **Visual**: Segue a paleta **Breeze Dark** (Fundo: `#232629`, Texto: `#eff0f1`).
- **Branding Parcel**: Slides interativos durante a instalação explicando as tecnologias **Thunder SDK** (NitroCore, OmniLock).
- **Seletor de Experiência**: Uma tela dedicada para escolher entre a **Sessão Basic (Gnome)** ou **Sessão Full (KDE)**, ambas com integração ao tema dark.

### B. Módulos de Inteligência (Custom Modules)
Desenvolvemos módulos exclusivos em Python e C++ integrados ao Calamares:
1.  **`nitro_align`**: Módulo que alinha as partições do disco para maximizar a performance de I/O, preparando o terreno para o **OmniLock**.
2.  **`kernel_selector`**: A interface do Octógono. Permite ao usuário selecionar entre os 8 sabores. Caso o usuário não saiba escolher, o módulo executa o **Nitro-Compatibility-Check** e sugere o sabor **Debian** como padrão seguro.
3.  **`thunder_benchmark`**: Um mini-teste de stress que detecta a CPU do usuário e configura os repositórios APT para baixar binários otimizados para aquela arquitetura (ex: x86-64-v4).
3.  **`universal_compat_stub`**: Pergunta ao usuário se deseja habilitar nativamente o suporte a **Snaps**, **Flatpaks**, **Waydroid (Android)** e **Proton (Windows)**.

### C. Motor de Automação (Backend)
- Suporte a **Instalação Declarativa**: O usuário pode carregar um arquivo `parcel-config.json` em um pendrive e o sistema se instalará sozinho com todas as preferências pré-definidas.

## 4. Diferenciais Exclusivos

*   **Offline First**: O instalador traz a base do **Ubuntu 26** e o **Kernel NitroCore** pré-carregados na ISO, permitindo uma instalação completa sem internet em menos de 5 minutos.
*   **Live RAM Boot**: Durante a instalação, o ambiente Live é carregado inteiramente na RAM via **OmniLock**, tornando o uso do sistema durante o processo de instalação extremamente fluido.
*   **Verificação de Assinatura**: Valida a integridade da ISO e do Kernel NitroCore antes de tocar no disco, garantindo segurança estilo **OpenBSD**.

## 5. Links de Referência para Estudo (Source Code)

*   **Calamares**: [github.com/calamares/calamares](https://github.com/calamares/calamares)
*   **archinstall**: [github.com/archlinux/archinstall](https://github.com/archlinux/archinstall)
*   **Fedora Anaconda**: [github.com/rhinstaller/anaconda](https://github.com/rhinstaller/anaconda)
*   **Ubuntu Subiquity**: [github.com/canonical/subiquity](https://github.com/canonical/subiquity)

---
*Status: Design de Módulos em andamento. Base: Calamares Framework.*
