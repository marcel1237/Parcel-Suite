# Nitro Build System: O Compilador de Vanguarda

O **Nitro Build System** é o nosso pipeline de compilação baseado em **Clang 19** e **GCC 16**, projetado para gerar binários que extraem cada gota de performance do hardware moderno.

## 1. Otimização de Microarquitetura (v3/v4)
Diferente das distros padrão que compilam para o "mínimo denominador comum", o Nitro Build detecta o nível de instrução do seu CPU:

- **Level v3 (AVX2)**: Padrão para CPUs a partir de 2015 (Ryzen 1000/Intel 4th Gen).
- **Level v4 (AVX-512)**: Otimização extrema para CPUs modernas (Ryzen 7000/Intel 12th Gen+).

## 2. Tecnologias de Linkagem (Sony & Google Style)
Adotamos técnicas de "Whole Program Optimization" para eliminar o overhead entre bibliotecas:

- **ThinLTO (Link Time Optimization)**: Reduz o tamanho do binário e acelera a execução ao otimizar funções entre diferentes arquivos no momento da linkagem.
- **AutoFDO (Feedback Directed Optimization)**: O compilador usa dados de uso real para reorganizar o código binário, colocando as partes mais quentes do jogo nos caches mais rápidos do processador.

## 3. O Script Orquestrador
O script `scripts/nitro-optimize-build.sh` automatiza a injeção dessas flags no processo de build do kernel e dos aplicativos nativos.

| Flag | Impacto |
| :--- | :--- |
| `-Ofast` | Aceleração matemática para física 3D. |
| `-fno-plt` | Chamadas de função mais rápidas em bibliotecas compartilhadas. |
| `-mprefer-vector-width=256` | Estabilização de frequência em CPUs AVX-512. |

---
*Filosofia: Se o silício pode fazer, o Nitro Build fará.*
