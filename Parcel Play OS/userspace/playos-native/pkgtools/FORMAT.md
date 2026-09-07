# Formato de pacote PlayOS `.pxz` v1

Um `.pxz` é um arquivo tar comprimido com xz. O payload reproduz caminhos
relativos à raiz. Metadados ficam em `PLAYOS/meta` e não são instalados.

Campos obrigatórios:

```text
NAME=hello
VERSION=1.0
ARCH=x86_64
BUILD=1
LICENSE=MIT
```

Restrições v1:

- nomes usam somente `A-Za-z0-9._+-`;
- nenhum caminho absoluto ou componente `..`;
- symlinks absolutos ou com componente `..` são recusados;
- device nodes, FIFOs e sockets são recusados no formato v1;
- instalação recusa sobrescrever arquivo pertencente a outro pacote;
- banco fica em `/var/lib/playpkg` ou sob `--root`;
- scripts de pós-instalação ainda não são suportados;
- assinatura criptográfica e transações atômicas completas são gates futuros.

Este formato é inspirado na simplicidade dos pacotes Slackware, mas não é um
pacote Slackware e não promete compatibilidade com `pkgtools`.
