# Nitro-Container Engine (Nitro-APX)

O **Nitro-Container Engine** (codinome **Nitro-APX**) é o coração da nossa estratégia multiverso. Ele é inspirado no `apx` do Vanilla OS, mas otimizado para a performance do **NitroCore**.

## 1. Arquitetura "Mestre-Escravo"
O Nitro-APX isola os ecossistemas de software em "Zonas" independentes, compartilhando apenas o que é necessário.

### Camada de Orquestração:
- **Host (Mestre)**: Ubuntu 26 (Imutável).
- **Sub-sistemas (Zonas)**:
    - **Zone Arch**: Onde mora o Pacman e o AUR.
    - **Zone Fedora**: Onde mora o DNF e o COPR.
    - **Zone openSUSE**: Onde mora o Zypper e o OBS.

## 2. Unificação de Comandos (`nitro-pkg`)
Criamos um wrapper unificado para que o usuário não precise decorar os comandos de cada distro:

| Ação | Comando Original | Comando Nitro-APX |
| :--- | :--- | :--- |
| Instalar do AUR | `yay -S app` | `nitro-pkg install --aur app` |
| Instalar do COPR | `dnf copr enable ...` | `nitro-pkg install --fedora app` |
| Instalar do Host | `apt install app` | `nitro-pkg install --host app` |

## 3. Segurança e Exportação
Assim como no Orbis OS da Sony, cada zona é uma **Nitro-Jail**. 
- Aplicativos instalados em zonas são "exportados" automaticamente para o menu do KDE.
- O Nitro-APX gerencia as permissões de acesso ao seu HD e GPU através de políticas **Polkit**.

---
*Status: Estrutura de Zonas definida. Próximo: Codificação do wrapper `nitro-pkg`.*
