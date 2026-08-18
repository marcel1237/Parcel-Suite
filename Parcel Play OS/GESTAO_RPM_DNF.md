# Integração Universal: Suporte a DNF, RPM e openSUSE

Embora o foco do **Parcel Play OS** seja a união **APT + Pacman**, o sistema foi desenhado para ser agnóstico. Documentamos aqui como incluiremos o suporte ao ecossistema da **Red Hat (Fedora)** e **openSUSE**.

## 1. Suporte a DNF e Fedora (Zonas COPR)

O suporte ao **DNF** não será feito por instalação direta no host (para evitar corrupção do banco de dados do APT). Utilizaremos a tecnologia de **Zonas de Contêiner Nitro**:

- **Nitro-Fedora Zone**: Um contêiner leve que contém o gestor **DNF**.
- **Função**: Permite habilitar repositórios **COPR** e instalar ferramentas exclusivas do ecossistema Fedora.
- **Integração**: Assim como no Arch, os binários instalados via DNF são exportados como links simbólicos para o sistema principal.

## 2. Suporte a openSUSE e OBS

A integração com o **openSUSE** foca na utilização do **Open Build Service (OBS)**:

- **Repositórios OBS**: O Parcel Play OS terá chaves GPG pré-configuradas para aceitar repositórios do OBS formatados para Debian/Ubuntu.
- **Vantagem**: Acesso a softwares compilados especificamente para a nossa base APT, mas mantidos pela infraestrutura de ponta do openSUSE.

## 3. Gestão de Arquivos .RPM

Para o usuário que possui apenas o arquivo `.rpm` isolado:
- **Nitro-Convert**: Um utilitário de menu de contexto (clique direito) que usa o `alien` em background para converter o RPM em um pacote compatível com o NitroCore, aplicando as CFLAGS de performance automaticamente.

## 4. Matriz de Gestão Expandida

| Sistema | Gestor | Tecnologia de União | Vantagem Principal |
| :--- | :--- | :--- | :--- |
| **Ubuntu 26** | APT | Host Imutável | Estabilidade e Drivers. |
| **Arch Linux** | Pacman | Distrobox / Namespace | **AUR** e Vanguarda. |
| **Fedora** | DNF | Nitro-Fedora Zone | Repositórios **COPR**. |
| **openSUSE** | Zypper | OBS Integration | Softwares de Terceiros Estáveis. |

---
*Filosofia: O Parcel Play OS é o único sistema onde um app do AUR e um pacote do COPR convivem em perfeita harmonia.*
