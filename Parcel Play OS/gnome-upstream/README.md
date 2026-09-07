# GNOME 50 upstream para a Live PlayOS

Esta área prepara uma segunda variante do PlayOS usando código-fonte oficial
GNOME, sem confundi-lo com os pacotes `gnome-core` fornecidos pelo Debian.

Estado atual: pesquisa preservada, direção `superseded`. O checkout upstream e
o grafo foram validados, mas o usuário decidiu manter userspace Debian e trocar
a variante planejada por KDE Full empacotado pelo Debian. O desktop GNOME
upstream não foi compilado, integrado ou empacotado em ISO.

## Identidade fixada

As versões ficam em `gnome-50.lock`. A primeira baseline usa o ramo estável
GNOME 50 no commit `ec28a45a6fcd99195ebc39c1aeda78fd6fe27b8f` e o alvo
`core/meta-gnome-core-shell.bst`.

Não atualizar o commit silenciosamente. Toda atualização precisa repetir a
resolução do grafo, a auditoria de fontes, o build e os testes de runtime.

## Arquitetura pretendida

- Live e base do sistema: Debian 13 Trixie;
- kernel e módulos: Ubuntu Noble `6.8.0-138-generic` locais;
- GNOME: fontes oficiais definidas por `gnome-build-meta`;
- composição: separada da ISO GNOME empacotada pelo Debian;
- instalador: ausente na primeira versão.

## Restrição de integração

`gnome-build-meta` usa Freedesktop SDK como base. Seu checkout de artefato não
é um conjunto de pacotes Debian e não deve ser copiado cegamente sobre `/usr`
do Trixie. Isso pode substituir GLib, GTK, systemd, Mesa, PipeWire e outras
bibliotecas com arquivos fora do controle do `dpkg`.

A integração só poderá avançar por uma destas rotas, com decisão registrada:

1. produzir pacotes `.deb` versionados dos módulos upstream e declarar
   conflitos/dependências corretamente; ou
2. usar o runtime completo GNOME/Freedesktop SDK como base da imagem, deixando
   de chamá-la de userspace Debian; ou
3. manter o GNOME Debian e substituir apenas módulos upstream isolados, depois
   de testes de ABI e dependências.

A rota 1 preserva melhor a arquitetura atual, mas exige uma cadeia de
empacotamento e repositório APT PlayOS. A rota 2 é a mais próxima do GNOME OS.

## Evidência da VM em 2026-09-06

- VM: `playos-debian-trixie-builder-vm`;
- disco ampliado de 12 para 24 GiB, com aproximadamente 20 GiB livres após as
  ferramentas;
- checkout: `/root/gnome-build-meta-50-playos`;
- cache: `/root/gnome-build-meta-50-cache`;
- BuildStream oficial: 2.8.0 em imagem `bst2`;
- grafo do Core Shell: 719 elementos;
- estados: 631 `fetch needed`, 86 `waiting`, 2 `buildable`;
- resultado: grafo resolvido; build completo não iniciado por capacidade
  insuficiente.

O contêiner BuildStream precisa de FUSE e namespaces de montagem. Dentro da VM
builder isolada, a resolução somente funcionou com Podman `--privileged`. Isso
não autoriza o mesmo uso diretamente no host.

## Próximo gate

Disponibilizar pelo menos 80 GiB para o cache e a área de build, de preferência
em volume separado e expansível. O valor é um requisito operacional prudente,
não uma medição final do consumo. Durante a primeira execução, monitorar o uso
e registrar o pico real.

Depois:

1. executar `bst build core/meta-gnome-core-shell.bst` como serviço persistente;
2. exportar e inventariar o artefato;
3. escolher formalmente a rota de integração;
4. construir a ISO em staging separado;
5. validar checksum, BIOS/UEFI e manifesto;
6. testar GDM, GNOME Shell, Wayland, kernel Noble, rede, áudio e gráficos em VM.

BuildStream concluído não comprova integração Debian nem boot da ISO.

## Binários upstream já disponíveis

Verificação executada em 2026-09-06, sem baixar os artefatos completos:

### GNOME OS 50.4 estável

```text
URL canônica: https://os.gnome.org/download/stable/50/gnome_os_installer_x86_64.iso
redirecionamento: GNOME OS 50.4 x86_64
tamanho HTTP: 3111137792 bytes (aproximadamente 2,90 GiB)
estado HTTP final: 200 OK
```

Esta é a opção oficial pronta mais simples para executar o GNOME 50 completo.
Ela não usa userspace Debian nem o kernel Noble do PlayOS. Deve ser tratada
como baseline upstream ou como uma nova arquitetura baseada no GNOME OS.

### GNOME OS nightly

A ISO `nightly.20260906.1` também estava disponível, com 3713217024 bytes.
Ela é software de desenvolvimento e não foi selecionada para a baseline.

### Imagem OCI Core GNOME 50

O registro oficial contém:

```text
quay.io/gnome_infrastructure/gnome-build-meta:core-50
```

O manifesto remoto respondeu e declarou cinco camadas que totalizam
aproximadamente 8,8 GB compactados. A imagem evita compilar o grafo de 719
elementos, mas é um filesystem baseado no Freedesktop SDK; não é um repositório
APT nem um conjunto de pacotes `.deb` instaláveis sobre o Trixie.

### Conclusão operacional

Existe GNOME 50 upstream já compilado. Para criar rapidamente outra Live, a
rota tecnicamente consistente é partir da ISO GNOME OS 50.4. Para preservar
Debian Trixie + kernel Noble, ainda é necessário criar uma camada explícita de
integração/empacotamento; extrair a imagem OCI sobre `/usr` não é aceitável.
