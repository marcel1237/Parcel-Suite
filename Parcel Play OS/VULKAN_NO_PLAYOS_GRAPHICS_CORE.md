# Vulkan no PlayOS Graphics Core

## Estado e decisão

- **Classificação:** `decision`, `architecture` e `proposal`.
- **Data:** 2026-08-26.
- **Produto:** `playos-graphics-core`.
- **API adicionada:** Vulkan.
- **Desktops necessários:** nenhum.
- **Implementação e runtime:** ainda não realizados por este documento.

Vulkan passa a integrar oficialmente o PlayOS Graphics Core sem GNOME, KDE ou
XFCE. Ele funcionará nas sessões X11 e Wayland/Labwc e também poderá executar
aplicações headless ou testes a partir do console, conforme driver e extensão.

Vulkan não será incorporado ao kernel. O kernel fornece DRM, memória, filas,
sincronização e acesso à GPU; loader, ICD, runtime e aplicação ficam no
userspace.

## 1. Conexão com a pilha PlayOS

```text
aplicação Vulkan
      ↓
Vulkan Loader (libvulkan)
      ↓ escolhe ICD
driver Vulkan userspace
      ↓
DRM/render node do kernel PlayOS
      ↓
GPU
```

Para apresentação em uma janela:

```text
Vulkan + WSI X11     → XCB/Xlib → Xorg → DRM/KMS
Vulkan + WSI Wayland → Wayland → Labwc → DRM/KMS
Vulkan headless      → extensão/driver → render node
```

WSI significa Window System Integration. A aplicação cria uma surface para o
sistema de janelas e apresenta imagens através de uma swapchain.

## 2. Componentes

### Vulkan Loader

`libvulkan` é o ponto de entrada comum usado pelas aplicações. Ele descobre
drivers instalados por manifestos ICD e encaminha chamadas ao driver correto.

O loader não é o driver da GPU e não deve ser substituído por arquivos copiados
manualmente de fornecedores.

### ICD

Installable Client Driver é a implementação Vulkan para uma GPU ou para
renderização por software. Manifestos normalmente ficam em diretórios como:

```text
/usr/share/vulkan/icd.d/
/etc/vulkan/icd.d/
```

Os caminhos finais devem ser confirmados nos pacotes da suite usada.

### Drivers Mesa candidatos

| Hardware/caminho | Driver Vulkan candidato | Estado PlayOS |
|---|---|---|
| Intel | ANV | resolver versão e hardware suportado |
| AMD | RADV | resolver versão, firmware e GPU |
| NVIDIA aberto | NVK/Mesa quando disponível | não presumir na versão Noble |
| software | lavapipe | fallback/teste, não aceleração de GPU |
| virtio-gpu | Venus/virgl conforme host e guest | perfil de virtualização |

A disponibilidade depende da versão Mesa efetivamente instalada. O nome do
driver não prova que toda geração de GPU esteja suportada.

### Drivers proprietários

Um driver proprietário pode fornecer seu próprio ICD. Ele pertence a perfil
separado por hardware, licença, assinatura de módulo e compatibilidade. O core
aberto não copiará bibliotecas proprietárias para seu pacote.

## 3. Pacotes candidatos Ubuntu/Debian

Runtime principal:

```text
libvulkan1
mesa-vulkan-drivers
```

Diagnóstico e desenvolvimento:

```text
vulkan-tools
vulkan-validationlayers
libvulkan-dev
spirv-tools
glslang-tools
```

Classificação proposta:

| Pacote | Perfil |
|---|---|
| `libvulkan1` | `CORE` |
| `mesa-vulkan-drivers` | `CORE` gráfico aberto |
| `vulkan-tools` | `RECOMMENDED` na ISO técnica; opcional no usuário |
| `vulkan-validationlayers` | `DEVTEST` |
| `libvulkan-dev` | `DEVELOPMENT` |
| `spirv-tools` | `DEVELOPMENT/DEVTEST` |
| `glslang-tools` | `DEVELOPMENT/DEVTEST` |

Os nomes, versões, arquiteturas e componentes do repositório precisam ser
resolvidos no APT Noble real antes do empacotamento.

## 4. Pacotes PlayOS

```text
playos-vulkan-runtime
├── loader Vulkan
├── ICDs Mesa selecionados
└── integração X11 e Wayland

playos-vulkan-tools
├── vulkaninfo
├── vkcube
└── validação de manifesto/driver

playos-vulkan-development
├── headers e loader de desenvolvimento
├── validation layers
├── SPIR-V tools
└── compiladores de shader aprovados
```

`playos-graphics-core` dependerá de `playos-vulkan-runtime`. Ferramentas ficam
recomendadas na ISO técnica e desenvolvimento fica fora da imagem final.

## 5. Vulkan sem desktop

GNOME, KDE e XFCE não são requisitos Vulkan. A API precisa somente de driver,
loader e, para exibir janelas, uma integração com o sistema de janelas.

No PlayOS Graphics Core:

- Xorg fornece a sessão X11 técnica;
- Labwc fornece o compositor Wayland básico;
- Xwayland permite aplicações X11 dentro de Wayland;
- Vulkan usa WSI nativo X11 ou Wayland conforme a aplicação;
- aplicações headless podem não precisar de Xorg/Labwc, se seu caminho e driver
  suportarem a operação.

## 6. Vulkan em X11

```text
aplicação
 → libvulkan
 → ICD Mesa
 → surface XCB/Xlib
 → Xorg
 → DRM/KMS
```

Testes precisam confirmar:

- criação de instância e dispositivo;
- surface XCB/Xlib;
- formato e modo de apresentação;
- criação e recriação da swapchain;
- redimensionamento e fullscreen;
- sincronização e encerramento sem erro;
- GPU correta em sistemas híbridos.

`vkcube` é smoke test, não benchmark nem certificação.

## 7. Vulkan em Wayland/Labwc

```text
aplicação
 → libvulkan
 → ICD Mesa
 → surface Wayland
 → Labwc
 → DRM/KMS
```

Testes adicionais:

- surface Wayland nativa;
- escala normal e fracionária quando suportada;
- múltiplos monitores;
- fullscreen e perda/recriação de surface;
- suspensão e retomada;
- ausência de dependência silenciosa de Xwayland.

Uma aplicação Vulkan X11 executada na sessão Wayland pode usar Xwayland. Isso é
diferente de uma aplicação Vulkan Wayland nativa e deve aparecer separado nos
resultados.

## 8. Seleção da GPU

Em notebooks híbridos pode haver mais de um dispositivo físico Vulkan. O
diagnóstico deve listar todos e indicar qual foi usado pelo teste.

Não fixar globalmente variáveis de seleção de driver ou GPU. Variáveis como
`VK_ICD_FILENAMES`/mecanismos equivalentes são úteis para diagnóstico, mas um
valor permanente pode ocultar drivers, quebrar atualizações e apontar para
manifesto inexistente.

Política:

- deixar o loader descobrir ICDs instalados;
- permitir seleção explícita por aplicação/perfil;
- registrar vendor ID, device ID, nome, driver e versão;
- testar GPU integrada e dedicada separadamente;
- não chamar lavapipe de aceleração por hardware.

## 9. SPIR-V e shaders

Aplicações Vulkan normalmente entregam shaders em SPIR-V. Ferramentas de
compilação e validação pertencem ao SDK/desenvolvimento, não ao runtime mínimo.

Regras PlayOS:

- runtime não compila fontes arbitrárias durante boot;
- caches de shader são dados de usuário e não entram pré-populados na ISO;
- cache deve respeitar `$XDG_CACHE_HOME` quando a implementação o utilizar;
- shaders não confiáveis são entrada para driver e precisam de stack atualizado;
- testes de compilador não substituem testes no driver real.

## 10. Validation Layers

As camadas de validação ajudam desenvolvedores a detectar uso incorreto da API.
Elas não devem ficar forçadas globalmente em produção porque aumentam consumo,
alteram timing e geram muito log.

Uso de laboratório:

```bash
VK_INSTANCE_LAYERS=VK_LAYER_KHRONOS_validation aplicação-de-teste
```

O comando é exemplo por processo. Não colocar essa variável em `/etc/environment`
ou no launcher normal do PlayOS.

## 11. Arquiteturas de 64 e 32 bits

O runtime amd64 é o núcleo. Aplicações e jogos antigos podem exigir bibliotecas
Vulkan i386 correspondentes.

Perfil futuro:

```text
playos-vulkan-runtime-i386
```

Requisitos:

- mesma família de driver em ambas as arquiteturas;
- manifestos ICD corretos;
- repositório multiarch configurado de modo reproduzível;
- medição do aumento da ISO;
- teste real de aplicação 32-bit;
- nenhuma ativação automática se a edição não precisar.

## 12. Virtualização

Perfis possíveis:

- passthrough de GPU: guest usa driver correspondente ao hardware;
- virtio-gpu/Venus: depende de suporte coordenado entre host, QEMU, kernel e
  Mesa do guest;
- renderização por software: lavapipe para funcionalidade e teste;
- aceleração OpenGL VirGL não equivale automaticamente a Vulkan.

O relatório precisa descrever host, hipervisor, dispositivo apresentado,
driver e API exposta.

## 13. Diagnóstico

Comandos candidatos:

```bash
vulkaninfo --summary
vulkaninfo
vkcube
ls -l /usr/share/vulkan/icd.d/
ls -l /usr/share/vulkan/explicit_layer.d/
ls -l /dev/dri/renderD*
journalctl -b -k | grep -iE 'drm|gpu|firmware|fault|hang'
```

Na sessão Wayland, usar ferramenta que crie surface Wayland nativa quando
disponível. O relatório deve guardar:

```text
session_type
WSI
physical_device
vendor_id/device_id
driver_name/driver_version
api_version
device_extensions
present_mode
software_or_hardware
```

## 14. Integração com `playos-graphicsctl`

```text
playos-graphicsctl vulkan status
playos-graphicsctl vulkan devices
playos-graphicsctl vulkan icds
playos-graphicsctl vulkan layers
playos-graphicsctl vulkan test --wsi x11
playos-graphicsctl vulkan test --wsi wayland
playos-graphicsctl vulkan report --json
```

Por padrão, os comandos são somente leitura. Testes que abrem janela devem
informar a sessão necessária; testes destrutivos ou de stress ficam separados.

## 15. Segurança

- ICDs e layers vêm de pacotes/repositórios autenticados;
- não carregar manifestos de diretórios arbitrários por padrão;
- não executar Vulkan como root para contornar permissões;
- render nodes recebem acesso por udev/logind;
- manter kernel, Mesa e firmware em combinações testadas;
- não habilitar validation layers globalmente;
- limitar logs que possam expor caminhos e detalhes de aplicações;
- travamentos de GPU precisam de recuperação e coleta segura de journal;
- drivers proprietários ficam em perfil e licença separados.

## 16. Desempenho

Uma medição Vulkan válida controla:

- hardware e firmware;
- kernel, Mesa e ICD;
- API e extensões;
- WSI X11, Wayland ou headless;
- resolução, formato e present mode;
- compositor e sessão;
- clocks, energia e temperatura;
- workload, duração, repetições e variância.

`vkcube` apenas confirma apresentação básica. FPS isolado não permite declarar
que Vulkan ou o kernel é “melhor”.

## 17. Live ISO

A ISO Graphics Core deve incluir o runtime Vulkan de 64 bits e, na edição
técnica, `vulkan-tools`.

Sequência de validação:

1. boot até console e detectar DRM;
2. confirmar render node e firmware;
3. executar `vulkaninfo --summary`;
4. iniciar X11 técnico e executar smoke test X11;
5. iniciar Labwc e executar smoke test Wayland nativo;
6. executar uma aplicação X11 por Xwayland separadamente;
7. guardar logs e identificar hardware/software;
8. repetir após suspensão e reboot.

Drivers para todo hardware podem aumentar muito a ISO. A decisão final será
baseada em perfis e medição, não em instalar cada ICD disponível.

## 18. Gates

| Gate | Evidência | Estado |
|---|---|---|
| VK0 | arquitetura Vulkan documentada | presente |
| VK1 | pacotes/versões Noble resolvidos | pendente |
| VK2 | loader e manifestos ICD validados | pendente |
| VK3 | Intel/ANV testado | pendente |
| VK4 | AMD/RADV testado | pendente |
| VK5 | NVIDIA aberta/proprietária classificada | pendente |
| VK6 | lavapipe identificado como software | pendente |
| VK7 | WSI X11 testada | pendente |
| VK8 | WSI Wayland/Labwc testada | pendente |
| VK9 | X11 Vulkan via Xwayland testado | pendente |
| VK10 | suspend/resume e recuperação | pendente |
| VK11 | Live ISO medida e inicializada | pendente |
| VK12 | multiarch 32-bit, se adotado | pendente |

## 19. Critérios de aceitação

Vulkan estará integrado ao PlayOS quando:

- loader localizar somente ICDs válidos;
- pelo menos um driver por perfil criar instância e dispositivo;
- hardware e fallback por software forem distinguidos;
- apresentação funcionar em X11 e Wayland/Labwc;
- aplicação X11 Vulkan funcionar por Xwayland quando exigido;
- erros de driver não impedirem recuperação por console;
- pacote puder ser atualizado e removido sem quebrar Mesa/OpenGL;
- ISO e hardware tiverem resultados reproduzíveis.

Até esses gates, Vulkan está **incluído na arquitetura e documentação**, não
validado no runtime PlayOS.

## Fontes primárias

- Vulkan: <https://www.vulkan.org/>
- Vulkan Specification: <https://registry.khronos.org/vulkan/specs/latest/html/vkspec.html>
- Vulkan Loader: <https://github.com/KhronosGroup/Vulkan-Loader>
- Vulkan Validation Layers: <https://github.com/KhronosGroup/Vulkan-ValidationLayers>
- Mesa Vulkan drivers: <https://docs.mesa3d.org/vulkan/index.html>
- SPIR-V: <https://registry.khronos.org/SPIR-V/>

## Documentos relacionados

- `PLAYOS_GRAPHICS_CORE_COMPLETO_SEM_DESKTOPS.md`;
- `KERNEL_GRAFICO_PLAYOS_SEM_DESKTOPS.md`;
- `MANUAL_COMPONENTES_BASE_PLAYOS_DESKTOP.md`.
