# Contributing to ProjectWizard 🧙‍♂️

Primeiramente, obrigado por demonstrar interesse em contribuir com o **ProjectWizard**! É a colaboração da comunidade que impulsiona esta IDE Java a se tornar uma ferramenta cada vez mais poderosa.

Para manter a qualidade do código, a estabilidade da IDE e a segurança jurídica do projeto, estabelecemos algumas diretrizes que todos os colaboradores devem seguir.

---

## ⚖️ Conformidade Legal Importante (Developer Certificate of Origin)

O ProjectWizard utiliza um regime de co-licenciamento triplo obrigatório (**EPL-2.0 AND MPL-2.0 AND AGPL-3.0-only**). 

Ao submeter qualquer código, documentação ou modificação para este projeto, você afirma categoricamente que:
1. Você possui os direitos autorais do código enviado ou tem permissão legal do detentor dos direitos para submetê-lo sob estas três licenças.
2. Você concorda em licenciar sua contribuição permanentemente sob os termos conjuntos da **EPL-2.0, MPL-2.0 e AGPL-3.0-only**.

### ⚠️ Regra de Commits (DCO - Sign-off)
Para garantir a procedência legal do código, exigimos que todos os commits enviados via Pull Request possuam a assinatura eletrônica do desenvolvedor (`Signed-off-by`).

Para fazer isso automaticamente, adicione a flag `-s` ao realizar seus commits no Git:
```bash
git commit -s -m "Adiciona suporte ao autocomplete de classes Java"
```
*Isso adicionará a seguinte linha ao final da sua mensagem de commit:*
`Signed-off-by: Seu Nome Completo <seu-email@provedor.com>`

---

## ☕ Padrões de Código Java

Para manter o código limpo, legível e auditável, siga estritamente estas regras:

1. **Cabeçalho de Licença Obrigatório:** Todo arquivo `.java` novo **deve** conter o cabeçalho SPDX padrão nas primeiras linhas. Pull Requests com arquivos sem cabeçalho serão rejeitados automaticamente.
2. **Convenção de Nomes:** Siga os padrões oficiais da Oracle (Classes em `PascalCase`, métodos e variáveis em `camelCase`, constantes em `UPPER_SNAKE_CASE`).
3. **Versão do Java:** O projeto utiliza o **Java [Insira a Versão, ex: 17 ou 21] LTS**. Não utilize recursos de pré-visualização (preview features) ou versões não suportadas.
4. **Testes Unitários:** Novas funcionalidades devem vir acompanhadas de testes unitários utilizando **JUnit 5** e, se necessário, **Mockito**. Mantemos uma cobertura mínima recomendada de 80% do código modificado.

---

## 🚀 Processo de Pull Request (Passo a Passo)

1. **Abra uma Issue:** Antes de começar a codificar, verifique se já existe uma discussão ou issue aberta sobre o assunto. Se não houver, abra uma nova issue descrevendo o bug ou a funcionalidade que deseja implementar.
2. **Faça um Fork:** Faça o fork do repositório oficial do ProjectWizard para a sua conta pessoal.
3. **Crie uma Branch Temática:** Crie uma branch a partir da `main` utilizando um nome descritivo:
   ```bash
   git checkout -b feature/gerenciador-de-plugins
   # ou para correções de bugs
   git checkout -b fix/leak-de-memoria-no-editor
   ```
4. **Adicione o Cabeçalho SPDX:** Certifique-se de que os novos arquivos possuam o bloco no topo:
   ```java
   /*
    * Copyright (C) 2026 Marcel Aparecido de Andrade e Colaboradores do ProjectWizard.
    * SPDX-License-Identifier: EPL-2.0 AND MPL-2.0 AND AGPL-3.0-only
    */
   ```
5. **Execute a Validação Local:** Certifique-se de que o projeto compila perfeitamente e que todos os testes existentes passam localmente antes de enviar:
   ```bash
   # Se usar Maven:
   mvn clean test
   # Se usar Gradle:
   ./gradlew test
   ```
6. **Envie o Commit Assinado:** Faça o commit com a flag `-s` e envie para o seu fork.
7. **Abra o Pull Request (PR):** Forneça uma descrição detalhada das alterações no formulário do PR, referenciando o número da Issue correspondente (ex: `Closes #42`).

---

## 🐛 Reportando Bugs ou Sugerindo Funcionalidades

Se você encontrou um comportamento inesperado ou tem uma grande ideia para o ProjectWizard:
* Certifique-se de que o bug não é causado por um plugin de terceiros.
* Use a aba de **Issues** do repositório.
* Utilize o modelo padrão de relatórios fornecendo:
  * O comportamento esperado vs. o comportamento atual.
  * Passos exatos para reproduzir o problema.
  * Detalhes do seu ambiente (Versão do Sistema Operacional, Versão do JDK utilizado).

---

Agradecemos imensamente o seu tempo e dedicação para tornar o **ProjectWizard** a melhor IDE Java do mercado!

Atenciosamente,  
**Marcel Aparecido de Andrade**  
*Criador e Mantenedor Principal do ProjectWizard*

