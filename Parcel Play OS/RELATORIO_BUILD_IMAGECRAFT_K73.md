# Relatório de Build: Ubuntu 26 (Resolute) com Kernel 7.3-rc3 via Imagecraft

- **ID da Missão:** `PLAYOS-IMAGECRAFT-K73-001`
- **Data:** 21 de Setembro de 2026
- **Estado Técnico:** `built-intermediate` (Imagem gerada, boot pendente)
- **Método:** Imagecraft (Destructive Mode) no Host Local

---

## 1. Identidade da Imagem
- **Arquivo:** `playos-resolute-k73/disk.img`
- **Tamanho:** 13 GiB (Tamanho nominal do disco virtual)
- **Userspace:** Ubuntu 26.04.1 LTS (Resolute Raccoon)
- **Kernel Vanilla:** 7.3.0-070300rc3-generic (Mainline Ubuntu Build)

## 2. Pipeline e Estratégia
Diferente das ISOs anteriores baseadas em `live-build`, esta imagem foi criada usando o **Imagecraft**, a ferramenta moderna da Canonical.

### Diferenciais Técnicos:
- **Modo Destrutivo:** Executado diretamente no host (`--destructive-mode`) para contornar restrições de dispositivos de loop (`/dev/loop`) encontradas em containers LXD.
- **Injeção Híbrida:** O sistema base foi montado via `mmdebstrap` e o kernel 7.3 foi injetado manualmente via `dpkg -i` dentro de um ambiente `chroot` orquestrado pelo YAML.
- **Persistence (Hold):** Os pacotes do kernel foram marcados como `hold` para evitar que futuras atualizações do Ubuntu os substituam pela versão genérica estável.

## 3. Composição de Software
- **Base:** Standard Ubuntu Desktop (Metapacote `ubuntu-desktop`).
- **Instalador:** Pre-installed (A imagem já contém o sistema pronto para rodar).
- **Usuário Padrão:** `playos` (Senha: `playos`).

## 4. Passo a Passo Executado
1.  **Instalação de Ferramentas:** `imagecraft` e `multipass` instalados via Snap.
2.  **Download do Kernel:** Obtidos os binários `linux-image` e `linux-modules` da versão 7.3-rc3 diretamente dos repositórios mainline da Ubuntu.
3.  **Configuração YAML:** Criação do `imagecraft.yaml` definindo partições GPT (EFI e Rootfs).
4.  **Ajuste de Montagem:** Correção do ponto de montagem `/boot/efi` no script de build para evitar erros de finalização do GRUB.
5.  **Build Final:** Execução do comando `sudo imagecraft pack --destructive-mode`.

## 5. Próximos Passos
1.  **Validação de Boot:** Testar o arquivo `disk.img` em uma VM (VirtualBox ou QEMU) para confirmar a inicialização do Kernel 7.3.
2.  **Teste de Hardware:** Gravar a imagem em mídia física para validar drivers no Lenovo V14.
3.  **Auditoria Gráfica:** Confirmar se o GNOME abre corretamente com as novas bibliotecas do Ubuntu 26.

---
**Observação:** O uso do `--destructive-mode` exige que o sistema host seja compatível com a suite alvo (Resolute). Como o host atual já é Noble/Resolute, o build foi bem-sucedido.
