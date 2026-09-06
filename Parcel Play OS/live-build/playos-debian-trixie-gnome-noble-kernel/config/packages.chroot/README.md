# Pacotes locais obrigatórios do kernel Noble

Coloque aqui, após auditoria, os três pacotes correspondentes à mesma ABI:

```text
linux-image-6.8.0-138-generic_*_amd64.deb
linux-modules-6.8.0-138-generic_*_amd64.deb
linux-modules-extra-6.8.0-138-generic_*_amd64.deb
```

Não habilite mirror Ubuntu dentro do chroot Debian. Registre os SHA-256 em
`../../manifests/noble-kernel.sha256` usando o importador do perfil.
