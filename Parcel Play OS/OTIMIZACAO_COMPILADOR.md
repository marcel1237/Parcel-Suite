# Otimização de Compilação: Binários de Performance (Sony Style)

Para garantir que o **Parcel Play OS** extraia 100% do poder do hardware (especialmente CPUs AMD Zen 2/3/4), adotamos uma estratégia de compilação agressiva inspirada no pipeline da Sony para o PlayStation 5.

## 1. Escolha do Compilador: Clang + LLVM
Seguindo o exemplo da Sony, o **NitroCore** e o **Thunder Browser** serão compilados preferencialmente com **Clang**.
- **Vantagem**: Melhor implementação de LTO e integração nativa com arquiteturas modernas de GPU e CPU.

## 2. Flags de "Extreme" Performance

Para cada binário do sistema, aplicaremos as seguintes flags no build:

| Flag | Função | Objetivo |
| :--- | :--- | :--- |
| `-march=znver4` | Arquitetura Específica | Ativa suporte nativo a **AVX-512** e **AMX** para CPUs AMD Ryzen 7000/8000+. |
| `-O3` | Otimização Agressiva | Maximiza a vetorização de loops e o inlining de funções. |
| `-flto=thin` | Thin Link-Time Opt | Otimiza o código entre diferentes arquivos (Sony style), reduzindo o tempo de carregamento e aumentando o FPS. |
| `-Ofast` | Fast Math | Habilita cálculos matemáticos ultra-rápidos (essencial para ambientes 3D e o motor de física do OS). |

## 3. Otimização Baseada em Perfil (PGO)
O NitroCore usará **PGO (Profile-Guided Optimization)**:
1.  **Geração**: Compilamos uma versão do kernel com rastreamento de dados.
2.  **Treinamento**: Rodamos um benchmark de jogos e produtividade 3D por 10 minutos.
3.  **Finalização**: O compilador usa os dados do benchmark para recompilar o kernel, colocando as funções mais usadas nos lugares mais rápidos do binário.

## 4. Estilo Sony (Sony-Style Bitfield & Debug)
- Utilizaremos a flag `-gsony` para compatibilidade com ferramentas de depuração de alto nível, permitindo auditoria profunda da memória em tempo real sem penalidade de performance.

---
*Filosofia: Não compilamos para o "mínimo denominador comum". Compilamos para o seu hardware específico.*
