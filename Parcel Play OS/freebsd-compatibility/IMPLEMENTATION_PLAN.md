# Plano de implementação

## Fase 0 — baseline recuperável

- FreeBSD 15.1-RELEASE-p2 amd64 fixado;
- instalação ZFS com boot environments;
- kernel GENERIC preservado no menu de boot;
- atualização e rollback validados;
- inventário de CPU, GPU, Wi-Fi, áudio, NVMe e firmware.

**Saída:** boot, rede e rollback funcionando em VM antes de customizações.

## Fase 1 — desktop nativo

- qualificar primeiro AMD e Intel; manter NVIDIA como trilha separada;
- validar DRM, console, Wayland/Xwayland, KDE ou GNOME, áudio e login;
- usar pacotes oficiais e registrar versões;
- testar suspend/resume, múltiplos monitores, vídeo e aceleração 3D.

**Gate:** 50 ciclos de boot, 20 de suspend/resume e sessão gráfica de oito
horas sem erro crítico.

## Fase 2 — Linux Compatibility Zone

- habilitar Linux ABI conforme o Handbook;
- criar Linux jail dedicada, com VNET e dataset ZFS próprio;
- começar com Ubuntu Noble, que é explicitamente citado na documentação atual;
- expor somente diretórios necessários; não montar o host inteiro com escrita;
- testar uma suíte de binários CLI antes de GUI ou Steam.

**Gate:** DNS, TLS, processos, arquivos, áudio e GUI documentados; cada falha de
syscall deve encaminhar a aplicação ao bhyve.

## Fase 3 — Wine Zone

- instalar Wine nativo pelo repositório FreeBSD escolhido;
- manter prefixo separado por aplicação;
- usar usuário sem privilégios e snapshots antes de mudanças;
- classificar cada programa por versão, arquitetura, gráficos e resultado.

**Gate:** testes funcionais, não apenas abertura da janela.

## Fase 4 — bhyve Compatibility VM

- confirmar virtualização de CPU e IOMMU;
- criar VM Linux para Waydroid, containers Linux, NTSYNC e workloads que
  dependem de kernel Linux;
- criar VM Windows apenas quando Wine não atender;
- usar virtio para disco/rede e avaliar passthrough por dispositivo;
- isolar bhyve em jail quando o desenho estiver estabilizado.

**Gate:** snapshot, backup, rede, áudio/display e desligamento limpo. GPU
passthrough só entra após teste em hardware dedicado.

## Fase 5 — roteador Parcel

Criar um catálogo assinado com `app-id`, backend, versão testada, requisitos,
fallback e estado. A loja deve mostrar a tecnologia usada e nunca apresentar
uma VM como execução nativa. A política inicial está em
`config/capability-policy.tsv`.

## Fase 6 — Live e instalador

- construir a Live pelo sistema de release do FreeBSD;
- manter `bsdinstall` como backend de instalação;
- frontend gráfico pode coletar opções, mas particionamento, ZFS e loader devem
  continuar em código FreeBSD validado;
- oferecer seleção de perfis: Base, Desktop, Linux Compatibility e VM Host.

## Itens que não devem virar patch de kernel agora

- NTSYNC do Linux;
- Waydroid/binder Linux;
- drivers DRM/Linux copiados;
- `sched_ext`, io_uring, eBPF ou cgroup v2 copiados integralmente;
- runqueues, locks ou APIs GPL do Linux.

O patchset `patch-linux7.1.8-FreeBSD/` deve continuar sendo laboratório. Primeiro
se mede a lacuna; depois se cria uma implementação BSD independente apenas se
Linuxulator, Wine ou bhyve não resolverem.

## Critério de “top compatível”

O marco só é atingido quando a matriz real de aplicações e hardware apresentar:

- 100% dos itens com backend ou bloqueio explicado;
- zero alegação “nativa” para execução virtualizada;
- rollback testado para toda mudança de kernel/driver;
- nenhuma regressão no GENERIC;
- resultados reproduzíveis em VM e em pelo menos AMD e Intel físicos.
