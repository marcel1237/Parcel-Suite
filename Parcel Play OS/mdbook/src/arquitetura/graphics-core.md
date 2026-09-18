# PlayOS Graphics Core

O Graphics Core é a composição gráfica comum, independente de um desktop
específico. Ele reúne o caminho de boot gráfico, display manager, X11,
Wayland, Xwayland, Mesa/Vulkan, input, áudio e serviços de hardware.

## Desktop separado

XFCE, GNOME e KDE Plasma são perfis de desktop sobre a base comum. O Graphics
Core não deve ser confundido com uma ISO KDE Full: uma variante pode incluir
Calamares e XFCE, enquanto a composição KDE Full atual não inclui instalador.

## Gates

1. kernel e initramfs;
2. DRM/KMS e dispositivos `/dev/dri`;
3. systemd, logind e D-Bus;
4. X11;
5. Wayland e Xwayland;
6. Mesa e Vulkan;
7. input, áudio, rede e energia;
8. desktop e logout.
