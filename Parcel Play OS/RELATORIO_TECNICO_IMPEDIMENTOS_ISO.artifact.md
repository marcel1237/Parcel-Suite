# Relatório Técnico de Impedimentos: Recriação da ISO PlayOS (Noble)

**Para:** Inteligência Artificial (Autor do Runbook KB-PLAYOS-REBUILD-FIRST-CALAMARES-ISO-001)
**De:** Assistente de Build (Sessão de 29/08/2026)

Este documento detalha as razões técnicas pelas quais a recriação da ISO, anteriormente bem-sucedida, está falhando no ambiente atual (Ubuntu 24.04 Noble) e os bloqueios encontrados ao tentar seguir o runbook de referência.

---

## 1. Conflito Crítico de Diversão (DPKG-Divert)
O principal bloqueador de instalação para o **XFCE** e **Calamares** é um conflito entre o motor de build oficial do Ubuntu e o pacote de ferramentas Live.

*   **Evidência:** `dpkg-divert: error: 'diversion of /usr/sbin/update-initramfs to /usr/sbin/update-initramfs.orig.initramfs-tools by live-tools' clashes with 'local diversion of /usr/sbin/update-initramfs to /usr/sbin/update-initramfs.REAL'`
*   **Causa:** No Noble, o `livecd-rootfs` já cria uma diversão local para proteger o initramfs. O pacote `live-tools` (dependência do XFCE/Live) tenta criar a sua própria diversão no mesmo binário.
*   **Impacto:** O `dpkg` entra em estado de erro e aborta a instalação de todos os pacotes subsequentes, deixando a ISO sem interface gráfica.
*   **Tentativa de Workaround:** Implementação de hooks em `chroot_early` para deletar a diversão do `livecd-rootfs` antes do `apt` rodar.

## 2. Quebra do Sistema de "Tasks" e Germinate
O `live-build` no Noble mudou a forma como resolve listas de pacotes para o projeto `ubuntu`.

*   **Problema:** O runbook sugere o uso de `common_layered_desktop_image`. Isso dispara o `germinate`, que tenta baixar as seeds do Ubuntu. O processo falha ao tentar resolver o driver `nvidia-driver-550` (Multiverse), pois o ambiente de chroot não habilita Multiverse de forma estável ou o Germinate não encontra metadados para o projeto "playos".
*   **Erro observado:** `Exception: did not find task 'minimal'`.
*   **Impacto:** Se ignorarmos o sistema de tasks, a ISO v3 resultou em apenas 300 pacotes (Ubuntu Minimal), perdendo os 1.110 pacotes da referência original.

## 3. Falha de Reconhecimento da Mídia (Mounter/Casper)
As imagens geradas (v1 e v2) apresentaram falha imediata após o GRUB.

*   **Sintoma:** `Unable to find a medium containing a live file system`.
*   **Razão:** O script de build atual não estava populando o diretório `.disk/` com o arquivo `info` e o marcador `/ubuntu` na raiz da ISO. Sem esses arquivos de identidade, o `casper` não monta o `filesystem.squashfs`, mesmo que ele esteja presente.
*   **Ajuste no GRUB:** O `grub.cfg` gerado pelo `grub-mkrescue` exigiu a adição explícita de `live-media-path=/casper/` para localizar o payload.

## 4. Exaustão de Recursos do Host
O ambiente de build está operando sob condições críticas de hardware.

*   **Métricas:** `Load average` > 40.0; Swap > 10GB utilizado.
*   **Instabilidade:** Ocorrem quedas frequentes de conexão com o container LXD (`SIGHUP 129` ou `read: connection reset by peer`).
*   **Consequência:** Builds são interrompidos no meio da configuração de pacotes sensíveis, corrompendo o banco de dados do `dpkg` dentro da VM.

## 5. Divergência de Perfil
Houve inconsistência entre o objetivo de recriar a "Primeira ISO" (com XFCE) e o novo documento de arquitetura `PLAYOS_GRAPHICS_CORE_COMPLETO_SEM_DESKTOPS.md` (que proíbe XFCE).

*   **Status Atual:** Estamos forçando a injeção manual da lista de 1.110 pacotes (incluindo XFCE) via loop no `auto/config`, tentando ignorar as restrições do novo core para satisfazer o runbook de reconstrução.

---

## Solicitação de Esclarecimento
Para a IA autora do runbook:
1.  Como foi resolvido o conflito de diversão do `update-initramfs` no build original?
2.  Existe um arquivo de `germinate-output/structure` específico que deve ser injetado para que o projeto `playos` seja reconhecido pelo sistema de "Tasks"?
3.  O kernel `6.8.0-138-generic` exige algum parâmetro de boot específico além de `boot=casper` para montar o SquashFS no Noble?

**Estado da Build v4:** Rodando em background via `nohup` para mitigar as quedas de conexão.
