# Nitro-Verify: Integridade do Sistema Imutável (Veriexec Style)

O **Nitro-Verify** é o escudo de integridade do Parcel Play OS, inspirado no **Veriexec** do NetBSD. Ele garante que nenhum binário vital do sistema seja executado se tiver sido alterado, protegendo o núcleo imutável.

## 1. Arquitetura "Trust-on-First-Use"
O Nitro-Verify utiliza a **IMA (Integrity Measurement Architecture)** do Linux combinada com o **BPF-LSM** para uma fiscalização em tempo real.

### Componentes:
- **Hash Manifest**: Uma lista assinada digitalmente contendo os hashes (SHA-512) de todos os binários em `/usr/bin`, `/sbin` e os módulos do kernel em `/lib/modules`.
- **BPF Enforcement**: Um programa rodando no kernel que intercepta a chamada `execve()` e valida o arquivo antes de permitir sua execução.

## 2. Implementação no NitroCore
Emulamos o Veriexec através de dois níveis:

### Nível 1: Medição (IMA)
O kernel calcula o hash de cada binário ao ser aberto e o estende para o **TPM (Trusted Platform Module)** da máquina. Isso cria uma trilha de auditoria impossível de apagar.

### Nível 2: Execução (BPF-LSM)
Nosso programa BPF-LSM (`nitro_verify.o`) bloqueia a execução se o hash não estiver no **Nitro-Trust-Map**:
```c
if (bpf_ima_file_hash(file) != trusted_hash) {
    return -EPERM; // Acesso negado: Binário não autorizado
}
```

## 3. Proteção da Base Imutável
Como o sistema base do Parcel Play OS é somente-leitura (estilo SteamOS), o Nitro-Verify atua como a trava final: mesmo que alguém consiga montar o sistema em modo escrita e trocar o `sudo` ou o `kernel`, o Nitro-Verify impedirá o boot pois a assinatura não baterá.

---
*Status: Motor de integridade integrado à Fase de Build.*
