# ISO Ubuntu Noble + KDE Full

## Artefato

```text
build/playos-ubuntu-noble-kde-full-knoppix-style/
```

```text
playos-ubuntu-noble-kde-full-live.iso
```

- tamanho: 6.458.335.232 bytes;
- SHA-256:
  `03863ec2c98d10cce3d33c3112bcb71f5a1b7fc2410c5170e780e42da50c5075`;
- kernel empacotado: `6.8.0-139-generic`;
- SquashFS: aproximadamente 6.024 MiB comprimidos;
- boot record: El Torito GRUB2 confirmado.

## Correções aplicadas durante o build

- remoção de `--updates true`, incompatível com o `live-build` local;
- inclusão de `syslinux-utils`;
- preservação do chroot concluído;
- uso de `--build-with-chroot false`;
- instalação de `genisoimage` na VM;
- geração manual em ISO9660 nível 3 para superar 4 GiB.

## Limite conhecido

`isohybrid` rejeitou a imagem porque o layout GRUB2 não forneceu a assinatura
`isolinux.bin`. O arquivo não deve ser chamado de ISO híbrida USB/BIOS até que
isso seja validado por uma ferramenta compatível e por boot real.
