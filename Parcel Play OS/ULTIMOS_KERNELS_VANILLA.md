# Status dos Kernels Linux Vanilla (Setembro 2026)

Este documento registra as versões mais recentes do kernel Linux "puro" (vanilla) disponíveis no kernel.org para orientação do projeto PlayOS.

---

## 1. Versões Atuais (21/09/2026)

| Categoria | Versão | Data de Lançamento | Observação |
| :--- | :--- | :--- | :--- |
| **Mainline** | **7.3-rc4** | 20/09/2026 | Versão de desenvolvimento (Release Candidate). |
| **Stable** | **7.2.6** | 14/09/2026 | **Recomendada para o PlayOS (Estável/Vanguarda).** |
| **Longterm (LTS)** | **6.18.52** | Set/2026 | Base de estabilidade a longo prazo. |
| **Longterm (LTS)** | **6.12.110** | Set/2026 | Versão com suporte estendido. |

---

## 2. Implicações para o PlayOS

*   **Série 7.x**: Introduz otimizações profundas no escalonador (scheduler) e suporte aprimorado para CPUs híbridas (Performance/Efficiency cores), o que pode beneficiar a performance de jogos e multitarefa no PlayOS.
*   **Transição Noble (6.8) -> Vanilla (7.2)**: Mudar para a base 7.2 significa ganhar suporte nativo a tecnologias que no 6.8 precisariam de backports complexos.

## 3. Link de Referência
Sempre verifique o status em tempo real em: [kernel.org](https://www.kernel.org)
