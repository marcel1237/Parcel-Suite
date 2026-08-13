# Navegador Thunder: Alta Performance Nativa

O **Thunder Browser** é a porta de entrada para a web no Parcel Play OS, otimizado para rodar em modo **Kiosk** diretamente sobre o hardware via **Dark Volt**.

## 1. Arquitetura Técnica

O navegador é construído sobre o motor **Qt WebEngine (Chromium)** com ajustes profundos para o backend **EGLFS**:
*   **Bypass de Servidor Gráfico**: Não utiliza X11 ou Wayland durante o boot acelerado.
*   **Acesso Direto à GPU**: Renderização via DRM/KMS para latência zero.

## 2. Otimizações Thunder SDK

| Recurso | Descrição |
| :--- | :--- |
| **GPU Rasterization** | Toda a renderização de CSS/HTML é feita pela GPU. |
| **Zero-Copy Video** | Decodificação de hardware que entrega o vídeo diretamente ao monitor. |
| **RAM Cache** | Cache do navegador armazenado inteiramente na RAM via **OmniLock**. |

## 3. Flags de Performance (Chromium)

O navegador inicia com estas diretivas para garantir fluidez máxima:
`--kiosk --enable-gpu-rasterization --ignore-gpu-blocklist --enable-native-gpu-memory-buffers --num-raster-threads=4`

---
*Status: Motor de Navegação Otimizado.*
