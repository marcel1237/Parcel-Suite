# Análise do Projeto Parcel Play OS

**Data da análise:** 15 de agosto de 2026  
**Escopo:** arquivos versionáveis, scripts, módulos do instalador, configuração de boot, documentação e artefatos locais do diretório `Parcel Play OS`.  
**Natureza da atividade:** inspeção e validação estática. Nenhuma funcionalidade do sistema operacional foi implementada ou alterada nesta análise.

## 1. Resumo executivo

O Parcel Play OS encontra-se no estágio de **pesquisa arquitetural com protótipo de mídia**, e não no estágio de sistema operacional completo. A parte mais concreta é uma ISO derivada do Ubuntu Resolute com um menu GRUB customizado. NitroCore, Thunder SDK, o instalador personalizado e os payloads BSD ainda são conceitos, configurações experimentais ou placeholders.

O projeto possui documentação ampla e um registro de progresso que, nas entradas mais recentes, distingue corretamente planejamento, protótipo e implementação. Entretanto, documentos mais antigos ainda apresentam algumas funcionalidades como ativas, integradas ou validadas, em conflito com o estado observado no código.

## 2. Estrutura e tecnologias identificadas

### 2.1 Base do sistema

- Ubuntu 26.04 Resolute Desktop amd64 como base do MVP.
- `casper`, SquashFS em camadas e Ubuntu Desktop Installer/Subiquity herdados da mídia oficial.
- GNOME/GDM como ambiente e display manager do baseline.
- KDE Full planejado como segundo ambiente gráfico.

### 2.2 Boot e mídia

- GRUB com menu de onze posições.
- Oito opções Linux planejadas: Ubuntu oficial e sete perfis NitroCore.
- Três sistemas BSD planejados: FreeBSD, NetBSD e OpenBSD.
- Boot híbrido BIOS/UEFI preservado na ISO-protótipo.
- Os Linux compartilhariam o rootfs Ubuntu; os BSDs exigem bootloader, kernel e userspace próprios.

### 2.3 Instalador

- O MVP documentado escolhe Ubuntu Desktop Installer/Subiquity.
- O código experimental existente em `installer/` usa Calamares, QML, Qt Quick, Kirigami e módulos Python.
- As duas abordagens ainda não estão integradas entre si.

### 2.4 Componentes conceituais

- **NitroCore:** perfis de kernel Linux inspirados em características de diferentes sistemas.
- **Thunder SDK:** conjunto conceitual de otimizações.
- **OmniLock:** proposta de gerenciamento de memória e redução de swap.
- **Dark Volt:** proposta de interface EGLFS durante o early boot.
- **Thunder Browser:** proposta de navegador Qt WebEngine/Chromium otimizado.
- **Parcel Software Center:** proposta de interface unificada para APT, Snap, Flatpak e AppImage.

## 3. Estado confirmado

### 3.1 Implementado ou produzido

- ISO oficial Ubuntu Resolute baixada e verificada conforme o histórico documentado.
- Árvore da ISO extraída em `build/resolute-mvp/work/iso-tree/`.
- ISO-protótipo disponível em:

  ```text
  build/resolute-mvp/output/parcel-play-11-menu-prototype-amd64.iso
  ```

- Tamanho observado: `6.279.266.304` bytes.
- Menu GRUB Parcel com onze posições.
- Ubuntu oficial como única entrada com kernel e initramfs reais.
- Entradas sem payload exibem explicitamente seu estado indisponível.
- Diretórios contratados para futuros payloads Linux e BSD.
- Protótipos visuais do instalador Calamares.
- Registro técnico extenso em Markdown.

### 3.2 Planejado ou simulado

- Bootstrap completo de Binutils, GCC e glibc.
- Compilação do NitroCore.
- Patches, configurações e pacotes NitroCore.
- Instalação do KDE Full no payload Live e no sistema instalado.
- Dark Volt funcional.
- Thunder Browser funcional.
- Parcel Software Center.
- Integração real de Waydroid, Proton/Wine, Flatpak e Snap pelo instalador Parcel.
- Payloads e instaladores BSD na ISO.
- Secure Boot dos kernels e módulos Parcel.
- Build integral e reproduzível da distribuição.

## 4. Verificações executadas

Foram realizadas verificações somente de leitura e validações sintáticas. A compilação sintática de Python criou caches temporários, removidos imediatamente após a verificação.

| Verificação | Resultado |
| --- | --- |
| Enumeração da estrutura e dos arquivos | Concluída |
| Leitura dos documentos centrais | Concluída |
| `bash -n` em todos os scripts `.sh` | Aprovado |
| Compilação sintática dos módulos Python | Aprovada |
| Validação de `scripts/kms-config.json` | Aprovada |
| `grub-script-check config/boot/grub-11-kernels.cfg` | Aprovado |
| ShellCheck | Não executado; ferramenta indisponível |
| Validação QML em runtime | Não executada |
| Boot da ISO em VM | Não executado; QEMU/KVM indisponível |
| Instalação em disco virtual | Não executada |
| Compilação de kernel | Não executada |
| Benchmark de performance | Não executado |

As aprovações acima confirmam apenas sintaxe e estrutura básica. Elas não comprovam funcionamento em runtime, boot, instalação, desempenho ou compatibilidade de hardware.

## 5. Achados técnicos

### 5.1 O orquestrador não constrói um sistema operacional

O arquivo `scripts/build_os.sh` anuncia oito etapas, mas executa somente `03-setup-fhs.sh`. As chamadas de bootstrap e kernel estão comentadas. O resultado prático é a criação de uma hierarquia vazia de diretórios em `build-env/rootfs`.

Os scripts `01-bootstrap-toolchain.sh` e `02-build-nitrocore.sh` apenas imprimem mensagens. Eles não baixam fontes, validam hashes, selecionam revisões, aplicam patches ou compilam artefatos.

### 5.2 NitroCore não possui implementação versionada

Não foram encontrados no projeto:

- fonte ou revisão fixada do kernel;
- patches NitroCore;
- arquivos `.config` por flavor;
- processo de aplicação de patches;
- empacotamento Debian do kernel e módulos;
- geração de initramfs;
- ABI e política de nomes;
- testes de boot;
- benchmarks reproduzíveis.

O valor `KERNEL_VERSION="6.18.44"` em `02-build-nitrocore.sh` não está conectado a uma tag, download ou verificação.

### 5.3 O instalador implementado não corresponde à decisão atual do MVP

A documentação mais recente escolhe Ubuntu Desktop Installer/Subiquity para reduzir o risco do primeiro MVP. Contudo, os protótipos presentes em `installer/` são módulos Calamares. Não há configuração completa do Calamares, sequência de módulos, configuração de payload nem integração que prove que essas telas sejam carregadas.

Os comandos relevantes de `installer/modules/universal_compat/main.py` estão comentados. O módulo apenas registra mensagens e retorna sucesso. Portanto, ele não instala Snap, Flatpak, Waydroid, Wine, Proton, GNOME ou KDE.

O mesmo ocorre em `installer/modules/thunder_setup/main.py`: as alterações no GRUB e a chamada a `update-grub` estão comentadas.

### 5.4 Defeitos no seletor de kernel

No arquivo `installer/modules/kernel_selector/View.qml`:

- NetBSD usa `flavor: "seguranca"`, quando o identificador esperado seria `netbsd`.
- O modelo contém dez opções e não oferece o Ubuntu oficial, embora a arquitetura atual defina onze posições.
- O campo de busca não possui lógica de filtragem.
- A seleção não apresenta feedback visual implementado.
- `Component.onCompleted` sempre grava `debian`, podendo substituir uma escolha persistida quando a tela for recriada.
- O botão de modo inteligente apenas grava Debian e não avança no fluxo.

### 5.5 Riscos de segurança em otimizações planejadas

`installer/modules/thunder_setup/main.py` propõe acrescentar `intel_pstate=passive` independentemente do fabricante da CPU. Esse parâmetro não deve ser aplicado indiscriminadamente em hardware AMD ou em sistemas cuja política de frequência seja diferente.

O código também associa a presença de AVX-512 a `mitigations=off`. Não existe relação técnica que justifique desligar mitigação de vulnerabilidades de CPU pela presença dessa extensão vetorial. Se ativada, essa política reduziria significativamente a segurança e deveria exigir decisão explícita, informação clara ao usuário e medição controlada — nunca detecção automática por AVX-512.

### 5.6 Otimizações gráficas pouco portáveis

- `QSG_RHI_BACKEND=vulkan` é forçado sem detecção de suporte ou fallback.
- EGLFS é forçado em scripts destinados a ambientes que também usam Wayland/KDE.
- `scripts/kms-config.json` fixa `/dev/dri/card0`, o que pode falhar em sistemas multi-GPU ou com outra enumeração DRM.
- `QT_NO_GLIB=1` pode prejudicar integração de eventos no desktop.
- Variáveis exportadas por um script executado normalmente não persistem na sessão gráfica futura.
- Alegações quantitativas, como redução de overhead “em até 60%”, não possuem benchmark ou fonte no repositório.

### 5.7 Dark Volt não está operacional

O serviço `scripts/thunder-dark-volt.service` aponta para `/usr/bin/thunder-login-eglfs`, mas esse binário não existe no projeto. A configuração ainda:

- executa como `root`;
- define `NoNewPrivileges=false`;
- permite acesso ao DRM;
- solicita prioridade de tempo real;
- entra antes do display manager.

Essas permissões exigem threat model, protótipo funcional e testes de recuperação antes de qualquer ativação. A decisão recente de manter Dark Volt em hold é tecnicamente adequada.

### 5.8 Thunder Browser não inicia navegador algum

`scripts/thunder-browser-optim.sh` define flags de ambiente, mas a execução do binário está comentada. Também são forçadas opções de GPU e EGLFS sem detecção de compatibilidade. O componente deve ser classificado como configuração experimental, não como navegador implementado.

### 5.9 O menu GRUB é a parte mais madura

`config/boot/grub-11-kernels.cfg` e `scripts/prepare-grub-11-kernels.sh` apresentam cuidados positivos:

- verificam a presença do kernel e initramfs Ubuntu;
- validam a configuração com `grub-script-check`;
- preservam cópias dos menus originais;
- não fingem que payloads ausentes estão disponíveis;
- distinguem boot Linux de chainload EFI BSD;
- oferecem recuperação Ubuntu com `nomodeset`.

Entretanto, um par `vmlinuz`/`initrd` não basta para integrar um flavor Linux: o rootfs também precisa conter `/lib/modules/$(uname -r)`, firmware, pacotes e metadados correspondentes. Para BSD, um loader EFI isolado também não representa um sistema completo.

## 6. Inconsistências documentais

Os registros recentes de `PROGRESSO.md`, `BUILD_RESOLUTE_MVP.md`, `ARQUITETURA_BOOT.md` e `kernel.md` são mais cautelosos e refletem melhor o estado real. Outros documentos ainda usam afirmações incompatíveis com o código observado, por exemplo:

- `DARK_VOLT.md`: declara motor ativo, embora esteja em hold e sem binário.
- `PORTABILIDADE_NETBSD.md`: declara Anykernel integrado, sem implementação correspondente.
- `MATRIZ_QUALIDADE.md`: declara qualidade validada, sem configuração, build ou benchmark NitroCore.
- Documentos antigos apresentam Calamares ou uma fusão Calamares/Subiquity como decisão consolidada.
- `DETALHAMENTO_TECNICO.md` descreve RPM/DNF como gestão moderna, enquanto a base efetiva do MVP é Ubuntu/APT.
- Algumas descrições tratam tecnologias planejadas como funcionalidades presentes.

Recomenda-se definir um campo de estado padronizado para cada recurso: `conceito`, `planejado`, `protótipo estático`, `implementado`, `testado` ou `validado`.

## 7. Infraestrutura de engenharia ausente

Não foram encontrados:

- `README.md` principal com início rápido e estado real;
- arquivo de licença;
- suíte de testes automatizados;
- integração contínua;
- manifesto central de versões e hashes;
- pipeline completo e idempotente da ISO;
- configuração versionada do kernel;
- política de releases;
- geração automatizada de checksums;
- matriz de hardware testado;
- critérios mensuráveis de performance.

O repositório Git engloba caminhos externos ao diretório atual e já contém alterações do usuário fora do projeto. Essas alterações foram apenas observadas e não foram modificadas. Dentro do diretório do Parcel Play OS já existia um PDF não rastreado, que também foi preservado.

## 8. Avaliação de maturidade

| Área | Avaliação |
| --- | --- |
| Visão de produto e pesquisa | Avançada |
| Registro documental recente | Bom |
| Arquitetura de boot | Boa como especificação |
| Menu GRUB | Protótipo estaticamente válido |
| ISO Ubuntu remasterizada | Parcial; somente menu alterado |
| KDE no Live e na instalação | Não implementado |
| NitroCore | Conceitual |
| Thunder SDK | Placeholders e configurações experimentais |
| Instalador Parcel | Protótipo visual desconectado do MVP |
| Payloads BSD | Não integrados |
| Secure Boot | Não resolvido |
| Testes em VM e hardware | Não executados |
| Build reproduzível | Não disponível |
| Evidência de performance | Não disponível |

## 9. Riscos prioritários

1. **Escopo excessivo:** onze opções de boot, dois desktops, quatro instaladores possíveis e diversas camadas de compatibilidade antes de validar o baseline.
2. **Segurança:** propostas como `mitigations=off`, serviços root e módulos próprios sem cadeia de assinatura.
3. **Reprodutibilidade:** artefatos locais existem, mas não há um pipeline completo que terceiros possam repetir.
4. **Compatibilidade:** flags de CPU/GPU fixas podem impedir boot ou sessão gráfica em parte do hardware.
5. **Divergência documental:** usuários e colaboradores podem interpretar protótipos como funcionalidades concluídas.
6. **Teste insuficiente:** a validação atual não cobre boot, instalação, atualização, Secure Boot nem recuperação.

## 10. Sequência recomendada

### Fase 1 — Baseline instalável

1. Manter somente o kernel oficial Ubuntu Resolute.
2. Integrar KDE ao conjunto correto de camadas do `fsimage-layered`.
3. Preservar GNOME, GDM e Ubuntu Desktop Installer/Subiquity.
4. Automatizar extração, composição, manifestos, SquashFS e reconstrução da ISO.
5. Fixar a origem da ISO e seus hashes.
6. Testar boot BIOS/UEFI e instalação em disco virtual descartável.

### Fase 2 — Qualidade e automação

1. Adicionar testes de sintaxe, estrutura da mídia e consistência dos manifestos.
2. Instalar ShellCheck no ambiente de CI.
3. Criar README, licença, changelog e política de releases.
4. Padronizar o estado de cada funcionalidade na documentação.
5. Registrar checksums e logs de build automaticamente.

### Fase 3 — Primeiro NitroCore experimental

1. Escolher apenas um flavor.
2. Fixar revisão da árvore Ubuntu Resolute.
3. Versionar `.config` e patches mínimos.
4. Gerar pacotes de imagem, módulos, headers e initramfs.
5. Integrar `/lib/modules` ao rootfs.
6. Manter Ubuntu oficial como fallback.
7. Comparar estabilidade, boot, latência e throughput com o baseline.

### Fase 4 — Expansões opcionais

- Acrescentar outros flavors somente quando houver diferença técnica mensurável.
- Integrar BSDs como payloads nativos independentes.
- Avaliar Calamares apenas como experimento separado do MVP Subiquity.
- Retomar Dark Volt somente após threat model, protótipo não privilegiado e testes.

## 11. Conclusão

O Parcel Play OS possui uma visão ampla, uma documentação significativa e um protótipo GRUB cuidadoso. A distância entre as promessas de produto e a implementação ainda é grande. O marco técnico de maior valor agora é uma única ISO Ubuntu Resolute, com GNOME e KDE, instalável e reproduzível.

Depois que esse baseline estiver validado em VM e hardware, NitroCore poderá evoluir como um experimento de kernel mensurável. Até lá, NitroCore, Thunder SDK, Dark Volt, Anykernel, o instalador Parcel e os payloads BSD devem permanecer explicitamente classificados como planejados ou protótipos.
