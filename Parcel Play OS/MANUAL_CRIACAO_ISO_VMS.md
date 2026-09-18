# Manual de Criação de ISOs PlayOS via Máquinas Virtuais (LXD)

Este manual descreve o procedimento técnico completo para a geração de imagens ISO do PlayOS, utilizando o pipeline isolado em Máquinas Virtuais para garantir a integridade e reprodutibilidade do sistema.

---

## 1. Visão Geral da Estratégia
Para mitigar conflitos de permissões no host e garantir um ambiente de compilação 100% limpo, adotamos o modelo **"Build-Inside-VM"**. O processo de construção não ocorre no sistema principal (host), mas sim dentro de uma instância isolada do Ubuntu Noble (24.04) gerenciada pelo LXD.

### Vantagens:
- **Root Nativo**: Evita erros de `Permission denied` ao criar dispositivos como `/dev/null` e `/dev/loop`.
- **Isolamento de Pacotes**: Impede que o `livecd-rootfs` do host interfira no `live-build` do projeto.
- **Resiliência**: O build sobrevive a quedas de conexão ou travamentos da IDE/Android Studio.

---

## 2. Pré-requisitos (Host)
Antes de iniciar, certifique-se de que o host (Lenovo V14) está preparado:
- **Swap**: Mínimo de 10GB recomendados (`/swap.img` e `/swapfile`).
- **LXD**: Deve estar inicializado e com suporte a VMs (`sudo lxd init`).
- **Espaço**: Pelo menos 30GB livres na partição de armazenamento do LXD.

---

## 3. Passo a Passo do Build

### Passo 1: Provisionamento da VM
Crie uma nova instância dedicada ao build da ISO:
```bash
lxc launch images:ubuntu/noble --vm livefs-builder-noble -c limits.memory=4GiB
```
*Nota: Limitamos a 4GB para manter a estabilidade do host durante a compressão do SquashFS.*

### Passo 2: Preparação do Perfil (No Host)
Antes de enviar os arquivos para a VM, o perfil deve ser preparado para o **Pure Pipeline** (sem Casper/Subiquity):
```bash
cd "/home/marcel/Parcel-Suite/Parcel Suite/Parcel Play OS"
profile_work=$(mktemp -d /tmp/playos-build.XXXXXX)
./live-build/playos-graphics-core-noble/tools/prepare-first-calamares-profile.sh "$profile_work"
```

### Passo 3: Sincronização Host → VM
Envie o código-fonte e o perfil preparado para o diretório root da VM:
```bash
lxc file push -r "$profile_work" livefs-builder-noble/root/build-area/
lxc file push -r "./live-build" livefs-builder-noble/root/source-code/
```

### Passo 4: Instalação do Toolchain (Na VM)
Instale as dependências de build necessárias dentro do ambiente isolado:
```bash
lxc exec livefs-builder-noble -- apt-get update
lxc exec livefs-builder-noble -- apt-get install -y live-build debootstrap squashfs-tools xorriso grub-pc-bin grub-efi-amd64-bin mtools dosfstools syslinux-utils
```

### Passo 5: Orquestração e Build
Execute a configuração e dispare o build em background (nohup). Isso garante que o build continue mesmo se a conexão cair.
```bash
lxc exec livefs-builder-noble -- bash -c "
  cd /root/build-area/profile
  lb config
  nohup lb build > /root/build-area/build.log 2>&1 &
  echo \$! > /root/build-area/build.pid
"
```

### Passo 6: Monitoramento
Acompanhe o progresso lendo o log em tempo real dentro da VM:
```bash
lxc exec livefs-builder-noble -- tail -f /root/build-area/build.log
```

---

## 4. Auditoria da ISO Gerada
Após o término do build (verificado pela ausência do PID ou presença da ISO), realize os seguintes testes de integridade:

1.  **Presença de Estrutura /live**:
    ```bash
    xorriso -indev pasta_da_iso/binary.hybrid.iso -find /live -maxdepth 2
    ```
2.  **Verificação do GRUB**:
    Extraia o `/boot/grub/grub.cfg` e confirme se a linha de boot utiliza `boot=live`.
3.  **Hibridização**:
    Certifique-se de que o comando `isohybrid` foi executado para compatibilidade com USB.

---

## 5. Coleta de Resultados
Traga a ISO e os logs para o host para distribuição:
```bash
lxc file pull livefs-builder-noble/root/build-area/profile/chroot/binary.hybrid.iso ./candidate-gemini/playos-noble.iso
lxc file pull livefs-builder-noble/root/build-area/build.log ./candidate-gemini/build.log
```

---

## 6. Solução de Problemas Comuns
- **Erro de Assinatura GPG**: Geralmente causado por falta de permissão no `/dev/null` dentro do chroot. Solução: Rodar estritamente dentro da VM LXD como root.
- **SIGHUP 129**: Ocorre quando o terminal do Android Studio perde a conexão com o LXD devido à carga do sistema. Solução: Usar `nohup` conforme descrito no Passo 5.
- **isohybrid not found**: Falha ao gerar ISO que dá boot por USB. Solução: Instalar o pacote `syslinux-utils` na VM antes do build.
