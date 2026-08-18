# Estudos FreeBSD `sys/kern` versus Linux/Ubuntu

Esta suíte executa versões seguras e reproduzíveis dos cinco casos definidos em `PORTABILIDADE_FREEBSD15_SYS_KERN_PARA_UBUNTU.md`.

## Estudos

- **A — Boottrace:** coleta capacidade de tracing, systemd e landmarks disponíveis sem escrever em tracefs.
- **B — Fault injection:** audita configuração e nós do kernel, mas não injeta falhas fora de VM descartável.
- **C — Scheduler:** mede latência de wake-up entre threads em `SCHED_OTHER` e `SCHED_BATCH`.
- **D — Rede/arquivos:** compara `read`/`write` e `sendfile` por `socketpair`, sem rede externa.
- **E — Algoritmos:** testa PID, min/max e regressão incremental em userspace.

## Execução

```sh
make
make test
make run
./repeat_benchmarks.sh 5
```

Os resultados são gravados em `results/`. Números obtidos em uma única execução não constituem benchmark publicável; servem para validar o harness e revelar bloqueios.

## Segurança

- nenhum script monta debugfs, altera sysctl, carrega módulo ou muda scheduler global;
- fault injection real é deliberadamente bloqueada fora de VM;
- o benchmark de I/O usa arquivo temporário anônimo de 64 MiB em `/tmp` e `socketpair` local;
- o estudo de scheduler usa apenas políticas permitidas a usuário normal;
- o kernel Ubuntu em uso não é modificado.
