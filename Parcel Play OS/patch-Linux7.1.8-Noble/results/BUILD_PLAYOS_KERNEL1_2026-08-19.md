# Build do PlayOS Kernel 1

Data: 2026-08-19

## Escopo

Esta validação cobre a árvore Ubuntu Noble Linux 6.8.4 acrescida do NTSYNC,
do `mseal` e da identidade `-playos-kernel1`. Ela não equivale a uma release
de produção.

## Evidência aprovada

- release: `6.8.4-playos-kernel1+`;
- `bzImage`: 14.914.048 bytes;
- SHA-256: `03f2675bcc4e5bdbccf9e2cbeeeb8b01d4b998a22e769a0996ac1a61e55752ca`;
- BTF presente no `vmlinux`;
- símbolos `__x64_sys_mseal` e `do_mseal` presentes no `vmlinux`;
- objetos `mseal`, `madvise`, `mmap`, `mprotect` e `mremap` compilados;
- `ntsync.ko` reconstruído com BTF e `vermagic` da nova release;
- selftest `mseal` compilado e executado no kernel host 7.0.0-30-generic:
  74 casos passaram, 4 falharam e 2 foram ignorados por ausência de PKEY.
- SHA-256 do patch NTSYNC:
  `42b32379711516473cc5ee60a4bf50bdb804a9cc81f7d6913c8308cf30ef9acd`;
- SHA-256 do patch mseal/identidade:
  `1d574061fb70370d9af11f6758492ad34c84298c450d64162d28432b83db8bdc`.

O teste no kernel host comprova que o binário de teste funciona; não comprova
o backport no PlayOS Kernel. Os casos que falharam foram 59, 61, 62 e 78.

## Módulos: estado pendente

O diretório incremental contém 6.468 arquivos `.ko`, todos não vazios, mas a
amostragem encontrou artefatos antigos com `vermagic`
`6.8.4-playos-freebsd-lab1+`. A reconstrução paralela encontrou condições de
corrida em arquivos temporários usados por `fixdep`; por isso, a contagem não
pode ser usada como aprovação do alvo global. Uma reconstrução serial foi
iniciada para reparar e uniformizar os módulos.

## Avisos observados

- frame de 1.160 bytes em `drivers/char/random.c`;
- dois IDs BTF não resolvidos ligados a alterações de segurança já existentes;
- alertas `fortify` em SMB servidor e cliente.

Esses avisos não foram introduzidos pelos patches NTSYNC/mseal, mas precisam de
triagem antes da promoção.

## Gates ainda abertos

1. alvo global `modules` concluído sem erro e `vermagic` uniforme;
2. assinatura e verificação dos módulos;
3. initramfs e checksums reproduzíveis;
4. boot em QEMU ou hardware com caminho de rollback;
5. selftests NTSYNC e mseal executados no PlayOS Kernel;
6. regressões MM, Wine/Proton e matriz mínima de hardware.

A fonte Linux 7.1.8 não deve ser apagada enquanto esses gates e o inventário de
origem reproduzível não estiverem fechados.

## Proveniência mínima

A fonte local identifica `VERSION=7`, `PATCHLEVEL=1`, `SUBLEVEL=8`, preserva
`COPYING` e o diretório `LICENSES`, mas não possui metadados Git nem um tarball
original ao lado dela. Antes de qualquer remoção deve ser criado e verificado
um snapshot assinado ou deve ser registrado o hash do arquivo upstream oficial.
