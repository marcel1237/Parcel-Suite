# OpenBSD: A Referência em Segurança Proativa e Blindagem

O **OpenBSD** (versão 7.9 de 2026) é a nossa "Bússola de Segurança". Ele não apenas corrige bugs, ele implementa tecnologias que tornam classes inteiras de ataques impossíveis.

## 1. Pledge(2) e Unveil(2): O Sandbox Definitivo
O OpenBSD criou a forma mais elegante de isolar aplicativos.
- **Pledge**: O app promete ao kernel que só usará certas funções (ex: "só quero ler arquivos e usar a rede"). Se ele tentar fazer algo diferente, o kernel o encerra imediatamente.
- **Unveil**: O app só pode "enxergar" as pastas que o desenvolvedor autorizou.
- **NitroCore Integration**: Nosso módulo **Nitro-Jail** emula o `unveil` usando Linux Namespaces, garantindo que o **Thunder Browser** nunca veja seus arquivos pessoais.

## 2. KARL: Kernel Address Randomized Link
Enquanto o Linux randomiza o lugar onde o kernel começa na memória (KASLR), o OpenBSD faz o **KARL**.
- **O que é**: No boot, o sistema gera um binário de kernel **único** para aquela sessão, trocando a ordem das funções internas.
- **DNA Parcel**: Estudaremos a implementação de um "Nitro-Linker" que gera versões customizadas do NitroCore a cada atualização de sistema, tornando exploits de memória impossíveis de serem repetidos.

## 3. Retguard e Pinsyscalls
Novas defesas de 2026 que o NitroCore herda:
- **Retguard**: Proteção contra ataques de estouro de pilha (Stack Smash).
- **Pinsyscalls**: Garante que chamadas de sistema só venham de lugares autorizados da biblioteca C (`libc`), matando "shellcodes" de hackers antes que comecem.

---
*Filosofia: Segurança não é um plugin, é a base. O OpenBSD é o nosso escudo.*
