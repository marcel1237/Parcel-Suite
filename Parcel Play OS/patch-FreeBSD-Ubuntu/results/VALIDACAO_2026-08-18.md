# Validação inicial do patchset — 18 de agosto de 2026

## Escopo

Validação estática contra a árvore local Noble 6.8 e validação funcional dos
artefatos em uma cópia temporária. Isso confirma compatibilidade inicial, não
compatibilidade final com Ubuntu Resolute.

**Correção posterior:** fontes oficiais da Canonical e o changelog do pacote
confirmam que o Resolute final usa Linux 7.0. Portanto, nenhum resultado abaixo
constitui validação contra o kernel oficial do Resolute.

## Identidade do alvo de compatibilidade

- commit: `74134bfb6b720ca18a73931662cbcc8170ef1bed`;
- branch: `master`;
- versão extraída: `6.8.4`;
- changelog: `linux (6.8.0-30.30) noble`;
- clone raso: sim;
- remote: repositório Launchpad nomeado `resolute`;
- modo: somente compatibilidade.

## Resultados confirmados

| Verificação | Resultado |
|---|---|
| sintaxe dos scripts (`bash -n`) | PASS |
| presença e ordem da série | PASS |
| `git apply --check` dos três patches | PASS |
| whitespace estrito dos patches | PASS |
| aplicação em cópia temporária | PASS |
| compilação de `parcel_sendfile.c` | PASS |
| flags `-Wall -Wextra -Werror` | PASS |
| correção de dados via `sendfile` | PASS |
| inventário não destrutivo de recursos | PASS |
| build da ferramenta `bootconfig` | PASS |
| suíte oficial da ferramenta bootconfig | 55 PASS, 0 FAIL |
| parsing de `parcel-boottrace.bconf` | PASS |

O host de validação apresentou cgroups, namespaces, tracefs e política BPF.
As interfaces de fault injection estavam ausentes e o teste as classificou
corretamente como `SKIP lab-only`.

## Não executado

- aplicação em Resolute verdadeiro;
- repetição integral da validação contra Linux 7.0 oficial;
- build de kernel Ubuntu;
- criação do flavour `parcel-lab`;
- boot em QEMU ou hardware;
- fault injection real;
- kTLS em NIC;
- benchmark scheduler controlado;
- assinatura e Secure Boot;
- instalação de pacote Debian.

## Conclusão

O kit está preparado para revisão e para checagem contra um clone Resolute
correto. Os três patches ativos são deliberadamente seguros: documentação,
amostra opt-in de boottrace e selftests. A configuração destrutiva permanece
fora da série automática.
