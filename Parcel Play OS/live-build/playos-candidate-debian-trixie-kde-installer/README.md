# PlayOS Debian Trixie KDE Full com kernel Ubuntu Noble

Perfil Live separado com userspace integralmente Debian 13 Trixie, KDE completo
fornecido pelos repositórios Debian e kernel Ubuntu Noble local.

## Identidade

- userspace e pipeline Live: Debian 13 Trixie;
- desktop: `kde-full` metapacote Debian 5:162;
- Plasma: série 6.3.6 disponível no Trixie na criação do perfil;
- display manager: SDDM;
- kernel: Ubuntu Noble `6.8.0-138-generic` em três pacotes locais;
- instalador: nenhum.

O software do desktop é desenvolvido pelo KDE, mas empacotado e integrado
pelos mantenedores Debian Qt/KDE. Isso é necessário para preservar ABI,
dependências e controle do `dpkg`. KDE neon não é usado porque seus binários
são destinados ao Ubuntu Noble, não ao Debian Trixie.

## Preparação

Importe os três pacotes locais do kernel com `tools/import-noble-kernel.sh` ou
copie este perfil para a VM com preservação dos arquivos já importados. Depois:

```sh
./tools/preflight.sh
./tools/build.sh
```

O build exige ambiente Debian Trixie, `live-build` moderno e privilégios dentro
da VM builder. Build bem-sucedido não comprova boot nem sessão Plasma.
