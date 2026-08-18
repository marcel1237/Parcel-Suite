# Fedora: A Vanguarda Tecnológica e a Ponte para o Windows

O **Fedora Workstation** (especialmente a versão 44 de 2026) serve como a referência técnica para o **Parcel Play OS** no que diz respeito à integração de hardware moderno e compatibilidade agressiva com o ecossistema Windows.

## 1. NTSYNC: A Revolução da Sincronização
A maior contribuição do Fedora para o DNA do NitroCore é o suporte ao **NTSYNC**.
- **O que é**: Implementação nativa das primitivas de sincronização do Windows NT (mutexes, semáforos, eventos) diretamente no kernel Linux.
- **Vantagem**: Elimina o gargalo do `wineserver`, permitindo que o Proton execute jogos e apps Adobe/Office com latência quase zero.
- **NitroCore Integration**: O módulo `nitro_ntsync.c` é baseado diretamente nesta arquitetura do Fedora para garantir 100% de compatibilidade NT.

## 2. Escalonador EEVDF e Proxy Execution
O Fedora liderou a transição do antigo escalonador CFS para o **EEVDF** (Earliest Eligible Virtual Deadline First).
- **Foco**: Garantir que processos sensíveis à latência (áudio, vídeo, frames de jogos) nunca percam seus prazos virtuais.
- **Proxy Execution**: Resolve problemas de "inversão de prioridade", onde um processo lento trava um processo rápido.
- **NitroCore Integration**: O `nitro_sched.c` utiliza os conceitos de "Virtual Deadline" do Fedora para dar o "Nitro-Boost" na interface 3D.

## 3. BTRFS e Gestão de Dados
O Fedora é o pioneiro no uso do **BTRFS** como sistema de arquivos padrão.
- **Snapshots**: Permite rollbacks instantâneos do sistema.
- **Compressão Transparente**: Usa ZSTD para economizar espaço em disco e aumentar a vida útil do SSD sem perda de performance.
- **NitroCore Integration**: Usaremos a lógica de subvolumes do Fedora para gerenciar nossas "Zonas de Agilidade" (Arch/AUR) de forma isolada e segura.

## 4. DNF5: Velocidade de Pacotes
O Fedora 44 consolidou o **DNF5** como o motor de pacotes mais rápido do mundo RPM.
- **DNA Parcel**: Nossa **Nitro-Fedora Zone** utilizará o DNF5 para garantir que o download e instalação de ferramentas do ecossistema Fedora sejam instantâneos.

---
*Filosofia: O Fedora é onde o futuro do Linux acontece primeiro. O Parcel Play OS traz esse futuro para o presente.*
