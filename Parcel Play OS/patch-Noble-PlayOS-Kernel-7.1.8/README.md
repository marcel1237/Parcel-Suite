# Noble atualizado para PlayOS Kernel 7.1.8

Este patchset cria a linha principal do PlayOS Kernel sobre Linux vanilla 7.1.8.
Ele reaproveita a política do Ubuntu Noble Generic, adapta a configuração às
APIs 7.1.8 e mantém os estudos PlayOS/FreeBSD como patches pequenos.

Isso é uma migração de base, não a renomeação do Noble 6.8.4. A integração de
empacotamento Ubuntu completa ainda precisa ser portada e testada separadamente.
Em 20/08/2026, kernel.org já listava 7.1.9 como stable; a escolha de 7.1.8 aqui
segue a fonte local do projeto e não deve impedir uma atualização incremental.

## Conteúdo

- identidade `7.1.8-playos-kernel2`;
- configuração Ubuntu Noble Generic reconciliada por `olddefconfig` 7.1.8;
- AppArmor, Landlock, seccomp, namespaces, cgroup/BPF, kTLS e NTSYNC;
- BTF e `sched_ext`, dependentes de pahole compatível;
- documentação, bootconfig e selftests PlayOS/FreeBSD existentes;
- testes adicionais de Landlock e composição de isolamento Linux;
- fault injection e Rust excluídos do perfil de produção atual.

## Aplicação em fonte limpa

```sh
scripts/check-series.sh /caminho/linux-7.1.8
scripts/apply-series.sh --apply /caminho/linux-7.1.8
scripts/prepare-config.sh /caminho/linux-7.1.8 /caminho/output
make -C /caminho/linux-7.1.8 O=/caminho/output -j8 bzImage modules
```

O diretório de fonte não pode conter espaços por uma restrição do Makefile do
kernel. Não instale os artefatos no host antes dos gates de boot e rollback.
