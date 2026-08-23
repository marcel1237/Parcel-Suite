# Autotransformação do PlayOS (Pós-Instalação)

O PlayOS utiliza uma estratégia de "Metamorfose" onde o sistema se auto-identifica e troca seus ativos visuais no estágio final da instalação, evitando a necessidade de reconstruir imagens SquashFS.

## Fluxo de Operação

1.  **Instalação**: O usuário inicia a instalação via Subiquity ou Calamares.
2.  **Late Commands**: Ao finalizar a cópia de arquivos, o instalador executa o script [`scripts/nitro-post-install.sh`](../../scripts/nitro-post-install.sh).
3.  **Ação Interna**:
    - O script entra no sistema recém-instalado via `chroot`.
    - Executa o `apply-internal-branding.sh` para mudar nomes.
    - Executa o `inject-visual-assets.sh` para trocar logos.
4.  **Primeiro Boot**: O usuário reinicia e o sistema já sobe como **PlayOS**.

## Vantagens
- **Velocidade de Build**: A ISO pode usar o SquashFS original do Ubuntu Noble, economizando horas de compressão.
- **Flexibilidade**: Podemos atualizar o branding apenas trocando scripts na árvore da ISO (`iso-tree`), sem privilégios de sudo.

## Implementação Técnica
- **Motor**: Subiquity `late-commands` ou Calamares `shellprocess`.
- **Configuração**: [`config/installer/post-install-hooks.yaml`](../../config/installer/post-install-hooks.yaml).
