# [Nome da IDE] 🚀

Uma IDE moderna, poderosa e extensível projetada para desenvolvedores que valorizam a liberdade de software e a robustez técnica.

---

## ⚖️ Licenciamento Conjunto Obrigatório (Triple Co-Licensing)

Este projeto adota uma abordagem de licenciamento robusta e inovadora para garantir a máxima proteção do código-fonte, incentivar a colaboração industrial e impedir o fechamento do ecossistema em ambientes de nuvem.

Para utilizar, modificar ou distribuir este software (no todo ou em parte), você **DEVE cumprir os termos e obrigações de três licenças simultaneamente**:

1. **Eclipse Public License v2.0 (EPL-2.0)** - Garante a proteção dos arquivos centrais e facilita a criação de um ecossistema de plugins comerciais/proprietários em arquivos separados.
2. **Mozilla Public License v2.0 (MPL-2.0)** - Protege os arquivos de código-fonte originais, exigindo que qualquer modificação neles permaneça pública.
3. **GNU Affero General Public License v3.0 (AGPL-3.0-only)** - Atua como *Licença Secundária e Combinada*, garantindo o "copyleft de rede" (se a IDE for modificada e executada na nuvem como serviço/SaaS, o código modificado deve ser liberado).

### Identificadores SPDX
Nos termos da Seção 1.13 da EPL 2.0 e da Seção 3.3 da MPL 2.0, a conformidade é rastreada através das seguintes tags padrão de mercado:
```text
SPDX-License-Identifier: EPL-2.0 AND MPL-2.0 AND AGPL-3.0-only
```

---

## 🔍 O que isso significa na prática?

* **Modificações no Núcleo:** Se você alterar qualquer arquivo original desta IDE, essas alterações **devem** ser disponibilizadas publicamente sob os mesmos termos.
* **Uso na Nuvem / SaaS:** Se você hospedar esta IDE em um servidor para que terceiros a utilizem remotamente pelo navegador, você é legalmente obrigado a liberar o código-fonte completo dessa infraestrutura modificada.
* **Plugins e Extensões:** Graças à estrutura da EPL 2.0, você pode desenvolver plugins proprietários ou comerciais para esta IDE, desde que eles residam em arquivos de código independentes e separados do núcleo.

---

## 🛠️ Tecnologias Utilizadas

* **Núcleo:** [Ex: TypeScript / Java / Rust]
* **Interface:** [Ex: Electron / Web Components]
* **Mecanismo de Extensão:** [Ex: Baseado na arquitetura EPL]

---

## 🚀 Como Começar

### Pré-requisitos
Certifique-se de ter instalado em sua máquina:
* [Requisito 1, ex: Node.js v20+]
* [Requisito 2, ex: Git]

### Instalação e Execução
1. Clone o repositório:
   ```bash
   git clone https://github.com[seu-usuario]/[nome-da-ide].git
   ```
2. Acesse a pasta do projeto:
   ```bash
   cd [nome-da-ide]
   ```
3. Instale as dependências:
   ```bash
   [Comando de instalação, ex: npm install]
   ```
4. Inicie a aplicação em modo de desenvolvimento:
   ```bash
   [Comando de execução, ex: npm run dev]
   ```

---

## 🤝 Como Contribuir

Contribuições são muito bem-vindas! Ao contribuir para este projeto, você concorda que seu código será submetido sob o mesmo regime de co-licenciamento triplo obrigatório (**EPL-2.0 AND MPL-2.0 AND AGPL-3.0-only**).

1. Faça um **Fork** do projeto.
2. Crie uma **Branch** para sua modificação (`git checkout -b feature/NovaFeature`).
3. Certifique-se de que todos os novos arquivos de código contenham o cabeçalho padrão de licença.
4. Faça o **Commit** das alterações (`git commit -m 'Adiciona nova feature'`).
5. Envie para o seu repositório remoto (`git push origin feature/NovaFeature`).
6. Abra um **Pull Request**.

### Cabeçalho padrão para novos arquivos de código:
```text
Copyright (C) 2026 [Seu Nome ou Organização].
SPDX-License-Identifier: EPL-2.0 AND MPL-2.0 AND AGPL-3.0-only

Este código-fonte é sujeito aos termos conjuntos da Eclipse Public License v. 2.0, 
da Mozilla Public License v. 2.0, e da GNU Affero General Public License v. 3.0.
A conformidade com todas as três licenças é obrigatória para uso e distribuição.
```

---

## 📞 Contato / Suporte

* **Mantenedor:** [Seu Nome] - [@seu_usuario](https://twitter.com)
* **E-mail:** [seu-email@dominio.com]
* **Discussions:** [Link para aba de discussões do GitHub/Discord]

---

## 📄 TERMO INTEGRAL DE LICENÇA (LICENSE)

```text
===============================================================================
TERMO DE OUTORGA DE LICENÇA CONJUNTA E OBRIGATÓRIA (TRIPLE CO-LICENSING)
===============================================================================

Copyright (C) 2026 [Seu Nome ou Organização]. Todos os direitos reservados.

Este software e seu código-fonte são distribuídos de forma conjunta e obrigatória 
sob os termos de três licenças de software livre distintas. Para qualquer tipo de 
uso, cópia, modificação, fusão, publicação, distribuição ou sublicenciamento 
deste software, o usuário DEVE cumprir cumulativamente e simultaneamente todas as 
obrigações, restrições e termos contidos nas seguintes licenças:

1. ECLIPSE PUBLIC LICENSE - v 2.0 (EPL-2.0)
   Disponível em: https://eclipse.org

2. MOZILLA PUBLIC LICENSE - v 2.0 (MPL-2.0)
   Disponível em: https://mozilla.org

3. GNU AFFERO GENERAL PUBLIC LICENSE - v 3.0 (AGPL-3.0-only)
   Disponível em: https://gnu.org

-------------------------------------------------------------------------------
CLÁUSULA DE COMPATIBILIDADE E COMBINAÇÃO (ESTRUTURA JURÍDICA)
-------------------------------------------------------------------------------

Nos termos da Seção 1.13 ("Secondary License") da Eclipse Public License v 2.0 e 
da Seção 3.3 ("Larger Works") da Mozilla Public License v 2.0, os outorgantes originais 
deste software declaram formalmente a GNU Affero General Public License v 3.0 como 
"Licença Secundária" e aplicável. 

Isso garante que:
a) O código permanece sob a proteção de arquivos da EPL-2.0 e MPL-2.0.
b) Qualquer trabalho maior, derivado ou disponibilizado via rede/nuvem herda de 
   forma mandatória o copyleft de rede estabelecido pela AGPL-3.0-only.

A falha em cumprir os termos de qualquer uma das três licenças listadas acima 
resultará na revogação automática e imediata de todos os direitos concedidos por este 
termo, constituindo violação de direitos autorais (copyright).

-------------------------------------------------------------------------------
IDENTIFICADOR INTERNACIONAL SPDX
-------------------------------------------------------------------------------
Para fins de auditoria de código e conformidade automatizada, o identificador do 
projeto é definido estritamente como:

SPDX-License-Identifier: EPL-2.0 AND MPL-2.0 AND AGPL-3.0-only
===============================================================================
```

