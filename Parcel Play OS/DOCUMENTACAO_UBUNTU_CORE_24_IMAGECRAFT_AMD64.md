# Documentação de Engenharia: Construção de Imagem Ubuntu Core 24 (amd64 / x86_64) via Imagecraft

## 1. Visão Geral
Este documento registra a especificação, o processo de construção e as correções de engenharia aplicadas para gerar com sucesso a imagem de disco do **Ubuntu Core 24** para máquinas x86_64 (`amd64`) utilizando a ferramenta oficial da Canonical **Imagecraft**.

---

## 2. Especificação e Estrutura da Imagem (`pc.img`)

A imagem final de **2,94 GiB (3.153.085.440 bytes)** possui rotulagem GPT e contém a estrutura oficial de 4 partições do Ubuntu Core 24:

| Partição | Tamanho | Sistema de Arquivos | Função no Ubuntu Core |
| :--- | :--- | :--- | :--- |
| `pc.img1` | 1,2 GiB | VFAT (FAT32) | `ubuntu-seed` (Gatilho de boot EFI, snaps iniciais e asserções) |
| `pc.img2` | 750 MiB | EXT4 | `ubuntu-boot` (Kernel e arquivos do gerenciador de inicialização) |
| `pc.img3` | 32 MiB | EXT4 | `ubuntu-save` (Dados de encriptação e chaves de segurança) |
| `pc.img4` | 1,0 GiB | EXT4 | `ubuntu-data` (Dados e snaps do usuário/aplicação) |

---

## 3. Arquivos de Configuração do Projeto

### 3.1. `imagecraft.yaml`
```yaml
name: core-amd64
base: bare
build-base: ubuntu@26.04
version: '0.1'
summary: A minimal Ubuntu Core image for x86_64/amd64 machines.
description: |
  A minimal, pre-installed Ubuntu Core image for x86_64 (amd64) machines. Its seed partition is
  created with the UC-prepare plugin via Imagecraft.

platforms:
  amd64:
    build-on: [amd64]
    build-for: amd64

volumes:
  pc:
    schema: gpt
    structure:
      - name: ubuntu-seed
        role: system-seed
        filesystem: vfat
        type: C12A7328-F81F-11D2-BA4B-00A0C93EC93B
        size: 1200M
      - name: ubuntu-boot
        role: system-boot
        filesystem: ext4
        type: 0FC63DAF-8483-4772-8E79-3D69D8477DE4
        size: 750M
      - name: ubuntu-save
        role: system-save
        filesystem: ext4
        type: 0FC63DAF-8483-4772-8E79-3D69D8477DE4
        size: 32M
      - name: ubuntu-data
        role: system-data
        filesystem: ext4
        type: 0FC63DAF-8483-4772-8E79-3D69D8477DE4
        size: 1G

filesystems:
  default:
    - device: (volume/pc/ubuntu-seed)
      mount: /

parts:
  seed:
    plugin: uc-prepare
    source: .
    uc-prepare-model-assert: model.assert
    uc-prepare-preseed: False
    organize:
      system-seed: (volume/pc/ubuntu-seed)
```

---

## 4. Diagnóstico e Resolução de Problemas no Build

### 4.1. Incompatibilidade de Assinatura no Modelo Asserção (`openpgp: hash tag doesn't match`)
- **Problema**: Alterar manualmente o cabeçalho de um modelo assinado (ex: `arm64` para `amd64`) invalida a assinatura OpenPGP embutida no rodapé do arquivo.
- **Solução**: Obtenção do modelo assinado oficial da Canonical para Ubuntu Core 24 x86_64 via comando `snap known --remote model series=16 brand-id=canonical model=ubuntu-core-24-amd64`.

### 4.2. Exigência de Chave Privada GPG no Preseed (`cannot use "default" key`)
- **Problema**: O plugin `uc-prepare` com `uc-prepare-preseed: True` tenta assinar asserções de preseed com uma chave privada GPG local do usuário.
- **Solução**: Configurar `uc-prepare-preseed: False`, permitindo o download e empacotamento direto dos snaps oficiais (`pc`, `pc-kernel`, `core24`, `snapd`, `console-conf`).

### 4.3. Falha de Codepage no `mcopy` do Snap (`Error converting to codepage 850`)
- **Problema**: O binário `mcopy` (mtools) contido dentro do snap `/snap/imagecraft/current/libexec/imagecraft/mcopy` falhava na conversão da tabela de caracteres CP850 ao formatar a partição VFAT.
- **Solução**: Mapeamento do binário `mcopy` nativo do host sobre o binário do snap usando bind mount:
  ```sh
  sudo mount --bind /usr/bin/mcopy /snap/imagecraft/current/libexec/imagecraft/mcopy
  ```

### 4.4. Execução em Caminho sem Espaços
- **Problema**: Scripts bash internos do `imagecraft` falham se o caminho absoluto do projeto contiver espaços (`/home/marcel/Parcel Suite/...`).
- **Solução**: Execução no caminho limpo `/home/marcel/imagecraft-core-amd64/`.

---

## 5. Procedimento de Compilação
```sh
# 1. Preparar o diretório sem espaços
sudo rm -rf /home/marcel/imagecraft-core-amd64
mkdir -p /home/marcel/imagecraft-core-amd64
rsync -a "imagecraft/core-amd64/" /home/marcel/imagecraft-core-amd64/

# 2. Aplicar o bind mount do mcopy se necessário
sudo mount --bind /usr/bin/mcopy /snap/imagecraft/current/libexec/imagecraft/mcopy

# 3. Gerar a imagem
cd /home/marcel/imagecraft-core-amd64
sudo imagecraft pack --destructive-mode --ignore
```

---

## 6. Validação do Artefato
O arquivo final `pc.img` (2,94 GiB) pode ser testado diretamente no QEMU/KVM:
```sh
qemu-system-x86_64 -m 2048 -smp 2 -drive file=/home/marcel/imagecraft-core-amd64/pc.img,format=raw
```
