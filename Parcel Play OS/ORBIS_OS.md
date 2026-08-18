# Orbis OS: A Engenharia por trás do PlayStation (PS4/PS5)

O **Orbis OS** é o sistema operacional proprietário da Sony Interactive Entertainment. Ele serve como a referência máxima de como um núcleo **FreeBSD** pode ser transformado em uma plataforma de entretenimento de alta performance.

## 1. Arquitetura do Kernel
Diferente dos sistemas operacionais de propósito geral, o Orbis OS é verticalizado para hardware específico (AMD x86-64 Custom APUs).

- **Base de Código**:
    - **PlayStation 4**: Baseado no **FreeBSD 9.0**.
    - **PlayStation 5 (Orbis 2.0)**: Baseado no **FreeBSD 11/12**.
- **Natureza**: Monolítico, mas com um "Microkernel de Sistema" isolado que gerencia chaves de criptografia e segurança em segundo plano.

## 2. A Tabela de Syscalls (O Segredo da Sony)
O Orbis OS mantém a compatibilidade POSIX, mas estende o kernel com centenas de chamadas exclusivas.
- **Syscalls 1-531**: Mapeamento padrão do FreeBSD (arquivos, sockets, memória).
- **Syscalls 532+**: Chamadas Sony-Proprietary (atualmente ultrapassando 650).
- **Funcionalidades Chave**:
    - `sys_dynlib_load_prx`: Carregamento de bibliotecas dinâmicas proprietárias (`.prx`).
    - **Direct Memory Access**: Chamadas para gestão unificada da memória GDDR (VRAM e RAM no mesmo barramento).

## 3. Pilhas Gráficas e de I/O

### Gráficos (GNM / AGC)
A Sony ignora APIs universais como DirectX ou Vulkan para extrair o máximo do silício:
- **GNM (PS4)**: API de baixo nível para controle direto de buffers de comando da GPU.
- **AGC (PS5)**: Evolução para arquitetura RDNA 2, suportando Ray Tracing e Mesh Shaders nativamente no kernel.
- **PSSL**: Linguagem de shader própria da PlayStation, otimizada para o conjunto de instruções da AMD.

### I/O de Ultra-Velocidade (PS5)
O Orbis 2.0 utiliza um **I/O Complex** que redefine o carregamento de dados:
- **Descompressão em Hardware**: O OS delega a descompressão de arquivos (Kraken/Zlib) para chips dedicados, liberando os núcleos de CPU.
- **Coherency Engine**: Garante que o cache da GPU receba dados do SSD instantaneamente, eliminando o gargalo do sistema de arquivos tradicional.

## 4. Segurança e Isolamento
- **Prisons (Jails)**: Todo aplicativo e jogo roda em uma "Prisão" (FreeBSD Jail) altamente restrita.
- **Isolamento de WebKit**: O navegador do console roda em uma sandbox separada para que exploits de web não alcancem os dados dos jogos.

## 5. Aplicação no Parcel Play OS (NitroCore)
O NitroCore absorve as seguintes lições do Orbis OS:
1.  **Syscall Expansion**: Inclusão de chamadas específicas para o Thunder SDK via IOCTLs.
2.  **Unified Memory**: Otimização do barramento PCIe para transferências P2P (Direct Storage).
3.  **Security Prisons**: Implementação do **Nitro-Jail** inspirado na rigidez do Orbis.

---
*Status: Documentação Técnica de Referência Orbis OS Finalizada.*
