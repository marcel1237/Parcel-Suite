# Ubuntu Core 24 (x86_64 / amd64) via Imagecraft

Este diretório contém o projeto de especificação **Ubuntu Core 24** adaptado para máquinas x86_64 (`amd64`), configurado para uso com a ferramenta oficial Canonical **Imagecraft**.

## Estrutura do Projeto
- **`imagecraft.yaml`**: Especificação declarativa da imagem x86_64 (`name: core-amd64`, `platforms: amd64`).
- **`model.assert`**: Asserção do modelo Ubuntu Core 24 adaptada para arquitetura `amd64`.

## Como Gerar a Imagem
```sh
cd imagecraft/core-amd64
imagecraft pack
```
