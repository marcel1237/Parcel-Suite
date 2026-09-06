# Execução do build da Live Debian Trixie XFCE com kernel Noble

## Registro

- ID: `PLAYOS-LIVE-DEBIAN-XFCE-NOBLE-RUN-001`
- Tipo: `result` e `execution-report`
- Estado: build e ISO concluídos; checksum, estrutura de boot e boot parcial
  em VM validados; desktop visual pendente
- Confiança: alta para comandos e resultados registrados
- Data: 2026-09-03
- Builder: `playos-debian-trixie-builder-vm`
- Serviço: `playos-debian-live-build.service`
- Perfil: `live-build/playos-debian-trixie-xfce-noble-kernel/`
- Fonte operacional: log interno da VM em
  `/root/playos-debian-trixie-xfce-noble-kernel/build.log`

## Objetivo desta execução

Construir uma ISO Live híbrida amd64 com:

- userspace Debian 13 Trixie;
- pipeline Debian `live-build`, `live-boot` e `live-config`;
- raiz comprimida SquashFS e escrita temporária por OverlayFS;
- XFCE, Xorg e LightDM vindos do Debian;
- kernel, módulos e módulos-extra Ubuntu Noble `6.8.0-138-generic` locais;
- nenhum Calamares, Anaconda, Subiquity, Curtin ou Casper;
- nenhum metapacote de kernel Debian.

O modelo é inspirado na arquitetura Live do Knoppix, mas não usa `cloop`,
AUFS, patches ou scripts Knoppix. A implementação é feita com mecanismos
Debian atuais.

## Estado anterior e preparação do perfil

O perfil versionado já continha:

- `auto/config` em modo Debian Trixie;
- lista operacional com 67 pacotes diretos;
- hooks de ativação do desktop e auditoria de instaladores;
- ferramentas de importação, preflight e build;
- três pacotes `.deb` oficiais do kernel Noble;
- manifesto SHA-256 dos três pacotes;
- referência histórica derivada do manifesto da primeira Live XFCE/Calamares.

O manifesto histórico original contém 1.110 entradas. A cópia de referência
contém 1.109 e remove literalmente apenas `calamares 3.3.5-0ubuntu4`. Ela não é
usada como entrada APT: o Debian recalcula as dependências a partir da receita
operacional, eliminando as dependências exclusivas do instalador sem remover
por engano bibliotecas compartilhadas.

## Primeira tentativa: contêiner Debian

Foi criado o contêiner LXD `playos-debian-trixie-builder` e instalado nele o
`live-build` atual do Debian. O perfil e os três pacotes Noble foram copiados;
o preflight passou.

O build avançou até:

- criação da raiz Debian;
- instalação de XFCE, LightDM, firmware e serviços;
- instalação do kernel e módulos Noble;
- geração de `/boot/initrd.img-6.8.0-138-generic` com `live-boot`.

A execução falhou durante `dictionaries-common`/Aspell. A auditoria encontrou
que `/dev/null` dentro do chroot era um arquivo comum, não um device node. Um
redirecionamento gravou `/usr/bin/aspell` nesse arquivo, que depois foi
interpretado como configuração inválida.

Classificação do resultado:

- `result`: kernel e initramfs puderam ser instalados no userspace Debian;
- `result`: nenhuma ISO foi produzida;
- `inference`: a falha pertence ao ambiente de contêiner, não demonstra
  incompatibilidade de runtime entre o kernel Noble e o Debian;
- `decision`: não tornar o contêiner persistentemente privilegiado;
- `unknown`: boot e funcionamento do kernel na Live.

## Migração segura para uma VM Debian

Foi escolhida uma máquina virtual completa para fornecer device nodes reais e
isolar o build. A configuração solicitada foi:

```text
nome: playos-debian-trixie-builder-vm
tipo: virtual-machine
vCPU: 4
memória: 3 GiB
disco raiz: 12 GiB
imagem: Debian 13 Trixie amd64
```

O download inicial pareceu parar quando a sessão cliente terminou, mas a
operação LXD continuou no servidor. Ao retomar o trabalho, o cliente `lxc`
falhou porque o Snap não conseguia usar os perfis AppArmor. O usuário ativou:

```sh
sudo systemctl enable --now snapd.apparmor.service
sudo systemctl restart snapd.service
```

O serviço foi confirmado como `active (exited)`. Dentro do isolamento da tarefa
Codex, o Snap ainda não conseguia observar o AppArmor; por isso os comandos
`lxc` seguintes foram executados fora desse isolamento, sempre sem `sudo` no
host e mediante autorização.

## Recuperação do download LXD

Foram encontradas duas operações para o mesmo nome de VM:

- a operação original continha o download real, inicialmente observado em 74%;
- a segunda operação não tinha progresso e aguardava o recurso com o mesmo nome.

A operação original foi preservada e avançou para 75% e 77%, a cerca de
89–90 kB/s. Nenhum segundo download útil foi mantido. A operação original
terminou e a VM ficou disponível.

## Estado confirmado da VM

Após a criação:

```text
Sistema: Debian GNU/Linux 13.6 (trixie)
Arquitetura: x86_64
IPv4 observado: 10.131.47.203
Disco raiz: 12 GiB
Espaço livre antes do build: aproximadamente 11 GiB
```

## Ferramentas instaladas dentro da VM

Os índices APT Trixie foram atualizados e estes pacotes de construção foram
solicitados:

```text
live-build
debootstrap
squashfs-tools
xorriso
grub-pc-bin
grub-efi-amd64-bin
dosfstools
mtools
isolinux
syslinux-common
syslinux-utils
rsync
```

O APT instalou `live-build 1:20250505+deb13u1` e suas dependências. A instalação
terminou sem erro.

## Transferência do perfil

A primeira cópia com caminho relativo falhou porque o confinamento Snap
resolveu o caminho a partir de `/home/marcel`. Nenhuma mudança parcial relevante
foi usada. A cópia foi repetida com caminho absoluto e concluída:

```text
/home/marcel/Parcel-Suite/Parcel Suite/Parcel Play OS/
  live-build/playos-debian-trixie-xfce-noble-kernel
    -> /root/playos-debian-trixie-xfce-noble-kernel
```

Foram transferidos o perfil, os hooks, manifests e os três `.deb` Noble.

## Preflight executado

O script `tools/preflight.sh` confirmou:

```text
linux-image-6.8.0-138-generic_6.8.0-138.138_amd64.deb: OK
linux-modules-6.8.0-138-generic_6.8.0-138.138_amd64.deb: OK
linux-modules-extra-6.8.0-138-generic_6.8.0-138.138_amd64.deb: OK
preflight estático concluído
```

Também foram confirmados exatamente três pacotes locais, ferramentas obrigatórias
presentes e ausência de instaladores nas listas do perfil.

## Inicialização persistente do build

O build foi iniciado dentro da VM como serviço transitório systemd, para não
depender de uma sessão terminal aberta:

```text
Unidade: playos-debian-live-build.service
Invocation ID: a7f881ec7e7f48229ce38aebb60d6089
Diretório: /root/playos-debian-trixie-xfce-noble-kernel
Log: /root/playos-debian-trixie-xfce-noble-kernel/build.log
Início: 2026-09-03 15:40:54 UTC
```

O script executou com sucesso até o início da composição:

```text
preflight
lb clean --purge
lb config
lb build
lb bootstrap
lb bootstrap_debootstrap
```

## Estado no momento deste relatório

Na captura feita aproximadamente 1 minuto e 33 segundos após o início:

```text
Serviço: active (running)
Memória corrente: aproximadamente 307 MiB
Pico de memória: aproximadamente 353 MiB
Disco da VM usado: aproximadamente 1,3 GiB de 12 GiB
Espaço livre: aproximadamente 11 GiB
```

O `debootstrap` já havia:

- validado assinaturas e índices do Debian Trixie;
- resolvido dependências da base;
- baixado e desempacotado os pacotes essenciais;
- iniciado a configuração da base, incluindo libc, dpkg, APT, systemd libs,
  PAM, mount, coreutils e passwd.

Esse estado comprova somente que o bootstrap Debian está em execução. Ainda não
comprova a instalação completa do desktop, a geração da ISO ou o boot.

### Atualização após a validação documental

O serviço permaneceu `active` e avançou para:

```text
lb chroot_archives chroot install
```

O APT do chroot reconheceu o repositório local `/packages`, que contém os
pacotes Noble, e começou a baixar os índices `trixie`, `trixie-updates` e
`trixie-security` das áreas `main`, `contrib` e `non-free-firmware`. Nesse
momento a VM usava aproximadamente 1,7 GiB e mantinha 9,8 GiB livres. Ainda não
havia ISO.

## Como acompanhar

No host, sem `sudo` quando o acesso LXD estiver autorizado:

```sh
lxc exec playos-debian-trixie-builder-vm -- \
  systemctl status playos-debian-live-build.service --no-pager -n 30

lxc exec playos-debian-trixie-builder-vm -- \
  tail -n 100 /root/playos-debian-trixie-xfce-noble-kernel/build.log

lxc exec playos-debian-trixie-builder-vm -- df -h /
```

Não iniciar outro `lb build` enquanto a unidade estiver ativa.

## Artefatos esperados

Após conclusão bem-sucedida, o diretório do perfil dentro da VM deve conter:

- uma ISO híbrida amd64;
- manifesto completo dos pacotes instalados;
- checksum SHA-256 gerado por `tools/build.sh`;
- log completo do build.

Os artefatos devem ser copiados para o diretório controlado do projeto somente
depois de conferir integridade, nome, tamanho e estrutura de boot.

## Gates ainda pendentes

1. concluir `lb bootstrap`, chroot e instalação dos 67 pacotes diretos;
2. passar pelos hooks, incluindo auditoria de ausência de instaladores;
3. gerar SquashFS, initramfs e estrutura híbrida BIOS/UEFI;
4. produzir ISO e SHA-256;
5. copiar os artefatos validados para o projeto;
6. auditar manifesto final;
7. iniciar em VM e validar Debian Trixie, kernel `6.8.0-138-generic`, OverlayFS,
   LightDM, XFCE, NetworkManager e ausência do Calamares;
8. testar áudio, gráficos, Vulkan e hardware real em etapas posteriores.

## Conclusão provisória

O ambiente inadequado de contêiner foi substituído por uma VM Debian completa,
sem conceder privilégio persistente ao contêiner. A VM, as ferramentas, o
perfil e os pacotes Noble foram verificados. O build real está ativo no estágio
de bootstrap Debian. ISO, boot e runtime continuam classificados como
`unknown` até os respectivos gates serem executados.

## Resultado final do build — atualização de 2026-09-06

O serviço transitório já havia encerrado e desaparecido do systemd, como
esperado após conclusão e reinicialização/limpeza da unidade. O final preservado
de `build.log` registrou:

```text
P: Binary stage completed
P: Build completed successfully
ISO criada: ./live-image-amd64.hybrid.iso
```

Artefatos produzidos dentro da VM:

| Artefato | Tamanho |
|---|---:|
| `live-image-amd64.hybrid.iso` | 1.388.435.456 bytes |
| `live-image-amd64.packages` | 28.019 bytes |
| `live-image-amd64.contents` | 18.492 bytes |
| `live-image-amd64.hybrid.iso.sha256` | 96 bytes |

SHA-256 confirmado:

```text
ed798d40e58da7bc5a0da531a6947da6263766e1fc86ea6e179492475df1c50d
```

O relatório El Torito confirmou GRUB BIOS, GRUB UEFI, MBR protetivo, GPT e o
volume `PLAYOS_D13_XFCE`. A ISO contém:

```text
/live/vmlinuz-6.8.0-138-generic
/live/initrd.img-6.8.0-138-generic
/live/filesystem.squashfs
```

O manifesto final confirmou XFCE 4.20.1, LightDM, `live-boot`, `live-config` e
os três pacotes Noble 6.8.0-138. Calamares, seus settings, Subiquity, Curtin e
Casper não aparecem no manifesto.

## Cópia para o projeto

Os artefatos foram copiados para:

```text
build/playos-debian-trixie-xfce-noble/output/
```

A primeira transferência da ISO terminou prematuramente com apenas
1.030.258.688 bytes; o SHA-256 detectou a truncagem. Essa cópia não foi usada.
A transferência foi repetida para extensão `.partial`, chegou aos
1.388.435.456 bytes e apresentou o hash esperado. Somente depois disso ela
substituiu a cópia incompleta. Uma nova verificação no diretório do projeto
retornou `OK`.

Foram preservados no projeto:

- ISO completa;
- arquivo SHA-256;
- manifesto de pacotes;
- inventário de conteúdo;
- log completo do build.

A ISO Calamares anterior foi preservada: a política de saída única não deve
eliminar o último artefato previamente conhecido antes da validação completa da
nova candidata.

## Teste de boot LXD

A ISO foi importada no pool LXD como volume somente leitura
`playos-d13-xfce-noble-iso`. Foi criada a VM isolada
`playos-d13-xfce-noble-boot-test`, com 2 vCPUs, 2 GiB de RAM, disco vazio de
8 GiB e Secure Boot desativado.

Resultados observados:

- `result`: a VM iniciou pela ISO e permaneceu `RUNNING`;
- `result`: o console serial exibiu `EFI stub: Loaded initrd`, confirmando que
  o firmware UEFI carregou o kernel e o initrd da mídia;
- `result`: a interface `eth0` ficou ativa e recebeu IPv4 `10.131.47.16` e
  IPv6, evidência de chegada ao userspace e configuração de rede;
- `unknown`: o console serial não mostra o desktop porque o GRUB/boot usa saída
  gráfica silenciosa;
- `unknown`: a imagem Live não inclui `lxd-agent`, portanto `lxc exec` não pode
  consultar `uname`, systemd ou a sessão gráfica por dentro;
- `unknown`: abertura visual efetiva do XFCE, áudio, Mesa/Vulkan e interação do
  usuário ainda precisam do console VGA.

Classificação atual correta: ISO **compilada, íntegra, inicializável via UEFI e
capaz de alcançar userspace/rede em VM**. Ela ainda não deve ser classificada
como desktop visual completamente validado nem pronta para hardware/produção.
