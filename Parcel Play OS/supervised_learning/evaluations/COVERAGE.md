# Cobertura da base supervisionada

Data: 19 de agosto de 2026

## Cobertura alta

- identidade e inventário FreeBSD 15.1-p2;
- arquitetura e limites de `sys/kern`;
- mapeamento conceitual FreeBSD–Linux;
- Jails, Capsicum, RCTL, MAC e equivalentes compostos Linux;
- estado dos builds Noble 6.8.4 e Linux 7.1.8;
- distinção entre Noble local e Resolute oficial;
- política de não portar subsistemas acoplados.

## Cobertura média

- rede, armazenamento, OpenZFS, bhyve e Linuxulator por inventário;
- arquitetura Live CD/instalador;
- estratégia de compatibilidade em camadas;
- OpenBSD versus FreeBSD por documentação local.

## Cobertura baixa

- NetBSD;
- código e versões atuais de OpenBSD;
- drivers/hardware específicos;
- benchmarks FreeBSD inicializado;
- GPU, áudio, energia e jogos;
- instalador e mídia executados;
- patchset Linux→FreeBSD funcional.

## Distribuição QA inicial

- treino: 20 exemplos;
- validação: 8 exemplos;
- adversarial: 8 exemplos;
- avaliação: 8 exemplos;
- total: 44 exemplos.

O dataset é um baseline de governança e recuperação, não volume suficiente para
treinar um modelo de linguagem do zero. Seu uso imediato é RAG, testes de agente,
fine-tuning leve futuro e prevenção de respostas incompatíveis com o projeto.

## Próximos gates

1. Adicionar árvores/fontes primárias OpenBSD e NetBSD.
2. Criar entradas por arquivo crítico do FreeBSD com linhas e símbolos.
3. Executar FreeBSD em VM e registrar resultados estruturados.
4. Gerar benchmarks comparativos repetíveis.
5. Expandir QA para pelo menos 250 exemplos, preservando splits sem duplicação.
6. Adicionar avaliação semântica de respostas, além da validação estrutural.
