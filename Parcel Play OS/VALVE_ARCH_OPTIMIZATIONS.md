# O Legado da Valve no Arch Linux: Lições para o NitroCore

A Valve escolheu o **Arch Linux** como base para o SteamOS 3 devido ao controle total e agilidade técnica. Analisamos as modificações da Valve para integrar essa inteligência ao **Parcel Play OS**.

## 1. Repositórios de Elite (Tiered Repos)
Diferente do Arch padrão, a Valve utiliza uma estratégia de "estabilidade em camadas":
- **`jupiter`**: Contém drivers específicos de hardware e firmwares.
- **`holo`**: Contém as modificações de interface e o Steam Client.
- **`core/extra`**: Espelhos do Arch, mas **congelados em versões testadas**.
- **Lição**: O Parcel Play OS terá repositórios "Snapshot", garantindo que uma atualização do Arch não quebre os drivers do Ubuntu 26.

## 2. Kernel "Neptune" (O Antecessor do NitroCore)
O kernel da Valve (`linux-neptune`) foca em:
- **Latência de Input**: Redução do polling de controles para **sub-1ms**.
- **AMD P-State**: Implementação do **EPP Boost** para performance gamer.
- **MGLRU**: Gestão de memória agressiva para evitar quedas de FPS (já integrado ao NitroCore).

## 3. Imutabilidade e HoloISO
A Valve transformou o Arch em um sistema imutável (Read-Only). 
- **A/B Partitioning**: Atualiza o sistema inteiro em uma partição separada e troca no próximo boot.
- **Lição**: O Parcel Play OS usará a base imutável do Ubuntu 26, mas com o "espírito" do Arch para as ferramentas de vanguarda.

## 4. Gamescope (O Coração Visual)
O micro-compositor da Valve é a maior inovação visual.
- **Bypass total**: Ele permite que o jogo renderize diretamente no buffer da GPU.
- **Integrado**: O NitroCore já suporta o Gamescope nativamente para a Sessão Full (KDE).

---
*Status: Inteligência da Valve integrada ao Plano Estratégico.*
