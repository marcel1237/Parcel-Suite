# Live ISO Noble + XFCE sem instalador

Data: 2026-08-31  
Tipo: `implementation-report`  
Estado: perfil e staging implementados; build e runtime pendentes.

## Objetivo

Produzir uma Live CD Ubuntu Noble amd64 com XFCE, destinada somente ao uso
Live. Calamares foi removido porque não funcionou nos testes manuais informados
pelo usuário. Nenhum outro instalador o substitui nesta variante.

## Composição preservada

- kernel Ubuntu Noble genérico;
- `live-boot`, `live-config` e `live-tools`;
- XFCE e LightDM;
- X11, Wayland, Xwayland e Labwc técnico;
- Mesa, DRM, OpenGL e Vulkan;
- PipeWire, WirePlumber e ALSA;
- NetworkManager, UPower e UDisks2;
- firmware, microcódigo e utilitários de diagnóstico;
- ferramentas de disco acessíveis pela sessão Live.

## Remoções

- pacote Calamares;
- `/etc/calamares` e módulos em `/usr/lib/calamares`;
- branding Calamares;
- wrapper e arquivo `.desktop` `Instalar PlayOS`;
- Subiquity Server e Curtin;
- Casper, mantendo somente o pipeline `live-boot`.

## Locais

- fonte versionável: `live-build/playos-noble-xfce-live-only/`;
- staging sem espaços: `/home/marcel/playos-noble-xfce-live-only`;
- saída planejada: `build/playos-noble-xfce-live-only/output/playos-noble-xfce-live-amd64.iso`.

O staging externo é transitório. O diretório versionável dentro do projeto é a
fonte de verdade.

## Estado verificado

- `result`: `lb config` concluiu;
- `result`: scripts passaram na validação de sintaxe;
- `result`: busca estática não encontrou Calamares, Subiquity, Curtin, Casper
  ou lançador de instalação na receita;
- `implementation`: staging sem espaços criado;
- `unknown`: build final;
- `unknown`: boot BIOS/UEFI e funcionamento da sessão XFCE.

O procedimento operacional está no `README.md` do perfil.

