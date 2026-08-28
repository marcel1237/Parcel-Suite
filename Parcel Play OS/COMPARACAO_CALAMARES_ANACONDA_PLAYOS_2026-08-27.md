# Calamares versus Anaconda para o PlayOS

## Metadados

- **ID:** `KB-PLAYOS-INSTALLER-COMPARE-001`
- **Tipo:** `comparative-analysis`
- **Estado:** `decision` e `recommendation`
- **Confiança:** alta para arquitetura; média para integração até teste final
- **Verificado em:** 2026-08-27
- **Escopo:** Ubuntu Noble, Live XFCE, payload SquashFS e pacotes DEB/APT

## Resumo executivo

Para a edição atual do PlayOS, **Calamares é a melhor escolha**. Anaconda é
mais completo para provisionamento Fedora/RHEL, storage empresarial e
automação Kickstart, mas adotá-lo no Noble exigiria adaptar seu runtime,
payload, DNF/RPM, árvore instalável, boot e integração da distribuição.

Calamares já existe no Noble como `3.3.5-0ubuntu4`, carregou o perfil PlayOS e
possui `unpackfs` adequado ao `filesystem.squashfs` da Live. Isso não prova uma
instalação completa, mas reduz substancialmente a distância até o primeiro MVP.

## Comparação

| Critério | Calamares | Anaconda | Melhor para o PlayOS atual |
|---|---|---|---|
| Base de distribuição | independente, configurada pelo derivado | Fedora/RHEL e derivados | Calamares |
| Noble/DEB/APT | pacote disponível e módulos genéricos | adaptação fora do fluxo principal | Calamares |
| Payload Live SquashFS | `unpackfs` configurável | possui Live OS payload, mas o ecossistema normal é RPM/DNF | Calamares |
| Interface na Live XFCE | Qt, funciona sem Plasma | UI/runtime próprios e integração maior | Calamares |
| Personalização visual | branding, YAML e QML/imagens | perfis, product/updates images e Web UI | empate técnico |
| Particionamento comum | automático/manual, EFI, ext4, LUKS | muito maduro e abrangente | Anaconda |
| LVM/RAID/iSCSI/multipath | possível, depende do perfil e módulos | suporte de primeira classe | Anaconda |
| Automação | módulos e configuração própria | Kickstart consolidado | Anaconda |
| Instalação em massa | exige engenharia adicional | forte e reproduzível | Anaconda |
| Custo de adoção atual | médio; perfil já iniciado | muito alto no Noble | Calamares |
| Risco imediato | configuração incompleta do derivado | incompatibilidade arquitetural com o pipeline | Calamares |

## Calamares

### Pontos fortes

- framework explicitamente independente de distribuição;
- sequência modular de páginas e jobs;
- branding sem manter um fork extenso;
- implantação direta do SquashFS da Live;
- pacote oficial disponível no Noble;
- combina com LightDM/XFCE sem instalar KDE Plasma;
- perfil PlayOS já carrega oito etapas no runtime 3.3.5.

### Limitações

- não é pronto para uso: cada distribuição precisa completar e testar o perfil;
- exemplos upstream garantem no máximo sintaxe, não adequação ao produto;
- limpeza de pacotes Live, bootloader, criptografia e dual boot são
  responsabilidade da integração;
- o projeto migrou do GitHub para Codeberg; a origem e a política de atualização
  precisam ser acompanhadas, embora o Noble permaneça fixado em 3.3.5.

## Anaconda

### Pontos fortes

- storage avançado, incluindo LVM, RAID, iSCSI e multipath;
- Kickstart para instalações não assistidas e em escala;
- fontes locais/remotas, perfis de produto, rescue e logs maduros;
- arquitetura modular via D-Bus e Web UI moderna;
- histórico forte no ecossistema Fedora/RHEL.

### Limitações no PlayOS Noble

- documentação e código atuais integram DNF, repositórios RPM e chaves RPM;
- a árvore instalável e o runtime de boot diferem da Live Debian `live-build`;
- o PlayOS teria que manter uma camada de adaptação APT/DEB ou abandonar parte
  do pipeline Noble;
- Kickstart automático não é suportado no modo Live ISO segundo a documentação
  de troubleshooting do Anaconda;
- o ganho empresarial não compensa o custo antes do primeiro instalador
  offline funcional.

## Recomendação por produto

- **PlayOS Noble Live XFCE:** Calamares.
- **PlayOS derivado de Fedora/RHEL:** Anaconda.
- **Provisionamento massivo de servidores RPM:** Anaconda + Kickstart.
- **Live desktop personalizável com SquashFS:** Calamares.
- **Instalador oficial Ubuntu completo:** avaliar Ubuntu Desktop Installer /
  Subiquity como terceira opção; não misturar motores no mesmo fluxo.

## Decisão

Calamares permanece como único instalador candidato da edição Noble XFCE. O
Anaconda fica como referência para storage e automação, não como dependência ou
segundo instalador da ISO.

A decisão deve ser reaberta se:

1. o PlayOS trocar a base de pacotes para RPM/DNF;
2. storage empresarial se tornar requisito anterior ao desktop;
3. Calamares não passar instalação UEFI e BIOS repetível;
4. o custo de manter o perfil Calamares superar uma integração oficial Ubuntu.

## Próximo gate

Gerar a ISO, instalar offline em disco virtual descartável e comprovar:
particionamento, extração, usuário, initramfs, GRUB, LightDM e XFCE. Até isso
ocorrer, Calamares é a melhor **recomendação arquitetural**, não um instalador
PlayOS comprovadamente pronto.

## Fontes primárias

- [Calamares: framework e build](https://github.com/calamares/calamares/blob/calamares/CMakeLists.txt)
- [Módulos do Calamares](https://github.com/calamares/calamares/blob/calamares/src/modules/README.md)
- [Migração oficial do Calamares para Codeberg](https://calamares.euroquis.nl/calamares-migration/)
- [Introdução ao Anaconda](https://anaconda-installer.readthedocs.io/en/latest/user-guide/intro.html)
- [Configuração do Anaconda](https://anaconda-installer.readthedocs.io/en/latest/developer/configuration-files.html)
- [Boot, repositórios e Kickstart](https://anaconda-installer.readthedocs.io/en/latest/user-guide/boot-options.html)
- [Problemas e limites de Live/Kickstart](https://anaconda-installer.readthedocs.io/en/latest/user-guide/troubleshooting/common-bugs.html)
