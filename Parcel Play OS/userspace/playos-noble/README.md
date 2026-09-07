# PlayOS Userspace 1 — Noble compatibility baseline

- ID: `PLAYOS-USERSPACE-NOBLE-001`
- tipo: `implementation`
- estado: manifesto e camada de identidade implementados; rootfs e runtime pendentes
- confiança: alta para o contrato; runtime `unknown`
- data: 2026-09-07

## Definição

Este diretório inicia o userspace próprio do PlayOS. “Próprio” significa que o
PlayOS controla a composição, identidade, configuração, sessão Live, políticas,
testes e, futuramente, seu repositório. Não significa que todos os componentes
foram reescritos ou recompilados pelo projeto.

A primeira geração usa compatibilidade binária Ubuntu Noble:

- APT/dpkg e pacotes binários Ubuntu Noble como bootstrap;
- glibc, systemd, Mesa, PipeWire, NetworkManager e KDE provenientes do arquivo
  Ubuntu, com proveniência registrada;
- identidade `/etc/os-release` e `/etc/playos-release` do PlayOS;
- nenhuma fonte APT Debian direta;
- kernel Ubuntu Noble `generic` na primeira Live;
- KDE Full como perfil de produto, não como parte obrigatória do núcleo do
  userspace.

Assim, o termo correto nesta fase é **distribuição PlayOS derivada e compatível
com Noble**, e não “userspace criado do zero”.

## Camadas

```text
PlayOS produto e políticas
├── identidade, defaults e testes PlayOS
├── perfil Live SquashFS + OverlayFS
├── perfil KDE Full
├── kernel Ubuntu Noble
└── bootstrap binário Ubuntu Noble
```

## Gates para independência crescente

1. gerar rootfs reproduzível a partir do manifesto;
2. criar pacote `playos-base-files` em vez de copiar arquivos diretamente;
3. criar repositório APT PlayOS assinado;
4. reconstruir e publicar somente pacotes modificados;
5. testar atualização, rollback e recuperação;
6. decidir quais componentes justificam fork próprio;
7. somente declarar independência de Ubuntu quando bootstrap, archive,
   segurança e atualizações não dependerem mais dele.

Licenças, fontes correspondentes e avisos de copyright devem acompanhar toda
redistribuição.
