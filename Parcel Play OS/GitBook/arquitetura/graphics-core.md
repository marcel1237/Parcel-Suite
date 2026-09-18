# Graphics Core

O Graphics Core reúne a base necessária para uma sessão gráfica:

- DRM/KMS e drivers no kernel;
- Mesa e Vulkan no userspace;
- compositor Wayland e suporte X11/Xwayland;
- KWin e SDDM no perfil KDE;
- input, áudio PipeWire e rede NetworkManager;
- ferramentas de diagnóstico e coleta de evidências.

A presença de pacotes ou drivers não comprova funcionamento em hardware. O
gate de runtime continua separado do gate de build.

