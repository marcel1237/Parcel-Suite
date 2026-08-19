# Política de evidência

## Hierarquia

1. Código-fonte identificado por versão/commit e linhas.
2. Resultado reproduzível de build ou teste.
3. Documentação primária do projeto upstream.
4. Documento de análise local que cita uma das fontes anteriores.
5. Inferência explicitamente rotulada.
6. Proposta sem validação.

Uma fonte de nível inferior não deve ser apresentada como confirmação de nível
superior.

## Confiança

- `high`: fonte primária ou execução reproduzível;
- `medium`: análise consistente apoiada em múltiplas evidências;
- `low`: hipótese ou fonte incompleta;
- `unknown`: ainda não pesquisado.

## Resposta obrigatória

Uma resposta técnica deve incluir IDs das fontes e declarar limitações. Quando
versão, estado ou resultado não estiver registrado, deve usar “não determinado”.

## Proibições

- inventar benchmark, compatibilidade ou estado de implementação;
- confundir Ubuntu Noble 6.8.4 com Resolute Linux 7.0;
- afirmar que FreeBSD e Linux compartilham ABI interna;
- recomendar cópia de ULE, Jails, VFS, mbufs, locks ou Newbus para Linux;
- atribuir propriedades internas de produtos Sony sem fonte verificável;
- chamar um patch de produção antes de boot, regressão e gate de hardware.

## Atualização

Toda entrada alterada deve atualizar `verified_at`, preservar a fonte e passar
pelo validador. Conteúdo superado deve ser arquivado ou marcado `superseded`,
nunca silenciosamente reescrito como se sempre tivesse sido verdadeiro.
