# Auditoria do kernel local para a Live Resolute + XFCE

- ID: `PLAYOS-KERNEL-LOCAL-LIVE-001`
- tipo: `audit`
- estado: fonte identificada; build e boot pendentes
- confiança: alta
- data: 2026-08-26
- relatório-base: `LIVE_CD_RESOLUTE_XFCE_MINIMAL_KNOPPIX.md`

## Veredito

A fonte escolhida em:

```text
/home/marcel/Parcel-Suite/Linux Kernels/ubuntu 26 resolute kernel
```

pode ser empacotada e usada em uma Live ISO com userland Ubuntu Resolute e
XFCE 4.20. Ela, porém, não contém o kernel oficial Resolute: é Ubuntu Noble
`6.8.0-30.30`, baseado em Linux 6.8.4. O produto deve ser descrito como
**Resolute userspace + kernel PlayOS/Noble 6.8**.

## Evidência de identidade

| Evidência local | Resultado | Classificação |
|---|---|---|
| `Makefile` | `VERSION=6`, `PATCHLEVEL=8`, `SUBLEVEL=4` | `fact` |
| `debian.master/changelog` | `linux (6.8.0-30.30) noble` | `fact` |
| commit | `74134bfb6b720ca18a73931662cbcc8170ef1bed` | `fact` |
| data do commit | 2024-04-09 | `fact` |
| checkout | raso, um commit, árvore limpa | `fact` |
| artefatos | nenhum `.deb`, `bzImage`, `vmlinux` ou `modules.order` | `fact` |

O remoto Git tem o nome `resolute`, mas a URL e o nome do diretório não
substituem a identidade do código. O arquivo `Ubuntu.md` também está obsoleto e
menciona Lunar 6.1; `Makefile` e changelog são as evidências dominantes.

O arquivo oficial Resolute disponibiliza atualmente `linux-generic
7.0.0-30.30` em amd64. Portanto, a diferença não é apenas nominal.

## Integridade da fonte observada

```text
Git tree: 790e6f48a08d27d2d0e0c2e83181407aa3f3f6e7
Makefile SHA-256: c98e6203b8e31a375fa78975d2ff0da4755bfdedcd467083b53fde196d58c10f
changelog SHA-256: 1ad1a7daf00baf9382f7eef0616bc4d260a690a85069cc8ceda2836c5f55d71e
annotations SHA-256: 6cb775a496702cbbf929cbb42fac12cd3f5e40d246dfd64f4dee44b0c363a08d
```

## Compatibilidade com Live boot

As políticas amd64 em `debian.master/config/annotations` confirmam:

```text
CONFIG_SQUASHFS=y
CONFIG_BLK_DEV_LOOP=y
CONFIG_DEVTMPFS=y
CONFIG_EFI=y
CONFIG_EFI_STUB=y
CONFIG_TMPFS=y
CONFIG_MODULES=y
CONFIG_OVERLAY_FS=m
CONFIG_ISO9660_FS=m
CONFIG_RD_GZIP=y
CONFIG_RD_XZ=y
CONFIG_RD_ZSTD=y
```

Isso é compatível com SquashFS + OverlayFS. Como OverlayFS e ISO9660 são
módulos, o initramfs deve conter `overlay`, `isofs` e dependências. Configuração
presente não comprova compilação ou boot.

## Integração correta

Quando o kernel local for adotado, remover `linux-generic` da lista de pacotes
da Live. Caso contrário, APT também instalará o kernel oficial Resolute 7.0.

O rootfs precisa receber o conjunto produzido pela mesma compilação:

```text
linux-image-unsigned-6.8.0-30-generic
linux-modules-6.8.0-30-generic
linux-modules-extra-6.8.0-30-generic, se produzido
linux-headers-6.8.0-30-generic, opcional na mídia
```

Os nomes finais devem ser confirmados nos `.deb`. Não copiar apenas o
`bzImage`: `/live/vmlinuz`, `/live/initrd.img` e
`/lib/modules/6.8.0-30-generic` precisam pertencer à mesma ABI.

## Pipeline proposto

1. Preservar a fonte externa como somente leitura.
2. Criar worktree ou cópia descartável de build.
3. Acrescentar revisão PlayOS ao changelog para evitar colisão com os pacotes
   oficiais `6.8.0-30.30`.
4. Instalar as dependências declaradas no empacotamento Ubuntu.
5. Gerar a configuração `amd64/generic` a partir de `annotations`.
6. Produzir imagem, módulos, módulos extras e headers como `.deb`.
7. Colocar os pacotes num repositório APT local assinado ou em packages locais
   do `live-build`.
8. Instalar os pacotes dentro do chroot e só então gerar o initramfs.
9. Copiar vmlinuz/initrd correspondentes para `/live`.
10. Registrar checksums da fonte, `.deb`, initramfs, SquashFS e ISO.

O alvo `binary-generic` existe nessa árvore. Comando de laboratório ainda não
executado:

```bash
fakeroot debian/rules clean
fakeroot debian/rules binary-headers binary-generic skipabi=true skipmodule=true
```

`skipabi` e `skipmodule` pulam verificações Ubuntu. Um build candidato a release
deve executá-las ou justificar de modo reproduzível a ausência dos baselines.

## Secure Boot

O perfil amd64 declara `uefi_signed = true`, mas um build local não recebe a
assinatura da Canonical automaticamente.

- laboratório: Secure Boot desativado;
- release PlayOS: assinar kernel e módulos com chave PlayOS, distribuir o
  certificado e testar enrollment; ou usar kernel oficialmente assinado;
- estado atual: Secure Boot `unknown`.

## Divergência operacional

`config/kernel-sources.conf` aponta para o caminho antigo
`/home/marcel/Parcel Suite/...`, mas a fonte verificada fica em
`/home/marcel/Parcel-Suite/...`. A configuração não foi alterada nesta auditoria
e deve ser corrigida antes do build automatizado.

## Gates

1. corrigir o caminho configurado;
2. criar staging sem editar a fonte canônica;
3. gerar `.deb` e registrar manifestos;
4. inspecionar imagem, módulos e initramfs da mesma ABI;
5. iniciar console Live em QEMU;
6. adicionar XFCE 4.20/LightDM;
7. testar BIOS, UEFI e hardware;
8. decidir antes de release se permanece no Noble 6.8 customizado ou migra para
   a fonte Resolute 7.0 correta.

## Fontes

- fonte local auditada, commit e arquivos identificados acima;
- [Ubuntu Resolute — linux-generic](https://packages.ubuntu.com/search?keywords=linux-generic&suite=resolute);
- [Ubuntu Resolute — linux-image-generic](https://packages.ubuntu.com/resolute-updates/amd64/linux-image-generic).
