# Ubuntu Core 24 (x86_64 / amd64) via Imagecraft

Este diretório contém o projeto de especificação **Ubuntu Core 24** adaptado para máquinas x86_64 (`amd64`), configurado para uso com a ferramenta oficial Canonical **Imagecraft**.

## Estrutura do Projeto
- **`imagecraft.yaml`**: Especificação declarativa da imagem x86_64 (`name: core-amd64`, `platforms: amd64`).
- **`model.assert`**: Asserção do modelo Ubuntu Core 24 adaptada para arquitetura `amd64`.

## Como Gerar a Imagem (Solução de Dispositivos Loop)
O `imagecraft` necessita de permissões de montagem de dispositivos loop (`losetup --partscan`) para criar a tabela de partições GPT da imagem. Para compilar diretamente no host:

```sh
cd imagecraft/core-amd64
sudo imagecraft pack --destructive-mode
```
