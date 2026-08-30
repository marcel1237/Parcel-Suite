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
