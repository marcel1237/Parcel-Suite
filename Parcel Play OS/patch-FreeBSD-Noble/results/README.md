# Resultados

O build mais completo é `BUILD_GENERIC_PROD_6.8.4_2026-08-18.md`. Ele usa a
configuração `amd64-generic` extraída das `annotations` oficiais do Ubuntu e
concluiu kernel, 6.467 módulos com BTF, instalação isolada, `depmod` e
initramfs. O relatório registra também os avisos e gates ainda pendentes.

`BUILD_6.8.4_PLAYOS_FREEBSD_LAB1_2026-08-18.md` preserva o histórico do
primeiro build mínimo baseado em `x86_64_defconfig`; ele não representa a
cobertura final de hardware.

Os selftests iniciais confirmaram `sendfile` sobre AF_UNIX, Landlock e os
mecanismos Linux escolhidos para isolamento. Eles rodaram no kernel host e não
substituem o futuro boot e validação dentro do novo kernel.
