# Kernel e userspace

O kernel fornece DRM/KMS, drivers, gerenciamento de memória, entrada, rede,
armazenamento e interfaces de baixo nível. O userspace fornece Wayland, X11,
KWin, SDDM, Mesa, PipeWire, NetworkManager, diagnóstico e políticas de sessão.

FreeBSD e Linux não compartilham ABI interna. O PlayOS deve comparar
comportamento e reimplementar ideias usando APIs nativas do kernel alvo; não
deve inserir diretamente `sys/kern` do FreeBSD no Kbuild Linux.

`fact`: essa separação é a regra arquitetural registrada no projeto.

