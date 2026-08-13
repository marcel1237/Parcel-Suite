# Matriz de Instalação: Ambientes e Metapackages

Este documento define quais componentes de software são instalados para cada modo de operação do **Parcel Play OS**, garantindo a conformidade com as definições de "Sessão Basic" e "Sessão Full".

## 1. Sessão Basic (Gnome Normal)

A Sessão Basic é focada em usuários que buscam a experiência padrão do Ubuntu com a estabilidade do Gnome.

| Componente | Pacote (Ubuntu 26) | Descrição |
| :--- | :--- | :--- |
| **Ambiente Desktop** | `ubuntu-desktop` | Interface Gnome com extensões Ubuntu. |
| **Gerenciador de Login** | `gdm3` | Gnome Display Manager. |
| **Navegador Padrão** | `thunder-browser` | Nosso navegador nativo acelerado. |
| **Suíte de Escritório** | `libreoffice-gnome` | Integrado ao GTK. |

## 2. Sessão Full (KDE Full)

A Sessão Full é a vitrine tecnológica do Parcel Play OS, oferecendo o máximo de ferramentas e integração com o NitroCore.

| Componente | Pacote (Ubuntu 26) | Descrição |
| :--- | :--- | :--- |
| **Ambiente Desktop** | `kde-full` | A suíte completa do KDE Plasma 6+. |
| **Gerenciador de Login** | `sddm` | Simple Desktop Display Manager (Tema Dark). |
| **Multimídia** | `kdenlive`, `elisa` | Editores e players profissionais. |
| **Gráficos** | `krita`, `gwenview` | Ferramentas de criação e visualização. |
| **Educação/Ciência** | `marble`, `kalzium` | Suíte educativa completa. |

## 3. Orquestração Técnica

O módulo `universal_compat` do instalador executa a lógica baseada na escolha do usuário:

```python
if selected_session == "full":
    apt_install("kde-full", "sddm")
else:
    apt_install("ubuntu-desktop", "gdm3")
```

### Notas sobre o Kernel:
Independente da sessão escolhida, o sistema instalará os drivers proprietários (Nvidia/AMD) de forma automática se o usuário selecionar um sabor de kernel de **Performance** (Arch/Fedora).

---
*Status: Metapackages definidos para Ubuntu 26.*
