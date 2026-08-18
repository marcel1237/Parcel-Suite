# Integração KDE Plasma 6 + Gamescope

Este documento detalha como o **Parcel Play OS** implementará a **Sessão Full (KDE)** rodando dentro do **Gamescope**, emulando a experiência "Game Mode" da Valve em todo tipo de hardware.

## 1. Arquitetura "Nested Compositor"
Em vez de rodar o KDE diretamente sobre o Wayland padrão, utilizaremos o Gamescope como o micro-compositor primário:
- **Latência Zero**: O Gamescope fala diretamente com o hardware DRM.
- **FSR & Upscaling**: Qualquer janela aberta no KDE poderá usar o upscaling da AMD (FSR) nativamente.

## 2. Implementação Técnica
Utilizaremos um script de "Shadowing" para injetar o Gamescope na inicialização do Plasma:

```bash
export QT_QPA_PLATFORM=wayland
export XDG_SESSION_TYPE=wayland
gamescope -W 1920 -H 1080 -r 60 --expose-wayland -e -- dbus-run-session startplasma-wayland
```

## 3. Benefícios para o Usuário
- **HDR Nativo**: Suporte total a High Dynamic Range em todas as janelas do sistema.
- **VRR (Variable Refresh Rate)**: Fim do "tearing" visual mesmo em modo janela.
- **Isolamento de Performance**: O Gamescope protege o compositor de quedas de performance de aplicativos individuais.

## 4. Integração com OmniLock
O Gamescope será o primeiro beneficiário do **OmniLock Memory Matrix**:
- **Texture Pinning**: As texturas compartilhadas entre o KDE e o Gamescope serão travadas na RAM física através da função `omnilock_pin_gamescope_buffer`.
- **Zero-Copy Handoff**: Isso permite transferências de memória de até **15GB/s** entre a CPU e a GPU, eliminando qualquer micro-stuttering causado por swap de memória de vídeo.

---
*Status: Em fase de prototipagem no script de inicialização.*
