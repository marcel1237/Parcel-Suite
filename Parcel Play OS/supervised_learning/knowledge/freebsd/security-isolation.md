# Segurança e isolamento no FreeBSD

ID: `KB-FBSD-SECURITY`

- tipo: `fact`
- confiança: `high`
- estado: `current`
- verificado em: `2026-08-19`
- fontes: `SRC-FBSD-SOURCE`, `SRC-FBSD-INVENTORY`, `SRC-FBSD-PORTABILITY`

## Mecanismos BSD

- Jails fornecem isolamento com hierarquia de `struct prison`;
- `prison0` representa o ambiente real/host e é raiz das prisons;
- VNET permite pilhas de rede virtualizadas por jail;
- RACCT coleta accounting e RCTL aplica regras de recursos;
- Capsicum restringe aplicações por capabilities e capability mode;
- MAC Framework hospeda políticas de controle de acesso;
- audit fornece trilha de eventos de segurança;
- securelevel e flags de arquivo complementam políticas operacionais.

## Comparação Linux

Não existe equivalência individual completa. Um sandbox Linux comparável exige
composição de user/PID/mount/network namespaces, cgroup v2, capabilities,
seccomp, AppArmor/SELinux, Landlock e política userspace. Jails não devem ser
descritas apenas como “namespaces do FreeBSD”, nem namespaces como uma cópia de
Jails.

Capsicum é orientado a capabilities em file descriptors; Landlock é um LSM
empilhável para restrições de acesso e seccomp filtra syscalls. São mecanismos
complementares, não substitutos semânticos diretos.

## Aplicação PlayOS

O contrato de isolamento pode ser comum no userspace, com backends nativos:

- FreeBSD: Jail/VNET/RCTL/Capsicum/MAC;
- Linux: namespaces/cgroup/seccomp/LSM/Landlock.

Critérios mínimos: isolamento de PID/rede/mount, limites de recurso, política de
filesystem, redução de privilégios, logs e testes de fuga. O protótipo
“Nitro-Jail” não deve ser chamado de implementação equivalente enquanto esses
gates não existirem.
