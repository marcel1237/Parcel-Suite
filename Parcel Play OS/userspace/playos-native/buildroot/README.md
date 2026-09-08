# Bootstrap nativo Stage1

O Stage1 usa Buildroot somente como ferramenta de cross-compilação e montagem
do SDK/rootfs a partir de fontes. Ele não importa um rootfs de distribuição e
não usa pacotes Debian, Ubuntu ou Slackware no sistema final.

O kernel não é compilado pelo Buildroot: a composição Live continua importando
somente o kernel e os módulos Noble validados. O rootfs Stage1 usa glibc,
SysVinit, eudev, Bash, ferramentas GNU, kmod, D-Bus e polkit. As interfaces
de pacotes expostas no runtime são `playpkg-install` e `playpkg-remove`.

Execute:

```sh
userspace/playos-native/buildroot/build-stage1.sh
```

O build é retomável em `/home/marcel/kernel-work/playos-native-stage1`, evitando
o limite pequeno do `/tmp`; downloads e resultados ficam em
`build/playos-native-stage1`. O rootfs e sua ISO já passaram no boot UEFI em
runlevel 3 com o kernel Noble. O próximo estágio usa o SDK gerado para Mesa,
X.Org, Wayland, PipeWire e Qt 6 antes da integração KDE.

## Stage2 gráfico

`playos-stage2-graphics_defconfig` estende a mesma base com NetworkManager,
UPower, udisks, ALSA, PipeWire/WirePlumber, libinput, DRM/Mesa/OpenGL/Vulkan,
X.Org, Xwayland, Weston e Qt 6. Ele não contém KDE: essa separação permite
validar o contrato gráfico primeiro.

Validação sem compilar:

```sh
userspace/playos-native/buildroot/validate-stage2-config.sh
```

Depois de validar e com pelo menos 15 GiB livres, a promoção incremental do
staging Stage1 pode ser iniciada em segundo plano:

```sh
userspace/playos-native/buildroot/start-stage2-build.sh
```

O log fica em `build/playos-native-stage2-graphics/build.log`. A promoção
reutiliza objetos/toolchain do Stage1 para reduzir disco e tempo, mas mantém os
artefatos finais Stage1 intactos em `build/playos-native-stage1/output/`.
