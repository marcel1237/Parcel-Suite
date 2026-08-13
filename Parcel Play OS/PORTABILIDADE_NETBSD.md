# Portabilidade Universal: A Arquitetura Anykernel (NetBSD Style)

O **Parcel Play OS** adota a filosofia **Anykernel** do NetBSD para garantir que o NitroCore seja o núcleo mais estável e portátil do mercado.

## 1. O Conceito Rump Kernel

Diferente de kernels puramente monolíticos, onde uma falha em um driver pode derrubar todo o sistema (Kernel Panic), a nossa implementação inspirada no NetBSD permite:
*   **Isolamento de Drivers**: Drivers de sistemas de arquivos, pilhas de rede e controladores de som podem rodar como bibliotecas em user-space.
*   **Rump Server**: Utilizamos o `rump_server` para disponibilizar serviços de kernel sem que eles residam permanentemente no espaço de memória privilegiado.

## 2. Implementação no NitroCore

Utilizamos o framework **Rumprun** para integrar drivers do NetBSD 11.0 diretamente na nossa base Linux:
1.  **Syscall Mapping**: Tradução de hypercalls do Rump para chamadas nativas do Linux NitroCore.
2.  **LXC Integration**: Drivers isolados rodam dentro de containers leves, protegendo o núcleo principal.
3.  **MicroVM Support**: Otimização para boot em 10ms em ambientes virtualizados.

## 3. Benefícios
*   **Estabilidade**: Se o driver de Wi-Fi falhar, apenas o processo do driver reinicia, não o computador.
*   **Portabilidade**: Facilita a execução do Parcel Play OS em arquiteturas exóticas (ARM, RISC-V) utilizando drivers genéricos do NetBSD.

---
*Status: Arquitetura Anykernel Integrada.*
