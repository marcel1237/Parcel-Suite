# Manifesto de baseline

## Ubuntu Noble

- diretório atual: `Kernels/ubuntu 26 resolute kernel/`;
- o nome do diretório está errado, mas o conteúdo é Noble;
- versão fonte: Linux 6.8.4;
- pacote: `linux (6.8.0-30.30) noble`;
- commit: `74134bfb6b720ca18a73931662cbcc8170ef1bed`;
- clone raso: sim;
- caminho contém espaços e não aceita build Kbuild completo;
- branch de trabalho: `codex/playos-freebsd-syskern-6.8-lab`.

## FreeBSD

- diretório: `/home/marcel/Parcel Suite/Operating Systems/freebsd-15.1.0-p2`;
- tag: `release/15.1.0-p2`;
- commit: `aadd58dddcbc78f4d5594827b46b5633552b15ce`;
- remote: `https://git.FreeBSD.org/src.git`;
- checkout limpo;
- `sys/`: aproximadamente 582 MiB;
- `sys/kern`: 248 arquivos no primeiro nível;
- hash da lista ordenada de arquivos de `sys/kern`:
  `9e8f599aea0a78f54111f2e12a391c1b311b6c4334924dc0b5225b402b9922f2`.

## Proveniência

Toda derivação deve registrar arquivo FreeBSD, licença, commit, comportamento
extraído e implementação Linux. BSD-2/3/4-Clause e arquivos históricos não
serão tratados como uma licença única. Código Linux resultante segue a licença
apropriada da árvore Linux e preserva atribuições exigidas.

## Estado de validação

- patches iniciais aplicados: sim;
- selftest sendfile direto: PASS;
- inventário de capacidades: PASS/SKIP esperado;
- build Kbuild: bloqueado pelo caminho;
- pacote Debian: não criado;
- boot em VM/hardware: não executado;
- patches de subsistemas FreeBSD: nenhum copiado.
