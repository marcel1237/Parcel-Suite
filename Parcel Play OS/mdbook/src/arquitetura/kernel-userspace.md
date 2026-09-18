# Fronteiras entre kernel e userspace

## Kernel

O kernel fornece DRM/KMS, drivers, DMA-BUF, input, filesystem, rede, energia,
firmware loader e mecanismos de segurança. Um kernel gráfico não deve conter
GNOME, KDE, XFCE, X.Org ou compositores Wayland.

## Userspace

O userspace contém:

- systemd, logind, D-Bus e polkit;
- NetworkManager, UPower e udisks2;
- Mesa, libdrm, Vulkan e ferramentas gráficas;
- X.Org, Wayland, Xwayland e compositores;
- PipeWire, WirePlumber e ALSA;
- display manager e desktop.

## Regra FreeBSD–Linux

FreeBSD `sys/kern` não é uma biblioteca que possa ser adicionada diretamente ao
Kbuild Linux. O fluxo correto é estudar o comportamento, encontrar o
equivalente nativo e reimplementar somente a menor ideia necessária com APIs
do kernel de destino.
