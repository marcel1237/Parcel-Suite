# Estratégia do instalador Parcel Play OS

## Arquitetura aprovada para o MVP

| Camada | Tecnologia | Função |
| :--- | :--- | :--- |
| Interface e backend | Ubuntu Desktop Installer + Subiquity | Coleta das opções, particionamento e implantação do Resolute |
| Payload | Conteúdo oficial da Live ISO remasterizada | GNOME, KDE Full, kernel e firmware oficiais |
| Login | GDM | Seleção entre GNOME e Plasma |
| Automação futura | Autoinstall | Instalações reproduzíveis em máquinas virtuais |

Calamares não será combinado com Subiquity no mesmo fluxo. Uma futura prova de conceito com Calamares deverá ser uma variante independente da ISO e terá que fornecer configuração completa de payload, particionamento e bootloader.

Anaconda e archinstall não serão utilizados no MVP: o primeiro é alinhado ao ecossistema RPM/DNF e o segundo instala Arch Linux.

## Fluxo mínimo

1. Inicializar a ISO Resolute.
2. Escolher experimentar ou instalar.
3. Informar idioma e teclado.
4. Escolher disco e particionamento.
5. Criar usuário, senha e fuso horário.
6. Implantar o payload offline da ISO.
7. Instalar o bootloader.
8. Reiniciar no sistema instalado.
9. Selecionar GNOME ou Plasma pelo GDM.

## Funcionalidades adiadas

- seletor Decágono/NitroCore;
- benchmark de hardware;
- Waydroid, Wine e Proton durante a instalação;
- escolha de instalar apenas GNOME ou apenas KDE;
- Dark Volt;
- backend híbrido Calamares/Subiquity.

Essas funcionalidades somente voltarão ao escopo depois que a instalação mínima offline for reproduzível e testada em máquina virtual.

Detalhes e comparação técnica: `INSTALADOR.md`.
