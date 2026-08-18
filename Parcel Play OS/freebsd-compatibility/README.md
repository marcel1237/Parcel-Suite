# Parcel FreeBSD Compatibility Fabric

Solução para tornar o FreeBSD 15.1 do Parcel Play OS tão compatível quanto é
tecnicamente possível, sem misturar ABIs de kernel nem prometer suporte falso.

## Decisão de arquitetura

Um único mecanismo não cobre todo o catálogo. O sistema deve escolher o backend
menos custoso que satisfaz cada aplicação:

1. **FreeBSD nativo (`pkg`/Ports):** primeira opção para desktop, servidor,
   ferramentas e jogos portados.
2. **Linuxulator em Linux jail:** binários Linux de userspace que não dependem
   de uma funcionalidade exclusiva do kernel Linux.
3. **Wine nativo:** aplicações Windows compatíveis com Wine no FreeBSD.
4. **bhyve:** Linux ou Windows completo para software dependente de kernel,
   driver, anti-cheat, Waydroid, NTSYNC, CUDA ou APIs sem equivalente FreeBSD.
5. **Streaming/host remoto:** fallback para GPU ou anti-cheat que não funcionem
   de modo confiável nem com passthrough.

```text
aplicação
   ├─ existe pacote/port FreeBSD? ───────────────► nativo
   ├─ binário Linux somente userspace? ─────────► Linux jail
   ├─ aplicativo Windows suportado pelo Wine? ──► Wine
   ├─ exige kernel/driver/anti-cheat específico? ► bhyve
   └─ GPU/passthrough inviável? ────────────────► streaming
```

Jails e Linuxulator compartilham o kernel FreeBSD. Uma Linux jail melhora
isolamento e organização, mas não fornece syscalls ou drivers de um kernel
Linux real. O bhyve é a fronteira correta quando essa diferença importa.

## Componentes deste kit

- `COMPATIBILITY_MATRIX.md`: decisões por classe de software;
- `IMPLEMENTATION_PLAN.md`: fases, critérios e riscos;
- `config/capability-policy.tsv`: política legível por máquina;
- `scripts/audit-host.sh`: auditoria somente leitura de um host FreeBSD;
- `scripts/check-kit.sh`: validação estática do próprio kit.

## Uso seguro

Em um FreeBSD 15.1 instalado, execute sem privilégios:

```sh
sh scripts/audit-host.sh
```

O script não instala pacotes, não carrega módulos e não altera `rc.conf`. A
saída identifica quais backends podem ser habilitados. Mudanças de sistema só
devem entrar depois em scripts separados, idempotentes e com confirmação.

No repositório, valide o kit com:

```sh
sh scripts/check-kit.sh
```

## Fontes oficiais

- [Compatibilidade binária Linux](https://docs.freebsd.org/en/books/handbook/linuxemu/)
- [Jails, inclusive Linux jails](https://docs.freebsd.org/en/books/handbook/jails/)
- [Wine no FreeBSD](https://docs.freebsd.org/en/books/handbook/wine/)
- [Wayland e Xwayland](https://docs.freebsd.org/en/books/handbook/wayland/)
- [Virtualização com bhyve](https://docs.freebsd.org/en/books/handbook/virtualization/)

## Limite do resultado atual

Este kit define a solução e audita pré-requisitos. Ele ainda não prova GPU,
áudio, suspend/resume, Wine, Steam, passthrough ou anti-cheat em hardware real.
Esses itens precisam de uma instalação FreeBSD inicializável e uma matriz de
máquinas físicas.
