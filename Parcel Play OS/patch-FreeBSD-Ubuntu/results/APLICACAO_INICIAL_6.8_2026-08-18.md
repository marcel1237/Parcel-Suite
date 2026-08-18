# Aplicação inicial do estudo `sys/kern` no kernel Ubuntu local

**Data:** 18 de agosto de 2026  
**Árvore:** `Kernels/ubuntu 26 resolute kernel/`  
**Branch criada:** `codex/playos-freebsd-syskern-6.8-lab`  
**Base:** `74134bfb6b720ca18a73931662cbcc8170ef1bed`

## Identidade real

A árvore declara Linux 6.8.4 e pacote Ubuntu Noble 6.8.0-30.30. Ela não é o
Ubuntu Resolute Linux 7.0 oficial. A aplicação inicia o laboratório e não deve
ser publicada como kernel Resolute.

## Alterações aplicadas

Quatro patches da série estão representados na árvore e no índice Git:

1. regras técnicas de tradução FreeBSD → Linux;
2. bootconfig opt-in para initcalls e exec;
3. selftests de inventário e correção de `sendfile`;
4. identidade local `-playos-freebsd-lab1`.

Estado: sete arquivos, 215 inserções; nenhuma linha de scheduler, VFS, rede,
memória ou syscall Linux foi substituída.

O sufixo separa o kernel de laboratório do kernel de distribuição. Na versão
fonte simples, a identidade pretendida é `6.8.4-playos-freebsd-lab1`; o pacote
Ubuntu poderá acrescentar sua própria ABI durante o empacotamento.

## Validações

| Verificação | Resultado |
|---|---|
| árvore limpa antes da aplicação | PASS |
| branch dedicada | PASS |
| aplicação indexada dos patches 1–3 | PASS |
| identidade local adicionada/indexada | PASS |
| `git diff --cached --check` | PASS |
| sintaxe/estrutura do kit | PASS |
| compilação direta de `parcel_sendfile.c` | PASS |
| correção de `sendfile` sobre AF_UNIX | PASS |
| inventário de seis capacidades do host | 5 PASS, 1 SKIP lab-only |
| build via infraestrutura kselftest | BLOCKED pelo caminho com espaços |
| build integral do kernel | NÃO EXECUTADO |
| boot | NÃO EXECUTADO |

O fault injection foi corretamente marcado como `SKIP`: a interface não está
ativa no kernel do host e pertence somente à configuração de laboratório.

## Bloqueio de build

O caminho físico contém múltiplos espaços. `tools/testing/selftests/lib.mk`
separou o caminho em alvos Make e falhou. O Kbuild principal já possui a mesma
restrição. O código do teste foi compilado diretamente com:

```text
-O2 -g -Wall -Wextra -Werror
```

O próximo build precisa de clone/worktree física fora desta hierarquia, em
caminho sem espaços. Um symlink não é considerado solução até comprovar o
caminho físico visto pelo Kbuild.

## Estado Git

As mudanças estão **staged**, mas não foram commitadas. Isso permite revisão ou
reversão antes de criar histórico. O kernel original permanece no commit-base e
a nova branch contém somente o laboratório.

## Próxima mudança permitida

O próximo patch deve adicionar infraestrutura de medição, não código FreeBSD
copiado. Candidatos, na ordem:

1. integrar o documento ao índice Sphinx se a versão local permitir;
2. adicionar KUnit/selftest para uma lacuna concreta;
3. preparar configuração `PLAYOS-LAB` no empacotamento Ubuntu;
4. compilar em caminho limpo;
5. iniciar em VM com o Ubuntu oficial preservado.

ULE, Jails, mbufs, locks, VFS, sendfile e kTLS FreeBSD continuam fora da árvore
Linux até existir benchmark que justifique um patch Linux nativo.
