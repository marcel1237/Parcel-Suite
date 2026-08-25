# Auditoria do diretório `ubuntu26-build`

- data: 2026-08-25
- diretório auditado: `/home/marcel/Parcel-Suite/Operating Systems/ubuntu26-build`
- tamanho observado: aproximadamente 49 MiB
- modo da auditoria: somente leitura
- conclusão: coleção de fontes upstream; não é um build concluído nem a fonte direta da ISO atual

## 1. Objetivo desta auditoria

Esta análise determina o conteúdo, a origem, o uso atual e o uso recomendado do
diretório externo `ubuntu26-build`, além de esclarecer sua relação com a ISO
PlayOS, a `iso-tree`, o wallpaper e os kernels compilados.

## 2. Conclusão executiva

O diretório reúne cinco repositórios Git em quatro agrupamentos visíveis. Seus
dois componentes mais importantes para uma ISO Ubuntu clássica são
`livecd-rootfs` e `ubuntu-cdimage`.

O diretório não contém o código-fonte completo do Ubuntu. Também não contém um
rootfs produzido, uma ISO real, pacotes baixados ou um build local concluído.
Não há alterações PlayOS nos repositórios e não existe evidência de que essas
fontes tenham criado `build/resolute-mvp/work/iso-tree/`.

A `iso-tree` usada atualmente pelo PlayOS veio da extração de uma ISO Ubuntu
Resolute já pronta. `ubuntu26-build` deve ser encarado como base para substituir
esse método por um pipeline futuro mais oficial e reproduzível.

## 3. Inventário

| Componente | Tamanho aproximado | Arquivos | Função |
|---|---:|---:|---|
| `livecd-rootfs` | 17 MiB | 662 | constrói o rootfs Live e seus artefatos |
| `ubuntu-cdimage` | 21 MiB | 536 | orquestra, compõe e publica imagens ISO |
| `core-base-desktop` | 5,2 MiB | 191 | base de desktop para Ubuntu Core |
| `ubuntu-core-desktop-24` | 5,9 MiB | 290 | agrupador de duas fontes Ubuntu Core Desktop |

Os 41 arquivos com extensão `.iso` encontrados não são imagens utilizáveis.
Eles são fixtures minúsculas da suíte de testes de `ubuntu-cdimage`, com zero
ou poucas dezenas de bytes.

Não foram encontrados arquivos reais de saída como `.deb`, `.snap`, ISO,
SquashFS, imagem raw ou artefato maior que 100 MiB.

## 4. Repositórios e versões exatas

### 4.1 `livecd-rootfs`

- remoto: `https://git.launchpad.net/livecd-rootfs`;
- branch: `ubuntu/master`;
- commit: `3dcf97af7e332f4a2f15bc815135e0b299677986`;
- data do commit: 2026-07-22;
- versão descrita: `26.10.5`;
- estado Git: limpo.

Este é o componente central para criar o sistema de arquivos da mídia Live.
Ele executa o ciclo `live-build`, seleciona pacotes, executa hooks, produz
camadas e gera artefatos `livecd.*`.

O checkout não está fixado numa versão Resolute 26.04: ele está em
`ubuntu/master` e declara `26.10.5`. Apesar de aceitar `--suite resolute`, usar
essa revisão para reproduzir uma ISO Resolute histórica cria risco de mudança
de layout, hooks, dependências e comportamento. O PlayOS precisa fixar uma
revisão compatível com a base escolhida.

### 4.2 `ubuntu-cdimage`

- remoto: `https://git.launchpad.net/ubuntu-cdimage`;
- branch: `main`;
- commit: `2170539b2d94a74792a32fb59926687dc2820bca`;
- data do commit: 2026-07-29;
- estado Git: limpo.

Esse projeto coordena a composição da mídia. Ele usa artefatos Live já
produzidos, gera listas via Germinate, integra `debian-cd`, monta conjuntos de
imagens e administra publicação e checksums.

O checkout local está incompleto para execução: não contém os diretórios
esperados `debian-cd`, `germinate`, `scratch` e `ftp`. Portanto, possuir apenas
essa árvore não torna o pipeline de ISO operacional.

### 4.3 `core-base-desktop`

- remoto: repositório Launchpad `core-base-desktop`;
- branch: `main`;
- commit: `28a34e3c535c62c0e6ce97193c111075faa28087`;
- data do commit: 2024-03-27;
- estado Git: limpo.

É uma base para Ubuntu Core Desktop, incluindo hooks, dados dconf e definição
Snapcraft. Não é a fonte do Ubuntu Desktop clássico baseado em pacotes `.deb`
e camadas Casper utilizada pela ISO PlayOS atual.

### 4.4 `ubuntu-core-desktop-24/core24-desktop`

- remoto: Launchpad `core-base-desktop`;
- branch: `24`;
- commit: `decbc41b11be779eac50ad838049172ffed4ebfe`;
- data do commit: 2025-04-21;
- estado Git: limpo.

É a variante Core 24 da base de desktop. Seu modelo é imutável e orientado a
snaps. Pode servir como estudo arquitetural, mas não deve ser misturado ao
rebuild clássico sem uma decisão explícita de produto.

### 4.5 `ubuntu-core-desktop-24/ubuntu-core-desktop`

- remoto: `https://github.com/canonical/ubuntu-core-desktop.git`;
- branch: `main`;
- commit: `4bbf6ec1c29117d0978524b6261c55d5f604f3c3`;
- data do commit: 2025-02-04;
- estado Git: limpo.

Esse repositório descreve o produto Ubuntu Core Desktop. Também pertence à
linha imutável/snap, não ao Ubuntu Desktop clássico usado hoje pelo PlayOS.

## 5. O que o diretório contém — e o que não contém

### Contém

- código de automação oficial/upstream para construir rootfs Live;
- código de orquestração de imagens e publicação;
- configurações, hooks e testes para múltiplos sabores e arquiteturas;
- estudos/fontes de Ubuntu Core Desktop;
- históricos Git e remotos upstream íntegros;
- documentação de execução local, inclusive via LXD.

### Não contém

- o código-fonte completo do Ubuntu;
- o código-fonte do kernel Resolute;
- GNOME, glibc, systemd e todos os demais pacotes-fonte da distribuição;
- um espelho APT ou snapshot dos pacotes;
- uma ISO Ubuntu/PlayOS real;
- uma `iso-tree` gerada por essas ferramentas;
- artefatos `livecd.*` reais;
- alterações, patches ou branding PlayOS;
- logs que comprovem uma execução local;
- configuração local do builder;
- dependências suficientes para executar o pipeline atual.

## 6. Prontidão do ambiente

Ferramentas presentes:

- `xorriso`;
- `mksquashfs`;
- Python 3.

Ferramentas ausentes durante a auditoria:

- LXC/LXD;
- `live-build` (`lb`);
- `debootstrap`;
- `germinate`;
- `tox`;
- `pre-commit`.

Também não existe `~/.config/livecd-rootfs/build-livefs.conf`, portanto não há
mirror, proxy ou cache APT local configurado para esse fluxo.

O `livecd-rootfs` declara ainda dependências como `apt-utils`, `live-build`,
`debootstrap`, Germinate, `python3-apt`, `python3-launchpadlib`, `qemu-utils`,
Snapd, SquashFS tools, `xorriso`, Zstandard, ferramentas de partição e outras.

Conclusão de prontidão: o diretório está apto para leitura e desenvolvimento,
mas não está pronto para produzir uma ISO neste host.

## 7. Relação com a ISO PlayOS atual

Não foi encontrada referência no projeto que invoque diretamente:

```text
/home/marcel/Parcel-Suite/Operating Systems/ubuntu26-build
```

Os documentos PlayOS mencionam `livecd-rootfs` como migração futura, não como
etapa já executada. A ISO atual foi produzida por outro fluxo:

```text
ISO Ubuntu Resolute pronta
       ↓ extração
build/resolute-mvp/work/iso-tree/
       ↓ alteração manual de SquashFS e xorriso
ISO PlayOS atual
```

Logo, `ubuntu26-build` não originou a `iso-tree`, não compilou o kernel da ISO e
não causou diretamente a falha do wallpaper.

## 8. Relação com a falha do wallpaper

Embora não tenha sido usado na ISO atual, `livecd-rootfs` é o local correto
para modelar a solução futura. Ele conhece a criação das camadas SquashFS e
possui o mecanismo `lb_binary_layered`, enquanto o builder PlayOS atual altera
apenas `minimal.squashfs` depois que a ISO já foi construída.

O branding deve ser implementado como configuração/hook rastreável antes da
geração das camadas. Assim, o wallpaper e os bancos GSettings podem ser
aplicados na camada efetiva da sessão Live, evitando que
`minimal.standard.live.squashfs` sobrescreva a configuração PlayOS.

As fontes upstream externas devem permanecer limpas. O recomendado é manter no
repositório PlayOS patches, overlays e configuração que sejam aplicados a um
commit fixo de `livecd-rootfs`, em vez de editar silenciosamente o clone.

## 9. Uso recomendado no PlayOS

### Linha clássica — recomendada agora

Usar `livecd-rootfs` para produzir o rootfs/camadas e `ubuntu-cdimage` para a
composição final, mantendo o Ubuntu Desktop clássico como base.

Requisitos:

1. escolher a ISO/série Ubuntu exata;
2. fixar commits compatíveis de `livecd-rootfs` e `ubuntu-cdimage`;
3. registrar mirror e snapshot dos pacotes;
4. completar `ubuntu-cdimage` com `debian-cd` e `germinate` compatíveis;
5. executar em VM ou LXD descartável, não diretamente no host;
6. criar hooks PlayOS para branding, pacotes e configurações;
7. gerar todas as camadas no mesmo pipeline;
8. conservar o kernel Ubuntu como fallback;
9. validar ISO, boot, Live, instalador e sistema instalado;
10. publicar manifesto de fontes, pacotes, commits e checksums.

### Linha Ubuntu Core Desktop — não misturar agora

`core-base-desktop` e `ubuntu-core-desktop-24` só devem ser usados se o PlayOS
decidir criar uma edição imutável baseada em snaps. Isso implica outro modelo
de atualização, recuperação, armazenamento e instalação. Esses componentes não
são necessários para corrigir a ISO clássica atual.
