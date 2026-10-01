# Diretriz do Agente de IA — Angel OS

Bem-vindo ao repositório do **Angel OS** (*"The Linux unix-like"*).

## Visão Geral do Projeto

O **Angel OS** é um sistema operacional em desenvolvimento projetado para combinar a fidelidade e padronização Unix (inspirada nas tradições BSD e Slackware) com a compatibilidade, desempenho e ecossistema moderno do Kernel Linux.

## Estrutura de Núcleos (Kernels)

1. **Seraphin (Angel Linux Kernel)**:
   - Kernel Linux principal de alta compatibilidade e performance (baseado em Ubuntu / Debian / RHEL / Slackware-like).
   - Foco em padronização Unix-like, estabilidade e suporte a hardware moderno.
2. **Querubin (Linux Mini-Kernel)**:
   - Mini-kernel ultraleve para tarefas embarcadas, inicialização rápida, telas de login imediatas (estilo Dark Volt) e recuperação.

## Diretrizes de Desenvolvimento e Modificação

- **Preservação de Fontes e Cuidado de Edição**: Não edite arquivos via comandos shell destrutivos (`sed -i`, `echo >`). Use as ferramentas do ambiente.
- **Rigor em Mudanças**: Todas as modificações de arquitetura e scripts de build devem ser documentadas em `docs/` e registradas no progresso do sistema.
- **Identidade Visual**: Manter a temática angelical ("Angel OS / Seraphin / Querubin") na identidade de boot, GRUB, temas Plymouth e terminal.
- **Regra de Auto-Documentação (`AI_AUTO_DOCUMENTATION_RULE.md`)**: Sempre que uma resposta relevante for fornecida ao usuário, persistir o conteúdo correspondente em um arquivo `.md` na pasta `docs/` e indexá-lo em `docs/README.md`.
