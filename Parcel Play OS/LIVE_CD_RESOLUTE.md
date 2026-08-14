# Live ISO Resolute com GNOME e KDE Full

## Objetivo

Criar rapidamente uma primeira imagem Live amd64 do Parcel Play OS baseada no Ubuntu 26.04 LTS (Resolute), contendo:

- GNOME completo por meio do metapacote `ubuntu-desktop`;
- KDE completo por meio do metapacote `kde-full`;
- escolha da sessão GNOME ou Plasma na tela de login;
- boot Live preservado pelo `casper` da imagem oficial;
- capacidade de instalação herdada da ISO Desktop oficial.

## Escopo deste documento

Este arquivo descreve somente o MVP baseado no kernel oficial Ubuntu Resolute. A arquitetura final de uma única ISO com seletor GRUB para onze kernels foi movida para `LIVE_ISO_11_KERNELS.md`.

## Verificações realizadas em 2026-08-13

### Ambiente local

- Sistema de construção: Ubuntu 26.04 LTS amd64.
- `ubuntu-desktop` instalado no host: versão `1.570.2`.
- `kde-full` disponível no repositório `universe`: versão `5:166ubuntu2`.
- `livecd-rootfs` disponível: versão candidata `26.04.35`.
- `live-build` disponível: versão candidata `3.0~a57-1ubuntu54`.
- `xorriso` e `squashfs-tools` já instalados.
- Espaço disponível observado: aproximadamente `161 GB`.
- Memória RAM observada: aproximadamente `5,1 GiB`, com `4 GiB` de swap.
- QEMU não foi encontrado no `PATH` durante a verificação.

O espaço em disco é suficiente para a remasterização. A memória é limitada, mas deve permitir o processo com menor paralelismo; a compressão e a execução simultânea de aplicações pesadas podem causar uso intenso de swap.

### Fontes oficiais consultadas

- O Ubuntu publica uma ISO Desktop amd64 do Resolute, já contendo GNOME, boot Live e instalador: <https://www1.cdimage.ubuntu.com/ubuntu/resolute/daily-live/current/>.
- O metapacote `ubuntu-desktop` existe oficialmente no Resolute: <https://packages.ubuntu.com/resolute/amd64/ubuntu-desktop>.
- O metapacote `kde-full` existe no componente `universe` do Resolute: <https://packages.ubuntu.com/search?keywords=kde&suite=resolute>.
- O Ubuntu fornece `livecd-rootfs` como sistema oficial de construção do sistema de arquivos Live: <https://launchpad.net/ubuntu/resolute/+source/livecd-rootfs>.
- A documentação comunitária descreve a remasterização por extração da ISO, alteração do SquashFS e remontagem com `xorriso`: <https://help.ubuntu.com/community/LiveCDCustomization>.

## Decisão técnica

### Primeira ISO: remasterização da ISO Desktop oficial

Este é o caminho mais rápido porque a imagem oficial já resolve:

- boot BIOS/UEFI;
- Secure Boot e carregadores oficiais;
- `casper` e sessão Live;
- GNOME e GDM;
- firmware e detecção de hardware;
- instalador Desktop do Ubuntu.

A única mudança funcional necessária para o protótipo é instalar `kde-full` dentro do sistema Live e garantir que o GDM continue como display manager padrão.

### Builds posteriores: `livecd-rootfs`

Depois de validar o protótipo, a configuração deve migrar para um processo automatizado baseado em `livecd-rootfs`. Essa será a abordagem adequada para builds repetíveis, integração contínua, branding, pacotes Parcel e futura inclusão do NitroCore.

O `live-build` genérico não foi escolhido para a primeira versão porque a ISO Desktop moderna do Ubuntu possui integração própria de `casper`, instalador, snaps, seeds e camadas de sistema. Reproduzir manualmente toda essa integração aumentaria o risco e o tempo da primeira entrega.

## Procedimento proposto para o protótipo

### 1. Obter e verificar a ISO oficial

Baixar, da pasta `current`, a ISO amd64 e os arquivos de assinatura:

- `resolute-desktop-amd64.iso`;
- `SHA256SUMS`;
- `SHA256SUMS.gpg`.

O checksum SHA-256 deve ser validado antes de qualquer alteração. A assinatura deve ser verificada com a chave oficial do arquivo Ubuntu.

### 2. Usar uma ferramenta de remasterização

A opção de menor complexidade operacional é uma ferramenta gráfica de remasterização compatível com a ISO atual, como o Cubic. Como o Cubic é externo ao Ubuntu e não está disponível nos repositórios atualmente configurados no host, sua compatibilidade com o Resolute deve ser validada antes da instalação.

Se o Cubic não reconhecer corretamente as camadas da ISO Resolute, o processo deve ser interrompido e migrado para `livecd-rootfs`. Não se deve reconstruir o boot manualmente copiando comandos antigos sem validar o layout real da ISO.

### 3. Alteração mínima dentro do ambiente da imagem

No terminal/chroot oferecido pela ferramenta de remasterização:

```bash
apt-get update
apt-get install -y kde-full
```

Durante a configuração de display manager, manter `gdm3`. A intenção é que o GDM continue iniciando por padrão e ofereça GNOME e Plasma no seletor de sessão.

Antes de fechar a imagem, confirmar:

```bash
dpkg-query -W ubuntu-desktop kde-full gdm3 plasma-desktop
cat /etc/X11/default-display-manager
```

O último comando deve apontar para o GDM. Se o pacote `kde-full` selecionar o SDDM automaticamente, o padrão precisa ser corrigido de maneira explícita e documentada antes da geração da ISO.

### 4. Limpeza da imagem

Antes da compressão final:

```bash
apt-get clean
rm -rf /var/lib/apt/lists/*
```

Também devem ser removidos arquivos temporários e históricos produzidos dentro do chroot. Nenhum dado pessoal do host pode entrar na imagem.

### 5. Gerar e testar

A saída deve ser identificada inicialmente como:

```text
parcel-play-resolute-gnome-kde-amd64.iso
```

Testes mínimos obrigatórios:

1. validar o checksum da ISO gerada;
2. iniciar em modo UEFI numa máquina virtual;
3. iniciar a sessão Live GNOME;
4. encerrar a sessão e iniciar Plasma;
5. validar rede, áudio, teclado e vídeo em ambas as sessões;
6. executar o instalador até a tela anterior ao particionamento destrutivo;
7. instalar em disco virtual descartável;
8. reiniciar o sistema instalado e testar as duas sessões;
9. testar posteriormente em pendrive e hardware físico.

## Tamanho da mídia

A ISO Desktop oficial do Resolute observada durante a pesquisa já possuía aproximadamente `6,1 GB`. Com `kde-full`, a imagem final será maior.

Consequências:

- não cabe em CD de 700 MB;
- provavelmente não cabe em DVD de camada simples de 4,7 GB;
- deve ser tratada como **Live ISO para pendrive USB**;
- recomenda-se pendrive de pelo menos 16 GB para os primeiros testes.

Apesar do nome histórico “Live CD”, a documentação do projeto deve preferir “Live ISO” ou “Live USB”.

## Riscos conhecidos

- GNOME e KDE Full juntos duplicam diversos aplicativos e aumentam significativamente o tamanho da imagem.
- A instalação de `kde-full` pode alterar o display manager padrão para SDDM.
- Portais XDG, temas, keyrings e aplicativos padrão podem apresentar conflitos entre sessões.
- A ISO diária muda com o tempo; checksum, manifesto e data da imagem-base devem ser registrados em cada build.
- Uma ferramenta externa de remasterização pode não acompanhar mudanças no layout da ISO Desktop moderna.
- Secure Boot deve ser novamente testado após qualquer troca de kernel; não faz parte deste primeiro protótipo.

## Plymouth do MVP

O primeiro protótipo usará apenas o kernel Ubuntu e o tema `parcel-ubuntu`. O mapeamento Plymouth dos onze kernels e os testes por entrada estão documentados em `LIVE_ISO_11_KERNELS.md`.

## Alternativa para reduzir tamanho

Se `kde-full` produzir uma imagem excessivamente grande, testar em uma variante separada:

```bash
apt-get install -y kde-standard
```

ou, para o menor protótipo Plasma:

```bash
apt-get install -y kde-plasma-desktop
```

Essas alternativas não satisfazem literalmente o requisito `kde-full`; só devem ser usadas após decisão registrada.

## Critério de conclusão da primeira etapa

A etapa estará concluída somente quando existir uma ISO testada que:

- inicialize em modo Live;
- ofereça GNOME e Plasma no login;
- mantenha o kernel oficial Resolute;
- instale em uma máquina virtual;
- reinicie com sucesso após a instalação;
- tenha comandos, versão da ISO-base, checksum e resultados registrados neste documento.
