# Glossário BSD/Linux/PlayOS

ID: `KB-BSD-GLOSSARY`

- tipo: `fact`
- confiança: `high`
- estado: `current`
- verificado em: `2026-08-19`
- fontes: `SRC-FBSD-INVENTORY`, `SRC-FBSD-PORTABILITY`, `SRC-PLAYOS-ARCH`

## Termos BSD

- **Jail**: ambiente isolado FreeBSD associado a uma `struct prison`.
- **prison0**: prison raiz que descreve o ambiente real/host.
- **VNET**: virtualização da pilha de rede usada por Jails e outros contextos.
- **Capsicum**: modelo de segurança por capabilities e direitos sobre descritores.
- **RACCT**: accounting de consumo de recursos.
- **RCTL**: regras e ações aplicadas sobre recursos contabilizados.
- **MAC Framework**: infraestrutura para políticas de controle de acesso.
- **ULE**: scheduler FreeBSD voltado a SMP e interatividade.
- **UMA**: alocador de objetos do kernel FreeBSD.
- **Newbus**: framework FreeBSD de dispositivos e barramentos.
- **KOBJ**: sistema de objetos/métodos usado por componentes como Newbus.
- **mbuf**: estrutura central de buffers da rede BSD.
- **vnode**: objeto VFS que representa arquivos e outros nós.
- **GEOM**: framework modular de transformação e composição de armazenamento.
- **CAM**: camada de acesso a dispositivos de armazenamento/SCSI.
- **bhyve**: hypervisor e VMM nativo FreeBSD.
- **Linuxulator**: camada de compatibilidade de ABI Linux sobre kernel FreeBSD.
- **epoch/SMR**: mecanismos de leitura concorrente e recuperação segura.
- **Witness**: diagnóstico de ordem e uso de locks.

## Termos Linux relacionados

- **namespace**: isolamento de uma visão de recurso do kernel Linux.
- **cgroup v2**: hierarquia unificada de organização e controle de recursos.
- **seccomp**: filtro de syscalls, normalmente por BPF.
- **LSM**: framework de módulos de segurança Linux.
- **Landlock**: LSM empilhável para restrições impostas por aplicações.
- **RCU/SRCU**: famílias de sincronização para leitura concorrente.
- **SLUB**: alocador comum de objetos do kernel Linux.
- **sk_buff**: estrutura central de pacotes da rede Linux.
- **inode/dentry**: objetos centrais do VFS Linux.
- **KVM**: virtualização baseada no kernel Linux.
- **LinuxKPI**: subconjunto de APIs Linux implementado no FreeBSD para casos
  específicos; não é conversor universal.

## Termos do projeto

- **PlayOS**: produto em desenvolvimento; não implica um kernel híbrido.
- **NitroCore**: conjunto experimental de protótipos e conceitos Linux.
- **FreeBSD Core**: proposta de FreeBSD isolado e integrado ao produto por API.
- **patchset**: série revisável de alterações; não equivale a release.
- **build**: compilação e artefatos; não comprova boot.
- **boot validado**: kernel iniciado com evidência e testes básicos.
- **produção**: exige gates de segurança, regressão, empacotamento e hardware.
