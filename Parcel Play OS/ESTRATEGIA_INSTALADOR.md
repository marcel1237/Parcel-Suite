# Estratégia do Instalador: Parcel Setup Engine

Este documento detalha a escolha tecnológica e a lógica de orquestração do instalador do **Parcel Play OS**.

## 1. Fusão de Tecnologias

Para entregar o instalador mais potente e amigável do mercado, unificamos duas tecnologias líderes:

| Camada | Tecnologia | Função |
| :--- | :--- | :--- |
| **Frontend (Interface)** | **Calamares (Qt6/Kirigami)** | Fornece a experiência visual "Dark Kubuntu", seletor de kernels e branding interativo. |
| **Backend (Motor)** | **Subiquity / Curtin** | Motor silencioso que realiza a cópia de arquivos e particionamento em alta velocidade (padrão Ubuntu). |
| **Inteligência** | **Parcel Python Modules** | Scripts customizados que aplicam as otimizações do Thunder SDK. |

## 2. O Seletor de Kernels (Decágono Selector)

O diferencial do Parcel Play OS é permitir que o usuário escolha o "cérebro" do seu sistema no momento da instalação entre 10 sabores distintos.

### Categorias de Sabores:
1.  **Gamer/Desktop**: Arch, Fedora, openSUSE.
2.  **Servidor/Enterprise**: CentOS, Oracle, Debian, FreeBSD.
3.  **Segurança/Portabilidade**: OpenBSD, NetBSD, Gentoo.

### Lógica de Decisão:
- **Escolha Manual**: Prioridade total do usuário.
- **Fallback Inteligente**: Se o usuário optar pelo modo automático, o sistema selecionará o sabor **Debian**, garantindo a maior compatibilidade de drivers do mercado.

## 3. Fluxo de Instalação
1.  **Boas-vindas**: Tema Breeze Dark com slides do Thunder SDK.
2.  **Seletor de Kernel**: Exibição dos 10 sabores do Decágono.
3.  **Particionamento Nitro**: Alinhamento de setores para o OmniLock e HugePages.
4.  **Execução**: Deploy de alta velocidade via motor Subiquity.

---
*Status: Arquitetura Decágono Consolidada.*
