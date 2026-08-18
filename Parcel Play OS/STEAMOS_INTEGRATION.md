# Inteligência SteamOS: O Guia de Otimização da Valve

O **SteamOS** (especialmente nas versões 3.5 e 3.8+) é a nossa maior referência para o pilar "Play" do Parcel Play OS. Analisamos a arquitetura da Valve e extraímos o DNA necessário para o **NitroCore**.

## 1. O Kernel "Jupiter/Neptune"
A Valve mantém uma série de patches críticos (atualmente na série Linux 6.16/6.18+) que transformam o Linux em um console de games:

- **MGLRU (Multi-Gen LRU)**: Integrado e forçado. Reduz o uso de CPU durante a gestão de memória pesada, evitando quedas de FPS em momentos de carregamento de texturas.
- **AMD P-State EPP Boost**: O NitroCore herda a lógica de impedir que o CPU baixe a frequência quando o jogo está em "short-sleep" (esperando o próximo quadro da GPU).
- **Ultra-Low Latency Input**: Patches que reduzem o atraso dos controles de ~8ms para **sub-1ms** através de ajustes no polling do kernel.

## 2. Gamescope: O Micro-Compositor
O **Gamescope** é o segredo da Valve para performance gráfica. O Parcel Play OS integrará o Gamescope como a camada de renderização para a **Sessão Full (KDE)**.
- **Bypass de Desktop**: O Gamescope fala diretamente com o kernel DRM, eliminando camadas que geram latência de input.
- **Integer Scaling & FSR**: Permite que qualquer jogo (mesmo os antigos) use upscaling de alta qualidade sem custo adicional de processamento.

## 3. Gestão de Cores no Kernel
A Valve reescreveu parte do pipeline de cores do kernel Linux.
- **HDR Nativo**: O NitroCore incluirá os patches de "driver-private color properties" da Valve, permitindo HDR real e tonemapping direto no hardware (LUT da GPU).
- **Emulação sRGB**: Melhora a vibração das cores sem causar "clipping" digital.

## 4. O Handoff da Valve (Gamescope-Session)
Utilizaremos a arquitetura do `gamescope-session` para o nosso **Dark Volt**:
- Iniciar o compositor imediatamente no boot.
- Alternar entre a interface de login e o ambiente 3D sem reiniciar o driver de vídeo.

---
*Filosofia: Se a Valve provou que funciona no Steam Deck, o NitroCore fará funcionar em todo o hardware moderno.*
