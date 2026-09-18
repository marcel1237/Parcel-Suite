# Kernels compilados

## Noble Generic

`build/playos-noble-generic/` contém:

- `vmlinuz-6.8.4-playos-freebsd-generic`;
- `initramfs-6.8.4-playos-freebsd-generic.img`;
- `config-6.8.4-playos-freebsd-generic`;
- `System.map-6.8.4-playos-freebsd-generic`;
- `SHA256SUMS`.

## Noble lab

`build/playos-noble/` contém a variante `6.8.4-playos-freebsd-lab1` e seus
artefatos de configuração, initramfs, mapa e hashes.

## Linux 7.1.8

`build/playos-7.1.8/` contém `7.1.8-playos-freebsd-lab1`, initramfs,
configuração, `System.map` e `SHA256SUMS`.

## Importante

Esses kernels foram construídos separadamente. A ISO Ubuntu Noble KDE Full
registrada neste livro usa `6.8.0-139-generic`, portanto a integração do kernel
PlayOS ainda é um gate posterior.
