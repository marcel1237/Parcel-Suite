# Resultados

Este diretório recebe registros produzidos pela aplicação e validação do
patchset. Não registrar chaves, certificados privados, imagens de disco ou
logs que contenham dados pessoais.

Arquivos esperados por execução:

- `target-identity.txt`;
- `patch-sha256.txt`;
- `check-series.txt`;
- `build.txt`;
- `boot.txt`;
- `selftests.txt`;
- `benchmarks.txt`.

No estado inicial somente a verificação estática é confirmada. Build e boot
permanecem pendentes até existir uma árvore Resolute correta em caminho válido.
