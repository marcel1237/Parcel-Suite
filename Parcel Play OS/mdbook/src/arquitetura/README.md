# Arquitetura

O PlayOS separa mecanismos de kernel, userspace, composição Live e desktops.
Essa separação permite testar cada camada sem afirmar compatibilidade ABI entre
FreeBSD e Linux.

## Camadas

```text
hardware
  -> kernel e drivers
  -> initramfs e init
  -> systemd/logind/D-Bus/polkit
  -> rede, energia, discos, input e áudio
  -> X11 ou Wayland
  -> desktop opcional
  -> aplicações
```

O KDE Plasma é userspace. X.Org, Wayland, Xwayland, Mesa, PipeWire e SDDM
também não são partes do kernel.
