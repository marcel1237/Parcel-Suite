# Relatório Técnico: Resolução de Erros no Pipeline Live-Build Debian Trixie + Vanilla Kernel

## 1. Visão Geral
Durante a construção da Live ISO do PlayOS baseada no **Debian 13 (Trixie)** com o **KDE Full** e o **Linux Kernel Vanilla 7.3-rc4**, o orquestrador nativo `live-build` encontrou três barreiras técnicas críticas que foram totalmente diagnosticadas e superadas.

---

## 2. Erro 1: Caminho com Espaços no Host
### Sintoma
```text
E: Cannot build live image from a directory containing spaces
```
### Causa Raiz
A ferramenta de orquestração `live-build` do Debian realiza operações internas de `tar`, `chroot` e manipulação de loops que não suportam caminhos absolutos contendo espaços em branco (como `/home/marcel/Parcel Suite/Parcel Suite/Parcel Play OS/...`).

### Solução Aplicada
Criação e sincronização do perfil de build para um diretório estritamente sem espaços no host:
```sh
/home/marcel/playos-debian-trixie-kde-full-vanilla-7.3/
```

---

## 3. Erro 2: Fallback Inadvertido para o Modo Ubuntu / Precise
### Sintoma
```text
P: Updating config tree for a ubuntu/amd64 system
E: Failed getting release file http://archive.ubuntu.com/ubuntu/dists/precise/Release
```
### Causa Raiz
Quando executado em um host Ubuntu, o `live-build` lê as configurações padrão globais (`/etc/live/build.conf`) e assume o modo Ubuntu, tentando puxar a suíte legada `precise` se o modo Debian não for explicitamente travado por arquivo de bootstrap.

### Solução Aplicada
Criação do arquivo de configuração persistente `config/bootstrap` no perfil:
```text
LB_MODE="debian"
LB_DISTRIBUTION="trixie"
LB_ARCHITECTURES="amd64"
LB_SECURITY="false"
LB_UPDATES="true"
```
E passagem explícita de `LB_MODE=debian LB_DISTRIBUTION=trixie` no comando `lb config`.

---

## 4. Erro 3: Erro 404 no Repositório de Segurança (`security.debian.org`)
### Sintoma
```text
E: The repository 'http://security.debian.org trixie/updates Release' does not have a Release file.
```
### Causa Raiz
Na distribuição **Debian 13 (Trixie)**, a estrutura e a URL do repositório de segurança mudaram. O caminho legado `security.debian.org trixie/updates` foi descontinuado e substituído por `security.debian.org/debian-security trixie-security`.

### Solução Aplicada
Implementação de um gancho de chroot (*chroot hook*) dedicado em `config/hooks/chroot/00-fix-security-repo.chroot` que intercepta a configuração de APT gerada pelo `live-build`, expurga entradas antigas e reconfigura o repositório de segurança atualizado:
```sh
echo "deb https://security.debian.org/debian-security trixie-security main contrib non-free-firmware" > /etc/apt/sources.list.d/debian-security.list
apt-get update
```

---

## 5. Conclusão
Com essas correções, o pipeline nativo Debian `live-build` opera de forma 100% autônoma e reprodutível, permitindo a injeção limpa de kernels customizados (como o Vanilla 7.3) sobre um userspace Debian Trixie com KDE Plasma completo.
