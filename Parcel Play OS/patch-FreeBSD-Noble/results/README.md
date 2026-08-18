# Resultados

O primeiro build do kernel PlayOS Noble foi concluído em 18 de agosto de 2026,
incluindo `bzImage`, módulos, instalação isolada dos módulos e hashes dos
artefatos. O kernel ainda não passou por boot. Veja
`BUILD_6.8.4_PLAYOS_FREEBSD_LAB1_2026-08-18.md` para identidade do alvo,
configuração, toolchain, resultados e limitações.

Os selftests iniciais confirmaram `sendfile` sobre AF_UNIX, Landlock e os
mecanismos Linux escolhidos para isolamento. Eles rodaram no kernel host e não
substituem o futuro boot e validação dentro do novo kernel.
