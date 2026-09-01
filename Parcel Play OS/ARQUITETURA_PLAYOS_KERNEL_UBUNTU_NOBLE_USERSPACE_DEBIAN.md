# PlayOS: kernel Ubuntu Noble sobre sistema e Live Debian

## Estado

- **ID:** `PLAYOS-NOBLE-KERNEL-DEBIAN-USERSPACE-001`
- **Tipo:** `decision` e `implementation-plan`
- **Confiança:** alta para a separação arquitetural; runtime ainda não testado
- **Estado:** aprovado como nova direção, ainda não implementado
- **Data:** 2026-08-31
- **Fontes locais:** `AGENTS.md`, catálogos supervisionados e resultados dos
  builds Live anteriores

## Decisão

O PlayOS passa a usar uma fronteira simples:

```text
kernel e módulos: Ubuntu Noble
userspace: Debian
repositórios de aplicações: Debian
initramfs, bootloader e firmware: Debian
construção da Live: live-build em modo Debian
```

Não será mantida uma distribuição Ubuntu completa. O único componente Ubuntu
pretendido é o kernel Noble e o conjunto inseparável de módulos correspondente
à mesma versão/ABI. X11, Wayland, Mesa, áudio, rede, desktop, instalador e
demais componentes permanecem no userspace Debian.

## Correção técnica importante

O kernel não contém a Live CD nem os servidores gráficos. O kernel Ubuntu pode
inicializar um userspace Debian porque preserva a ABI Linux de userspace, mas
isso precisa ser comprovado para cada artefato. Compatibilidade provável não é
resultado de runtime.

Não se deve habilitar repositórios Ubuntu e Debian simultaneamente no sistema.
Essa mistura permitiria ao APT resolver bibliotecas e utilitários de releases
diferentes, criando upgrades não determinísticos. O kernel Noble deve entrar
como artefato local isolado, com versão, origem, licença e SHA-256 registrados.

## Baseline ainda a fixar

O nome “kernel Noble” não basta para reprodução. Antes do primeiro build devem
ser registrados:

1. versão upstream e ABI completa mostrada pelo pacote;
2. nomes exatos de imagem e módulos;
3. origem dos arquivos `.deb` ou do build local;
4. checksums SHA-256;
5. configuração do kernel;
6. firmware e microcode exigidos;
7. política de assinatura e Secure Boot.

O projeto possui referência histórica a Noble Linux 6.8.4, mas o artefato
escolhido deve ser confirmado pelo conteúdo, não pelo nome da pasta.

## Modelo de empacotamento recomendado

O kernel e seus módulos devem ser importados para um repositório APT local do
PlayOS ou reempacotados de forma rastreável como:

```text
playos-kernel-noble-image
playos-kernel-noble-modules
playos-kernel-noble-headers        # somente para desenvolvimento/DKMS
playos-kernel-noble-meta
```

O reempacotamento não altera silenciosamente os binários. Ele declara origem,
licenças, dependências Debian compatíveis e conflito com kernels incompatíveis.
Uma alternativa inicial é instalar os `.deb` Ubuntu em chroot somente após
auditar suas dependências com `dpkg-deb -I`; não usar `apt` contra um mirror
Ubuntu durante o build Debian.

## Pipeline Live Debian

O novo perfil deve usar `live-build` nativo em modo Debian:

```text
receita versionada
  -> lb config --mode debian --distribution <suite-fixada>
  -> bootstrap Debian
  -> pacotes e configuração Debian
  -> importação do kernel Noble local
  -> initramfs-tools Debian
  -> live-boot + live-config
  -> SquashFS
  -> GRUB/ISO híbrida BIOS e UEFI
  -> manifesto, checksums e SBOM
```

A suite Debian permanece `unknown` até decisão explícita. Ela não deve seguir
automaticamente `stable`, pois esse alias muda com o tempo. O codinome e um
snapshot/repositório datado devem ser fixados para reprodução.

## Fontes por componente

| Componente | Fonte permitida |
|---|---|
| kernel, módulos inseparáveis e config | Ubuntu Noble, artefato local fixado |
| base filesystem e libc | Debian |
| systemd, udev e initramfs-tools | Debian |
| live-boot, live-config e live-build | Debian |
| GRUB, shim e ferramentas ISO | Debian |
| firmware e microcode | Debian, salvo exceção documentada |
| Mesa, Vulkan, Xorg e Wayland | Debian |
| PipeWire, rede e serviços | Debian |
| desktops e aplicações | Debian |
| instalador futuro | Debian ou pacote PlayOS auditado |

## Staging e limpeza

As receitas permanentes ficam dentro do repositório. Chroots, caches e árvores
binárias ficam em staging sem espaços fora dele. Em 2026-08-31 foram marcados
para remoção os seguintes stagings antigos:

```text
/home/marcel/playos-graphics-core-noble-gnome
/home/marcel/playos-graphics-core-noble-no-desktop
/home/marcel/build-playos-fix
/home/marcel/playos-noble-xfce-live-only
/home/marcel/live-build
```

Antes de apagar um staging é obrigatório verificar processos e mounts. Nesta
auditoria, o primeiro caminho ainda tinha `devpts`, `proc` e `sysfs` montados;
eles precisam ser desmontados antes da exclusão. As receitas versionadas em
`live-build/` dentro do projeto não fazem parte dessa remoção.

## Gates

1. escolher codinome e snapshot Debian;
2. identificar e verificar o kernel Noble exato;
3. auditar dependências dos pacotes do kernel;
4. construir repositório local e metapacote;
5. criar perfil Debian Live mínimo sem desktop;
6. construir ISO com código de saída zero;
7. verificar manifesto: somente kernel/módulos Ubuntu autorizados;
8. testar BIOS e UEFI em VM;
9. testar initramfs, módulos, firmware, rede, armazenamento e desligamento;
10. testar hardware e política de atualizações/rollback.

Até esses gates, o estado correto é `decision`, não “sistema pronto”.
