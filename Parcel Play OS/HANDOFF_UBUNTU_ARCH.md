# Plano de Handoff: A Simbiose Ubuntu-Arch

Este documento detalha a orquestração técnica entre a fundação estável (**Ubuntu 26**) e a vanguarda tecnológica (**Arch Linux/AUR**), garantindo uma experiência de usuário sem costuras.

## 1. O Handoff de Bibliotecas (Glibc Hybrid)
Para evitar conflitos entre as versões da `glibc`, o Parcel Play OS utiliza o **Namespace de Montagem Híbrido**.

### Como funciona:
1.  **O Gatilho**: Quando o usuário clica em um app do Arch (AUR), o script `nitro-pkg` inicia o processo.
2.  **A Bolha**: O sistema cria um namespace isolado onde a pasta `/lib` é redirecionada para a versão vanguarda do Arch.
3.  **O Compartilhamento**: Pastas como `/home`, `/tmp` e `/dev` são "linkadas" do sistema host (Ubuntu).
4.  **Resultado**: O app do Arch "pensa" que está em um sistema puro Arch, mas salva seus documentos e acessa a GPU do seu sistema Ubuntu de forma nativa.

## 2. Exportação de Aplicações (Seamless Integration)
O **Nitro-APX** (nosso motor de contêiner) realiza a ponte de interface:
- **Desktop Entry**: Ao instalar um app no Arch, um arquivo `.desktop` é gerado automaticamente em `~/.local/share/applications/` no host Ubuntu.
- **Ícones e Temas**: O app do Arch herda automaticamente o tema **Breeze Dark** e o cursor do mouse do seu KDE Plasma principal.

## 3. O Handoff de Performance (NitroCore)
O kernel não faz distinção entre o app "nativo" (Ubuntu) e o app "vanguarda" (Arch). Ambos recebem:
- **Nitro-Boost**: Prioridade de CPU do escalonador.
- **OmniLock**: Travamento de memória na RAM.
- **NTSYNC**: Sincronização acelerada se o app for um jogo Windows vindo do AUR.

## 4. Matriz de Responsabilidades

| Responsabilidade | Camada Ubuntu (Host) | Camada Arch (Nitro-Zone) |
| :--- | :--- | :--- |
| **Boot & Kernel** | Sim (NitroCore) | Não |
| **Drivers de Vídeo** | Sim (Mesa/Proprietário) | Não (Usa os do Host) |
| **Apps de Trabalho** | Sim (Office/Navegador) | Opcional |
| **Apps de Dev/AUR** | Não | **Sim (Prioridade)** |

---
*Filosofia: O Ubuntu é a rocha. O Arch é a flecha.*
