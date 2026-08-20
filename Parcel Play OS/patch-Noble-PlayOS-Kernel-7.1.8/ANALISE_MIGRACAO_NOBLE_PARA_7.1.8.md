# Migração do perfil Ubuntu Noble para Linux 7.1.8

Data: 2026-08-20

## Conclusão arquitetural

Para que o PlayOS seja tecnicamente uma versão 7.1.8, o kernel base precisa ser
Linux 7.1.8. Backports sobre Noble 6.8.4 não alteram sua versão-base. Por isso,
o projeto passa a manter duas linhas:

- PlayOS Kernel 1: Noble 6.8.4 vitaminado, fallback conservador;
- PlayOS Kernel 2: Linux 7.1.8 com política/configuração Noble e patches PlayOS.

O segundo é um forward-port. Ele não preserva automaticamente a ABI de módulos
Ubuntu 6.8 e ainda não contém todo o empacotamento Canonical.

## Estado upstream verificado

O Ubuntu 26.04 LTS Resolute foi oficialmente lançado com Linux 7.0. As fontes
primárias consultadas foram:

- https://discourse.ubuntu.com/t/26-04-lts-resolute-raccoon-shipping-with-the-final-7-0-linux-kernel/80838
- https://launchpad.net/ubuntu/+source/linux/+changelog

Em 20/08/2026, kernel.org já apresentava 7.2 como mainline e 7.1.9 como stable:

- https://www.kernel.org/
- https://www.kernel.org/pub/linux/kernel/v7.x/

Logo, 7.1.8 é mais novo que o kernel-base 7.0 do Resolute, mas já não é o último
stable. Versão maior não comprova estabilidade, desempenho ou suporte melhor.

## Construção da configuração

1. as annotations Noble foram exportadas para `amd64/generic`;
2. o resultado foi carregado pelo Kconfig do Linux 7.1.8;
3. `olddefconfig` reconciliou símbolos removidos, renomeados e novos;
4. chaves privadas Canonical foram removidas do build local;
5. Rust foi desativado por ausência de toolchain fixada e reproduzível;
6. fault injection foi removido do perfil de produção;
7. NTSYNC, BTF e sched_ext foram confirmados explicitamente.

A reconciliação produziu 1.514 linhas de diferenças de Kconfig. Esse número
inclui remoção de símbolos obsoletos, novos defaults e mudanças de dependência;
não significa 1.514 patches de código. Os warnings iniciais de Kconfig para
Binder, Hyper-V e alguns helpers de crypto foram resolvidos por `olddefconfig`.

## Compatibilidade preservada por configuração

O perfil resultante mantém, entre outros:

- AppArmor e Landlock;
- seccomp e namespaces;
- cgroups e integração BPF;
- DRM e framebuffer console;
- kTLS como módulo;
- NTSYNC como módulo;
- BTF e sched_ext;
- infraestrutura Ubuntu Generic ampla para drivers.

Presença na configuração e compilação não comprovam funcionamento no hardware.

## Série reproduzível

O patchset contém identidade, documentação, bootconfig e selftests. A série foi
testada contra uma reconstrução limpa da fonte local 7.1.8: `git apply --check`
passou para todos os patches, a aplicação passou e `kernelrelease` retornou
`7.1.8-playos-kernel2`.

A árvore local original não possui `.git` nem tarball upstream ao lado dela.
O download do tarball oficial foi tentado, mas a conexão terminou repetidamente
após blocos parciais. A verificação criptográfica da origem permanece um gate.

## Gates de promoção

1. concluir `bzImage` e todos os módulos sem erro;
2. inspecionar BTF, `vermagic`, NTSYNC, sched_ext e LSMs;
3. executar os selftests PlayOS e upstream relevantes;
4. criar staging, initramfs e pacote Debian;
5. definir chave PlayOS e fluxo Secure Boot;
6. iniciar em VM e depois em hardware com fallback 6.8.4;
7. testar DKMS, GPU, Wi-Fi, áudio, armazenamento, Wine/Proton e suspend/resume;
8. somente então avaliar a promoção sobre o kernel Resolute 7.0.
