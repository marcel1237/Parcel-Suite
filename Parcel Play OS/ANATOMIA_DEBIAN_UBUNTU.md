# Anatomia Técnica: Kernel Debian vs. Ubuntu (Referência 2026)

Este documento documenta as descobertas sobre a estrutura dos kernels Debian e Ubuntu, servindo de guia para a construção do **NitroCore**.

## 1. O Modelo Debian (A Base)
O Debian fornece a **Infraestrutura de Build**.
- **Pasta `debian.master/` (ou `debian/`)**: Contém os metadados do pacote.
    - `changelog`: Histórico de versões.
    - `control`: Dependências de build.
    - `rules`: O script que orquestra o compilador GCC.
- **Filosofia**: Estabilidade máxima. O kernel atual do **Debian 13 (Trixie)** foca no **Linux 6.12 LTS**. Ele é mais "antigo", mas extremamente testado e livre de blobs binários (DFSG).

## 2. O Modelo Ubuntu (A Extensão)
O Ubuntu pega a base Debian e adiciona a **Habilitação de Hardware (HWE)**.
- **Pasta `ubuntu/`**: Onde a mágica acontece.
    - Contém drivers de fabricantes (Nvidia, Intel Panther Lake) que ainda não entraram no Linux oficial.
    - Inclui patches de segurança para **Livepatch** (atualização sem reboot).
- **Filosofia**: O kernel do **Ubuntu 26 Resolute** utiliza o **Linux 7.0**, sendo muito mais moderno que o do Debian. Ele é focado em laptops novos e IA (NPUs).

## 3. O que o Debian tem que o Ubuntu não tem?
Após análise, identifiquei pontos que o Debian preserva e o Ubuntu altera:
- **Pureza de Licença**: O kernel do Debian é "limpo" (sem firmware proprietário no núcleo). O Ubuntu já vem com "blobs" embutidos na pasta `ubuntu/` para facilitar o uso.
- **Conserva de ABI**: O Debian mantém a mesma interface binária (ABI) por anos. O Ubuntu a quebra frequentemente para introduzir novos drivers (HWE).
- **Simplicidade de Build**: O sistema de build do Debian é mais fácil de auditar, pois não possui as camadas de scripts complexos que a Canonical usa para buildar kernels de nuvem (AWS/Azure).

## 4. Estratégia NitroCore
O **NitroCore** será a terceira via:
1.  Pegaremos a **Infraestrutura do Debian** (para ser fácil de buildar).
2.  Pegaremos a **Modernidade do Ubuntu** (Kernel 7.0+).
3.  Adicionaremos a **Aceleração Parcel** (Pasta `nitrocore/`).

---
*Atualizado em: 2026-08-18*
