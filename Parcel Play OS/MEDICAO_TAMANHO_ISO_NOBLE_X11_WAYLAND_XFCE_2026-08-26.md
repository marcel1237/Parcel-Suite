# Medição de tamanho: Ubuntu Noble + X11 + Wayland + XFCE

- ID: `PLAYOS-LIVE-SIZE-001`
- tipo: `measurement-and-estimate`
- estado: pacotes medidos; ISO final estimada; kernel local não compilado
- confiança: alta para tamanhos APT; média para faixa da ISO
- data: 2026-08-26
- arquitetura: amd64

## Resposta direta

Considerando pacotes convencionais do Ubuntu Noble, com recomendações APT
habilitadas — perfil comparável a uma distribuição desktop de mercado — os
quatro blocos acumulam:

```text
1.424,4 MiB de pacotes .deb para download
3.104,1 MiB instalados/descompactados no rootfs
1.163 pacotes binários e dependências
```

Uma Live ISO completa, após SquashFS e inclusão de kernel, initramfs, GRUB,
metadados e arquivos Live, deve ficar aproximadamente entre:

```text
1,6 e 2,1 GiB
```

Essa faixa é uma `estimate`, não um resultado de build. Nenhuma ISO com esse
perfil foi gerada ainda. O tamanho exato só existe depois de produzir o
SquashFS e a ISO.

## O que foi considerado como “quatro softwares”

1. Ubuntu Noble mínimo com kernel generic;
2. X11/Xorg;
3. Wayland, Labwc e Xwayland;
4. XFCE/Xubuntu Desktop Minimal.

O kernel é apresentado também separadamente dentro do primeiro bloco para
mostrar seu custo.

## Metodologia

Foi criado um estado APT vazio e isolado em `/tmp`, sem considerar os pacotes
já instalados no host. Foram usados os índices assinados oficiais:

```text
noble
noble-updates
noble-security
main restricted universe multiverse
amd64
```

Os perfis foram resolvidos cumulativamente:

```text
Ubuntu:  ubuntu-minimal linux-generic
X11:     anterior + xorg
Wayland: anterior + wayland-protocols libwayland-server0 xwayland labwc
XFCE:    anterior + xubuntu-desktop-minimal
```

Foram somados os campos `Size` e `Installed-Size` das versões escolhidas pelo
APT. `Size` representa bytes dos `.deb`; `Installed-Size` é declarado em KiB.

Dois cenários foram calculados:

- `standard`: comportamento normal do APT, com recomendações;
- `lean`: `--no-install-recommends`, útil apenas como referência de redução.

## Resultado padrão de mercado

### Valores cumulativos

| Etapa | Pacotes | Download `.deb` | Rootfs instalado |
|---|---:|---:|---:|
| Ubuntu Noble + kernel | 313 | 976,1 MiB | 1.539,5 MiB |
| + X11 | 659 | 1.137,7 MiB | 2.226,1 MiB |
| + Wayland/Labwc/Xwayland | 675 | 1.141,8 MiB | 2.240,1 MiB |
| + XFCE completo mínimo | 1.163 | **1.424,4 MiB** | **3.104,1 MiB** |

### Custo marginal de cada bloco

| Bloco adicionado | Download adicional | Espaço instalado adicional |
|---|---:|---:|
| Ubuntu Noble + kernel | 976,1 MiB | 1.539,5 MiB |
| X11 | 161,6 MiB | 686,6 MiB |
| Wayland + Labwc + Xwayland | 4,2 MiB | 13,9 MiB |
| XFCE/Xubuntu minimal | 282,6 MiB | 864,0 MiB |

O custo marginal pequeno do bloco Wayland não significa que todo o stack
Wayland ocupe somente 13,9 MiB isoladamente. Muitas bibliotecas GTK, Mesa,
input e infraestrutura já entraram pelo Xorg/base. A medição marginal evita
contar dependências compartilhadas duas vezes.

## Decomposição do bloco Ubuntu

No perfil standard:

| Parte | Pacotes | Download | Instalado |
|---|---:|---:|---:|
| `ubuntu-minimal` e dependências | 194 | 71,3 MiB | 261,8 MiB |
| acréscimo de `linux-generic` | 119 | 904,8 MiB | 1.277,8 MiB |

O kernel aparece grande porque o conjunto standard inclui recomendações,
firmware, microcode, módulos, headers/metapacotes e ferramentas relacionadas.
Para compatibilidade ampla de mercado, remover firmware indiscriminadamente é
uma economia falsa: reduz a possibilidade de iniciar rede, GPU e outros
dispositivos.

## Resultado enxuto sem recomendações

### Valores cumulativos

| Etapa | Pacotes | Download `.deb` | Rootfs instalado |
|---|---:|---:|---:|
| Ubuntu Noble + kernel | 163 | 866,5 MiB | 1.106,5 MiB |
| + X11 | 373 | 962,2 MiB | 1.489,0 MiB |
| + Wayland/Labwc/Xwayland | 392 | 966,1 MiB | 1.501,6 MiB |
| + XFCE | 570 | **1.057,4 MiB** | **1.822,8 MiB** |

### Diferença para standard

```text
366,9 MiB a menos de downloads
1.281,3 MiB a menos no rootfs descompactado
593 pacotes a menos
```

Essa variante pode perder integração esperada: áudio PipeWire, portals,
fontes, energia, firmware, drivers, utilitários, indicadores e funcionalidades
do desktop. Não deve ser chamada “padrão de mercado” antes de testar uma lista
explícita de reposição.

## Versões resolvidas

| Pacote | Versão Noble selecionada |
|---|---|
| `ubuntu-minimal` | 1.539.2 |
| `linux-generic` | 6.8.0-138.138 |
| `xorg` | 1:7.7+23ubuntu3 |
| `wayland-protocols` | 1.45-1~ubuntu0.24.04.2 |
| `libwayland-server0` | 1.22.0-2.1build1 |
| `xwayland` | 2:23.2.6-1ubuntu0.8 |
| `labwc` | 0.7.1-1build1 |
| `xubuntu-desktop-minimal` | 2.262 |

Essas são versões observadas em 2026-08-26 nos pockets consultados. Atualizações
podem mudar tamanhos e dependências.

## Kernel oficial usado como proxy

O cálculo usa `linux-generic 6.8.0-138.138` porque ele possui metadados e
pacotes oficiais disponíveis. O kernel local escolhido pelo projeto é a fonte
Noble `6.8.0-30.30`, baseada em Linux 6.8.4, e ainda não possui `.deb`
compilados.

Portanto:

- o custo exato do kernel local é `unknown`;
- a medição de 976,1 MiB do primeiro bloco é referência conservadora do kernel
  oficial standard, não medição do futuro `linux-playos-graphics`;
- o tamanho do kernel PlayOS dependerá de módulos extras, debug, headers,
  firmware e conteúdo colocado na Live;
- arquivos de debug e headers não precisam entrar na ISO de uso final, embora
  devam ser preservados no repositório de desenvolvimento.

## Como estimar a ISO

O rootfs standard possui 3.104,1 MiB descompactados. A ISO não grava esses
arquivos de forma direta; o rootfs vira SquashFS. A compressão varia muito por:

- algoritmo e nível de compressão;
- firmware já comprimido;
- binários ELF;
- imagens e fontes;
- idiomas;
- duplicação de arquivos;
- caches e documentação removidos;
- snaps, se forem adicionados;
- navegador e codecs, que não foram incluídos explicitamente neste perfil.

Além do SquashFS, a mídia acrescenta:

```text
kernel e initramfs fora do SquashFS
GRUB BIOS/UEFI e imagem EFI
catálogos, checksums e manifestos
metadados ISO9660
configuração live-boot
```

Por isso foi adotada a faixa de engenharia de 1,6–2,1 GiB. Não é correto
calcular a ISO aplicando uma porcentagem fixa universal ao rootfs.

## Itens ausentes que podem aumentar a ISO

O perfil medido é desktop mínimo, não uma edição comercial completa. Podem
acrescentar tamanho:

- navegador;
- suíte de escritório;
- codecs e fontes adicionais;
- Steam/Wine e bibliotecas i386;
- drivers NVIDIA proprietários;
- instalador gráfico;
- slideshow e branding;
- múltiplos idiomas;
- documentação offline;
- ferramentas de recuperação;
- snaps;
- segundo kernel ou fallback completo.

Bibliotecas i386 para jogos podem aumentar bastante o conjunto porque repetem
partes de Mesa, Vulkan, áudio e runtime em outra arquitetura.

## Meta recomendada

Para a primeira Live PlayOS Graphics Stack:

| Classe | Meta |
|---|---:|
| rootfs descompactado | até 3,5 GiB |
| ISO sem navegador/office | até 2,1 GiB |
| ISO com navegador básico | medir; alvo inicial até 2,5 GiB |
| mídia USB recomendada | 8 GiB ou maior |

As metas são limites de produto, não resultados já alcançados.

## Como obter o tamanho definitivo

1. compilar `linux-playos-graphics` em `.deb`;
2. montar o perfil standard com lista congelada;
3. gerar rootfs e manifesto;
4. executar `du` no chroot limpo;
5. gerar SquashFS com algoritmo registrado;
6. medir `filesystem.squashfs`;
7. gerar a ISO;
8. medir ISO, SHA-256 e conteúdo;
9. repetir depois de instalar XFCE/X11/Wayland para calcular marginais reais.

Comandos de verificação após o build:

```bash
du -sh chroot
du -h binary/live/filesystem.squashfs
du -h playos-noble-xfce.iso
sha256sum playos-noble-xfce.iso
```

Os caminhos reais dependem do output do builder e devem ser confirmados, não
presumidos.

## Conclusão

O conjunto standard medido ocupa **3.104,1 MiB descompactado**. A melhor
previsão atual para uma ISO mínima utilizável é **1,6–2,1 GiB**. Não existe
ainda um “tamanho que deu” para a ISO nem para o kernel local: ambos precisam
ser compilados. Este documento separa medições APT reproduzíveis da estimativa
de compressão para evitar apresentar um número projetado como artefato real.
