# Relatório de Build: PlayOS Noble XFCE (Pure Pipeline)

**Assunto:** Recuperação da Primeira ISO Calamares via Pure Live-Build
**Estado Atual:** Executando `lb build` nativo em VM LXD Noble.

---

## 1. Diagnóstico do Erro Anterior
As tentativas iniciais falharam devido à mistura de dois ecossistemas de construção incompatíveis:
- **Erro:** Uso do motor `livecd-rootfs` (Ubuntu-style) com `casper` e `germinate`.
- **Consequência:** Conflitos de diversão de binários (`dpkg-divert`), erro de montagem da mídia no boot e falha de permissão no `/dev/null`.
- **Causa Raiz:** A ISO original PlayOS utilizava o pipeline **Debian-style** (`live-build` puro + `live-boot`).

## 2. Mudança de Rota (Implementada)
Seguindo a análise da auditoria, abandonamos os scripts da Canonical e adotamos o pipeline histórico:
- **Motor:** `live-build` (3.0~a57).
- **Initramfs:** `live-boot` (não usamos `casper`).
- **Estrutura de Diretórios:** `/live` (vmlinuz, initrd, squashfs).
- **Parâmetros de Kernel:** `boot=live components ...`

## 3. Estado Técnico Atual
O build foi disparado dentro do container LXD `livefs-builder-noble` para garantir privilégios de root e acesso total aos dispositivos de sistema.

- **Diretório de Trabalho (na VM):** `/root/build-pure/profile`
- **Script Preparador Usado:** `prepare-first-calamares-profile.sh`
- **Configuração de Boot:**
  - Aplicação: PlayOS Graphics Core
  - Volume ID: PLAYOS_NOBLE_GC
  - Bootloader: GRUB2
- **Logs de Progresso:** Monitorando via `/root/build-pure/build.log`.

## 4. Impedimentos Ambientais (Alerta)
- **Host Load:** O sistema host apresenta carga > 40.0.
- **IO Wait:** Alta latência de disco, atrasando a descompactação dos 1.110 pacotes.
- **Estratégia de Resiliência:** O comando está sendo executado via `nohup` em background na VM para sobreviver a desconexões do terminal ou travamentos do Android Studio.

## 5. Solicitação para Codex
Com base no pipeline de **pure live-build**, valide os seguintes pontos:
1.  **Geração do Manifesto:** O `live-build` no Noble gera o `filesystem.manifest` corretamente sem a necessidade de hooks extras de manifesto?
2.  **Calamares Nativo:** Há alguma restrição conhecida no Noble que impeça o Calamares de usar o `unpackfs` do `live-boot` (em vez do `casper`)?
3.  **Grub Finalization:** Caso o build pare antes de gerar a ISO híbrida, o script `tools/finalize-grub-iso.sh` deve ser invocado apontando para qual diretório de stage?

---
**Status da VM (Última Checagem):** `debootstrap` concluído, iniciando fase de `chroot` e instalação da lista PlayOS.

---

## 6. Resposta e auditoria Codex — 2026-08-30

### Estado real encontrado

O relatório estava correto sobre a escolha do pipeline, porém seu estado ficou
desatualizado. Na inspeção da VM `livefs-builder-noble`:

- não havia processo `lb build`, debootstrap, mksquashfs ou grub-mkrescue;
- `/root/build-pure/build.log` terminou em `Terminated` durante a
  descompactação do pacote 421;
- o live-build desmontou filesystems e salvou caches após o sinal;
- não existiam ISO, SquashFS, manifesto ou árvore `binary/` final;
- Calamares já estava presente, mas `live-boot`, `live-config` e `live-tools`
  ainda não tinham sido instalados;
- não houve evento OOM registrado no kernel da VM; a origem exata do sinal que
  encerrou o processo permanece `unknown`.

Esse chroot não deve ser promovido nem finalizado. Para um resultado
reproduzível, execute `lb clean --purge` e reinicie o build puro.

### 1. Manifesto

O `live-build 3.0~a57-1ubuntu49.1` gera o inventário sem hook adicional. O
próprio `/usr/lib/live/build/lb_binary_manifest` seleciona:

```text
casper    -> /casper/filesystem.manifest
live-boot -> /live/filesystem.packages
```

Portanto, nesta ISO o arquivo correto é `/live/filesystem.packages`, acompanhado
de `/live/filesystem.packages-remove`. Exigir `filesystem.manifest` misturaria
novamente a convenção Casper.

### 2. Calamares `unpackfs`

O pacote Noble `calamares 3.3.5-0ubuntu4` contém o módulo nativo em:

```text
/usr/lib/x86_64-linux-gnu/calamares/modules/unpackfs/
```

O módulo não depende conceitualmente de Casper; ele extrai o filesystem
definido em `unpackfs.conf`. Para a primeira ISO, a origem obrigatória é:

```text
/run/live/medium/live/filesystem.squashfs
```

A presença do módulo e uma configuração válida não comprovam instalação. O
caminho montado deve ser verificado durante boot real, e Calamares ainda precisa
ser testado com `calamares -d` em disco virtual descartável.

### 3. Finalização GRUB

Execute `tools/finalize-grub-iso.sh` a partir da raiz do perfil. O script
detecta, nesta ordem:

```text
binary/
chroot/binary/
```

Não se passa o diretório de stage como argumento. O primeiro argumento é apenas
o nome/caminho da ISO de saída:

```sh
cd /root/build-pure/profile
sudo ./tools/finalize-grub-iso.sh \
  playos-noble-xfce-calamares-amd64.iso
```

O finalizador só deve ser usado quando uma dessas árvores binárias estiver
completa e contiver `/live/filesystem.squashfs`, kernel, initrd e configuração
GRUB. No estado auditado nenhuma delas existia, logo o script não se aplica.

### Próxima execução segura

```sh
cd /root/build-pure/profile
sudo lb clean --purge
sudo lb config
sudo lb build 2>&1 | tee /root/build-pure/build.log
```

`nohup` pode proteger contra fechamento do terminal, mas não contra sinal
externo, falta de memória ou travamento de I/O. Se usado, registre PID e código
de saída separadamente; ausência do processo nunca deve ser descrita como build
em execução.
