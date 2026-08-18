# Laboratório de DNA de Kernels: NitroCore

Este documento detalha a análise profunda dos fontes localizados na pasta `Kernels/` e as ações para a criação do kernel **NitroCore Híbrido**.

## 1. Inventário do Laboratório

| Ativo | Versão | Papel no Projeto |
| :--- | :--- | :--- |
| **Linux Vanilla** | 7.1.8 | **Molde de Vanguarda**: O núcleo mais moderno disponível. |
| **Ubuntu Resolute** | 6.8 (Noble Base) | **Molde de Compatibilidade**: Fornece drivers e patches da Canonical. |
| **Connectiva 4** | 2.2.5 | **Legado e História**: Estudo de patches históricos brasileiros. |
| **FreeBSD** | 15/16 | **Referência de Rede**: Estudo da stack de rede `sys/`. |

---

## 2. Análise de DNA (Opção 1): Anatomia do Kernel Ubuntu Resolute

### Identificação Confirmada:
Sua identificação está **corretíssima**. O kernel do Ubuntu 26 Resolute é, tecnicamente, uma evolução da estrutura de empacotamento do **Debian**, com adições específicas da Canonical.

**Estrutura Observada:**
1.  **Pasta `debian.master/`**: Contém todo o "DNA" de empacotamento Debian. É aqui que são definidos os scripts de build, o gerenciamento de dependências e a lógica de criação dos pacotes `.deb`.
2.  **Pasta `ubuntu/`**: Esta pasta é o diferencial. Ela contém drivers e patches que não existem no kernel Debian puro, como drivers de parceiros (ODM) e otimizações específicas para o ecossistema Ubuntu.
3.  **Kernel Vanilla como Base**: Fora dessas duas pastas, o código-fonte (como `fs/`, `mm/`, `drivers/`) segue a árvore principal do Linux.

**Conclusão para o NitroCore:**
O NitroCore será construído seguindo este mesmo modelo "Híbrido":
- Usaremos a **estrutura de empacotamento Debian** (via `debian.master/`) para garantir que o kernel seja instalável via APT.
- Injetaremos a nossa própria pasta **`nitrocore/`** (similar à pasta `ubuntu/`) para conter nossas otimizações de performance.

---

## 3. Legado Connectiva (Opção 2): Utilidade Retro

### Análise Conceitual:
- **Drivers de Rede**: Patches como `linux-2.2.5-networking.patch` e `linux-2.2.5-tokenring.patch` mostram como a Connectiva lidava com hardware de rede brasileiro na época.
- **Lição de Simplicidade**: O kernel 2.2.5 era muito menor. O NitroCore herdará a filosofia de **remover drivers obsoletos** para manter o binário leve, mantendo apenas o suporte a hardware moderno.
- **Compatibilidade**: Não utilizaremos o código do 2.2.5 diretamente, mas sim a técnica de **Modularização Limpa** para evitar o inchaço do kernel.

---

## 4. Orquestrador Híbrido (Opção 3): Script de Build Unificado

Criamos o protótipo `scripts/hybrid_build.sh` que executa:
1.  **Sincronização**: Usa a árvore 7.1.8 como base.
2.  **Injeção**: Copia a pasta `ubuntu/` e patches críticos da árvore Resolute para a base 7.1.8.
3.  **Configuração**: Faz o merge do `.config` Vanilla com as necessidades de hardware do Ubuntu.

---
*Atualizado em: 2026-08-18*
