# Infraestrutura de Máquinas Virtuais (VMs) e Containers

Este documento descreve como o projeto PlayOS utiliza virtualização para garantir builds limpos, isolados e reproduzíveis, mitigando conflitos de dependências do host.

---

## 1. Orquestração: LXD / LXC
O projeto utiliza o **LXD** como camada de orquestração. Ele permite alternar entre **Containers** (mais leves, para tarefas de compilação de pacotes) e **VMs** (Máquinas Virtuais completas, necessárias para o `live-build` e manipulação de kernel/bootloader).

### Instâncias Principais:
| Nome | Tipo | Propósito | Suite Alvo |
| :--- | :--- | :--- | :--- |
| `livefs-builder-noble` | VM | Build de ISOs (Pure Pipeline) | Ubuntu 24.04 (Noble) |
| `playos-noble-graphics-builder` | Container | Compilação de componentes gráficos | Ubuntu 24.04 (Noble) |
| `playos-ubuntu-noble-kde-builder-vm` | VM | Experimentos com KDE/Plasma | Ubuntu 24.04 (Noble) |

---

## 2. Metodologia de Build "Pure Inside"
Para evitar erros de permissão (ex: `/dev/null: Permission denied`) e conflitos de ferramentas (`livecd-rootfs` vs `live-build`), adotamos a estratégia de rodar o pipeline **inteiramente dentro da VM**.

### Fluxo de Trabalho:
1.  **Host**: Prepara o perfil básico (scripts, listas de pacotes, configurações de branding).
2.  **Sincronização**: O perfil é enviado para a VM via `lxc file push`.
3.  **Instalação de Toolchain**: A VM é provisionada com:
    *   `live-build` (3.0~a57)
    *   `debootstrap`
    *   `xorriso`, `squashfs-tools`
    *   `grub-pc-bin`, `grub-efi-amd64-bin`
4.  **Execução Nativa**: O comando `lb build` roda como root nativo dentro da VM, com acesso total a loops e dispositivos `/dev`.

---

## 3. Estratégia de Resiliência (Background Execution)
Dada a carga elevada do host (Load Average > 20), builds interativos no terminal são propensos a quedas (`SIGHUP 129`). Implementamos um sistema de rastreamento persistente:

*   **Comando**: `sudo nohup lb build > build.log 2>&1 &`
*   **Rastreamento**:
    *   `build.pid`: Armazena o PID do processo para monitoramento via `kill -0`.
    *   `build.exit-status`: Criado apenas após a conclusão (sucesso ou falha).
    *   `nohup.out`: Captura mensagens de erro do orquestrador bash.

---

## 4. Gestão de Recursos (Host Lenovo V14 G4)
*   **RAM**: Atribuição recomendada de **4 GiB** para VMs Noble para evitar swapping excessivo no host.
*   **Swap**: O host utiliza arquivos de swap expandidos (`/swap.img` e `/swapfile`) para absorver picos de uso durante a geração do SquashFS.
*   **I/O**: O gargalo identificado é o disco (I/O Wait). Builds devem ser disparados sequencialmente, nunca em paralelo na mesma VM.

---

## 5. Comandos Úteis de Manutenção
### Limpeza de Trava (Dentro da VM):
```bash
lxc exec livefs-builder-noble -- rm -f /var/lib/dpkg/lock-frontend
lxc exec livefs-builder-noble -- rm -f /var/lib/apt/lists/lock
```

### Sincronização de Artefatos:
```bash
# Puxar a ISO gerada para o host
lxc file pull livefs-builder-noble/root/build-pure/profile/chroot/binary.hybrid.iso ./ISO_CANDIDATA.iso
```

---

## 6. Próximos Passos na Infraestrutura
*   **Integração do isohybrid**: Garantir que o pacote `syslinux-utils` esteja sempre presente nas VMs para evitar ISOs que não dão boot por falta de MBR híbrido.
*   **Snapshots**: Implementar snapshots LXD após a fase de `lb bootstrap` para acelerar tentativas de rebuild.
