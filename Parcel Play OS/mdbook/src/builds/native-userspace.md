# Native Userspace

## Stage0

O Stage0 concentra fontes mínimas, BusyBox, rootfs, initramfs, composição ISO e
smoke tests. Seu resultado inclui uma ISO inicial e checksum.

## Stage1

O Stage1 amplia o userspace e usa Buildroot. O resultado principal é um
rootfs tar com checksum, além da ISO correspondente em
`playos-native-stage1-iso/`.

## Stage2 Graphics

O Stage2 tenta adicionar a pilha gráfica e Qt. No estado documentado, há logs
de tentativas e não há ISO final identificada. Portanto o estágio é
`implementation` parcial, não desktop gráfico validado.
