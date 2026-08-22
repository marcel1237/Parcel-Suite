# Reconstrução integral da pasta `build`

- ID: `PLAYOS-BUILD-RECREATE-001`
- tipo: `procedure`
- confiança: `high` para inventário e builds já registrados; `medium` para
  reprodução em outro host antes da primeira repetição completa
- estado: `current`
- data: 2026-08-21
- fontes: relatórios de build listados ao final, patchsets versionados,
  artefatos e checksums locais

## Finalidade e regra de segurança

Este é o procedimento canônico para recriar `build/` após clone novo, limpeza
ou primeira abertura em outra máquina. `build/` é área transitória: somente
este manual é versionado; ISOs, objetos, módulos, initramfs e binários não são.

Nenhuma etapa deste documento autoriza instalar kernel, módulos, GRUB, entrada
de boot ou pacote no host. Builds usam diretórios de trabalho sem espaços e
staging isolado. Fonte FreeBSD externa é somente leitura.

## Entrada em qualquer abertura

Na raiz do projeto:

```sh
./start
```

O comando cria somente o layout vazio, mostra fontes e ferramentas ausentes,
valida a base supervisionada, executa smoke tests e confere checksums já
existentes. Comandos adicionais: `./start status`, `./start verify`,
`./start verify-full`, `./start layout` e `./start guide`. A verificação
completa relê a ISO de 6,3 GB e pode demorar.

## O que existia em `build/` na auditoria

| Diretório | Conteúdo gerado | Estado comprovado |
|---|---|---|
| `playos-7.1.8/output/` | kernel, config, System.map, initramfs e SHA256SUMS | build histórico `7.1.8-playos-freebsd-lab1`; sem boot |
| `playos-noble/output/` | mesmos quatro artefatos | build lab `6.8.4-playos-freebsd-lab1`; sem boot |
| `playos-noble-generic/output/` | mesmos quatro artefatos | build Generic `6.8.4-playos-freebsd-generic`; sem boot |
| `resolute-mvp/download/` | ISO oficial e manifestos | download/assinatura documentados |
| `resolute-mvp/gnupg/` | keyring isolado | transitório |
| `resolute-mvp/work/` | árvore ISO extraída e validações | transitório |
| `resolute-mvp/output/` | ISO de protótipo do menu | SHA-256 confirmado; sem boot QEMU |

Um build concluído não comprova boot. O build Kernel 2 iniciado posteriormente
foi interrompido e não possui resultado final; não deve ser contado como
artefato reproduzido.

## Checklist do primeiro clone

1. Ler `AGENTS.md`, `supervised_learning/README.md` e este arquivo.
2. Executar `./start status`.
3. Confirmar espaço livre: a árvore auditada ocupava aproximadamente 18 GB,
   sobretudo pela ISO extraída. Reservar margem adicional para Kbuild.
4. Restaurar separadamente as fontes ignoradas pelo Git:
   `Kernels/kernel linux-7.1.8/` e
   `Kernels/ubuntu 26 resolute kernel/`.
5. Confirmar identidade pelo `Makefile`, Git commit quando disponível e pelos
   scripts `identify-target.sh`; nome de pasta não é evidência de versão.
6. Instalar manualmente as dependências do host. Em Debian/Ubuntu, revisar:
   `build-essential bc bison flex libssl-dev libelf-dev dwarves zstd kmod
   dracut xorriso squashfs-tools grub-common gpg python3`.
7. Usar um work root sem espaços, por exemplo `/var/tmp/playos-kernel-work`.
8. Executar `./start` e resolver todos os gates relevantes antes do rebuild.

O projeto não executa `sudo apt install` automaticamente. Em distribuição
diferente, os nomes dos pacotes mudam. Para BTF e `sched_ext`, `pahole` precisa
ser compatível; o patchset atualmente exige ao menos 1.24.

## Recriar o layout vazio

```sh
./start layout
```

Isso é idempotente e não apaga arquivos existentes.

## Recriar o PlayOS Kernel 2 sobre Linux 7.1.8

Use uma fonte **limpa** Linux 7.1.8. Copie-a para um caminho sem espaços e não
aplique o patchset duas vezes:

```sh
mkdir -p /var/tmp/playos-kernel-work/kernel2
cp -a 'Kernels/kernel linux-7.1.8/.' /var/tmp/playos-kernel-work/kernel2/source/
patch-Noble-PlayOS-Kernel-7.1.8/scripts/check-series.sh /var/tmp/playos-kernel-work/kernel2/source
patch-Noble-PlayOS-Kernel-7.1.8/scripts/apply-series.sh --apply /var/tmp/playos-kernel-work/kernel2/source
patch-Noble-PlayOS-Kernel-7.1.8/scripts/prepare-config.sh /var/tmp/playos-kernel-work/kernel2/source /var/tmp/playos-kernel-work/kernel2/out
make -C /var/tmp/playos-kernel-work/kernel2/source O=/var/tmp/playos-kernel-work/kernel2/out -j"$(nproc)" bzImage modules
make -C /var/tmp/playos-kernel-work/kernel2/source O=/var/tmp/playos-kernel-work/kernel2/out INSTALL_MOD_PATH=/var/tmp/playos-kernel-work/kernel2/stage modules_install
```

Obtenha a release real, gere initramfs contra o staging (nunca contra módulos
inexistentes do host), copie e assine o inventário:

```sh
release=$(make -s -C /var/tmp/playos-kernel-work/kernel2/source O=/var/tmp/playos-kernel-work/kernel2/out kernelrelease)
depmod -b /var/tmp/playos-kernel-work/kernel2/stage "$release"
dracut --force --no-hostonly --kmoddir "/var/tmp/playos-kernel-work/kernel2/stage/lib/modules/$release" "/var/tmp/playos-kernel-work/kernel2/initramfs-$release.img" "$release"
mkdir -p build/playos-7.1.8/output
cp /var/tmp/playos-kernel-work/kernel2/out/arch/x86/boot/bzImage "build/playos-7.1.8/output/vmlinuz-$release"
cp /var/tmp/playos-kernel-work/kernel2/out/.config "build/playos-7.1.8/output/config-$release"
cp /var/tmp/playos-kernel-work/kernel2/out/System.map "build/playos-7.1.8/output/System.map-$release"
cp "/var/tmp/playos-kernel-work/kernel2/initramfs-$release.img" build/playos-7.1.8/output/
(cd build/playos-7.1.8/output && sha256sum "vmlinuz-$release" "config-$release" "System.map-$release" "initramfs-$release.img" > SHA256SUMS)
```

Se a versão local do `dracut` não aceitar `--kmoddir`, interrompa e adapte em
staging/chroot controlado; não gere silenciosamente um initramfs do kernel host.

## Recriar Noble 6.8.4 lab e Generic

Esses artefatos são históricos e pertencem ao patchset
`patch-FreeBSD-Noble/`. A árvore Noble precisa estar no commit
`74134bfb6b720ca18a73931662cbcc8170ef1bed`. Como essa integração contém
mudanças mantidas na própria árvore ignorada e não há uma série portátil única
equivalente ao Kernel 2, a reprodução limpa ainda não é de um comando só.

Procedimento auditável:

1. restaurar a fonte Noble 6.8.4 no commit fixado em caminho sem espaços;
2. reaplicar somente as mudanças descritas em `patch-FreeBSD-Noble/MANIFEST.md`
   e confirmar o diff contra os relatórios;
3. formar `.config` com `config/playos-production.config`; para lab, também
   fundir `config/playos-lab.config`, sempre seguido de `olddefconfig`;
4. executar `make ... bzImage modules`, `modules_install` em staging, `depmod`
   e `dracut --no-hostonly` contra esse staging;
5. copiar os quatro artefatos para `build/playos-noble/output/` (lab) ou
   `build/playos-noble-generic/output/` (Generic) e gerar `SHA256SUMS`;
6. comparar configuração, release e hashes com os relatórios de 18/08/2026.

**Gate pendente:** antes de apagar a fonte Noble ignorada, exportar suas
mudanças numa série completa e validá-la sobre checkout limpo. Até lá, os
relatórios reproduzem o método, mas não garantem reconstrução bit a bit.

## Recriar a ISO protótipo do menu

Primeiro restaure a ISO oficial Resolute validada em
`build/resolute-mvp/download/` e repita SHA-256 e GPG conforme
`BUILD_RESOLUTE_MVP.md`. Depois:

```sh
xorriso -osirrox on -indev build/resolute-mvp/download/resolute-desktop-amd64.iso -extract / build/resolute-mvp/work/iso-tree
scripts/prepare-grub-11-kernels.sh build/resolute-mvp/work/iso-tree
mkdir -p build/resolute-mvp/output
xorriso -indev build/resolute-mvp/download/resolute-desktop-amd64.iso -outdev build/resolute-mvp/output/parcel-play-11-menu-prototype-amd64.iso -map build/resolute-mvp/work/iso-tree / -boot_image any replay
sha256sum build/resolute-mvp/output/parcel-play-11-menu-prototype-amd64.iso
```

Hash histórico esperado do protótipo: `44a1ca2c3c239b0b87747c8372daee7d50c1a8d043644a1a5b0666516b95ec5d`.
Se o hash divergir, registre ferramenta, ISO de entrada, timestamp e diff da
árvore; reprodutibilidade byte a byte de ISO também pode variar por metadados.
Não substitua `-boot_image any replay`: ele preserva a estrutura híbrida
BIOS/UEFI. Valide os dois GRUBs com `grub-script-check` e teste em QEMU/OVMF.

## Validação final obrigatória

```sh
./start verify
git diff --check
```

Para kernels, ainda são necessários boot em QEMU, rollback, selftests e depois
hardware controlado. Para a ISO, boot BIOS e UEFI, Live e instalador. Nada nesta
pasta está autorizado para produção apenas por possuir hash válido.

## Fontes canônicas locais

- `BUILD_RESOLUTE_MVP.md`
- `LIVE_ISO_11_KERNELS.md`
- `patch-FreeBSD-Noble/results/BUILD_6.8.4_PLAYOS_FREEBSD_LAB1_2026-08-18.md`
- `patch-FreeBSD-Noble/results/BUILD_GENERIC_PROD_6.8.4_2026-08-18.md`
- `patch-FreeBSD-Kernel-7.1.8/results/BUILD_PLAYOS_7.1.8_2026-08-18.md`
- `patch-Noble-PlayOS-Kernel-7.1.8/README.md`
- `patch-Noble-PlayOS-Kernel-7.1.8/MANIFEST.md`
