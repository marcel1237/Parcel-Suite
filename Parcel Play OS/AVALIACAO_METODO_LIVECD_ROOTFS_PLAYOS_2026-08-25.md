# Avaliação — `livecd-rootfs` como método oficial do PlayOS

- data: 2026-08-25
- decisão: adotar, condicionado aos gates deste documento
- método comparado: build oficial em camadas versus remaster de `iso-tree`

## Veredito

O método baseado em `livecd-rootfs` é melhor e deve substituir o remaster manual
como pipeline principal do PlayOS. Ele cria as camadas Casper desde a origem,
permite branding na camada correta e oferece rastreabilidade muito superior.

Ele ainda não está pronto para releases: as alterações PlayOS não estão
versionadas, não há snapshot de seeds/pacotes e o primeiro build parou por HTTP
+503 no servidor oficial de seeds.

## Evidências do perfil PlayOS

O perfil `live-build/playos` existe e deriva corretamente do Ubuntu:

- os 23 arquivos que compartilha com `live-build/ubuntu` são idênticos;
- acrescenta wallpaper QHD, override GSettings, identidade, hostname, MOTD e
  logotipo;
- o wallpaper tem o mesmo SHA-256 do ativo canônico PlayOS;
- imagem e override são colocados em `includes.chroot.minimal.standard.live`,
  a camada que prevalece na sessão Live;
- o caso `playos` usa `FLAVOUR=ubuntu`, desktop em camadas e kernel
  `generic-hwe-26.04`;
- todos os scripts passam na validação de sintaxe conforme seus shebangs.

Isso corrige arquiteturalmente o erro do builder antigo, que modificava somente
`minimal.squashfs` depois da composição da mídia.

## Resultado da execução real

O comando foi executado duas vezes:

```bash
./live-build/build-livefs-lxd --suite resolute --project playos --output ./out
```

A VM `livefs-builder-resolute` iniciou com 4 CPUs, 8 GiB de RAM e disco de 100
GiB. Dentro dela foi usado o pacote oficial `livecd-rootfs 26.04.35`. Os índices
APT `resolute` e `resolute-updates` foram baixados corretamente.

As duas tentativas falharam no Germinate porque
`https://ubuntu-archive-team.ubuntu.com/seeds/ubuntu.resolute/STRUCTURE`
respondeu HTTP 503. Nenhuma ISO foi criada. A falha é externa e anterior às
fases de rootfs, wallpaper e ISO.

## Comparação

| Critério | Remaster da `iso-tree` | `livecd-rootfs` |
|---|---|---|
| Origem | árvore já modificada | pacotes e configuração declarados |
| Camadas Casper | altera uma camada | gera todas as camadas |
| Wallpaper | foi sobrescrito | inserido na camada Live efetiva |
| Repetibilidade | baixa | alta quando fontes são congeladas |
| Atualizações | manuais e acumulativas | novo build limpo |
| Auditoria | difícil distinguir origem | hooks e commits rastreáveis |
| Boot | reaproveita estruturas antigas | gerado pelo pipeline Ubuntu |
| Custo | rápido | demorado e dependente de rede |
| Infraestrutura | SquashFS e xorriso | VM/LXD, APT, seeds e mais espaço |
| Estado atual | produz ISO experimental | ainda bloqueado antes do build |

## Problemas que precisam ser corrigidos

1. Existem 39 alterações locais no checkout: `auto/config` modificado e perfil
   PlayOS não rastreado.
2. O checkout do host declara `livecd-rootfs 26.10.5`, enquanto a VM instala
   `26.04.35`; a relação entre código montado e pacote de dependências precisa
   ser registrada explicitamente.
3. Seeds dependem de um endpoint externo atualmente indisponível.
4. Não há snapshot APT nem data fixa de repositório.
5. Não existe ainda ISO, log final, teste de boot ou teste de instalação.
6. QEMU não está instalado no host para validação automatizada.
7. A integração do kernel PlayOS 7.1.8 ainda não faz parte deste perfil.

## Gates para adoção

### Gate 1 — rastreabilidade

- criar branch/commit PlayOS ou patchset reproduzível;
- versionar `live-build/playos` e as mudanças em `auto/config`;
- registrar commit upstream, versão do pacote na VM e hashes dos ativos;
- manter fontes upstream separadas de outputs.

### Gate 2 — congelamento de entradas

- espelhar ou versionar os seeds Resolute;
- configurar `--seedmirror` para uma fonte validada;
- usar snapshot/mirror APT com data registrada;
- registrar snaps, PPAs e canais utilizados.

### Gate 3 — build completo

- produzir todas as camadas SquashFS;
- gerar ISO BIOS/UEFI;
- copiar somente artefatos `livecd.*` para `out/`;
- registrar logs, manifestos e SHA-256.

### Gate 4 — validação visual

Na sessão Live, confirmar:

```bash
gsettings get org.gnome.desktop.background picture-uri
gsettings get org.gnome.desktop.background picture-uri-dark
gsettings get org.gnome.desktop.screensaver picture-uri
```

Os três valores devem apontar para
`file:///usr/share/backgrounds/playos/default.png`.

### Gate 5 — instalação e kernel

- testar instalação completa e primeiro boot;
- validar Secure Boot e fallback;
- manter inicialmente o kernel Ubuntu oficial;
- integrar o PlayOS Kernel 7.1.8 em etapa separada, com módulos e initramfs
  correspondentes.

## Recomendação operacional

Adotar este fluxo como alvo oficial, mas manter a ISO atual somente como
referência até o novo pipeline passar por todos os gates. Não continuar
corrigindo o wallpaper por remaster sucessivo. Primeiro deve ser estabilizado o
mirror de seeds, depois concluído o build oficial e só então substituído o
artefato canônico.

A VM LXD pode ser mantida para aproveitar caches durante a estabilização. Quando
o pipeline estiver reproduzível, builds de release devem começar em ambiente
limpo ou snapshot conhecido.
