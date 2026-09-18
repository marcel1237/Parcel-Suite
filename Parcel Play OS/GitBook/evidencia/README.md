# Evidências

Toda conclusão deve informar seu estado. A documentação do GitBook é uma
camada de navegação; a evidência continua nos arquivos, logs, catálogos e
execuções reproduzíveis do projeto.

*** Add File: /home/marcel/Parcel-Suite/Parcel Suite/Parcel Play OS/GitBook/evidencia/estados-e-gates.md
# Estados e gates

| Estado | Significado |
|---|---|
| `fact` | Confirmado em fonte ou execução |
| `inference` | Derivado de evidências |
| `decision` | Direção aprovada |
| `proposal` | Ideia ainda não implementada |
| `implementation` | Código ou documentação existente |
| `result` | Teste ou medição executada |
| `unknown` | Ainda não determinado |

## Gates

1. **Build**: saída, manifesto, arquivos e checksum.
2. **Estrutura**: ISO, boot catalog, kernel, initramfs e SquashFS.
3. **Boot**: firmware, bootloader, kernel, Live root e OverlayFS.
4. **Runtime gráfico**: SDDM, Plasma, KWin, X11, Wayland, Mesa, Vulkan,
   input, áudio, rede, logout e shutdown.
5. **Hardware**: comportamento em hardware real ou VM representativa.

