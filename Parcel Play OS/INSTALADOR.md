# Instalador mínimo do Parcel Play OS

## Objetivo da primeira Live ISO

Entregar uma Live ISO Resolute amd64 que:

- inicialize GNOME e KDE Plasma;
- possua um atalho **Instalar Parcel Play OS**;
- permita idioma, teclado, fuso horário, usuário e particionamento;
- copie para o disco o sistema com as duas sessões;
- instale e configure o bootloader;
- funcione offline usando o conteúdo da ISO;
- seja testável sem NitroCore, Decágono, Dark Volt ou módulos experimentais.

## Decisão para o MVP

O instalador mínimo será o instalador Ubuntu Desktop já incluído na ISO oficial do Resolute, cujo backend é o **Subiquity**.

Essa escolha reduz a primeira integração a três tarefas:

1. preservar o instalador da ISO Desktop durante a remasterização;
2. mudar somente nome, ícone e atalho quando isso puder ser feito sem alterar o backend;
3. comprovar que a instalação transfere `ubuntu-desktop` e `kde-full` para o sistema instalado.

Não haverá fusão entre Calamares e Subiquity no MVP. Cada instalador deve controlar sozinho particionamento, montagem, criação do usuário, implantação do sistema e bootloader. Dois motores escrevendo no mesmo disco aumentariam a complexidade e o risco de perda de dados.

## Comparação dos quatro candidatos

| Candidato | Integração com Resolute | Trabalho mínimo | Adequação ao MVP | Decisão |
| :--- | :--- | :--- | :--- | :--- |
| **Subiquity / Ubuntu Desktop Installer** | Nativa; já faz parte da ISO Desktop Ubuntu | Preservar e testar | Alta | **Escolhido** |
| **Calamares** | Pacote `3.3.14-0ubuntu25` disponível no `universe`, mas exige configuração própria | Criar perfil completo, payload, particionamento, bootloader e testes | Média | Fase futura opcional |
| **Anaconda** | Projetado principalmente para Fedora/RHEL, RPM/DNF, comps e Kickstart | Adaptar payload, empacotamento e ambiente de instalação ao Ubuntu | Baixa | Não usar |
| **archinstall** | Biblioteca e instalador guiado para Arch Linux | Reescrever instalação APT/Ubuntu e boot para outro sistema | Muito baixa | Apenas referência de UX/logs |

### Subiquity

Pontos favoráveis:

- é o backend do instalador Ubuntu Desktop;
- conhece o particionamento, os pacotes, o boot e as particularidades do Ubuntu;
- suporta instalação automatizada por `autoinstall` para testes posteriores;
- acompanha as mudanças do Resolute sem manter uma pilha paralela.

Limitação:

- branding e telas Parcel dependem dos pontos de extensão oferecidos pelo instalador Desktop; não se deve modificar o backend somente para mudar a aparência.

Referências:

- <https://canonical-subiquity.readthedocs-hosted.com/en/latest/>
- <https://canonical-subiquity.readthedocs-hosted.com/en/latest/howto/autoinstall-quickstart.html>

### Calamares

Calamares é tecnicamente viável no Resolute e combina com KDE/Qt. Entretanto, instalar apenas o pacote `calamares` não cria um instalador funcional. Uma distribuição precisa fornecer seu próprio perfil em `/etc/calamares`.

O mínimo funcional exigiria:

- `settings.conf` com ordem dos módulos;
- branding selecionado pelo `settings.conf`;
- `unpackfs.conf` apontando para o payload correto da Live ISO;
- configurações de `partition`, `mount`, `fstab` e `bootloader`;
- módulos de locale, teclado, usuários e display manager;
- limpeza dos componentes exclusivos da sessão Live no alvo;
- atalho `.desktop` executando Calamares com elevação de privilégio;
- testes destrutivos somente em discos virtuais descartáveis.

Sequência conceitual mínima de módulos:

```yaml
show:
  - welcome
  - locale
  - keyboard
  - partition
  - users
  - summary
exec:
  - partition
  - mount
  - unpackfs
  - machineid
  - fstab
  - locale
  - keyboard
  - users
  - displaymanager
  - initramfs
  - bootloader
  - umount
show-final:
  - finished
```

Essa lista é um desenho de fluxo, não um `settings.conf` pronto. Os nomes e instâncias precisam ser conferidos contra os módulos efetivamente entregues pelo pacote Calamares do Resolute.

Os protótipos atuais em `installer/modules/` não constituem um instalador funcional porque ainda faltam o perfil principal, as configurações do payload e os módulos de implantação. As operações dos módulos Python também estão comentadas.

Referências:

- <https://calamares.io/docs/users-guide/>
- <https://github-wiki-see.page/m/calamares/calamares/wiki/Deploy-Configuration>
- <https://calamares.euroquis.nl/docs/develop-guide>

### Anaconda

Anaconda possui particionamento avançado e automação por Kickstart, mas sua arquitetura normal utiliza o ecossistema Fedora/RHEL, incluindo RPM, DNF, comps e uma árvore de instalação própria. A documentação também informa que o Anaconda não cria a imagem Live; a distribuição precisa fornecer o payload.

Adaptá-lo ao Ubuntu exigiria mais trabalho do que construir o restante do MVP. Ele permanece apenas como referência para LVM, RAID, criptografia e instalações enterprise.

Referências:

- <https://anaconda-installer.readthedocs.io/en/latest/user-guide/intro.html>
- <https://anaconda-installer.readthedocs.io/en/latest/user-guide/troubleshooting/common-bugs.html>

### archinstall

`archinstall` é uma biblioteca Python para instalar Arch Linux. Seu fluxo depende de conceitos e ferramentas do Arch, como `pacstrap`, `pacman` e `mkinitcpio`. Não é um instalador genérico para uma distribuição Ubuntu.

Pode inspirar:

- log transparente;
- configuração declarativa;
- execução sequencial;
- perfis automatizados.

Não deve ser incorporado como motor do instalador Resolute.

Referência: <https://archinstall.archlinux.page/index.html>.

## Conteúdo mínimo dentro da Live ISO

A remasterização deve preservar todos os componentes do instalador oficial existentes na ISO-base. Além deles, o sistema Live deve conter:

- `ubuntu-desktop`;
- `kde-full`;
- `gdm3` como display manager padrão;
- kernel, initramfs e firmware oficiais do Resolute;
- acesso offline ao payload usado pelo instalador;
- um atalho para iniciar o instalador.

Não instalar no MVP:

- Calamares em paralelo;
- Anaconda;
- archinstall;
- módulos `kernel_selector`, `thunder_setup` ou `universal_compat`;
- `mitigations=off`;
- serviços Dark Volt.

## Verificações antes de gerar a ISO

Dentro do ambiente de remasterização:

```bash
dpkg-query -W ubuntu-desktop kde-full gdm3
cat /etc/X11/default-display-manager
```

No conteúdo extraído da ISO, registrar:

```bash
find . -maxdepth 4 -type f \
  \( -iname '*subiquity*' -o -iname '*installer*' -o -iname '*bootstrap*' \) \
  -print
```

Também registrar o manifesto e as camadas do payload:

```bash
find casper -maxdepth 2 -type f -print | sort
```

Essas inspeções são necessárias porque a ISO Desktop moderna pode usar múltiplas camadas SquashFS. Não se deve assumir que alterar uma única `filesystem.squashfs` fará o KDE chegar ao sistema instalado.

## Teste mínimo obrigatório

O instalador só será considerado integrado depois deste teste em máquina virtual descartável:

1. iniciar a ISO em UEFI;
2. entrar na sessão Live;
3. abrir o instalador pelo atalho;
4. executar instalação offline usando o disco inteiro virtual;
5. reiniciar sem a ISO;
6. confirmar que o sistema inicia pelo bootloader instalado;
7. confirmar a existência de `ubuntu-desktop` e `kde-full`;
8. iniciar GNOME;
9. encerrar a sessão e iniciar Plasma;
10. guardar logs, checksum da ISO e resultado neste documento.

Nenhum teste inicial deve utilizar disco físico. Particionamento e instalação devem ser validados primeiro em uma máquina virtual com disco descartável.

## Plano de evolução

### Fase 1 — MVP

- ISO Desktop Resolute oficial remasterizada;
- GNOME + KDE Full;
- instalador Ubuntu Desktop/Subiquity preservado;
- kernel oficial;
- instalação offline validada em VM.

### Fase 2 — Identidade Parcel

- nome, ícone, slides e atalho Parcel;
- testes de atualização e recuperação;
- perfil `autoinstall` para CI.

### Fase 3 — Avaliação Calamares

Somente após o MVP, criar uma ISO experimental separada com Calamares. Ela deverá substituir, e não chamar, o Subiquity. O experimento precisa comprovar instalação offline, UEFI, BIOS, criptografia, dual boot e limpeza correta da sessão Live.

### Fase 4 — NitroCore

Adicionar o kernel personalizado apenas após a instalação do kernel oficial estar reproduzível. O instalador deve sempre manter um kernel oficial conhecido como fallback durante os primeiros testes.

## Estado real em 2026-08-13

- **Decisão arquitetural**: Subiquity/Ubuntu Desktop Installer escolhido para o MVP.
- **Implementação**: ainda não iniciada.
- **Calamares**: existem protótipos de branding e telas, mas não existe perfil instalável completo.
- **Anaconda e archinstall**: avaliados e descartados como motores do MVP.
- **Próxima ação**: baixar e extrair a ISO Desktop Resolute, identificar suas camadas e confirmar como o instalador seleciona o payload instalado.
