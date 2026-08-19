# PlayOS: decisões e estado real

ID: `KB-PLAYOS-STATUS`

- tipo: `decision`
- confiança: `high`
- estado: `current`
- verificado em: `2026-08-19`
- fontes: `SRC-PLAYOS-ARCH`, `SRC-PLAYOS-UNIFIED`, `SRC-PROJECT-AUDIT`, `SRC-RESOLUTE-VERIFY`

## Direção vigente

PlayOS não deve ser um kernel que mistura diretamente FreeBSD e Linux. As
opções tecnicamente sustentáveis registradas são:

- produto/família com edições e kernels separados;
- host Linux para desktop/jogos e FreeBSD Core isolado em KVM;
- contratos userspace comuns com backends nativos;
- patchsets experimentais pequenos que traduzem ideias, sem transplantar ABI.

## Identidades que não podem ser confundidas

- `Kernels/ubuntu 26 resolute kernel` contém Noble Linux 6.8.4;
- Ubuntu Resolute oficial usa Linux 7.0 segundo a verificação do projeto;
- `Kernels/kernel linux-7.1.8` é vanilla 7.1.8;
- FreeBSD completo está fora da raiz gravável do projeto, em 15.1-p2.

## Estado das implementações

- patchset Noble: compilado em perfil Generic, sem boot;
- patchset Linux 7.1.8: compilado, sem boot;
- patchset Linux→FreeBSD: propostas e validação estática, não kernel FreeBSD
  funcionalmente modificado e testado;
- NitroCore: protótipos experimentais, não subsistema integrado de produção;
- FreeBSD compatibility: arquitetura/política, testes reais pendentes;
- Live CD: análise e plano, não mídia final validada.

## Regra para respostas

“Criado”, “proposto”, “compilado”, “inicializável” e “pronto para produção” são
estados distintos. A IA deve usar exatamente o estado registrado e citar a
evidência correspondente.
