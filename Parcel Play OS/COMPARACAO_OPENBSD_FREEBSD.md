# Comparação Inicial: OpenBSD e FreeBSD

**Data:** 15 de agosto de 2026

## 1\. Objetivo e escopo

Este documento inicia uma comparação técnica entre OpenBSD e FreeBSD para
orientar pesquisas do Parcel Play OS. A análise cobre objetivos, arquitetura,
segurança, rede, armazenamento, virtualização, aplicações, portabilidade,
licenciamento e possível reaproveitamento de ideias.

Esta etapa é documental. Nenhum código dos dois sistemas foi unido, portado,
compilado ou executado. As conclusões não significam que um kernel possa
substituir o outro nem que um kernel BSD possa iniciar diretamente o rootfs
Ubuntu.

## 2\. Origem comum e divergência

OpenBSD e FreeBSD são sistemas Unix-like completos derivados da família BSD. Em
ambos, kernel, bibliotecas e ferramentas do sistema base são desenvolvidos de
forma integrada. Isso difere do modelo comum das distribuições Linux, que
combinam o kernel Linux com componentes mantidos por muitos projetos
independentes.

Apesar da origem comum, os projetos atuais possuem kernels, drivers, APIs
internas, ABIs, sistemas de build e prioridades próprios. Código em C pode ser
portado entre eles, mas não é automaticamente compatível.

## 3\. Resumo comparativo


|Área                     |OpenBSD                                                                             |FreeBSD                                                                                 |
|-------------------------|------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------|
|Prioridade central       |Correção, simplicidade, segurança preventiva, padronização e portabilidade          |Desempenho, estabilidade, rede, armazenamento, escalabilidade e uso amplo               |
|Sistema base             |Kernel e userland integrados                                                        |Kernel e userland integrados                                                            |
|Segurança de processos   |`pledge`, `unveil`, W^X, auditoria contínua e redução de complexidade               |Capsicum, MAC, audit, securelevel, jails e controles por recurso                        |
|Isolamento no nível do SO|Não possui equivalente direto e abrangente às jails FreeBSD                         |Jails maduras, incluindo VNET e integração com ZFS                                      |
|Hipervisor nativo        |`vmm`/`vmd`, com escopo deliberadamente limitado                                    |`bhyve`, com escopo mais amplo de hóspedes e operação de servidor                       |
|Firewall principal       |PF, originado e mantido no OpenBSD                                                  |PF, IPFW e IPFilter; a variante de PF divergiu da árvore OpenBSD                        |
|Armazenamento            |FFS, softraid e ferramentas focadas em simplicidade                                 |UFS2, GEOM e integração profunda com OpenZFS                                            |
|Compatibilidade Linux    |Não é objetivo central                                                              |Linuxulator e Linux jails para parte do userland Linux                                  |
|Pacotes                  |`pkg_add` e ports; pacotes binários são recomendados                                |`pkg` e Ports Collection, com catálogo maior e ampla customização                       |
|Hardware                 |Grande diversidade de arquiteturas, mas suporte por dispositivo pode ser conservador|Foco forte nas arquiteturas principais e uso em servidores/appliances                   |
|Licenciamento            |Preferência forte por ISC/BSD e rejeição de novas dependências GPL no base          |Preferência por BSD-2-Clause, aceitando licenças alternativas isoladas quando necessário|
|Perfil natural           |Firewall, roteador, bastion, VPN, DNS e serviços pequenos de alta confiança         |Servidor, storage, appliance, virtualização, rede de alto volume e base de produto      |

## 4\. Filosofia de projeto

### 4.1 OpenBSD

O OpenBSD declara como objetivos correção, segurança, padronização,
portabilidade e acesso integral ao código. Sua política favorece licenças ISC
ou Berkeley e evita introduzir novo código GPL no sistema base.

O projeto aceita remover funcionalidades ou restringir comportamentos quando
isso reduz superfície de ataque ou complexidade. A segurança é tratada como
propriedade do sistema completo, não apenas como um conjunto opcional de
módulos.

Fontes oficiais:

- [Objetivos do OpenBSD](https://www.openbsd.org/goals.html)
- [Introdução ao OpenBSD](https://www.openbsd.org/faq/faq1.html)
- [Política de copyright](https://www.openbsd.org/policy.html)

### 4.2 FreeBSD

O FreeBSD se apresenta como sistema voltado a recursos, velocidade e
estabilidade. O projeto dá grande importância a rede, armazenamento,
escalabilidade, appliances, servidores e produtos derivados.

Sua árvore única e seu build integrado facilitam criar produtos baseados no
sistema completo. A licença permissiva é explicitamente tratada como vantagem
para produtos comerciais e embarcados.

Fontes oficiais:

- [Sobre o FreeBSD](https://www.freebsd.org/about/)
- [Recursos do FreeBSD](https://www.freebsd.org/features/)
- 
  [Introdução do Handbook](https://docs.freebsd.org/en/books/handbook/introduction/)

## 5\. Arquitetura do kernel

Os dois projetos usam kernels monolíticos modulares, mas suas estruturas
internas evoluíram separadamente. Ambos suportam SMP, memória virtual, módulos
e múltiplas arquiteturas, porém estruturas de processos, VFS, drivers,
sincronização, rede e APIs internas não são intercambiáveis.

### OpenBSD

- Prefere interfaces menores e comportamento previsível.
- Aplica mudanças de segurança de forma abrangente ao sistema base.
- Costuma privilegiar clareza e auditabilidade sobre a adição de subsistemas
  muito amplos.
- Mantém kernel e userland sincronizados por release e por `\-current`.

### FreeBSD

- Possui infraestrutura ampla para módulos carregáveis.
- Dá atenção explícita a SMP, escalabilidade e cargas de servidor.
- Integra subsistemas extensos como GEOM, OpenZFS, VNET, jails, DTrace e bhyve.
- Mantém branches `CURRENT`, `STABLE` e releases de produção.

Para o Parcel Play OS, copiar estruturas internas de um kernel para o outro não
é uma estratégia inicial segura. A comparação deve ocorrer por mecanismo e
propriedade desejada, seguida de porte isolado ou reimplementação compatível.

## 6\. Segurança

### 6.1 OpenBSD: segurança preventiva no sistema base

Tecnologias associadas ao OpenBSD incluem:

- `pledge(2)`: limita classes de operações que um processo pode realizar.
- `unveil(2)`: restringe a visão do processo sobre o sistema de arquivos.
- W^X: evita que memória seja simultaneamente gravável e executável.
- randomização e endurecimento do toolchain e do runtime.
- separação de privilégios em daemons do sistema.
- criptografia integrada e componentes como LibreSSL, OpenSSH, OpenIKED e 
  `signify`.

O valor principal não está em uma única função, mas na aplicação sistemática
dessas técnicas ao userland base.

Fontes oficiais:

- [Inovações do OpenBSD](https://www.openbsd.org/innovations.html)
- [Segurança do OpenBSD](https://www.openbsd.org/security.html)

### 6.2 FreeBSD: múltiplos mecanismos e isolamento operacional

O FreeBSD oferece:

- Capsicum para capability mode e limitação de descritores.
- Mandatory Access Control Framework.
- auditoria de eventos.
- `securelevel`.
- jails e limites de recursos.
- VNET para pilhas de rede separadas por jail.
- integração de jails com datasets ZFS.

O modelo é particularmente forte para consolidar serviços isolados em um mesmo
host. A configuração incorreta de uma jail ou a concessão excessiva de
dispositivos, mounts e recursos continua sendo risco operacional.

Fontes oficiais:

- 
  [Segurança no FreeBSD Handbook](https://docs.freebsd.org/en/books/handbook/security/)
- [Jails e containers](https://docs.freebsd.org/en/books/handbook/jails/)
- [Recursos do FreeBSD](https://www.freebsd.org/features/)

### 6.3 Leitura para o Parcel Play OS

- OpenBSD é a referência mais direta para reduzir superfície de ataque e
  aplicar sandbox por processo.
- FreeBSD é a referência mais direta para isolamento de serviços e recursos no
  nível do sistema operacional.
- Não se deve descrever `pledge`, `unveil`, Capsicum ou jails como mecanismos
  equivalentes: eles atuam em níveis e modelos diferentes.

## 7\. Rede e firewall

O OpenBSD é a origem do PF e mantém forte integração entre PF, roteamento,
IPsec, OpenBGPD, rpki-client, OpenIKED e outros componentes de rede. É
especialmente atraente para firewalls, routers, VPNs e infraestrutura de
confiança.

O FreeBSD oferece PF, IPFW e IPFilter, além de uma pilha de rede voltada a
desempenho e escalabilidade. VNET permite uma pilha de rede por jail. O PF do
FreeBSD não deve ser tratado como idêntico ao PF atual do OpenBSD: as árvores
divergiram e possuem diferenças de sintaxe, recursos e implementação.

Hipótese inicial para pesquisa:

- estudar no OpenBSD desenho seguro de serviços de rede e defaults;
- estudar no FreeBSD escalabilidade, VNET, filas e isolamento de workloads;
- evitar portar uma pilha TCP/IP inteira para o NitroCore sem benchmark, threat
  model e manutenção definida.

## 8\. Armazenamento

### OpenBSD

O OpenBSD favorece uma pilha menor, com FFS e softraid integrados ao sistema. A
prioridade é previsibilidade, coerência e manutenção controlada.

### FreeBSD

O FreeBSD oferece UFS2, GEOM e integração completa com OpenZFS, incluindo:

- root-on-ZFS;
- snapshots e clones;
- checksums;
- compressão;
- criptografia nativa;
- boot environments;
- delegação de datasets a jails.

Para storage, snapshots e rollback do sistema, FreeBSD oferece uma referência
mais completa. Isso não significa que o código OpenZFS possa ser transferido
para um kernel Linux/Ubuntu como patches BSD; o Parcel Play OS deve usar a
implementação OpenZFS compatível com Linux se optar por ZFS.

Fonte oficial: 
[OpenZFS no FreeBSD Handbook](https://docs.freebsd.org/en/books/handbook/zfs/).

## 9\. Virtualização e isolamento

### OpenBSD

O OpenBSD fornece `vmm(4)` e `vmd(8)`. O desenho privilegia integração simples e
redução de superfície. O conjunto de hóspedes e recursos é mais limitado que
soluções de virtualização de propósito amplo.

Fonte oficial: 
[FAQ de virtualização do OpenBSD](https://www.openbsd.org/faq/faq16.html).

### FreeBSD

O FreeBSD fornece:

- jails para virtualização no nível do sistema operacional;
- VNET para rede isolada;
- bhyve para máquinas virtuais completas;
- possibilidade de executar bhyve dentro de jail com permissões controladas;
- Linuxulator para executar diversos binários Linux sem VM.

Fonte oficial: 
[Virtualização no FreeBSD Handbook](https://docs.freebsd.org/en/books/handbook/virtualization/)
.

Para a mídia multi-OS do Parcel Play OS, KVM/QEMU no host Ubuntu continua sendo
a rota mais direta. `vmm` e bhyve são referências, não substitutos executáveis
sobre o kernel Linux.

## 10\. Hardware e portabilidade

Em agosto de 2026, o OpenBSD declara suporte oficial a treze plataformas,
incluindo amd64, arm64, armv7, i386, powerpc64, riscv64, sparc64 e arquiteturas
históricas menos comuns. “Plataforma suportada” não significa que todo
dispositivo daquela arquitetura possui driver.

O FreeBSD 15.x classifica amd64 e aarch64 como Tier 1; armv7, powerpc64,
powerpc64le e riscv64 aparecem como Tier 2. O sistema mantém foco forte nas
arquiteturas mais usadas em servidores e appliances.

Fontes oficiais:

- [Plataformas OpenBSD](https://www.openbsd.org/plat.html)
- [Plataformas FreeBSD](https://www.freebsd.org/platforms/)

Conclusão inicial:

- OpenBSD fornece uma referência valiosa de portabilidade arquitetural e código
  conservador.
- FreeBSD fornece uma referência forte para hardware contemporâneo de servidor,
  storage e virtualização.
- A compatibilidade real do Parcel Play OS precisa ser medida por dispositivo:
  GPU, Wi-Fi, áudio, NVMe, suspend/resume e firmware.

## 11\. Aplicações e pacotes

O OpenBSD utiliza pacotes binários e Ports. O próprio projeto recomenda pacotes
binários para usuários e esclarece que a coleção de ports não recebe o mesmo
nível de auditoria do sistema base.

O FreeBSD utiliza `pkg` e uma Ports Collection maior, com mais de 35 mil
aplicações declaradas pelo projeto. Também possui Linuxulator, o que amplia a
compatibilidade com alguns binários Linux.

Fontes oficiais:

- [Pacotes OpenBSD](https://www.openbsd.org/faq/faq15.html)
- [FreeBSD Ports](https://docs.freebsd.org/en/books/handbook/ports/)

Para desktop e catálogo amplo de software, FreeBSD tende a oferecer uma base
mais extensa. Para o Parcel Play OS, nenhum dos dois substitui diretamente o
userspace Ubuntu, APT, Flatpak ou os aplicativos Linux já escolhidos.

## 12\. Licenciamento e possibilidade de compartilhar código

Os dois projetos preferem licenças BSD/ISC permissivas, mas cada arquivo deve
ser verificado individualmente.

- OpenBSD busca código utilizável por qualquer pessoa e para qualquer
  finalidade, com preferência por ISC/Berkeley.
- FreeBSD prefere BSD-2-Clause para novos arquivos e isola componentes com
  licenças diferentes.
- A licença da compilação do sistema não substitui licenças específicas
  existentes em arquivos individuais.
- Incorporar código BSD em um projeto GPL pode ser possível em determinadas
  condições, mas avisos e atribuições devem ser preservados.
- Incorporar código GPL no sistema base OpenBSD contraria sua política para
  novo código.

Fontes oficiais:

- [Política de copyright do OpenBSD](https://www.openbsd.org/policy.html)
- 
  [Política de licenças do FreeBSD](https://docs.freebsd.org/en/articles/license-guide/)

## 13\. Qual sistema estudar para cada objetivo


|Objetivo do Parcel Play OS               |Referência inicial|Motivo                                                    |
|-----------------------------------------|------------------|----------------------------------------------------------|
|Sandbox por processo                     |OpenBSD           |`pledge` e `unveil`, além de aplicação ampla no base      |
|Redução de superfície e defaults seguros |OpenBSD           |prioridade explícita do projeto                           |
|Firewall e serviços de roteamento seguros|OpenBSD           |PF e ecossistema de rede integrado                        |
|Jails e isolamento de serviços           |FreeBSD           |subsistema maduro e integrado com VNET/ZFS                |
|Storage e rollback                       |FreeBSD           |OpenZFS, GEOM e boot environments                         |
|Virtualização de servidor                |FreeBSD           |bhyve e integração operacional                            |
|Escalabilidade de rede                   |FreeBSD           |foco de projeto em servidores e appliances                |
|Portabilidade entre arquiteturas         |Ambos             |estratégias e conjuntos de hardware diferentes            |
|Código simples para auditoria            |OpenBSD           |prioridade por clareza, correção e redução de complexidade|
|Compatibilidade com aplicações Linux     |FreeBSD           |Linuxulator, embora sem equivalência total ao Linux       |

## 14\. Impacto inicial na arquitetura Parcel

1.  Manter OpenBSD e FreeBSD como sistemas convidados separados na mídia
    multi-OS.
2.  Não tentar iniciar o rootfs Ubuntu com kernels BSD.
3.  Não fundir binários, módulos ou estruturas internas dos dois kernels.
4.  Comparar componentes isolados por propriedade mensurável.
5.  Preservar Ubuntu/Linux como host do desktop e do ecossistema de aplicações
    no MVP.
6.  Usar máquinas virtuais separadas para os primeiros testes BSD.
7.  Tratar qualquer porte como projeto próprio, com licença, adaptador, testes
    e responsável por manutenção.

## 15\. Próxima etapa experimental proposta

Criar duas VMs equivalentes e executar a mesma matriz de testes:

1.  OpenBSD 7.9 amd64, instalação mínima oficial.
2.  FreeBSD 15.1-RELEASE amd64, instalação mínima oficial.
3.  Uma vCPU, 1 GiB de RAM e disco virtual do mesmo tamanho.
4.  Console serial para logs reproduzíveis.
5.  Medir tempo de boot, memória ociosa, tamanho instalado e tempo de
    atualização.
6.  Configurar um serviço HTTP mínimo e medir latência/throughput sob a mesma
    carga.
7.  Aplicar sandbox ao serviço: `pledge`/`unveil` no OpenBSD quando suportado
    pela aplicação e jail/Capsicum no FreeBSD conforme aplicável.
8.  Registrar falhas de drivers virtuais, consumo, complexidade de configuração
    e superfície exposta.

Esses valores são pontos iniciais, não critérios finais de superioridade. A
comparação precisa usar versões, configurações, commits, imagens e hashes
fixados.

## 16\. Conclusão inicial

OpenBSD e FreeBSD não são duas variantes intercambiáveis do mesmo kernel. O
OpenBSD é a referência mais forte para segurança preventiva, auditabilidade e
redução deliberada de complexidade. O FreeBSD é a referência mais forte para
uma plataforma BSD ampla, com storage, jails, virtualização, rede escalável e
compatibilidade operacional.

Para o Parcel Play OS, a abordagem tecnicamente segura é estudar mecanismos
específicos e manter os dois sistemas independentes. Uma decisão de portar
código somente deve ocorrer depois de um experimento que demonstre benefício
mensurável e identifique custo de manutenção, compatibilidade e licença.

