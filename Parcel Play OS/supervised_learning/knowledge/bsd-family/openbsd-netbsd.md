# OpenBSD e NetBSD na estratégia PlayOS

ID: `KB-BSD-FAMILY`

- tipo: `inference`
- confiança: `medium`
- estado: `experimental`
- verificado em: `2026-08-19`
- fontes: `SRC-OPENBSD-FREEBSD`, `SRC-OPENBSD-NOTES`, `SRC-NETBSD-NOTES`, `SRC-BSD-TRIAD`

## FreeBSD versus OpenBSD

O documento comparativo posiciona FreeBSD como a base BSD mais adequada para
servidor, armazenamento, ZFS, Jails, bhyve e maior amplitude de hardware. O
OpenBSD é referência de segurança por padrão, auditoria do sistema base,
mitigações, PF e simplicidade deliberada.

Para PlayOS, a conclusão vigente é usar FreeBSD como alvo funcional principal e
estudar políticas OpenBSD de redução de superfície, defaults seguros e revisão.
Isso não autoriza copiar código OpenBSD sem fonte, licença e teste.

## NetBSD

As notas existentes destacam portabilidade, interfaces de drivers e rump
kernels. Porém, não há árvore NetBSD completa nem auditoria equivalente à do
FreeBSD. Portanto qualquer recomendação NetBSD permanece conceitual e com
confiança baixa/média.

## Limitação essencial

O corpus BSD é assimétrico: FreeBSD possui fonte completa, inventário e estudos;
OpenBSD possui comparação documental; NetBSD possui notas breves. Uma IA deve
refletir essa diferença de evidência, não tratar a “tríade BSD” como três bases
igualmente validadas.
