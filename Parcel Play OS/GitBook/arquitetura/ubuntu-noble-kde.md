# Ubuntu Noble + KDE Full

O perfil atual usa bootstrap e pacotes Ubuntu Noble, KDE Full, Plasma, KWin,
SDDM, Mesa/Vulkan, PipeWire, NetworkManager e componentes Live.

A arquitetura Live é inspirada no modelo do KNOPPIX, mas não copia o rootfs,
`cloop`, AUFS ou scripts privados do KNOPPIX. O modelo adotado usa SquashFS,
OverlayFS, live-boot e live-config.

`implementation`: o perfil foi construído em VM isolada. `unknown`: boot e
runtime KDE ainda não foram validados integralmente.

