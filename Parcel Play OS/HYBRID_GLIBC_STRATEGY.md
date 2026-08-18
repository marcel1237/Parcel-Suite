# Estratégia de Isolamento: Glibc e Dependências Híbridas

Para garantir que o **Parcel Play OS** rode o **Pacman (Arch)** e o **APT (Ubuntu)** simultaneamente sem quebrar o sistema (conflitos de biblioteca `glibc`), adotamos a estratégia de **Isolamento por Namespaces de Montagem**.

## 1. O Problema: Conflito de Glibc
A `glibc` (GNU C Library) é o componente mais sensível do Linux. Se você tentar rodar um binário do Arch (agressivo/novo) usando a `glibc` do Ubuntu (estável/LTS), o programa falhará com erros de "version GLIBC_X.XX not found".

## 2. A Solução: Isolamento por Camadas

### Camada A: O Sistema Host (Glibc Estável)
- **Caminho**: `/lib/x86_64-linux-gnu/`
- **Gestão**: APT.
- **Função**: Mantém o Kernel NitroCore e o ambiente desktop (KDE/Gnome).

### Camada B: O Ambiente Agilidade (Glibc Vanguarda)
- **Caminho**: `/var/lib/nitrocore/arch/rootfs/lib/`
- **Gestão**: Pacman.
- **Tecnologia**: **Mount Namespaces** e **Chroot/PivotRoot** (via Distrobox/Podman).
- **Função**: Rodar aplicativos do AUR.

## 3. Como funciona a união (Seamless Handoff)

Quando o usuário executa um app do Arch dentro do OS:
1.  O NitroCore cria um **Namespace de Montagem** privado para aquele app.
2.  Dentro desse namespace, a pasta `/lib` aponta para a biblioteca nova do Arch.
3.  As pastas `/home`, `/tmp` e `/dev` permanecem as mesmas do sistema original.
4.  O app enxerga as bibliotecas de que precisa (vanguarda), mas salva seus arquivos no seu HD normalmente.

## 4. Integração DNF/RPM (Fedora e openSUSE)
Seguindo a mesma lógica, o suporte para **DNF (Fedora)** e **openSUSE** será feito através de **Zonas de Contêiner**:
- **Zona Fedora**: Habilita o acesso ao **COPR**.
- **Zona openSUSE**: Habilita o acesso ao **OBS (Open Build Service)**.

Ambas as zonas serão isoladas na camada de biblioteca, mas integradas na camada de interface (X11/Wayland).

---
*Veredito: Você pode ter o GCC 16 do Arch e o Kernel 7.1.8 rodando sobre o Ubuntu 26 sem nenhum conflito.*
