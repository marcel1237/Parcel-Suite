# Manifesto do patchset

## Origem

- referência FreeBSD: `Kernels/FreeBSD 15/sys/kern/`;
- alvo pretendido: Ubuntu 26.04 LTS Resolute oficial, Linux 7.0;
- alvo local auditado: Noble 6.8.4, inadequado como baseline final;
- relatório: `../APLICACAO_FREEBSD15_NO_UBUNTU_RESOLUTE_2026-08-18.md`;
- estudos: `../studies/freebsd15_sys_kern/`.

## Série ativa

### 0001 — documentação

Adiciona ao kernel a especificação da tradução conceitual. Não altera ABI,
configuração ou comportamento.

### 0002 — bootconfig

Adiciona uma amostra de tracing de initcalls. A amostra não é habilitada por
default e não altera a linha de comando do kernel.

### 0003 — selftests

Adiciona testes de correção para `sendfile(2)` e uma auditoria não destrutiva
das interfaces usadas pelos estudos. Não mede performance como condição de
PASS e não exige fault injection.

## Fora da série automática

### Fault injection

O fragmento `config/parcel-lab.config` documenta as opções desejadas. A
conversão para `annotations` depende da criação real do flavour `parcel-lab`.

### Scheduler

Não há patch ULE. A árvore local não possui `sched_ext`. Quando o baseline
Resolute verdadeiro for obtido, a primeira implementação deve ser eBPF e
reversível.

### Rede/VFS

O Linux já contém sendfile, splice, dcache e kTLS. Novos patches só serão
criados para lacunas comprovadas por tracing e benchmarks.

### Algoritmos

PID, min/max e regressão permanecem em userspace. Não existe consumidor kernel
aprovado e min/max já possui equivalentes Linux.

## Política de versão

Cada aplicação deve gerar um registro em `results/` contendo:

- commit do alvo antes da aplicação;
- hash SHA-256 dos patches;
- versão do kernel;
- changelog/distribuição;
- data;
- resultado de `git apply --check`;
- configuração usada;
- resultados de build, boot e testes.
