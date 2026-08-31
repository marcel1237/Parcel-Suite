# Instruções para o Gemini recriar a ISO PlayOS Calamares + XFCE

## Identidade da missão

- **ID:** `KB-PLAYOS-GEMINI-FIRST-CALAMARES-ISO-001`
- **Tipo:** `agent-execution-directive`
- **Estado:** `implementation`; execução e nova ISO pendentes
- **Confiança:** alta para o procedimento; runtime permanece não validado
- **Data:** 2026-08-30
- **Agente destinatário:** Gemini ou outro agente executor de build

## Ordem principal

Recrie a composição histórica da primeira ISO PlayOS Noble com XFCE e
Calamares usando exclusivamente `live-build` + `live-boot`.

Não analise todo o projeto. Leia, nesta ordem:

1. `AGENTS.md`;
2. este arquivo;
3. `RECRIAR_PRIMEIRA_ISO_CALAMARES_XFCE.md` somente quando este arquivo pedir
   detalhes adicionais;
4. `SOLUCAO_IMPEDIMENTOS_RECRIACAO_ISO_CALAMARES_XFCE.md` somente para
   diagnóstico.

Este arquivo prevalece sobre relatórios históricos conflitantes para esta
missão específica.

## Resultado esperado

Produzir:

```text
playos-noble-xfce-calamares-amd64.iso
playos-noble-xfce-calamares-amd64.iso.sha256
filesystem.packages
playos-noble-xfce-calamares-build.log
RELATORIO_GEMINI_RESULTADO_ISO_CALAMARES_XFCE.md
```

Destino final, somente depois de todos os gates estáticos passarem:

```text
build/playos-graphics-core-noble/output/
```

Não apague nem sobrescreva a ISO histórica antes de comparar os resultados.
Se já existir um arquivo com o nome canônico, mantenha a nova ISO em staging e
peça autorização antes de substituir.

## Pipeline obrigatório

```text
live-build
live-boot
/live/filesystem.squashfs
/live/filesystem.packages
boot=live
```

É proibido nesta missão usar ou introduzir:

```text
livecd-rootfs
build-livefs
build-livefs-lxd
common_layered_desktop_image
germinate ou seeds PlayOS
casper
curtin
subiquity-server
/casper/
boot=casper
live-media-path=/casper/
marcador /ubuntu
injeção direta dos 1.110 pacotes do manifesto histórico
```

Se qualquer item proibido aparecer na cópia de trabalho, pare antes do build e
corrija a cópia. Não altere o perfil-fonte.

## Estado conhecido que não deve ser confundido

- A tentativa anterior terminou com `Terminated` durante o pacote 421.
- Não existe ISO, SquashFS ou árvore binária recuperável dessa tentativa.
- O chroot anterior deve ser descartado por `lb clean --purge`.
- `nohup` não prova que um processo continua executando.
- A causa exata do sinal anterior é `unknown`; não houve OOM registrado na VM.
- A ISO histórica foi construída, mas o usuário informou que o Calamares não
  funcionou. A recriação da composição não comprova a instalação.

## Etapa 1 — verificar a VM

Use a VM LXD Noble `livefs-builder-noble` apenas se ela estiver saudável.

```sh
lxc list livefs-builder-noble
lxc storage info default
lxc exec livefs-builder-noble -- free -h
lxc exec livefs-builder-noble -- df -h /
lxc exec livefs-builder-noble -- sh -lc \
  'pgrep -af "lb build|debootstrap|mksquashfs|grub-mkrescue" || true'
```

Critérios mínimos:

- Ubuntu Noble amd64;
- até 4 GiB de RAM atribuída neste host;
- pelo menos 25 GiB livres dentro da VM;
- pelo menos 6 GiB realmente livres no pool indicado por
  `lxc storage info default`;
- nenhum build concorrente;
- DNS e repositórios Ubuntu acessíveis.

Se houver build ativo, não inicie outro. Se o pool estiver cheio, não confie no
`df` interno: volumes LXD podem ser thin-provisioned. Não apague instâncias ou
imagens sem autorização. Se houver alta carga persistente, swap exaurida ou
erros de I/O, pare e relate.

## Etapa 2 — instalar somente ferramentas do pipeline correto

Dentro da VM:

```sh
sudo apt-get update
sudo apt-get install -y \
  live-build debootstrap squashfs-tools xorriso \
  grub-pc-bin grub-efi-amd64-bin mtools dosfstools
```

Registre:

```sh
dpkg-query -W live-build debootstrap squashfs-tools xorriso \
  grub-pc-bin grub-efi-amd64-bin mtools dosfstools
```

Não instale `livecd-rootfs` para esta missão.

## Etapa 3 — preparar uma cópia histórica nova

Na raiz do projeto, execute o preparador versionado. O destino deve ser novo:

```sh
profile_work="$(mktemp -d /tmp/playos-first-calamares.XXXXXX)"
rmdir "$profile_work"

./live-build/playos-graphics-core-noble/tools/prepare-first-calamares-profile.sh \
  "$profile_work"
```

Transfira essa cópia para a VM preservando permissões, ou execute o preparador
diretamente sobre uma cópia do projeto disponível na VM. Diretório recomendado
na VM:

```text
/root/build-pure/profile
```

Não copie `chroot/`, `binary/`, `.build/`, `cache/` ou logs de tentativa
anterior para o novo perfil.

## Etapa 4 — gates antes do build

Na raiz da cópia preparada:

```sh
set -eu

grep -qx live-boot config/package-lists/playos-graphics-core.list.chroot
! grep -qxE '(casper|subiquity-server|curtin)' \
  config/package-lists/playos-graphics-core.list.chroot
grep -q -- '--initramfs live-boot' auto/config
grep -q '^      - unpackfs$' \
  config/includes.chroot/etc/calamares/settings.conf
grep -q '^      - bootloader$' \
  config/includes.chroot/etc/calamares/settings.conf
! find config/includes.chroot/usr/lib/calamares/modules \
  -maxdepth 1 -type d -name 'subiquity_*' | grep -q .
! grep -R -E 'common_layered|germinate|boot=casper|/casper/' \
  auto config tools
```

Todos devem passar. Não ignore falhas com `|| true`, exceto em comandos de
observação explicitamente marcados neste documento.

## Etapa 5 — limpar e construir

Na VM, dentro de `/root/build-pure/profile`:

```sh
sudo lb clean --purge
sudo lb config
```

Confirme que `config/` foi gerado e que o initramfs continua `live-boot`.

Execute o build com Bash, registro de PID lógico e código de saída. Não use
`sh`, pois `pipefail` e `PIPESTATUS` não são portáveis para Dash:

```sh
cd /root/build-pure/profile

sudo bash -o pipefail -c '
  lb build 2>&1 | tee /root/build-pure/build.log
  status=${PIPESTATUS[0]}
  printf "%s\n" "$status" > /root/build-pure/build.exit-status
  exit "$status"
'
```

Para execução desacoplada do terminal:

```sh
sudo nohup bash -o pipefail -c '
  cd /root/build-pure/profile
  lb build 2>&1 | tee /root/build-pure/build.log
  status=${PIPESTATUS[0]}
  printf "%s\n" "$status" > /root/build-pure/build.exit-status
  exit "$status"
' > /root/build-pure/nohup.out 2>&1 &

echo $! | sudo tee /root/build-pure/build.pid
```

Para declarar “executando”, confirme simultaneamente:

```sh
pid=$(cat /root/build-pure/build.pid)
kill -0 "$pid"
pgrep -af 'lb build'
```

Ausência do processo significa encerrado, mesmo que o último log diga que o
build estava instalando pacotes.

## Etapa 6 — política para falhas

Pare e gere relatório se ocorrer:

- `Terminated`, SIGHUP, reset de conexão ou soft lockup;
- OOM ou swap thrashing;
- conflito `dpkg-divert` em `update-initramfs`;
- referência a Casper, germinate ou tasks;
- erro APT/dpkg;
- ausência de kernel, initrd ou SquashFS;
- falta de espaço.
- menos de 6 GiB livres no pool LXD, mesmo que a VM anuncie espaço virtual;

Não execute `dpkg --configure -a` para salvar um build que será chamado
reproduzível. Não remova diversões por hooks. Faça novo `lb clean --purge` e
recomece somente após identificar a causa.

Relate sempre:

```sh
cat /root/build-pure/build.exit-status 2>/dev/null || true
tail -200 /root/build-pure/build.log
free -h
df -h /
lxc storage info default  # executar no host
journalctl -k --no-pager | \
  grep -Ei 'oom|out of memory|killed process|soft lockup|I/O error' | tail -100
```

## Etapa 7 — manifesto correto

Com `live-boot`, `live-build 3.0~a57` gera automaticamente:

```text
binary/live/filesystem.packages
binary/live/filesystem.packages-remove
```

ou os mesmos arquivos sob `chroot/binary/live/`, conforme a árvore produzida.
Não exija `filesystem.manifest`; esse nome pertence ao modo Casper.

O manifesto esperado deve conter Calamares, XFCE, LightDM, kernel, live-boot e
live-config, e não deve conter os backends proibidos:

```sh
manifest=$(find binary chroot/binary -path '*/live/filesystem.packages' \
  -type f -print -quit 2>/dev/null)
test -n "$manifest"

grep -E '^(calamares|xfce4|lightdm|live-boot|live-config|linux-image-generic)[[:space:]]' \
  "$manifest"
! grep -E '^(casper|subiquity-server|curtin)[[:space:]]' "$manifest"
```

## Etapa 8 — finalização GRUB

Primeiro verifique se `lb build` já gerou uma ISO utilizável. Só use o
finalizador se o build falhar exclusivamente na montagem final e existir uma
árvore completa.

Na raiz do perfil:

```sh
test -d binary || test -d chroot/binary

iso_tree=binary
test -d "$iso_tree" || iso_tree=chroot/binary

test -s "$iso_tree/live/filesystem.squashfs"
find "$iso_tree/live" -maxdepth 1 -type f -name 'vmlinuz*' | grep -q .
find "$iso_tree/live" -maxdepth 1 -type f -name 'initrd*' | grep -q .
test -f "$iso_tree/boot/grub/grub.cfg"
```

Somente então:

```sh
sudo ./tools/finalize-grub-iso.sh \
  playos-noble-xfce-calamares-amd64.iso
```

O argumento é o nome da ISO, não o diretório de stage. O script detecta
`binary/` ou `chroot/binary/` automaticamente.

## Etapa 9 — auditoria da ISO

```sh
iso=playos-noble-xfce-calamares-amd64.iso
test -s "$iso"
sha256sum "$iso" > "$iso.sha256"
sha256sum -c "$iso.sha256"
stat -c '%n %s bytes' "$iso"

xorriso -indev "$iso" -report_el_torito as_mkisofs
xorriso -indev "$iso" -find /live -maxdepth 2 -type f

xorriso -osirrox on -indev "$iso" \
  -extract /boot/grub/grub.cfg /tmp/playos-grub.cfg

grep -E 'boot=live|/live/vmlinuz|/live/initrd' /tmp/playos-grub.cfg
! grep -E 'boot=casper|/casper/' /tmp/playos-grub.cfg
```

O relatório `-report_el_torito` deve mostrar duas entradas: BIOS e UEFI. Também
deve mostrar MBR híbrido e estrutura EFI. Uma ISO com somente
`-b /boot/grub/grub_eltorito` não passa este gate.

Extraia e confira a configuração Calamares:

```sh
audit_dir=$(mktemp -d /tmp/playos-iso-audit.XXXXXX)
xorriso -osirrox on -indev "$iso" \
  -extract /live/filesystem.squashfs "$audit_dir/filesystem.squashfs"

unsquashfs -cat "$audit_dir/filesystem.squashfs" \
  etc/calamares/settings.conf
```

Ela deve executar `unpackfs`, `initramfs` e `bootloader`, não módulos
`subiquity_*`.

## Etapa 10 — staging e preservação

Copie os resultados para um staging novo no projeto. Não sobrescreva o
artefato histórico:

```text
build/playos-graphics-core-noble/candidate-gemini/
```

Inclua ISO, SHA-256, manifesto, log e relatório. A promoção para `output/`
depende de comparação e autorização.

## Etapa 11 — relatório obrigatório do Gemini

Crie `RELATORIO_GEMINI_RESULTADO_ISO_CALAMARES_XFCE.md` com:

1. data e VM utilizadas;
2. versões das ferramentas;
3. comando completo executado;
4. PID e código de saída;
5. duração;
6. tamanho e SHA-256 da ISO;
7. caminho do manifesto e quantidade de pacotes;
8. versões de kernel, Calamares e XFCE;
9. resultado da auditoria BIOS/UEFI;
10. ausência confirmada de Casper/Subiquity/Curtin;
11. warnings e erros completos;
12. estado classificado como `built`, `static-audited`, `booted` ou
    `installed`, sem confundir essas categorias;
13. próximo gate.

Se falhar, informe o primeiro erro causal, não apenas o último erro em cascata.
Inclua as últimas 200 linhas do log e os diagnósticos de recursos.

## Critério de conclusão desta missão

A missão de build termina apenas quando a ISO candidata e sua auditoria
estática existirem. Ela não deve ser chamada funcional até:

- boot UEFI passar;
- boot BIOS passar;
- XFCE abrir;
- Calamares concluir instalação em disco virtual descartável;
- o sistema instalado reiniciar sem a mídia.

Até esses testes, use o estado `built-static-audit`, nunca “pronta”.
