# Design de Interface: Central de Segurança Nitro

A **Central de Segurança Nitro** é o painel de controle de integridade do Parcel Play OS, permitindo ao usuário monitorar e gerenciar o **Decágono de Blindagem** em tempo real.

## 1. Módulos de Monitoramento

A interface é baseada em **KDE Plasma 6 / Kirigami** e oferece visão clara dos seguintes motores:

| Módulo | Status Visível | Função |
| :--- | :--- | :--- |
| **Nitro-Jail** | Lista de Processos Isolados | Monitora quais apps estão em "Prisões" (FreeBSD style). |
| **Nitro-Verify** | Integridade de Binários | Mostra se o sistema imutável sofreu tentativas de alteração. |
| **Nitro-CFI** | Registro de Bloqueios | Exibe tentativas de ataques ROP barradas pelo kernel. |
| **Secure-Boot** | Status da Chave MOK | Confirma a validade do binário UKI (Unified Kernel Image). |

## 2. Lógica de "Modo de Defesa"
O usuário pode alternar entre três níveis de segurança:
1.  **Modo Gamer (Nitro)**: Ativa o NTSYNC e isolamento leve para máximo FPS.
2.  **Modo Trabalho (Standard)**: Proteção balanceada com Veriexec ativo.
3.  **Modo Fortaleza (Paranoid)**: Blindagem total (OpenBSD style), restrição máxima de syscalls.

## 3. Integração com a IA
A central exibe alertas baseados na **Aprendizagem Supervisionada**, identificando comportamentos anômalos de aplicativos antes que eles se tornem uma ameaça real.

---
*Status: Design de UI em fase de Mockup.*
