# Calamares versus Ubuntu Desktop Provision para o PlayOS

## Metadados

- **ID:** `KB-PLAYOS-INSTALLER-DESKTOP-PROVISION-001`
- **Tipo:** `comparative-analysis`
- **Estado:** `decision` e `recommendation`
- **Confiança:** alta para arquitetura; média para custo de integração
- **Verificado em:** 2026-08-27
- **Escopo:** Ubuntu Noble, Live XFCE, SquashFS, DEB/APT

## O que está sendo comparado

`ubuntu-desktop-provision` é uma suíte Canonical em Flutter, não um backend de
instalação isolado:

- `ubuntu_bootstrap`: interface que conduz o Subiquity na etapa de instalação;
- `ubuntu_init`: interface que conduz o `provd` no primeiro boot/OEM;
- `ubuntu_provision`: páginas e código compartilhados;
- clientes Dart para Subiquity e `provd`.

Calamares reúne interface, sequência de módulos e jobs dentro do próprio
framework, chamando ferramentas do sistema e módulos configurados pelo derivado.

## Resumo executivo

- **Melhor para gerar rapidamente a Live PlayOS atual:** Calamares.
- **Melhor para uma futura variante Ubuntu oficialmente alinhada:** Desktop
  Provision + Subiquity + Curtin + Casper/livecd-rootfs.
- **Melhor para primeiro boot/OEM:** Desktop Provision.
- **Menor acoplamento ao GNOME e à ISO oficial Ubuntu:** Calamares.

O Desktop Provision é tecnicamente mais alinhado ao Ubuntu e já reconhece
fontes de instalação de flavors, incluindo Xubuntu. Porém, a Live atual foi
criada com `live-build` e um único `filesystem.squashfs`; ela ainda não possui
todo o contrato esperado pela pilha oficial, como snap
`ubuntu-desktop-bootstrap`, servidor Subiquity, Curtin, Casper,
`casper/install-sources.yaml`, hooks e camadas oficiais.

## Comparação

| Critério | Calamares | Desktop Provision |
|---|---|---|
| Natureza | framework instalador independente | frontend Ubuntu para Subiquity e `provd` |
| Backend | módulos Calamares | Subiquity/Curtin na instalação; `provd` no primeiro boot |
| Interface | Qt Widgets/QML | Flutter |
| Ubuntu Noble | pacote 3.3.5 disponível | pilha nativa das imagens Ubuntu modernas |
| Live XFCE | funciona como aplicação XDG | suporta flavors, mas exige serviços e integração do flavor |
| GNOME obrigatório | não | não conceitualmente, mas existem serviços GNOME padrão no código e hooks locais |
| Payload atual | aponta diretamente para `filesystem.squashfs` | espera fontes declaradas e pipeline Casper/Subiquity |
| Branding | `branding.desc`, QML/imagens | `whitelabel.yaml`, temas e slides |
| OEM/primeiro boot | possível, exige configuração | função central de `ubuntu_init` + `provd` |
| Autoinstall | scripts/módulos próprios | contrato Subiquity `autoinstall` |
| TPM/FDE e recursos Ubuntu | integração manual | melhor alinhamento upstream |
| Snap | não obrigatório | componentes principais são normalmente snaps |
| Integração já existente | perfil carrega oito etapas | apenas configuração de branding local, sem ISO integrada |
| Custo imediato | médio | alto no perfil `live-build` atual |

## Calamares no PlayOS

### Vantagens

- já está no manifesto Noble;
- perfil PlayOS foi carregado no runtime real;
- implanta diretamente o SquashFS da Live;
- interface independente do desktop e do backend Canonical;
- pode permanecer em XFCE e Labwc/Xwayland;
- menor quantidade de infraestrutura para o primeiro teste offline.

### Limitações

- PlayOS assume responsabilidade por particionamento, boot, limpeza do alvo e
  manutenção do perfil;
- OEM, autoinstall e criptografia precisam de validação própria;
- não herda automaticamente avanços específicos do instalador Ubuntu.

## Desktop Provision no PlayOS

### Vantagens

- frontend mantido para o Ubuntu Desktop e seus flavors;
- Subiquity/Curtin oferecem contratos Ubuntu para storage e implantação;
- `autoinstall` produz configuração reaproveitável;
- `ubuntu_init` cobre identidade e primeiro boot/OEM;
- `whitelabel.yaml` permite nome, páginas e aparência do flavor;
- documentação do Subiquity lista fontes Xubuntu minimal e standard.

### Limitações atuais

- não basta instalar um pacote ou copiar o frontend;
- requer snap, socket/serviço Subiquity, Curtin e fonte de instalação válida;
- a fonte é identificada por `casper/install-sources.yaml`, não simplesmente
  por qualquer SquashFS;
- código padrão possui serviços GNOME registrados; um flavor XFCE deve fornecer
  ou validar substituições em vez de assumir neutralidade;
- hooks locais de `ubuntu-core-desktop-24` instalam `gnome-initial-setup` e
  configuram temas GNOME, portanto não podem ser copiados para esta Live XFCE;
- migrar agora equivale a trocar o pipeline `live-build` simples pelo
  `livecd-rootfs`/Casper oficial.

## Recomendação

### Curto prazo: Calamares

Concluir primeiro a ISO existente e provar uma instalação UEFI/BIOS offline.
Ele é o caminho mais curto entre o perfil atual e um sistema instalado.

### Médio prazo: prova separada de Desktop Provision

Criar outra variante, sem colocar dois motores na mesma ISO:

```text
livecd-rootfs + Casper
  -> camadas e install-sources.yaml
  -> ubuntu-desktop-bootstrap
  -> Subiquity + Curtin
  -> PlayOS/XFCE flavor config
  -> ubuntu_init/provd opcional no primeiro boot
```

Se essa variante instalar o mesmo PlayOS com menos patches, melhor suporte a
autoinstall, atualização e criptografia, ela pode substituir Calamares.

## Critérios para trocar de instalador

Desktop Provision só será promovido quando houver:

1. build reproduzível pelo `livecd-rootfs`;
2. fonte PlayOS válida em `casper/install-sources.yaml`;
3. bootstrap funcional sem dependência involuntária do GNOME;
4. instalação offline XFCE em UEFI e BIOS;
5. primeiro boot sem `gnome-initial-setup` residual;
6. branding PlayOS por `whitelabel.yaml` validado;
7. custo de manutenção menor ou igual ao perfil Calamares.

## Decisão atual

Calamares continua no MVP. Desktop Provision passa a ser a rota estratégica
para uma futura edição PlayOS alinhada aos flavors Ubuntu. Eles não serão
incluídos simultaneamente na mesma ISO.

## Fontes primárias

- [Ubuntu Desktop Provision](https://github.com/canonical/ubuntu-desktop-provision)
- [Subiquity](https://github.com/canonical/subiquity)
- [Fontes de instalação e autoinstall](https://github.com/canonical/subiquity/blob/main/subiquity/doc/reference/autoinstall-reference.rst)
- [Calamares](https://github.com/calamares/calamares/blob/calamares/CMakeLists.txt)
