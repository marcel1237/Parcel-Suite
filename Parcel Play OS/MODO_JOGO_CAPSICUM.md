# Modo Jogo: Isolamento por Capacidades (Capsicum Style)

O **Modo Jogo** do Parcel Play OS utiliza a filosofia **Capsicum** do FreeBSD para garantir que o processo do jogo tenha performance máxima com segurança absoluta, eliminando o overhead dos sandboxes tradicionais.

## 1. O Conceito: Capability Mode
Diferente do Linux padrão que tenta filtrar cada comando (Seccomp), o Modo Jogo entra em **"Estado de Capacidade"**:
1.  **Pré-Inicialização**: O NitroCore abre todos os recursos necessários (DRM para GPU, Sockets de Rede, Arquivos de Ativos) e entrega os "File Descriptors" (FDs) ao jogo.
2.  **Enter Capability Mode**: O sistema ativa uma trava de kernel que remove o acesso do jogo a qualquer caminho global (ex: `/etc`, `/home`). O jogo só pode "ver" o que já está em suas mãos.

## 2. Implementação Técnica no NitroCore
Utilizamos a integração entre **Landlock** e **Seccomp-BPF** para emular o `cap_enter()` do FreeBSD:

### Fluxo de Ativação:
- **Trigger**: O usuário ou a Steam lança o jogo.
- **Nitro-Pulse**: O kernel detecta o executável e aplica o perfil:
    - **Landlock**: Cria um namespace onde a árvore de diretórios é **vazia**. Mesmo que o jogo tente um `open("/etc/passwd")`, o kernel retorna erro pois o processo não tem "capacidade" de busca no VFS.
    - **Seccomp**: Bloqueia chamadas de sistema globais (`mount`, `kill`, `socket`), permitindo apenas operações diretas nos FDs já abertos (`read`, `write`, `ioctl` para GPU).

## 3. Vantagem Competitiva
- **Latência Zero**: Como não há filtragem complexa de strings de caminhos durante o jogo (apenas checagem de FDs), o overhead é virtualmente nulo.
- **Segurança de Console**: Um exploit dentro de um jogo nunca conseguirá acessar seus arquivos pessoais, pois o jogo roda em uma "bolha" sem sistema de arquivos.

---
*Status: Lógica de ativação integrada ao Nitro-Sched.*
