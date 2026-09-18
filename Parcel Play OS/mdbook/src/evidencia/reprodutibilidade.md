# Checksums e reprodutibilidade

Checksums identificam bytes; não identificam funcionalidade. Para reproduzir
ou conferir uma ISO:

```sh
cd build/<projeto>/output
sha256sum -c <arquivo>.sha256
```

O diretório correto importa porque alguns arquivos usam `./nome.iso` e outros
somente `nome.iso`.

Uma reprodução completa também precisa registrar baseline, arquitetura,
mirrors, pacotes, versão do kernel, configuração, ferramentas, ambiente
privilegiado, logs e espaço disponível.
