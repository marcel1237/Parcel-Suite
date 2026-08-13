# Matriz de Qualidade do Decágono (NitroCore)

Este documento detalha como o kernel **NitroCore** absorve e adapta as melhores qualidades técnicas dos 10 sistemas que compõem o nosso Decágono de Referência.

## 1. Mapeamento de DNA Técnico

| Sistema | Qualidade Herdada | Implementação no NitroCore |
| :--- | :--- | :--- |
| **OpenBSD** | Segurança Proativa | Uso de **Landlock**, **W^X** e **Seccomp-BPF** mandatários. |
| **FreeBSD** | Performance de Rede | Integração de **XDP**, **eBPF** e pilhas TCP/IP otimizadas. |
| **Oracle Linux** | Performance de I/O | Otimização do **io_uring** e suporte avançado a **HugePages**. |
| **CentOS Stream** | Hardening Enterprise | Implementação de **IMA** (Integrity Measurement Architecture). |
| **NetBSD** | Portabilidade | Arquitetura modular **Anykernel** (drivers em user-space via **Rump Kernels**). |
| **Gentoo** | Otimização de Build | Compilação com **LTO**, **PGO** e **CFLAGS** agressivas. |
| **Arch Linux** | Simplicidade (KISS) | Baseado no **Kernel Mainline** puro com mínima modificação. |
| **Fedora** | Vanguarda Tecnológica | Suporte nativo a **BTF**, **Maple Tree** e últimas APIs Linux. |
| **Debian** | Estabilidade | Patches de segurança **LTS** validados pela comunidade. |
| **openSUSE** | Configuração Modular | Ferramentas de build reproduzíveis e **Kconfig** granular. |

## 2. A "Super-Pilha" de Segurança e Integridade
Inspirado no trio OpenBSD, Debian e CentOS:
- **Verificação de Assinatura**: O kernel só carrega módulos assinados digitalmente por nossa chave privada.
- **Isolamento de Processos**: Cada "Flavor" aplica níveis diferentes de restrição de syscalls.

## 3. A "Super-Pilha" de I/O e Dados
Herdado do Oracle Linux (UEK) e FreeBSD:
- **Zero-Copy I/O**: Minimiza a cópia de dados entre kernel e apps, acelerando bancos de dados e jogos pesados.
- **Maple Tree Structure**: Substitui as antigas árvores de busca de memória por uma estrutura mais rápida e paralelizável.

---
*Status: Qualidade validada pelo Decágono de Referência.*
