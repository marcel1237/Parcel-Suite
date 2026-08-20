# Migração para o PlayOS Kernel

ID: `KB-PLAYOS-KERNEL-MIGRATION`

- tipo: `implementation`
- confiança: `high`
- estado: `build-no-runtime`
- verificado em: `2026-08-19`
- fontes: `SRC-PLAYOS-KERNEL1`, `SRC-NTSYNC-NOBLE`, `SRC-LINUX718-BUILD`

## O produto

PlayOS Kernel é um kernel Linux Ubuntu Noble 6.8.4 mantido por patches
rastreáveis. A primeira identidade é `6.8.4-playos-kernel1+`. Não é FreeBSD e
não deve usar um nome que sugira ABI ou kernel FreeBSD.

## O que veio da linha moderna

NTSYNC foi portado do Linux 7.1.8 como módulo reversível. `mseal` foi trazido da
implementação oficial inicial do Linux 6.10, mais próxima das APIs de memória
do Noble, usando o 7.1.8 como referência de maturidade. O kernel e esses objetos
compilam; runtime no kernel produzido ainda não foi comprovado.

## O que não será copiado diretamente

`sched_ext`, Rust/EXECMEM e stacks completas de DRM ou drivers exigem projetos
próprios. DRM Panic conflita com o framebuffer console do perfil Generic.
`fwctl` isolado não agrega valor sem atualizar seus grandes consumidores. Vários
recursos do 7.1.8 já existem no Noble e só devem receber correções pontuais.

## Regra para retirar a árvore 7.1.8

A árvore só pode ser removida depois de preservar patches, origem e licenças;
classificar todos os candidatos; obter build limpo, initramfs, assinatura, boot,
selftests, regressão e rollback; e manter hashes ou referência upstream que
permitam reconstrução. Até lá, ela é uma fonte auditável, não lixo duplicado.
